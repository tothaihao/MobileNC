import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';

class AdminSupportRequestService {
  final String baseUrl = '${Config.baseUrl}/api/admin/support-request';

  Future<List<Map<String, dynamic>>> fetchRequests() async {
    final res = await http.get(Uri.parse(baseUrl));
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      return List<Map<String, dynamic>>.from(data['data']);
    } else {
      throw Exception('Lỗi lấy danh sách support request: ${res.body}');
    }
  }

  Future<Map<String, dynamic>> fetchRequestDetail(String id) async {
    final res = await http.get(Uri.parse('$baseUrl/$id'));
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      return data['data'];
    } else {
      throw Exception('Lỗi lấy chi tiết support request: ${res.body}');
    }
  }

  Future<bool> updateRequestStatus(String id, String status) async {
    final res = await http.put(
      Uri.parse('$baseUrl/$id/status'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'status': status}),
    );
    return res.statusCode == 200;
  }
} 