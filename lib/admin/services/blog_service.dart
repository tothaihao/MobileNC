import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:do_an_mobile_nc/config.dart';
import 'package:do_an_mobile_nc/models/blog_model.dart';

class BlogService {
  static Future<List<Blog>> getAllBlogs() async {
    final res = await http.get(Uri.parse('${Config.baseUrl}/api/admin/blog'));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      List blogs = data is List ? data : data['blogs'] ?? data['data'] ?? [];
      return blogs.map((e) => Blog.fromJson(e)).toList();
    } else {
      throw Exception('Lỗi tải blog: ${res.body}');
    }
  }

  static Future<bool> createBlog(Blog blog) async {
    final res = await http.post(
      Uri.parse('${Config.baseUrl}/api/admin/blog'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(blog.toJson()),
    );
    return res.statusCode == 201 || res.statusCode == 200;
  }

  static Future<bool> updateBlog(String id, Blog blog) async {
    final res = await http.put(
      Uri.parse('${Config.baseUrl}/api/admin/blog/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(blog.toJson()),
    );
    return res.statusCode == 200;
  }

  static Future<bool> deleteBlog(String id) async {
    final res = await http.delete(
      Uri.parse('${Config.baseUrl}/api/admin/blog/$id'),
    );
    return res.statusCode == 200;
  }

  static Future<String> uploadImage(File imageFile) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${Config.baseUrl}/api/admin/blog/upload-image'),
    );
    request.files.add(await http.MultipartFile.fromPath('my_file', imageFile.path));
    final response = await request.send();

    if (response.statusCode == 200) {
      final resData = await response.stream.bytesToString();
      final decoded = jsonDecode(resData);
      return decoded['url'] ?? decoded['secure_url'];
    } else {
      throw Exception('Lỗi upload ảnh blog');
    }
  }
}
