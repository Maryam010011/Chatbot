import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatbotService {
  final String baseUrl;
  
  ChatbotService({this.baseUrl = 'http://127.0.0.1:8081'});
  
  // Send a message to the chatbot
  Future<ChatResponse> sendMessage(String message, String userId) async {
    try {
      print('🌐 Calling API: POST $baseUrl/api/chat');
      print('📋 Headers: Content-Type=application/json, X-User-Id=$userId');
      print('📨 Body: {"message":"$message"}');
      
      final response = await http.post(
        Uri.parse('$baseUrl/api/chat'),
        headers: {
          'Content-Type': 'application/json',
          'X-User-Id': userId,
        },
        body: jsonEncode({
          'message': message,
        }),
      );
      
      print('📡 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ChatResponse(
          success: data['success'] ?? true,
          message: data['message'] ?? '',
          response: data['data'] != null 
              ? data['data']['response'] ?? '' 
              : '',
        );
      } else {
        final error = jsonDecode(response.body);
        return ChatResponse(
          success: false,
          message: error['error'] ?? 'Failed to get response',
        );
      }
    } catch (e) {
      print('❌ Network error: $e');
      return ChatResponse(
        success: false,
        message: 'Network error: $e',
      );
    }
  }
  
  // Get conversation history
  Future<List<ChatMessage>> getHistory(String userId, {int limit = 50}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/history?userId=$userId&limit=$limit'),
        headers: {
          'X-User-Id': userId,
        },
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          List<dynamic> messages = data['data'];
          return messages.map((msg) => ChatMessage.fromJson(msg)).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching history: $e');
      return [];
    }
  }
  
  // Clear conversation history
  Future<bool> clearHistory(String userId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/history/clear'),
        headers: {
          'X-User-Id': userId,
        },
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] ?? false;
      }
      return false;
    } catch (e) {
      print('Error clearing history: $e');
      return false;
    }
  }
  
  // Add custom response
  Future<bool> addCustomResponse(
    String userId,
    String keyword,
    String response,
  ) async {
    try {
      final httpResponse = await http.post(
        Uri.parse('$baseUrl/api/response'),
        headers: {
          'Content-Type': 'application/json',
          'X-User-Id': userId,
        },
        body: jsonEncode({
          'keyword': keyword,
          'response': response,
        }),
      );
      
      if (httpResponse.statusCode == 200) {
        final data = jsonDecode(httpResponse.body);
        return data['success'] ?? false;
      }
      return false;
    } catch (e) {
      print('Error adding custom response: $e');
      return false;
    }
  }
  
  // Get statistics
  Future<ChatStatistics> getStatistics() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/statistics'),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return ChatStatistics.fromJson(data['data']);
        }
      }
      return ChatStatistics(messageCount: 0);
    } catch (e) {
      print('Error fetching statistics: $e');
      return ChatStatistics(messageCount: 0);
    }
  }
  
  // Health check
  Future<bool> checkHealth() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/health'),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

// Data models
class ChatResponse {
  final bool success;
  final String message;
  final String response;
  
  ChatResponse({
    required this.success,
    this.message = '',
    this.response = '',
  });
}

class ChatMessage {
  final String content;
  final String sender;
  final String timestamp;
  
  ChatMessage({
    required this.content,
    required this.sender,
    required this.timestamp,
  });
  
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      content: json['content'] ?? '',
      sender: json['sender'] ?? '',
      timestamp: json['timestamp'] ?? '',
    );
  }
}

class ChatStatistics {
  final int messageCount;
  
  ChatStatistics({required this.messageCount});
  
  factory ChatStatistics.fromJson(Map<String, dynamic> json) {
    return ChatStatistics(
      messageCount: json['messageCount'] ?? 0,
    );
  }
}

