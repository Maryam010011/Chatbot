import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // ⭐ Change this to your actual IP address if running on phone
  // For web browser, localhost is fine
  static const String baseUrl = 'http://127.0.0.1:8081/api';
  
  // Send chat message
  static Future<Map<String, dynamic>> sendMessage(
    String message, 
    String userId
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat'),
        headers: {
          'Content-Type': 'application/json',
          'X-User-Id': userId,
        },
        body: jsonEncode({
          'message': message,
        }),
      );

      print('📤 Sent: $message');
      print('📥 Status: ${response.statusCode}');
      print('📥 Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error sending message: $e');
      rethrow;
    }
  }

  // Get chat history
  static Future<List<dynamic>> getHistory(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/history?userId=$userId&limit=50'),
        headers: {
          'X-User-Id': userId,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? [];
      } else {
        throw Exception('Failed to load history');
      }
    } catch (e) {
      print('❌ Error loading history: $e');
      return [];
    }
  }

  // Clear history
  static Future<bool> clearHistory(String userId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/history/clear'),
        headers: {
          'X-User-Id': userId,
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('❌ Error clearing history: $e');
      return false;
    }
  }
}