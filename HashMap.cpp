#include "HashMap.h"
#include <iostream>
#include <algorithm>
#include <functional>

// ResponseMap Implementation
ResponseMap::ResponseMap() : size(0), capacity(TABLE_SIZE) {
    table = new HashNode*[TABLE_SIZE];
    for (int i = 0; i < TABLE_SIZE; i++) {
        table[i] = nullptr;
    }
}

ResponseMap::~ResponseMap() {
    clear();
    delete[] table;
}

int ResponseMap::hashFunction(const std::string& key) const {
    std::hash<std::string> hasher;
    return hasher(key) % TABLE_SIZE;
}

HashNode* ResponseMap::findNode(const std::string& key) const {
    int index = hashFunction(key);
    HashNode* current = table[index];
    
    while (current != nullptr) {
        if (current->key == key) {
            return current;
        }
        current = current->next;
    }
    
    return nullptr;
}

void ResponseMap::insert(const std::string& key, const std::string& value) {
    int index = hashFunction(key);
    HashNode* existingNode = findNode(key);
    
    if (existingNode != nullptr) {
        // Key exists, add to values if not already present
        for (const auto& val : existingNode->values) {
            if (val == value) {
                return;  // Value already exists
            }
        }
        existingNode->values.push_back(value);
    } else {
        // New key, create new node
        HashNode* newNode = new HashNode(key, value);
        newNode->next = table[index];
        table[index] = newNode;
        size++;
    }
}

std::vector<std::string> ResponseMap::get(const std::string& key) const {
    HashNode* node = findNode(key);
    if (node != nullptr) {
        return node->values;
    }
    return {};
}

bool ResponseMap::contains(const std::string& key) const {
    return findNode(key) != nullptr;
}

bool ResponseMap::remove(const std::string& key) {
    int index = hashFunction(key);
    HashNode* current = table[index];
    HashNode* prev = nullptr;
    
    while (current != nullptr) {
        if (current->key == key) {
            if (prev == nullptr) {
                table[index] = current->next;
            } else {
                prev->next = current->next;
            }
            delete current;
            size--;
            return true;
        }
        prev = current;
        current = current->next;
    }
    
    return false;
}

bool ResponseMap::update(const std::string& key, const std::string& oldValue, 
                        const std::string& newValue) {
    HashNode* node = findNode(key);
    if (node == nullptr) {
        return false;
    }
    
    auto it = std::find(node->values.begin(), node->values.end(), oldValue);
    if (it != node->values.end()) {
        *it = newValue;
        return true;
    }
    
    return false;
}

int ResponseMap::getSize() const {
    return size;
}

bool ResponseMap::isEmpty() const {
    return size == 0;
}

void ResponseMap::clear() {
    for (int i = 0; i < TABLE_SIZE; i++) {
        HashNode* current = table[i];
        while (current != nullptr) {
            HashNode* temp = current;
            current = current->next;
            delete temp;
        }
        table[i] = nullptr;
    }
    size = 0;
}

std::vector<std::string> ResponseMap::getAllKeys() const {
    std::vector<std::string> keys;
    
    for (int i = 0; i < TABLE_SIZE; i++) {
        HashNode* current = table[i];
        while (current != nullptr) {
            keys.push_back(current->key);
            current = current->next;
        }
    }
    
    return keys;
}

void ResponseMap::display() const {
    std::cout << "\n========== Response Map ==========\n";
    for (int i = 0; i < TABLE_SIZE; i++) {
        HashNode* current = table[i];
        while (current != nullptr) {
            std::cout << "Key: " << current->key << " -> ";
            for (const auto& value : current->values) {
                std::cout << value << " | ";
            }
            std::cout << "\n";
            current = current->next;
        }
    }
    std::cout << "================================\n";
}

double ResponseMap::getLoadFactor() const {
    return static_cast<double>(size) / TABLE_SIZE;
}

