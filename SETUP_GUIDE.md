# Setup Guide: Chatbot with Firebase and Flutter Integration

## Prerequisites

1. **C++ Compiler** (g++, clang++, or MSVC)
2. **libcurl** for HTTP requests to Firebase
3. **Flutter SDK** (for Android app)
4. **Firebase Project** with Realtime Database enabled
5. **Android Studio** (for Flutter development)

## Part 1: Firebase Setup

### 1. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add Project"
3. Enter project name and follow setup wizard
4. Enable **Realtime Database** (not Firestore)
5. Set database rules to:
```json
{
  "rules": {
    ".read": "auth != null",
    ".write": "auth != null"
  }
}
```

### 2. Get Firebase Credentials

1. Go to Project Settings → General
2. Copy your **Database URL** (e.g., `https://your-project.firebaseio.com`)
3. Go to Project Settings → Service Accounts
4. Generate a new private key (for server-side auth) OR use Web API Key

### 3. Configure Authentication (Optional)

1. Go to Authentication → Sign-in method
2. Enable Email/Password authentication
3. Note your API key from project settings

## Part 2: C++ Server Setup

### 1. Install Dependencies

**Windows:**
```bash
# Install vcpkg or download libcurl
# Using vcpkg:
vcpkg install curl
```

**Linux:**
```bash
sudo apt-get install libcurl4-openssl-dev
```

**Mac:**
```bash
brew install curl
```

### 2. Update config.txt

Edit `config.txt` with your Firebase credentials:
```
FIREBASE_URL=https://your-project-id.firebaseio.com
FIREBASE_KEY=your-firebase-api-key
PORT=8080
```

### 3. Compile the Server

**Windows (MinGW):**
```bash
g++ -std=c++11 -o chatbot_server.exe server_main.cpp APIServer.cpp FirebaseClient.cpp Chatbot.cpp LinkedList.cpp Queue.cpp Stack.cpp HashMap.cpp -lcurl -lws2_32
```

**Linux:**
```bash
g++ -std=c++11 -o chatbot_server server_main.cpp APIServer.cpp FirebaseClient.cpp Chatbot.cpp LinkedList.cpp Queue.cpp Stack.cpp HashMap.cpp -lcurl -lpthread
```

**Mac:**
```bash
g++ -std=c++11 -o chatbot_server server_main.cpp APIServer.cpp FirebaseClient.cpp Chatbot.cpp LinkedList.cpp Queue.cpp Stack.cpp HashMap.cpp -lcurl
```

### 4. Run the Server

```bash
./chatbot_server    # Linux/Mac
chatbot_server.exe  # Windows
```

The server will start on port 8080 (or your configured port).

## Part 3: Flutter Android App Setup

### 1. Create Flutter Project

```bash
flutter create chatbot_flutter
cd chatbot_flutter
```

### 2. Copy Files

Copy the following files to your Flutter project:
- `flutter/lib/services/chatbot_service.dart` → `lib/services/chatbot_service.dart`
- `flutter/lib/screens/chat_screen.dart` → `lib/screens/chat_screen.dart`

### 3. Update pubspec.yaml

Add the http dependency (already in provided pubspec.yaml):
```yaml
dependencies:
  http: ^0.13.5
```

Then run:
```bash
flutter pub get
```

### 4. Update main.dart

```dart
import 'package:flutter/material.dart';
import 'screens/chat_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chatbot App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ChatScreen(userId: 'user123'), // Use actual user ID
    );
  }
}
```

### 5. Update Server URL

In `lib/services/chatbot_service.dart` and `lib/screens/chat_screen.dart`, replace:
- `http://localhost:8080` with your server's IP address
- For Android emulator: use `http://10.0.2.2:8080`
- For physical device: use your computer's IP (e.g., `http://192.168.1.100:8080`)

### 6. Add Internet Permission

In `android/app/src/main/AndroidManifest.xml`, add:
```xml
<uses-permission android:name="android.permission.INTERNET" />
```

### 7. Run Flutter App

```bash
flutter run
```

## Part 4: Testing

### 1. Test API Endpoints

Using curl or Postman:

**Send a message:**
```bash
curl -X POST http://localhost:8080/api/chat \
  -H "Content-Type: application/json" \
  -H "X-User-Id: user123" \
  -d '{"message":"Hello"}'
```

**Get history:**
```bash
curl http://localhost:8080/api/history?userId=user123
```

**Health check:**
```bash
curl http://localhost:8080/api/health
```

### 2. Test Flutter App

1. Open the Flutter app on Android device/emulator
2. Type a message and send
3. Verify response appears
4. Check Firebase console to see data being saved

## Troubleshooting

### Server won't start
- Check if port 8080 is available
- Verify libcurl is installed
- Check config.txt has correct Firebase URL

### Flutter can't connect
- Ensure server is running
- Check firewall settings
- Use correct IP address (not localhost for physical devices)
- Verify internet permission in AndroidManifest.xml

### Firebase connection issues
- Verify Firebase URL is correct
- Check API key is valid
- Ensure Realtime Database is enabled
- Check database rules allow read/write

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/chat` | Send message to chatbot |
| GET | `/api/history` | Get conversation history |
| DELETE | `/api/history/clear` | Clear history |
| POST | `/api/response` | Add custom response |
| GET | `/api/statistics` | Get statistics |
| GET | `/api/health` | Health check |

## Firebase Data Structure

```
users/
  {userId}/
    messages/
      {messageId}/
        content: "message text"
        sender: "user" | "bot"
        timestamp: "timestamp"
    customResponses/
      {keyword}/
        response: "custom response"
```

## Next Steps

1. Implement user authentication
2. Add more sophisticated response generation
3. Implement conversation context
4. Add file upload support
5. Implement push notifications
6. Add analytics

