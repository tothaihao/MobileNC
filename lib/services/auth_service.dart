import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class AuthService {
  final String baseUrl = AppConfig.baseUrl;

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );
      final data = json.decode(response.body);
      return data;
    } catch (e) {
      return {
        'success': false,
        'message': 'Có lỗi xảy ra khi đăng nhập: ${e.toString()}'
      };
    }
  }

  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userName': name,
          'email': email,
          'password': password,
        }),
      );
      final data = json.decode(response.body);
      return data;
    } catch (e) {
      return {
        'success': false,
        'message': 'Có lỗi xảy ra khi đăng ký:  [${e.toString()}'
      };
    }
  }

  Future<Map<String, dynamic>> logout() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/logout'),
        headers: {'Content-Type': 'application/json'},
      );
      final data = json.decode(response.body);
      return data;
    } catch (e) {
      return {
        'success': false,
        'message': 'Có lỗi xảy ra khi đăng xuất: ${e.toString()}'
      };
    }
  }

  // Optional: Lấy thông tin user hiện tại nếu có token
  Future<Map<String, dynamic>> getCurrentUser(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      final data = json.decode(response.body);
      return data;
    } catch (e) {
      return {
        'success': false,
        'message': 'Không thể lấy thông tin user: ${e.toString()}'
      };
    }
  }
} 