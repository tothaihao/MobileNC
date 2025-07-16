import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';

class AdminSupportChatService {
  final String baseUrl = '${Config.baseUrl}/api/admin/support-chat';

  Future<List<Map<String, dynamic>>> fetchThreads() async {
    final res = await http.get(Uri.parse(baseUrl));
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      return List<Map<String, dynamic>>.from(data['data']);
    } else {
      throw Exception('Lỗi lấy danh sách chat: ${res.body}');
    }
  }

  Future<Map<String, dynamic>> fetchThreadDetail(String threadId) async {
    final res = await http.get(Uri.parse('$baseUrl/$threadId'));
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      return data['data'];
    } else {
      throw Exception('Lỗi lấy chi tiết chat: ${res.body}');
    }
  }

  Future<bool> sendMessage(String threadId, String message) async {
    final res = await http.post(
      Uri.parse('$baseUrl/$threadId/message'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'message': message}),
    );
    return res.statusCode == 200;
  }
} 