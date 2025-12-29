#include "Queue.h"
#include <iostream>
#include <algorithm>
#include <climits>

// MessageQueue Implementation
MessageQueue::MessageQueue(int maxSize) 
    : front(nullptr), rear(nullptr), size(0), maxSize(maxSize) {}

MessageQueue::~MessageQueue() {
    clear();
}

void MessageQueue::enqueue(const Message& msg) {
    std::lock_guard<std::mutex> lock(mtx);

    // Drop oldest if full (do it unlocked helper to avoid nested locks)
    if (size >= maxSize) {
        QueueNode* temp = front;
        front = front->next;
        if (front == nullptr) {
            rear = nullptr;
        }
        delete temp;
        size--;
    }
    
    QueueNode* newNode = new QueueNode(msg);
    
    if (front == nullptr) {
        front = rear = newNode;
    } else {
        rear->next = newNode;
        rear = newNode;
    }
    size++;
}

void MessageQueue::enqueueWithPriority(const Message& msg, int priority) {
    std::lock_guard<std::mutex> lock(mtx);

    // Drop oldest if full to make room
    if (size >= maxSize) {
        QueueNode* temp = front;
        front = front->next;
        if (front == nullptr) {
            rear = nullptr;
        }
        delete temp;
        size--;
    }
    
    QueueNode* newNode = new QueueNode(msg, priority);
    
    if (front == nullptr) {
        front = rear = newNode;
    } else {
        // Insert based on priority (higher priority first)
        QueueNode* current = front;
        QueueNode* prev = nullptr;
        
        while (current != nullptr && current->priority >= priority) {
            prev = current;
            current = current->next;
        }
        
        if (prev == nullptr) {
            // Insert at front
            newNode->next = front;
            front = newNode;
        } else {
            // Insert in middle or end
            newNode->next = current;
            prev->next = newNode;
            
            if (current == nullptr) {
                rear = newNode;
            }
        }
    }
    size++;
}

Message MessageQueue::dequeue() {
    std::lock_guard<std::mutex> lock(mtx);
    
    if (isEmpty()) {
        return Message("", "", "");
    }
    
    QueueNode* temp = front;
    Message msg = temp->data;
    
    front = front->next;
    if (front == nullptr) {
        rear = nullptr;
    }
    
    delete temp;
    size--;
    
    return msg;
}

bool MessageQueue::isEmpty() const {
    std::lock_guard<std::mutex> lock(mtx);
    return front == nullptr;
}

bool MessageQueue::isFull() const {
    std::lock_guard<std::mutex> lock(mtx);
    return size >= maxSize;
}

int MessageQueue::getSize() const {
    std::lock_guard<std::mutex> lock(mtx);
    return size;
}

Message MessageQueue::peek() const {
    std::lock_guard<std::mutex> lock(mtx);
    
    if (isEmpty()) {
        return Message("", "", "");
    }
    
    return front->data;
}

void MessageQueue::clear() {
    std::lock_guard<std::mutex> lock(mtx);
    
    while (front != nullptr) {
        QueueNode* temp = front;
        front = front->next;
        delete temp;
    }
    rear = nullptr;
    size = 0;
}

void MessageQueue::display() const {
    std::lock_guard<std::mutex> lock(mtx);
    
    if (isEmpty()) {
        std::cout << "Queue is empty.\n";
        return;
    }
    
    std::cout << "\n========== Message Queue ==========\n";
    QueueNode* current = front;
    int count = 1;
    
    while (current != nullptr) {
        std::cout << "[" << count << "] Priority: " << current->priority 
                  << " - " << current->data.sender << ": " 
                  << current->data.content << "\n";
        current = current->next;
        count++;
    }
    std::cout << "===================================\n";
}

void MessageQueue::displayRecent(int count) const {
    std::lock_guard<std::mutex> lock(mtx);

    if (isEmpty()) {
        std::cout << "No messages in queue.\n";
        return;
    }

    // Step 1: total size check
    int skip = size - count;
    if (skip < 0) skip = 0;

    // Step 2: traverse linked list
    QueueNode* temp = front;
    int index = 0;

    while (temp != nullptr) {
        if (index >= skip) {
            std::cout << temp->data.sender << ": "
                      << temp->data.content
                      << " (" << temp->data.timestamp << ")\n";
        }
        temp = temp->next;
        index++;
    }
}
