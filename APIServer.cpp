#define _WIN32_WINNT 0x0A00
#include "APIServer.h"
#include "FirebaseClient.h"
#include <iostream>
#include <sstream>
#include <algorithm>
#include <thread>
#include <chrono>
#include <ctime>
#include "httplib.h"
// Simple JSON helper functions
std::string escapeJson(const std::string& str) {
    std::ostringstream o;
    for (char c : str) {
        switch (c) {
            case '"': o << "\\\""; break;
            case '\\': o << "\\\\"; break;
            case '\b': o << "\\b"; break;
            case '\f': o << "\\f"; break;
            case '\n': o << "\\n"; break;
            case '\r': o << "\\r"; break;
            case '\t': o << "\\t"; break;
            default: o << c; break;
        }
    }
    return o.str();
}

std::string createJsonResponse(const std::string& message, const std::string& data = "") {
    std::ostringstream json;
    json << "{\"success\":true,\"message\":\"" << escapeJson(message) << "\"";
    if (!data.empty()) {
        json << ",\"data\":" << data;
    }
    json << "}";
    return json.str();
}

std::string createJsonError(const std::string& error) {
    std::ostringstream json;
    json << "{\"success\":false,\"error\":\"" << escapeJson(error) << "\"}";
    return json.str();
}

APIServer::APIServer(int port, const std::string& firebaseUrl, const std::string& firebaseKey,
                     const std::string& groqKey, const std::string& groqModel)
    : port(port), running(false) {
    chatbot = std::unique_ptr<Chatbot>(new Chatbot());
    firebaseClient = std::unique_ptr<FirebaseClient>(new FirebaseClient(firebaseUrl, firebaseKey));
    
    // Initialize AI if API key is provided
    if (!groqKey.empty()) {
        std::string model = groqModel.empty() ? "llama-3.3-70b-versatile" : groqModel;
        chatbot->initializeAI(groqKey, model);
    }
}

APIServer::~APIServer() = default;

std::string APIServer::extractUserId(const APIRequest& req) const {
    // Extract from headers or query params
    if (req.headers.find("X-User-Id") != req.headers.end()) {
        return req.headers.at("X-User-Id");
    }
    if (req.queryParams.find("userId") != req.queryParams.end()) {
        return req.queryParams.at("userId");
    }
    return "default";  // Default user if not provided
}

std::string APIServer::parseJsonField(const std::string& json, const std::string& field) const {
    std::string searchStr = "\"" + field + "\":\"";
    size_t pos = json.find(searchStr);
    if (pos != std::string::npos) {
        pos += searchStr.length();
        size_t end = json.find("\"", pos);
        if (end != std::string::npos) {
            return json.substr(pos, end - pos);
        }
    }
    return "";
}

APIResponse APIServer::jsonResponse(int code, const std::string& message, const std::string& data) const {
    APIResponse resp(code, createJsonResponse(message, data));
    return resp;
}

APIResponse APIServer::errorResponse(int code, const std::string& message) const {
    APIResponse resp(code, createJsonError(message));
    return resp;
}

APIResponse APIServer::handleChat(const APIRequest& req) {
    if (req.method != "POST") {
        return errorResponse(405, "Method not allowed. Use POST.");
    }
    
    std::string userId = extractUserId(req);
    std::string userInput = parseJsonField(req.body, "message");
    
    if (userInput.empty()) {
        return errorResponse(400, "Missing 'message' field in request body");
    }
    
    // Get bot response
    std::string botResponse = chatbot->respond(userInput);
    
    // Save to Firebase
    time_t now = time(0);
    char* dt = ctime(&now);
    std::string timestamp(dt);
    timestamp.pop_back();  // Remove newline
    
    Message userMsg(userInput, "user", timestamp);
    Message botMsg(botResponse, "bot", timestamp);
    
    firebaseClient->saveMessage(userMsg, userId);
    firebaseClient->saveMessage(botMsg, userId);
    
    // Create response JSON
    std::ostringstream json;
    json << "{\"response\":\"" << escapeJson(botResponse) << "\",\"userId\":\"" << userId << "\"}";
    
    return jsonResponse(200, "Chat response generated", json.str());
}

APIResponse APIServer::handleHistory(const APIRequest& req) {
    if (req.method != "GET") {
        return errorResponse(405, "Method not allowed. Use GET.");
    }
    
    std::string userId = extractUserId(req);
    int limit = 50;
    
    if (req.queryParams.find("limit") != req.queryParams.end()) {
        limit = std::stoi(req.queryParams.at("limit"));
    }
    
    std::vector<Message> messages = firebaseClient->getMessages(userId, limit);
    
    // Create JSON array
    std::ostringstream json;
    json << "[";
    for (size_t i = 0; i < messages.size(); i++) {
        if (i > 0) json << ",";
        json << "{\"content\":\"" << escapeJson(messages[i].content) 
             << "\",\"sender\":\"" << escapeJson(messages[i].sender)
             << "\",\"timestamp\":\"" << escapeJson(messages[i].timestamp) << "\"}";
    }
    json << "]";
    
    return jsonResponse(200, "History retrieved", json.str());
}

APIResponse APIServer::handleClearHistory(const APIRequest& req) {
    if (req.method != "DELETE") {
        return errorResponse(405, "Method not allowed. Use DELETE.");
    }
    
    std::string userId = extractUserId(req);
    
    if (firebaseClient->clearUserHistory(userId)) {
        chatbot->clearHistory();
        return jsonResponse(200, "History cleared successfully");
    }
    
    return errorResponse(500, "Failed to clear history");
}

APIResponse APIServer::handleAddResponse(const APIRequest& req) {
    if (req.method != "POST") {
        return errorResponse(405, "Method not allowed. Use POST.");
    }
    
    std::string userId = extractUserId(req);
    std::string keyword = parseJsonField(req.body, "keyword");
    std::string response = parseJsonField(req.body, "response");
    
    if (keyword.empty() || response.empty()) {
        return errorResponse(400, "Missing 'keyword' or 'response' field");
    }
    
    chatbot->addCustomResponse(keyword, response);
    
    if (firebaseClient->saveUserResponse(keyword, response, userId)) {
        return jsonResponse(200, "Custom response added successfully");
    }
    
    return errorResponse(500, "Failed to save custom response");
}

APIResponse APIServer::handleStatistics(const APIRequest& req) {
    if (req.method != "GET") {
        return errorResponse(405, "Method not allowed. Use GET.");
    }
    
    std::ostringstream json;
    json << "{\"messageCount\":" << chatbot->getMessageCount() << "}";
    
    return jsonResponse(200, "Statistics retrieved", json.str());
}

APIResponse APIServer::handleHealth(const APIRequest& req) {
    std::ostringstream json;
    json << "{\"status\":\"running\",\"port\":" << port << "}";
    return jsonResponse(200, "Server is healthy", json.str());
}

APIResponse APIServer::processRequest(const APIRequest& req) {
    // Route to appropriate handler
    if (req.path == "/api/chat" || req.path == "/api/chat/") {
        return handleChat(req);
    } else if (req.path == "/api/history" || req.path == "/api/history/") {
        return handleHistory(req);
    } else if (req.path == "/api/history/clear" || req.path == "/api/history/clear/") {
        return handleClearHistory(req);
    } else if (req.path == "/api/response" || req.path == "/api/response/") {
        return handleAddResponse(req);
    } else if (req.path == "/api/statistics" || req.path == "/api/statistics/") {
        return handleStatistics(req);
    } else if (req.path == "/api/health" || req.path == "/api/health/") {
        return handleHealth(req);
    } else {
        return errorResponse(404, "Endpoint not found");
    }
}


void APIServer::start() {
    httplib::Server svr;

    // POST /api/chat
    svr.Post("/api/chat", [&](const httplib::Request& req, httplib::Response& res) {
        std::cout << "📥 Incoming: [POST] /api/chat | Body: " << req.body << std::endl;
        APIRequest apiReq;
        apiReq.method = "POST";
        apiReq.path = "/api/chat";
        apiReq.body = req.body;

        for (auto& h : req.headers) {
            apiReq.headers[h.first] = h.second;
        }

        APIResponse apiResp = processRequest(apiReq);
        res.set_content(apiResp.body, "application/json");
        res.status = apiResp.statusCode;
    });


    // POST /api/response
    svr.Post("/api/response", [&](const httplib::Request& req, httplib::Response& res) {
        std::cout << "📥 Incoming: [POST] /api/response" << std::endl;
        APIRequest apiReq;
        apiReq.method = "POST";
        apiReq.path = "/api/response";
        apiReq.body = req.body;

        for (auto& h : req.headers) {
            apiReq.headers[h.first] = h.second;
        }

        APIResponse apiResp = processRequest(apiReq);
        res.set_content(apiResp.body, "application/json");
        res.status = apiResp.statusCode;
    });

    // GET /api/statistics
    svr.Get("/api/statistics", [&](const httplib::Request&, httplib::Response& res) {
        std::cout << "📥 Incoming: [GET] /api/statistics" << std::endl;
        APIRequest apiReq;
        apiReq.method = "GET";
        apiReq.path = "/api/statistics";

        APIResponse apiResp = processRequest(apiReq);
        res.set_content(apiResp.body, "application/json");
        res.status = apiResp.statusCode;
    });

    // GET /api/history
    svr.Get("/api/history", [&](const httplib::Request& req, httplib::Response& res) {
        std::cout << "📥 Incoming: [GET] /api/history" << std::endl;
        APIRequest apiReq;
        apiReq.method = "GET";
        apiReq.path = "/api/history";

        for (auto& q : req.params) {
            apiReq.queryParams[q.first] = q.second;
        }

        APIResponse apiResp = processRequest(apiReq);
        res.set_content(apiResp.body, "application/json");
        res.status = apiResp.statusCode;
    });


    // DELETE /api/history/clear
    svr.Delete("/api/history/clear", [&](const httplib::Request& req, httplib::Response& res) {
        std::cout << "📥 Incoming: [DELETE] /api/history/clear" << std::endl;
        APIRequest apiReq;
        apiReq.method = "DELETE";
        apiReq.path = "/api/history/clear";

        for (auto& h : req.headers) {
            apiReq.headers[h.first] = h.second;
        }

        APIResponse apiResp = processRequest(apiReq);
        res.set_content(apiResp.body, "application/json");
        res.status = apiResp.statusCode;
    });

    // GET /api/health
    svr.Get("/api/health", [&](const httplib::Request&, httplib::Response& res) {
        APIRequest apiReq;
        apiReq.method = "GET";
        apiReq.path = "/api/health";

        APIResponse apiResp = processRequest(apiReq);
        res.set_content(apiResp.body, "application/json");
        res.status = apiResp.statusCode;
    });

    // OPTIONS handler for CORS preflight requests
    svr.Options(R"(.*)", [](const httplib::Request&, httplib::Response& res) {
        res.status = 204; // No Content
    });

    // Set CORS headers for all responses
    svr.set_post_routing_handler([](const httplib::Request&, httplib::Response& res) {
        res.set_header("Access-Control-Allow-Origin", "*");
        res.set_header("Access-Control-Allow-Methods", "GET, POST, DELETE, OPTIONS");
        res.set_header("Access-Control-Allow-Headers", "Content-Type, X-User-Id");
    });

    std::cout << "✅ Server running on port " << port << std::endl;
    std::cout << "🌐 CORS enabled for web browser access" << std::endl;
    running = true;
    svr.listen("0.0.0.0", port);
}



void APIServer::stop() {
    running = false;
}

bool APIServer::isRunning() const {
    return running;
}

Chatbot* APIServer::getChatbot() const {
    return chatbot.get();
}

