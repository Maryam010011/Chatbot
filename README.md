aa# Chatbot Project using Data Structures and Algorithms (DSA)

A comprehensive C++ chatbot implementation demonstrating various data structures and algorithms.

## Project Structure

```
Project/
├── Chatbot.h          - Main chatbot class header
├── Chatbot.cpp        - Main chatbot implementation
├── LinkedList.h       - Linked List for conversation history
├── LinkedList.cpp     - Linked List implementation
├── Queue.h            - Queue for message processing
├── Queue.cpp          - Queue implementation
├── Stack.h            - Stack for undo functionality
├── Stack.cpp          - Stack implementation
├── HashMap.h          - Hash Map for response lookup
├── HashMap.cpp        - Hash Map implementation
├── main.cpp           - Main program entry point
├── Makefile           - Build configuration
└── README.md          - This file
```
## Architecture
```
┌─────────────────────────────────────────────────────────────┐
│                     Flutter Mobile App                      │
│                    (Android/iOS/Web)                        │
└────────────────────────┬────────────────────────────────────┘
                         │ HTTP/REST API
                         ↓
┌─────────────────────────────────────────────────────────────┐
│              C++ REST API Server (Port 8081)                │
│   ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│   │   Chatbot    │  │   Firebase   │  │  Gork   API  │      │
│   │   Engine     │→ │   Client     │  │              │      │ 
│   └──────────────┘  └──────────────┘  └──────────────┘      │
└────────────────────────┬────────────────────────────────────┘
                         │ REST API
                         ↓
┌─────────────────────────────────────────────────────────────┐
│              Firebase Realtime Database                     │
│         (User Data, Chat History, Responses)                │
└─────────────────────────────────────────────────────────────┘
```
## Data Structures Used

### 1. **Linked List** (`LinkedList.h/cpp`)
   - **Purpose**: Store conversation history
   - **Operations**: Insert at beginning/end, search, display, clear
   - **Features**: 
     - Maintains chronological order of messages
     - Efficient insertion and traversal
     - Search functionality by content

### 2. **Queue** (`Queue.h/cpp`)
   - **Purpose**: Process messages in FIFO order
   - **Operations**: Enqueue, dequeue, priority enqueue, peek
   - **Features**:
     - Thread-safe operations (mutex-based)
     - Priority queue support
     - Bounded queue with automatic overflow handling

### 3. **Stack** (`Stack.h/cpp`)
   - **Purpose**: Undo/redo functionality
   - **Operations**: Push, pop, peek
   - **Features**:
     - LIFO structure for message history
     - Bounded stack to prevent memory issues
     - Undo last user message

### 4. **Hash Map** (`HashMap.h/cpp`)
   - **Purpose**: Fast response lookup using hash table
   - **Operations**: Insert, get, remove, update, contains
   - **Features**:
     - Chaining for collision resolution
     - Multiple values per key
     - Load factor calculation
     - O(1) average case lookup
     
### Flutter App

1. **Login** with Firebase Auth
2. **Chat** with bot in real-time
3. **Switch personalities** (Buddy, Professor, Tech Guru)
4. **View statistics** (message counts, daily activity)
5. **Add custom responses** for personalized interactions

## Features

- **News Integration**: Fetch latest news using Guardian API
- **AI Integration**: Groq AI (Llama 3) support (Server Mode)
- **Interactive Chat Interface**: Chat with the bot in real-time
- **Conversation History**: View all past conversations
- **Keyword Matching**: Intelligent response generation using Hash Map
- **Undo Functionality**: Undo last message using Stack
- **Custom Responses**: Add your own keyword-response pairs
- **Message Statistics**: View conversation statistics
- **Search Functionality**: Search through conversation history

## Compilation

### Using Makefile (Linux/Mac):
```bash
make
```

### Manual Compilation:
```bash
g++ -std=c++11 -Wall -Wextra -O2 -o chatbot main.cpp Chatbot.cpp LinkedList.cpp Queue.cpp Stack.cpp HashMap.cpp FirebaseClient.cpp -lcurl
```

### Windows (MinGW/MSVC):
```bash
g++ -std=c++11 -Wall -Wextra -O2 -o chatbot.exe main.cpp Chatbot.cpp LinkedList.cpp Queue.cpp Stack.cpp HashMap.cpp FirebaseClient.cpp -lcurl -lws2_32
```

## Running the Program

```bash
### Local Chatbot (CLI)
```bash
./chatbot        # Linux/Mac
chatbot.exe      # Windows
```

### API Server (For Flutter App)
```bash
./chatbot_server    # Linux/Mac
chatbot_server.exe  # Windows
```
```

Or use make:
```bash
make run
```

## Usage

1. **Chat Mode**: Select option 1 to start chatting with the bot
2. **View History**: Select option 2 to see all conversation history
3. **Recent Messages**: Select option 3 to view recent messages
4. **Undo**: Select option 4 to undo the last message
5. **Clear History**: Select option 5 to clear all conversation history
6. **Add Custom Response**: Select option 6 to add keyword-response pairs
7. **Statistics**: Select option 7 to view message statistics
8. **Search**: Select option 8 to search conversation (in progress)
9. **Exit**: Select option 9 to exit the program

## Example Interactions

```
You: Hello
Bot: Hello! How can I help you today?

You: What is your name?
Bot: I'm a chatbot! You can call me ChatBot.

You: Tell me about yourself
Bot: I'm a chatbot built using C++ and various data structures like Linked Lists, Queues, Stacks, and Hash Maps!

You: Thanks
Bot: You're welcome! Happy to help!
```

## Algorithm Complexity

| Data Structure | Operation | Time Complexity | Space Complexity |
|---------------|-----------|----------------|------------------|
| Linked List   | Insert    | O(1)           | O(1)             |
| Linked List   | Search    | O(n)           | O(1)             |
| Queue         | Enqueue   | O(1)           | O(1)             |
| Queue         | Dequeue   | O(1)           | O(1)             |
| Stack         | Push      | O(1)           | O(1)             |
| Stack         | Pop       | O(1)           | O(1)             |
| Hash Map      | Insert    | O(1) avg       | O(1)             |
| Hash Map      | Search    | O(1) avg       | O(1)             |

Where:
- `n` = number of elements

## Future Enhancements

- [ ] Implement conversation search using Linked List
- [ ] Add file I/O for saving/loading conversation history
- [ ] Implement graph structure for conversation flow
- [ ] Add sentiment analysis
- [ ] Implement priority queue for message importance
- [ ] Add multi-threading support
- [ ] Implement conversation context using tree structure

## Requirements

- C++11 or higher
- Standard C++ libraries
- Compiler: g++, clang++, or MSVC

##  Author

**Maryam Jahangir**  
DSA & Full-Stack Development Project

## License

Educational Project

