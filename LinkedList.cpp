#include "LinkedList.h"
#include <iostream>
#include <iomanip>

// ConversationHistory Implementation
ConversationHistory::ConversationHistory() : head(nullptr), tail(nullptr), size(0) {}

ConversationHistory::~ConversationHistory() {
    clear();
}

void ConversationHistory::insertAtEnd(const Message& msg) {
    MessageNode* newNode = new MessageNode(msg);
    
    if (isEmpty()) {
        head = tail = newNode;
    } else {
        tail->next = newNode;
        tail = newNode;
    }
    size++;
}

void ConversationHistory::insertAtBeginning(const Message& msg) {
    MessageNode* newNode = new MessageNode(msg);
    
    if (isEmpty()) {
        head = tail = newNode;
    } else {
        newNode->next = head;
        head = newNode;
    }
    size++;
}

void ConversationHistory::displayAll() const {
    if (isEmpty()) {
        std::cout << "No conversation history.\n";
        return;
    }
    
    MessageNode* current = head;
    int count = 1;
    
    std::cout << "\n========== Conversation History ==========\n";
    while (current != nullptr) {
        std::cout << "[" << count << "] " << current->data.sender 
                  << " (" << current->data.timestamp << "):\n";
        std::cout << "    " << current->data.content << "\n\n";
        current = current->next;
        count++;
    }
    std::cout << "==========================================\n";
}

void ConversationHistory::displayRecent(int count) const {
    if (isEmpty()) {
        std::cout << "No conversation history.\n";
        return;
    }
    
    // Count total messages
    int totalMessages = getSize();
    int startIndex = std::max(0, totalMessages - count);
    
    MessageNode* current = head;
    int currentIndex = 0;
    
    // Skip to start index
    while (current != nullptr && currentIndex < startIndex) {
        current = current->next;
        currentIndex++;
    }
    
    std::cout << "\n========== Recent Messages ==========\n";
    while (current != nullptr && currentIndex < totalMessages) {
        std::cout << "[" << (currentIndex + 1) << "] " << current->data.sender 
                  << " (" << current->data.timestamp << "):\n";
        std::cout << "    " << current->data.content << "\n\n";
        current = current->next;
        currentIndex++;
    }
    std::cout << "=====================================\n";
}

bool ConversationHistory::isEmpty() const {
    return head == nullptr;
}

int ConversationHistory::getSize() const {
    return size;
}

void ConversationHistory::clear() {
    MessageNode* current = head;
    while (current != nullptr) {
        MessageNode* temp = current;
        current = current->next;
        delete temp;
    }
    head = tail = nullptr;
    size = 0;
}

Message ConversationHistory::getLastMessage() const {
    if (isEmpty()) {
        return Message("", "", "");
    }
    return tail->data;
}

MessageNode* ConversationHistory::searchByContent(const std::string& keyword) const {
    MessageNode* current = head;
    std::string lowerKeyword = keyword;
    std::transform(lowerKeyword.begin(), lowerKeyword.end(), lowerKeyword.begin(), ::tolower);
    
    while (current != nullptr) {
        std::string content = current->data.content;
        std::transform(content.begin(), content.end(), content.begin(), ::tolower);
        
        if (content.find(lowerKeyword) != std::string::npos) {
            return current;
        }
        current = current->next;
    }
    return nullptr;
}

std::vector<Message> ConversationHistory::getMessagesBySender(const std::string& sender) const {
    std::vector<Message> messages;
    MessageNode* current = head;
    
    while (current != nullptr) {
        if (current->data.sender == sender) {
            messages.push_back(current->data);
        }
        current = current->next;
    }
    
    return messages;
}

