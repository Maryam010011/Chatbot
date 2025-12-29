#include "Chatbot.h"
#include "LinkedList.h"
#include "Queue.h"
#include "Stack.h"
#include "GuardianAPI.h"
#include "HashMap.h"
#include <ctime>
#include <sstream>
#include <algorithm>
#include <random>
#include <iostream>

void Chatbot::displayRecent(int count) const {
    if (messageQueue) {
        messageQueue->displayRecent(count);
    } else {
        std::cout << "No messages to display.\n";
    }
}
void Chatbot::searchConversation(const std::string& keyword) const {
    if (!conversationHistory || conversationHistory->isEmpty()) {
        std::cout << "No conversation history.\n";
        return;
    }

    // Use the existing searchByContent method (case-insensitive) to find a match
    MessageNode* found = conversationHistory->searchByContent(keyword);
    if (!found) {
        std::cout << "No messages found containing \"" << keyword << "\"." << std::endl;
        return;
    }

    std::cout << "Found message:\n";
    std::cout << found->data.sender << " (" << found->data.timestamp << "):\n";
    std::cout << "  " << found->data.content << "\n";
}


// Chatbot Implementation
Chatbot::Chatbot() : messageCount(0), useAI(false) {
    conversationHistory = std::make_unique<ConversationHistory>();
    messageQueue = std::make_unique<MessageQueue>(100);
    undoStack = std::make_unique<MessageStack>(50);
    responseMap = std::make_unique<ResponseMap>();
    
    // Groq client will be initialized via initializeAI()
    loadResponses(); // Ensure responses are loaded
}


Chatbot::~Chatbot() = default;

std::string Chatbot::toLowerCase(const std::string& str) {
    std::string result = str;
    std::transform(result.begin(), result.end(), result.begin(), ::tolower);
    return result;
}

std::string Chatbot::getCurrentTime() const {
    time_t now = time(0);
    char* dt = ctime(&now);
    std::string timeStr(dt);
    timeStr.pop_back();  // Remove newline
    return timeStr;
}

void Chatbot::addToHistory(const Message& msg) {
    conversationHistory->insertAtEnd(msg);
    messageQueue->enqueue(msg);
    messageCount++;
}

std::string Chatbot::findBestResponse(const std::string& input) {
    std::string lowerInput = toLowerCase(input);

    
    // ========== NEWS QUERIES ==========
    if (lowerInput.find("news") != std::string::npos || 
        lowerInput.find("latest") != std::string::npos ||
        lowerInput.find("headlines") != std::string::npos) {
        
        std::istringstream iss(lowerInput);
        std::string word;
        std::string keyword = "general";  // default if no keyword found

        while (iss >> word) {
            if (word != "news" &&
                word != "latest" &&
                word != "headlines" &&
                word != "about" &&
                word != "on" &&
                word != "the") {
                keyword = word;   // first meaningful word
                break;
            }
        }

        std::cout << "[Fetching news from Guardian API...]" << std::endl;

        std::string jsonResponse = GuardianAPI::fetchNews(keyword, 5);
        auto articles = GuardianAPI::parseNews(jsonResponse);
        std::string newsResponse = GuardianAPI::formatNewsResponse(articles);

        return newsResponse;
    }

    // ========== CHECK HASHMAP FIRST (Fast responses) ==========
    
    // Exact phrase match
    std::vector<std::string> responses = responseMap->get(lowerInput);
    if (!responses.empty()) {
        std::cerr << "[DEBUG] Exact match for input: '" << lowerInput << "'\n";
        std::random_device rd;
        std::mt19937 gen(rd());
        std::uniform_int_distribution<> dis(0, responses.size() - 1);
        return responses[dis(gen)];
    }
    
    // Individual word matching
    std::istringstream iss(lowerInput);
    std::vector<std::string> words;
    std::string word;
    
    while (iss >> word) {
        words.push_back(word);
    }
    
    for (const auto& w : words) {
        std::vector<std::string> wordResponses = responseMap->get(w);
        if (!wordResponses.empty()) {
            std::cerr << "[DEBUG] Word match for word: '" << w << "'\n";
            std::random_device rd;
            std::mt19937 gen(rd());
            std::uniform_int_distribution<> dis(0, wordResponses.size() - 1);
            return wordResponses[dis(gen)];
        }
    }
    
    // Partial word matching
    for (const auto& w : words) {
        std::vector<std::string> allKeys = responseMap->getAllKeys();
        for (const auto& key : allKeys) {
            if (key.find(w) != std::string::npos || w.find(key) != std::string::npos) {
                std::vector<std::string> partialResponses = responseMap->get(key);
                if (!partialResponses.empty()) {
                    std::cerr << "[DEBUG] Partial match key: '" << key << "' for word: '" << w << "'\n";
                    std::random_device rd;
                    std::mt19937 gen(rd());
                    std::uniform_int_distribution<> dis(0, partialResponses.size() - 1);
                    return partialResponses[dis(gen)];
                }
            }
        }
    }
    
    return "I'm not sure how to respond to that. Could you try rephrasing?";
}

std::string Chatbot::processUserInput(const std::string& input) {
    if (input.empty()) {
        return "Please enter a message.";
    }
    
    // Add user message to history
    Message userMsg(input, "user", getCurrentTime());
    addToHistory(userMsg);
    
    // Find and generate response
    std::string response = findBestResponse(input);
    
    // Add bot response to history
    Message botMsg(response, "bot", getCurrentTime());
    addToHistory(botMsg);
    
    // Push to undo stack
    undoStack->push(userMsg);
    
    return response;
}

std::string Chatbot::respond(const std::string& userInput) {
    if (userInput.empty()) {
        return "Please enter a message.";
    }
    
    // Add user message to history first
    Message userMsg(userInput, "user", getCurrentTime());
    addToHistory(userMsg);
    
    std::string response;
    
    // Try AI response if enabled
    if (isAIEnabled()) {
        std::cerr << "[Chatbot] Using Groq AI for response..." << std::endl;
        response = groqClient->sendMessage(userInput);
        
        if (!response.empty()) {
            std::cerr << "[Chatbot] AI response received successfully" << std::endl;
        } else {
            std::cerr << "[Chatbot] AI response empty, falling back to local" << std::endl;
        }
    }
    
    // Fallback to local response if AI fails or is disabled
    if (response.empty()) {
        std::cerr << "[Chatbot] Using local response matching" << std::endl;
        response = findBestResponse(userInput);
    }
    
    // Add bot response to history
    Message botMsg(response, "bot", getCurrentTime());
    addToHistory(botMsg);
    
    // Push to undo stack
    undoStack->push(userMsg);
    
    return response;
}

// Initialize AI with Groq
void Chatbot::initializeAI(const std::string& apiKey, const std::string& model) {
    if (!apiKey.empty()) {
        groqClient = std::make_unique<GroqClient>(apiKey, model);
        useAI = true;
        std::cerr << "[Chatbot] Groq AI initialized with model: " << model << std::endl;
    } else {
        std::cerr << "[Chatbot] No API key provided, AI disabled" << std::endl;
        useAI = false;
    }
}

void Chatbot::displayHistory() const {
    conversationHistory->displayAll();
}

void Chatbot::clearHistory() {
    conversationHistory->clear();
    messageQueue->clear();
    messageCount = 0;
}

void Chatbot::undoLastMessage() {
    if (!undoStack->isEmpty()) {
        Message lastMsg = undoStack->pop();
        std::cout << "Undid message: " << lastMsg.content << "\n";
        // Note: In a full implementation, you'd also remove from history
    } else {
        std::cout << "Nothing to undo.\n";
    }
}

int Chatbot::getMessageCount() const {
    return messageCount;
}

void Chatbot::loadResponses() {
    // Load responses into HashMap
    responseMap->insert("hello", "Hello! How can I help you today?");
    responseMap->insert("hi", "Hi there! What's on your mind?");
    responseMap->insert("hey", "Hey! Nice to meet you!");
    responseMap->insert("greetings", "Greetings! How may I assist you?");
    
    responseMap->insert("name", "I'm a chatbot created using Data Structures and Algorithms!");
    responseMap->insert("who", "I'm an AI chatbot. What would you like to know?");
    responseMap->insert("what", "I'm here to help answer your questions!");
    
    responseMap->insert("help", "I'm here to help! What do you need assistance with?");
    responseMap->insert("assist", "Of course! How can I assist you?");
    responseMap->insert("support", "I'm here to support you. What's the issue?");
    
    responseMap->insert("bye", "Goodbye! Have a great day!");
    responseMap->insert("goodbye", "Farewell! Take care!");
    responseMap->insert("exit", "See you later! Thanks for chatting!");
    
    responseMap->insert("thanks", "You're welcome! Happy to help!");
    responseMap->insert("thank", "You're very welcome!");
    responseMap->insert("appreciate", "I'm glad I could help!");
    
    responseMap->insert("how", "I'm doing great! How about you?");
    responseMap->insert("fine", "That's wonderful to hear!");
    responseMap->insert("good", "That's great! What else can I help with?");
    
    responseMap->insert("weather", "I don't have access to weather data, but I hope it's nice where you are!");
    responseMap->insert("time", "I can't tell the exact time, but I'm here whenever you need me!");
    
    // Load responses into HashMap for phrase matching
    responseMap->insert("how are you", "I'm doing great, thanks for asking! How about you?");
    responseMap->insert("what is your name", "I'm a chatbot! You can call me ChatBot.");
    responseMap->insert("tell me about yourself", "I'm a chatbot built using C++ and various data structures like Linked Lists, Queues, Stacks, and Hash Maps!");
    responseMap->insert("what can you do", "I can chat with you, remember our conversation, and help answer questions!");
    
    // Add multiple responses for same keyword
    responseMap->insert("joke", "Why don't scientists trust atoms? Because they make up everything!");
    responseMap->insert("joke", "Why did the scarecrow win an award? He was outstanding in his field!");
    responseMap->insert("funny", "I try to be funny! Did you hear about the mathematician who's afraid of negative numbers? He'll stop at nothing to avoid them!");
}

void Chatbot::addCustomResponse(const std::string& keyword, const std::string& response) {
    responseMap->insert(keyword, response);
    std::cout << "Added custom response for keyword: " << keyword << "\n";
}

