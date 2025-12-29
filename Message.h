#ifndef MESSAGE_H
#define MESSAGE_H

#include <string>

struct Message {
    std::string content;
    std::string sender;
    std::string timestamp;
    Message* next;
    
    Message(const std::string& c, const std::string& s, const std::string& t)
        : content(c), sender(s), timestamp(t), next(nullptr) {}
};

#endif