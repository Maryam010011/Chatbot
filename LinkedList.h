#ifndef LINKEDLIST_H
#define LINKEDLIST_H
#include "Message.h"

#include <string>
#include <vector>
#include <algorithm>



// Node for Linked List (Conversation History)
class MessageNode {
public:
    Message data;
    MessageNode* next;
    
    MessageNode(const Message& msg) : data(msg), next(nullptr) {}
};

// Linked List class for storing conversation history
class ConversationHistory {
private:
    MessageNode* head;
    MessageNode* tail;
    int size;
    
public:
    ConversationHistory();
    ~ConversationHistory();
    
    // Insert operations
    void insertAtEnd(const Message& msg);
    void insertAtBeginning(const Message& msg);
    
    // Display operations
    void displayAll() const;
    void displayRecent(int count) const;
    
    // Utility operations
    bool isEmpty() const;
    int getSize() const;
    void clear();
    Message getLastMessage() const;
    
    // Search operations
    MessageNode* searchByContent(const std::string& keyword) const;
    std::vector<Message> getMessagesBySender(const std::string& sender) const;
};

#endif // LINKEDLIST_H

