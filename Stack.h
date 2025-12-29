#ifndef STACK_H
#define STACK_H
#include "Message.h"

#include <string>


// Node for Stack
struct StackNode {
    Message data;
    StackNode* next;
    
    StackNode(const Message& msg) : data(msg), next(nullptr) {}
};

// Stack class for undo/redo functionality
class MessageStack {
private:
    StackNode* top;
    int size;
    int maxSize;
    
public:
    MessageStack(int maxSize = 50);
    ~MessageStack();
    
    // Basic stack operations
    void push(const Message& msg);
    Message pop();
    Message peek() const;  // View top without removing
    
    // Utility operations
    bool isEmpty() const;
    bool isFull() const;
    int getSize() const;
    
    // Clear stack
    void clear();
    
    // Display stack contents (for debugging)
    void display() const;
};

#endif // STACK_H

