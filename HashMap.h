#ifndef HASHMAP_H
#define HASHMAP_H

#include <string>
#include <vector>
#include <functional>

// Hash Map Node
struct HashNode {
    std::string key;
    std::vector<std::string> values;  // Multiple responses for same key
    HashNode* next;  // For chaining
    
    HashNode(const std::string& k, const std::string& value) 
        : key(k), next(nullptr) {
        values.push_back(value);
    }
};

// Hash Map class for response lookup
class ResponseMap {
private:
    static const int TABLE_SIZE = 101;  // Prime number for better distribution
    HashNode** table;
    int size;
    int capacity;
    
    // Hash function
    int hashFunction(const std::string& key) const;
    
    // Helper to find node
    HashNode* findNode(const std::string& key) const;
    
public:
    ResponseMap();
    ~ResponseMap();
    
    // Insert operation
    void insert(const std::string& key, const std::string& value);
    
    // Get operation
    std::vector<std::string> get(const std::string& key) const;
    
    // Check if key exists
    bool contains(const std::string& key) const;
    
    // Remove operation
    bool remove(const std::string& key);
    
    // Update operation
    bool update(const std::string& key, const std::string& oldValue, const std::string& newValue);
    
    // Utility operations
    int getSize() const;
    bool isEmpty() const;
    void clear();
    
    // Get all keys
    std::vector<std::string> getAllKeys() const;
    
    // Display (for debugging)
    void display() const;
    
    // Load factor
    double getLoadFactor() const;
};

#endif // HASHMAP_H

