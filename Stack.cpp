#include "Stack.h"
#include <iostream>

// MessageStack Implementation
MessageStack::MessageStack(int maxSize) : top(nullptr), size(0), maxSize(maxSize) {}

MessageStack::~MessageStack() {
    clear();
}

void MessageStack::push(const Message& msg) {
    if (isFull()) {
        // Remove bottom element if stack is full (circular stack behavior)
        // For simplicity, we'll just not add if full
        std::cout << "Stack is full. Cannot add more messages.\n";
        return;
    }
    
    StackNode* newNode = new StackNode(msg);
    
    if (isEmpty()) {
        top = newNode;
    } else {
        newNode->next = top;
        top = newNode;
    }
    size++;
}

Message MessageStack::pop() {
    if (isEmpty()) {
        return Message("", "", "");
    }
    
    StackNode* temp = top;
    Message msg = temp->data;
    
    top = top->next;
    delete temp;
    size--;
    
    return msg;
}

Message MessageStack::peek() const {
    if (isEmpty()) {
        return Message("", "", "");
    }
    
    return top->data;
}

bool MessageStack::isEmpty() const {
    return top == nullptr;
}

bool MessageStack::isFull() const {
    return size >= maxSize;
}

int MessageStack::getSize() const {
    return size;
}

void MessageStack::clear() {
    while (top != nullptr) {
        StackNode* temp = top;
        top = top->next;
        delete temp;
    }
    size = 0;
}

void MessageStack::display() const {
    if (isEmpty()) {
        std::cout << "Stack is empty.\n";
        return;
    }
    
    std::cout << "\n========== Message Stack ==========\n";
    StackNode* current = top;
    int count = 1;
    
    while (current != nullptr) {
        std::cout << "[" << count << "] " << current->data.sender 
                  << ": " << current->data.content << "\n";
        current = current->next;
        count++;
    }
    std::cout << "===================================\n";
}

