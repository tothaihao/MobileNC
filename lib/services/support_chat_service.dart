import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/support_chat_model.dart';

class SupportChatService {
  final String baseUrl = AppConfig.supportChat;

  Future<SupportThread?> getThread(String userEmail) async {
    final response = await http.post(
      Uri.parse('$baseUrl/start-or-append'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'userEmail': userEmail}),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return SupportThread.fromJson(data);
    } else {
      return null;
    }
  }

  Future<SupportThread?> sendUserMessage(String userEmail, String userName, String message) async {
    final response = await http.post(
      Uri.parse('$baseUrl/start-or-append'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'userEmail': userEmail, 'userName': userName, 'message': message}),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return SupportThread.fromJson(data);
    } else {
      return null;
    }
  }
} 