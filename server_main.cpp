#include "APIServer.h"
#include <iostream>
#include <string>
#include <fstream>

// Configuration file reader
struct Config {
    std::string firebaseUrl;
    std::string firebaseKey;
    std::string groqApiKey;
    std::string groqModel;
    int port;
    
    Config() : port(8080), groqModel("llama-3.3-70b-versatile") {}
    
    bool loadFromFile(const std::string& filename) {
        std::ifstream file(filename);
        if (!file.is_open()) {
            return false;
        }
        
        std::string line;
        while (std::getline(file, line)) {
            // Skip comments and empty lines
            if (line.empty() || line[0] == '#') continue;
            
            size_t pos = line.find('=');
            if (pos != std::string::npos) {
                std::string key = line.substr(0, pos);
                std::string value = line.substr(pos + 1);
                
                // Trim whitespace
                while (!value.empty() && (value.back() == '\r' || value.back() == '\n')) {
                    value.pop_back();
                }
                
                if (key == "FIREBASE_URL") {
                    firebaseUrl = value;
                } else if (key == "FIREBASE_KEY") {
                    firebaseKey = value;
                } else if (key == "PORT") {
                    port = std::stoi(value);
                } else if (key == "Groq_API_Key") {
                    groqApiKey = value;
                } else if (key == "Groq_Model") {
                    groqModel = value;
                }
            }
        }
        
        return !firebaseUrl.empty() && !firebaseKey.empty();
    }
};

int main() {
    std::cout << "==========================================\n";
    std::cout << "   Chatbot API Server with Firebase     \n";
    std::cout << "          + Groq AI (Llama 3)           \n";
    std::cout << "==========================================\n";
    
    // Load configuration
    Config config;
    if (!config.loadFromFile("config.txt")) {
        std::cout << "Warning: config.txt not found. Using defaults.\n";
        
        // Use defaults
        config.firebaseUrl = "https://chatbot.firebaseio.com";
        config.firebaseKey = "AIzaSyAIxJ1XU2JxIV_aRDPgyY7WtjQ_EiSvIpE";
        config.port = 8080;
    }
    
    std::cout << "Config loaded. Port: " << config.port << std::endl;
    
    if (!config.groqApiKey.empty()) {
        std::cout << "Groq AI: ENABLED (Model: " << config.groqModel << ")" << std::endl;
    } else {
        std::cout << "Groq AI: DISABLED (No API key)" << std::endl;
    }
    
    // Initialize and start API Server
    APIServer server(config.port, config.firebaseUrl, config.firebaseKey, 
                     config.groqApiKey, config.groqModel);
    
    // server.start() is blocking, so this will keep the process running
    server.start();
    
    return 0;
}
