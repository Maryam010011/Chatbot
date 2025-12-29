#include "FirebaseClient.h"
#include <iostream>
#include <sstream>
#include <curl/curl.h>
#include <cstring>
#include <ctime>
#include <vector>
#include <iomanip>
#include "json.hpp"

using json = nlohmann::json;

// Helper function to escape JSON strings
std::string escapeJsonString(const std::string& str) {
    std::ostringstream escaped;
    for (char c : str) {
        switch (c) {
            case '"': escaped << "\\\""; break;
            case '\\': escaped << "\\\\"; break;
            case '\b': escaped << "\\b"; break;
            case '\f': escaped << "\\f"; break;
            case '\n': escaped << "\\n"; break;
            case '\r': escaped << "\\r"; break;
            case '\t': escaped << "\\t"; break;
            default:
                if ('\x00' <= c && c <= '\x1f') {
                    // Control characters - escape as unicode
                    escaped << "\\u" << std::hex << std::setfill('0') << std::setw(4) << (int)c;
                } else {
                    escaped << c;
                }
        }
    }
    return escaped.str();
}

// CURL write callback for response data
static size_t WriteCallback(void* contents, size_t size, size_t nmemb, std::string* data) {
    size_t totalSize = size * nmemb;
    data->append((char*)contents, totalSize);
    return totalSize;
}

FirebaseClient::FirebaseClient(const std::string& url, const std::string& key) 
    : firebaseUrl(url), apiKey(key), authToken("") {
    curl_global_init(CURL_GLOBAL_DEFAULT);
}

FirebaseClient::~FirebaseClient() {
    curl_global_cleanup();
}

std::string FirebaseClient::buildUrl(const std::string& path) const {
    std::ostringstream url;
    url << firebaseUrl << path; // path should already include ".json"
    if (!authToken.empty()) {
        url << (path.find('?') != std::string::npos ? "&" : "?") << "auth=" << authToken;
    }
    return url.str();
}

std::string FirebaseClient::httpGet(const std::string& url) const {
    CURL* curl = curl_easy_init();
    std::string response;
    
    if (curl) {
        curl_easy_setopt(curl, CURLOPT_URL, url.c_str());
        curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, WriteCallback);
        curl_easy_setopt(curl, CURLOPT_WRITEDATA, &response);
        curl_easy_setopt(curl, CURLOPT_SSL_VERIFYPEER, 0L);
        
        CURLcode res = curl_easy_perform(curl);
        if (res != CURLE_OK) {
            std::cerr << "curl_easy_perform() failed: " << curl_easy_strerror(res) << std::endl;
        }
        
        curl_easy_cleanup(curl);
    }
    
    return response;
}

std::string FirebaseClient::httpPost(const std::string& url, const std::string& data) const {
    CURL* curl = curl_easy_init();
    std::string response;
    
    if (curl) {
        struct curl_slist* headers = nullptr;
        headers = curl_slist_append(headers, "Content-Type: application/json");
        
        curl_easy_setopt(curl, CURLOPT_URL, url.c_str());
        curl_easy_setopt(curl, CURLOPT_POSTFIELDS, data.c_str());
        curl_easy_setopt(curl, CURLOPT_HTTPHEADER, headers);
        curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, WriteCallback);
        curl_easy_setopt(curl, CURLOPT_WRITEDATA, &response);
        curl_easy_setopt(curl, CURLOPT_SSL_VERIFYPEER, 0L);
        
        CURLcode res = curl_easy_perform(curl);
        if (res != CURLE_OK) {
            std::cerr << "curl_easy_perform() failed: " << curl_easy_strerror(res) << std::endl;
        }
        
        curl_slist_free_all(headers);
        curl_easy_cleanup(curl);
    }
    
    return response;
}

std::string FirebaseClient::httpPut(const std::string& url, const std::string& data) const {
    CURL* curl = curl_easy_init();
    std::string response;
    
    if (curl) {
        struct curl_slist* headers = nullptr;
        headers = curl_slist_append(headers, "Content-Type: application/json");
        
        curl_easy_setopt(curl, CURLOPT_URL, url.c_str());
        curl_easy_setopt(curl, CURLOPT_CUSTOMREQUEST, "PUT");
        curl_easy_setopt(curl, CURLOPT_POSTFIELDS, data.c_str());
        curl_easy_setopt(curl, CURLOPT_HTTPHEADER, headers);
        curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, WriteCallback);
        curl_easy_setopt(curl, CURLOPT_WRITEDATA, &response);
        curl_easy_setopt(curl, CURLOPT_SSL_VERIFYPEER, 0L);
        
        CURLcode res = curl_easy_perform(curl);
        if (res != CURLE_OK) {
            std::cerr << "curl_easy_perform() failed: " << curl_easy_strerror(res) << std::endl;
        }
        
        curl_slist_free_all(headers);
        curl_easy_cleanup(curl);
    }
    
    return response;
}

std::string FirebaseClient::httpDelete(const std::string& url) const {
    CURL* curl = curl_easy_init();
    std::string response;
    
    if (curl) {
        curl_easy_setopt(curl, CURLOPT_URL, url.c_str());
        curl_easy_setopt(curl, CURLOPT_CUSTOMREQUEST, "DELETE");
        curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, WriteCallback);
        curl_easy_setopt(curl, CURLOPT_WRITEDATA, &response);
        curl_easy_setopt(curl, CURLOPT_SSL_VERIFYPEER, 0L);
        
        CURLcode res = curl_easy_perform(curl);
        if (res != CURLE_OK) {
            std::cerr << "curl_easy_perform() failed: " << curl_easy_strerror(res) << std::endl;
        }
        
        curl_easy_cleanup(curl);
    }
    
    return response;
}

bool FirebaseClient::authenticate(const std::string& email, const std::string& password) {
    std::ostringstream json;
    json << "{\"email\":\"" << email << "\",\"password\":\"" << password 
         << "\",\"returnSecureToken\":true}";
    
    std::string url = "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=" + apiKey;
    std::string response = httpPost(url, json.str());
    
    // Simple JSON parsing for token
    size_t tokenPos = response.find("\"idToken\":\"");
    if (tokenPos != std::string::npos) {
        tokenPos += 11; // move past "idToken":" 
        size_t tokenEnd = response.find("\"", tokenPos);
        if (tokenEnd != std::string::npos) {
            std::string parsedIdToken = response.substr(tokenPos, tokenEnd - tokenPos);
            authToken = parsedIdToken;  // assign the parsed token to authToken
            return true;
        }
    }

    return false;
}

void FirebaseClient::setAuthToken(const std::string& token) {
    authToken = token;
}

bool FirebaseClient::saveMessage(const Message& message, const std::string& userId) {
    // Create JSON payload with proper escaping
    std::ostringstream json;
    json << "{"
         << "\"content\":\"" << escapeJsonString(message.content) << "\","
         << "\"sender\":\"" << escapeJsonString(message.sender) << "\","
         << "\"timestamp\":\"" << escapeJsonString(message.timestamp) << "\""
         << "}";

    std::string path = "/users/" + userId + "/messages.json";
    // Note: auth token is added by buildUrl()

    std::string url = buildUrl(path);
    std::string response = httpPost(url, json.str());

    // Return true if no "error" field
    return !response.empty() && response.find("error") == std::string::npos;
}



std::vector<Message> FirebaseClient::getMessages(const std::string& userId, int limit) {
    std::vector<Message> messages;

    std::string path = "/users/" + userId + "/messages.json?orderBy=\"timestamp\"&limitToLast=" + std::to_string(limit);
    // Note: auth token is added by buildUrl()

    std::string url = buildUrl(path);
    std::string response = httpGet(url);

    // DEBUG: Log raw response
    std::cerr << "--- DEBUG: Firebase Raw Response ---\n" << response << "\n-----------------------------------\n" << std::endl;

    if (response.empty() || response == "null") return messages;

    try {
        json j = json::parse(response);
        if (j.is_object()) {
            // Firebase returns an object with push IDs as keys
            for (auto it = j.begin(); it != j.end(); ++it) {
                json msgObj = it.value();
                std::string content = msgObj.value("content", "");
                std::string sender = msgObj.value("sender", "");
                std::string timestamp = msgObj.value("timestamp", "");
                
                messages.push_back(Message(content, sender, timestamp));
            }
        } else if (j.is_array()) {
            // Sometimes Firebase returns an array if keys are numeric indices
            for (const auto& msgObj : j) {
                if (msgObj.is_null()) continue;
                std::string content = msgObj.value("content", "");
                std::string sender = msgObj.value("sender", "");
                std::string timestamp = msgObj.value("timestamp", "");
                
                messages.push_back(Message(content, sender, timestamp));
            }
        }
    } catch (const std::exception& e) {
        std::cerr << "JSON Parse error in getMessages: " << e.what() << std::endl;
    }

    return messages;
}

bool FirebaseClient::saveUserResponse(const std::string& keyword, const std::string& response, 
                                     const std::string& userId) {
    std::ostringstream json;
    json << "{\"response\":\"" << escapeJsonString(response) << "\"}";
    
    std::string path = "/users/" + userId + "/customResponses/" + keyword + ".json";
    // Note: auth token is added by buildUrl()
    
    std::string url = buildUrl(path);
    std::string result = httpPut(url, json.str());
    
    return !result.empty() && result.find("error") == std::string::npos;
}

std::vector<std::pair<std::string, std::string>> FirebaseClient::getUserResponses(const std::string& userId) {
    std::vector<std::pair<std::string, std::string>> responses;

    std::string path = "/users/" + userId + "/customResponses.json";
    // Note: auth token is added by buildUrl()

    std::string url = buildUrl(path);
    std::string result = httpGet(url);

    if (result.empty() || result == "null") return responses;

    try {
        json j = json::parse(result);
        if (j.is_object()) {
            for (auto it = j.begin(); it != j.end(); ++it) {
                std::string key = it.key();
                std::string val = it.value().value("response", "");
                responses.push_back({key, val});
            }
        }
    } catch (const std::exception& e) {
        std::cerr << "JSON Parse error in getUserResponses: " << e.what() << std::endl;
    }

    return responses;
}

bool FirebaseClient::clearUserHistory(const std::string& userId) {
    std::string path = "/users/" + userId + "/messages.json";
    // Note: auth token is added by buildUrl()
    
    std::string url = buildUrl(path);
    std::string result = httpDelete(url);
    
    return !result.empty() && result.find("error") == std::string::npos;
}

bool FirebaseClient::createUser(const std::string& userId, const std::string& email) {
    std::ostringstream json;
    json << "{\"email\":\"" << escapeJsonString(email) << "\",\"createdAt\":\"" 
         << std::to_string(time(nullptr)) << "\"}";
    
    std::string path = "/users/" + userId + ".json";
    // Note: auth token is added by buildUrl()
    
    std::string url = buildUrl(path);
    std::string result = httpPut(url, json.str());
    
    return !result.empty() && result.find("error") == std::string::npos;
}

bool FirebaseClient::userExists(const std::string& userId) {
    std::string path = "/users/" + userId + ".json";
    // Note: auth token is added by buildUrl()
    
    std::string url = buildUrl(path);
    std::string result = httpGet(url);
    
    return !result.empty() && result != "null" && result.find("error") == std::string::npos;
}

