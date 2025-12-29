#ifndef QUEUE_H
#define QUEUE_H
#include "Message.h"

#include <string>
#include <mutex>


// Node for Queue
struct QueueNode {
    Message data;
    QueueNode* next;
    int priority;  // For priority queue functionality
    
    QueueNode(const Message& msg, int prio = 0) 
        : data(msg), next(nullptr), priority(prio) {}
};

// Queue class for message processing
class MessageQueue {
private:
    QueueNode* front;
    QueueNode* rear;
    int size;
    int maxSize;
    
    // Thread safety (optional for future multi-threading)
    mutable std::mutex mtx;
    
public:
    MessageQueue(int maxSize = 100);
    ~MessageQueue();
    
    // Basic queue operations
    void enqueue(const Message& msg);
    void enqueueWithPriority(const Message& msg, int priority);
    Message dequeue();
    
    // Utility operations
    bool isEmpty() const;
    bool isFull() const;
    int getSize() const;
    Message peek() const;  // View front without removing
    
    // Clear queue
    void clear();
    
    // Display queue contents
    void display() const;
    void displayRecent(int count) const;

};

#endif // QUEUE_H

