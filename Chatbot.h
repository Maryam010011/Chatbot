#ifndef CHATBOT_H
#define CHATBOT_H
#include "Message.h"
#include "GroqClient.h"
#include <string>
#include <vector>
#include <memory>

// Forward declarations
class MessageNode;
class ConversationHistory;
class MessageQueue;
class MessageStack;
class ResponseMap;


// Main Chatbot class
class Chatbot {
private:
    std::unique_ptr<GroqClient> groqClient;  // AI client
    std::unique_ptr<ConversationHistory> conversationHistory;  // Linked List
    std::unique_ptr<MessageQueue> messageQueue;        // Queue for processing
    std::unique_ptr<MessageStack> undoStack;           // Stack for undo
    std::unique_ptr<ResponseMap> responseMap;          // Hash Map for responses
    
    int messageCount;
    bool useAI;  // Flag to toggle AI vs local responses
    
    // Helper functions
    std::string toLowerCase(const std::string& str);
    std::string processUserInput(const std::string& input);
    std::string findBestResponse(const std::string& input);
    void addToHistory(const Message& msg);
 
public:
    Chatbot();
    ~Chatbot();
    
    // Main interface
    std::string respond(const std::string& userInput);
    void displayHistory() const;
    void clearHistory();
    void undoLastMessage();
    int getMessageCount() const;
    
    // Utility functions
    void loadResponses();
    void addCustomResponse(const std::string& keyword, const std::string& response);
    std::string getCurrentTime() const;  // Make public for API use
    void displayRecent(int count) const;
    void searchConversation(const std::string& keyword) const;
    
    // AI Integration
    void initializeAI(const std::string& apiKey, const std::string& model = "llama-3.3-70b-versatile");
    void setUseAI(bool enable) { useAI = enable; }
    bool isAIEnabled() const { return useAI && groqClient && groqClient->isAvailable(); }


};

#endif // CHATBOT_H

