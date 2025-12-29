#ifndef FIREBASECLIENT_H
#define FIREBASECLIENT_H

#include <string>
#include <vector>
#include <memory>
#include "Chatbot.h"

// Firebase REST API Client
class FirebaseClient {
private:
    std::string firebaseUrl;
    std::string apiKey;
    std::string authToken;
    
    // Helper functions for HTTP requests
    std::string httpGet(const std::string& url) const;
    std::string httpPost(const std::string& url, const std::string& data) const;
    std::string httpPut(const std::string& url, const std::string& data) const;
    std::string httpDelete(const std::string& url) const;
    std::string buildUrl(const std::string& path) const;
    
public:
    FirebaseClient(const std::string& url, const std::string& key);
    ~FirebaseClient();
    
    // Authentication
    bool authenticate(const std::string& email, const std::string& password);
    void setAuthToken(const std::string& token);
    
    // Database operations
    bool saveMessage(const Message& message, const std::string& userId);
    std::vector<Message> getMessages(const std::string& userId, int limit = 50);
    bool saveUserResponse(const std::string& keyword, const std::string& response, const std::string& userId);
    std::vector<std::pair<std::string, std::string>> getUserResponses(const std::string& userId);
    bool clearUserHistory(const std::string& userId);
    
    // User management
    bool createUser(const std::string& userId, const std::string& email);
    bool userExists(const std::string& userId);
};

#endif // FIREBASECLIENT_H

