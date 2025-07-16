import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';

class AdminBlogService {
  final String baseUrl = '${Config.baseUrl}/api/admin/blog';

  Future<List<Map<String, dynamic>>> fetchBlogs() async {
    final res = await http.get(Uri.parse(baseUrl));
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      return List<Map<String, dynamic>>.from(data['data']);
    } else {
      throw Exception('Lỗi lấy danh sách blog: ${res.body}');
    }
  }

  Future<bool> addBlog(Map<String, dynamic> blog) async {
    final res = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(blog),
    );
    return res.statusCode == 201;
  }

  Future<bool> updateBlog(String id, Map<String, dynamic> blog) async {
    final res = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(blog),
    );
    return res.statusCode == 200;
  }

  Future<bool> deleteBlog(String id) async {
    final res = await http.delete(Uri.parse('$baseUrl/$id'));
    return res.statusCode == 200;
  }
} 