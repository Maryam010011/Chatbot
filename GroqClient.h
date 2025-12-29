#ifndef GROQ_CLIENT_H
#define GROQ_CLIENT_H

#include <string>
#include <vector>
#include <curl/curl.h>
#include <iostream>
#include <sstream>
#include <iomanip>
#include "json.hpp"

using json = nlohmann::json;

class GroqClient {
private:
    std::string apiKey;
    std::string model;
    std::string baseUrl;
    std::vector<std::pair<std::string, std::string>> conversationHistory; // role, content pairs
    
    static size_t WriteCallback(void* contents, size_t size, size_t nmemb, void* userp) {
        ((std::string*)userp)->append((char*)contents, size * nmemb);
        return size * nmemb;
    }
    
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
                        escaped << "\\u" << std::hex << std::setfill('0') << std::setw(4) << (int)c;
                    } else {
                        escaped << c;
                    }
            }
        }
        return escaped.str();
    }

public:
    GroqClient(const std::string& key, const std::string& modelName = "llama-3.3-70b-versatile") 
        : apiKey(key), model(modelName), baseUrl("https://api.groq.com/openai/v1/chat/completions") {
        // Add system prompt to set chatbot personality
        conversationHistory.push_back({
            "system", 
            "You are a helpful, friendly AI assistant. Keep your responses concise and helpful. "
            "You can help with general questions, coding, explanations, and casual conversation."
        });
    }
    
    void clearHistory() {
        // Keep system prompt, clear user/assistant messages
        if (!conversationHistory.empty()) {
            auto systemPrompt = conversationHistory[0];
            conversationHistory.clear();
            conversationHistory.push_back(systemPrompt);
        }
    }
    
    std::string sendMessage(const std::string& userMessage) {
        CURL* curl;
        CURLcode res;
        std::string readBuffer;
        
        // Add user message to history
        conversationHistory.push_back({"user", userMessage});
        
        curl = curl_easy_init();
        if (curl) {
            // Build messages array JSON
            std::ostringstream messagesJson;
            messagesJson << "[";
            
            // Only include last 10 messages to avoid token limits
            size_t startIdx = 0;
            if (conversationHistory.size() > 11) {
                startIdx = conversationHistory.size() - 11;
                // Always include system prompt (index 0)
                messagesJson << "{\"role\":\"" << conversationHistory[0].first 
                             << "\",\"content\":\"" << escapeJsonString(conversationHistory[0].second) << "\"},";
                startIdx = std::max(startIdx, (size_t)1);
            }
            
            for (size_t i = (startIdx == 0 ? 0 : startIdx); i < conversationHistory.size(); i++) {
                if (i > (startIdx == 0 ? 0 : startIdx)) messagesJson << ",";
                messagesJson << "{\"role\":\"" << conversationHistory[i].first 
                             << "\",\"content\":\"" << escapeJsonString(conversationHistory[i].second) << "\"}";
            }
            messagesJson << "]";
            
            // Build request body
            std::ostringstream requestBody;
            requestBody << "{"
                       << "\"model\":\"" << model << "\","
                       << "\"messages\":" << messagesJson.str()
                       << "}";
            
            std::string bodyStr = requestBody.str();
            
            // Set up headers
            struct curl_slist* headers = nullptr;
            headers = curl_slist_append(headers, "Content-Type: application/json");
            std::string authHeader = "Authorization: Bearer " + apiKey;
            headers = curl_slist_append(headers, authHeader.c_str());
            
            curl_easy_setopt(curl, CURLOPT_URL, baseUrl.c_str());
            curl_easy_setopt(curl, CURLOPT_HTTPHEADER, headers);
            curl_easy_setopt(curl, CURLOPT_POSTFIELDS, bodyStr.c_str());
            curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, WriteCallback);
            curl_easy_setopt(curl, CURLOPT_WRITEDATA, &readBuffer);
            curl_easy_setopt(curl, CURLOPT_SSL_VERIFYPEER, 0L);
            curl_easy_setopt(curl, CURLOPT_TIMEOUT, 30L);
            
            // Debug logging
            std::cerr << "[Groq] Sending request to: " << baseUrl << std::endl;
            std::cerr << "[Groq] Model: " << model << std::endl;
            
            res = curl_easy_perform(curl);
            
            curl_slist_free_all(headers);
            curl_easy_cleanup(curl);
            
            if (res != CURLE_OK) {
                std::cerr << "[Groq] CURL error: " << curl_easy_strerror(res) << std::endl;
                // Remove the user message we added since request failed
                conversationHistory.pop_back();
                return "";
            }
            
            // Debug: log raw response
            std::cerr << "[Groq] Response: " << readBuffer << std::endl;
            
            // Parse JSON response
            try {
                json responseJson = json::parse(readBuffer);
                
                // Check for error
                if (responseJson.contains("error")) {
                    std::string errorMsg = responseJson["error"]["message"].get<std::string>();
                    std::cerr << "[Groq] API Error: " << errorMsg << std::endl;
                    conversationHistory.pop_back();
                    return "";
                }
                
                // Extract assistant response
                if (responseJson.contains("choices") && !responseJson["choices"].empty()) {
                    std::string assistantResponse = responseJson["choices"][0]["message"]["content"].get<std::string>();
                    
                    // Add assistant response to history
                    conversationHistory.push_back({"assistant", assistantResponse});
                    
                    return assistantResponse;
                }
            } catch (const std::exception& e) {
                std::cerr << "[Groq] JSON parse error: " << e.what() << std::endl;
                conversationHistory.pop_back();
                return "";
            }
        }
        
        conversationHistory.pop_back();
        return "";
    }
    
    bool isAvailable() const {
        return !apiKey.empty();
    }
};

#endif // GROQ_CLIENT_H
