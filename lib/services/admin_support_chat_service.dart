import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/support_chat_model.dart';

class AdminSupportChatService {
  final String baseUrl = AppConfig.supportChat;

  // Lấy tất cả threads cho admin
  Future<List<SupportThread>> getAllThreads() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/all'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => SupportThread.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load threads: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading threads: $e');
    }
  }

  // Admin gửi tin nhắn vào thread
  Future<SupportThread?> sendAdminMessage(String threadId, String message) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$threadId/message'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'content': message}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return SupportThread.fromJson(data);
      } else {
        throw Exception('Failed to send message: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error sending message: $e');
    }
  }

  // Lấy thread cụ thể theo ID
  Future<SupportThread?> getThreadById(String threadId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/thread/$threadId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return SupportThread.fromJson(data);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to load thread: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading thread: $e');
    }
  }

  // Lấy thread theo email (cho user)
  Future<SupportThread?> getThreadByEmail(String email) async {
    try {
      final encodedEmail = Uri.encodeComponent(email);
      final response = await http.get(
        Uri.parse('$baseUrl/user/$encodedEmail'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return SupportThread.fromJson(data);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to load thread by email: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading thread by email: $e');
    }
  }

  // Đánh dấu thread là đã đọc (có thể implement sau)
  Future<bool> markThreadAsRead(String threadId) async {
    try {
      // Backend endpoint cần được thêm vào cho chức năng này
      final response = await http.patch(
        Uri.parse('$baseUrl/thread/$threadId/read'),
        headers: {'Content-Type': 'application/json'},
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Lấy thống kê chat (có thể implement sau)
  Future<Map<String, dynamic>> getChatStats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/stats'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load chat stats: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading chat stats: $e');
    }
  }
}
