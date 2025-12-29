# Chatbot API Server with Firebase Integration

This is the REST API server that connects the C++ chatbot backend to Firebase and provides endpoints for Flutter Android app.

## Architecture

```
Flutter App (Android) 
    ↓ HTTP Requests
C++ API Server (REST API)
    ↓ HTTP Requests
Firebase Realtime Database
```

## Features

- **REST API Server**: HTTP endpoints for chatbot operations
- **Firebase Integration**: Stores conversation history and user data
- **DSA Implementation**: Uses Linked List, Queue, Stack, and Hash Map
- **Multi-user Support**: Each user has isolated conversation history
- **CORS Enabled**: Allows Flutter app to connect

## API Endpoints

### POST `/api/chat`
Send a message to the chatbot.

**Request:**
```json
{
  "message": "Hello, how are you?"
}
```

**Headers:**
```
Content-Type: application/json
X-User-Id: user123
```

**Response:**
```json
{
  "success": true,
  "message": "Chat response generated",
  "data": {
    "response": "Hello! How can I help you today?",
    "userId": "user123"
  }
}
```

### GET `/api/history`
Get conversation history for a user.

**Query Parameters:**
- `userId` (required): User identifier
- `limit` (optional): Number of messages to retrieve (default: 50)

**Headers:**
```
X-User-Id: user123
```

**Response:**
```json
{
  "success": true,
  "message": "History retrieved",
  "data": [
    {
      "content": "Hello",
      "sender": "user",
      "timestamp": "Mon Jan 1 12:00:00 2024"
    },
    {
      "content": "Hello! How can I help you?",
      "sender": "bot",
      "timestamp": "Mon Jan 1 12:00:01 2024"
    }
  ]
}
```

### DELETE `/api/history/clear`
Clear conversation history for a user.

**Headers:**
```
X-User-Id: user123
```

**Response:**
```json
{
  "success": true,
  "message": "History cleared successfully"
}
```

### POST `/api/response`
Add a custom keyword-response pair.

**Request:**
```json
{
  "keyword": "greeting",
  "response": "Welcome! How can I assist you?"
}
```

**Headers:**
```
Content-Type: application/json
X-User-Id: user123
```

**Response:**
```json
{
  "success": true,
  "message": "Custom response added successfully"
}
```

### GET `/api/statistics`
Get chatbot statistics.

**Response:**
```json
{
  "success": true,
  "message": "Statistics retrieved",
  "data": {
    "messageCount": 42
  }
}
```

### GET `/api/health`
Health check endpoint.

**Response:**
```json
{
  "success": true,
  "message": "Server is healthy",
  "data": {
    "status": "running",
    "port": 8080
  }
}
```

## Compilation

### Prerequisites
- C++11 compiler
- libcurl development libraries
- Windows: Winsock2 (included)

### Build Commands

**Linux:**
```bash
make server
# Or manually:
g++ -std=c++11 -o chatbot_server server_main.cpp APIServer.cpp FirebaseClient.cpp Chatbot.cpp LinkedList.cpp Queue.cpp Stack.cpp HashMap.cpp -lcurl -lpthread
```

**Windows (MinGW):**
```bash
g++ -std=c++11 -o chatbot_server.exe server_main.cpp APIServer.cpp FirebaseClient.cpp Chatbot.cpp LinkedList.cpp Queue.cpp Stack.cpp HashMap.cpp -lcurl -lws2_32
```

**Mac:**
```bash
g++ -std=c++11 -o chatbot_server server_main.cpp APIServer.cpp FirebaseClient.cpp Chatbot.cpp LinkedList.cpp Queue.cpp Stack.cpp HashMap.cpp -lcurl
```

## Configuration

Create `config.txt`:
```
FIREBASE_URL=https://your-project-id.firebaseio.com
FIREBASE_KEY=your-firebase-api-key
PORT=8080
```

## Running the Server

```bash
./chatbot_server    # Linux/Mac
chatbot_server.exe  # Windows
```

The server will start on the configured port (default: 8080).

## Testing with curl

```bash
# Send a message
curl -X POST http://localhost:8080/api/chat \
  -H "Content-Type: application/json" \
  -H "X-User-Id: user123" \
  -d '{"message":"Hello"}'

# Get history
curl http://localhost:8080/api/history?userId=user123

# Health check
curl http://localhost:8080/api/health
```

## Firebase Data Structure

The server stores data in Firebase Realtime Database:

```
{
  "users": {
    "user123": {
      "messages": {
        "msg1": {
          "content": "Hello",
          "sender": "user",
          "timestamp": "Mon Jan 1 12:00:00 2024"
        },
        "msg2": {
          "content": "Hello! How can I help?",
          "sender": "bot",
          "timestamp": "Mon Jan 1 12:00:01 2024"
        }
      },
      "customResponses": {
        "greeting": {
          "response": "Welcome!"
        }
      }
    }
  }
}
```

## Error Responses

All errors follow this format:
```json
{
  "success": false,
  "error": "Error message here"
}
```

Common HTTP status codes:
- `200`: Success
- `400`: Bad Request (missing/invalid parameters)
- `404`: Not Found (invalid endpoint)
- `405`: Method Not Allowed
- `500`: Internal Server Error

## Security Notes

- In production, implement proper authentication
- Use HTTPS instead of HTTP
- Validate and sanitize all inputs
- Implement rate limiting
- Use Firebase Authentication for user management
- Secure API keys and credentials

## Troubleshooting

### Server won't start
- Check if port is available: `netstat -an | grep 8080`
- Verify libcurl is installed
- Check config.txt has correct values

### Can't connect to Firebase
- Verify Firebase URL is correct
- Check API key is valid
- Ensure Realtime Database is enabled
- Check database rules allow read/write

### Flutter app can't connect
- Ensure server is running
- Use correct IP address (not localhost for physical devices)
- Check firewall settings
- Verify CORS headers are set

