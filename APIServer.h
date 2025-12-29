#ifndef APISERVER_H
#define APISERVER_H

#include "Chatbot.h"
#include "FirebaseClient.h"
#include <string>
#include <memory>
#include <functional>
#include <map>

// API Request structure
struct APIRequest {
    std::string method;
    std::string path;
    std::string body;
    std::map<std::string, std::string> headers;
    std::map<std::string, std::string> queryParams;
};

// API Response structure
struct APIResponse {
    int statusCode;
    std::string body;
    std::map<std::string, std::string> headers;
    
    APIResponse(int code = 200, const std::string& b = "") 
        : statusCode(code), body(b) {
        headers["Content-Type"] = "application/json";
    }
};

// REST API Server
class APIServer {
private:
    std::unique_ptr<Chatbot> chatbot;
    std::unique_ptr<FirebaseClient> firebaseClient;
    int port;
    bool running;
    
    // Route handlers
    APIResponse handleChat(const APIRequest& req);
    APIResponse handleHistory(const APIRequest& req);
    APIResponse handleClearHistory(const APIRequest& req);
    APIResponse handleAddResponse(const APIRequest& req);
    APIResponse handleStatistics(const APIRequest& req);
    APIResponse handleHealth(const APIRequest& req);
    
    // Helper functions
    std::string extractUserId(const APIRequest& req) const;
    std::string parseJsonField(const std::string& json, const std::string& field) const;
    APIResponse jsonResponse(int code, const std::string& message, const std::string& data = "") const;
    APIResponse errorResponse(int code, const std::string& message) const;
    
public:
    APIServer(int port, const std::string& firebaseUrl, const std::string& firebaseKey,
              const std::string& groqKey = "", const std::string& groqModel = "");
    ~APIServer();
    
    // Server control
    void start();
    void stop();
    bool isRunning() const;
    
    // Request processing
    APIResponse processRequest(const APIRequest& req);
    
    // Get chatbot instance (for direct access if needed)
    Chatbot* getChatbot() const;
};

#endif // APISERVER_H

