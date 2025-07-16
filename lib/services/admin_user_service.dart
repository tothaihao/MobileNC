import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';

class AdminUserService {
  final String baseUrl = '${Config.baseUrl}/api/admin/users';

  Future<List<Map<String, dynamic>>> fetchUsers() async {
    final res = await http.get(Uri.parse(baseUrl));
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      return List<Map<String, dynamic>>.from(data['data']);
    } else {
      throw Exception('Lỗi lấy danh sách user: ${res.body}');
    }
  }

  Future<bool> deleteUser(String id) async {
    final res = await http.delete(Uri.parse('$baseUrl/$id'));
    return res.statusCode == 200;
  }
} 