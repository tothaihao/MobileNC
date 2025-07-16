import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';

class AdminProductService {
  final String baseUrl = '${Config.baseUrl}/api/admin/products';

  Future<List<Map<String, dynamic>>> fetchProducts() async {
    final res = await http.get(Uri.parse(baseUrl));
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      return List<Map<String, dynamic>>.from(data['data']);
    } else {
      throw Exception('Lỗi lấy danh sách sản phẩm: ${res.body}');
    }
  }

  Future<bool> addProduct(Map<String, dynamic> product) async {
    final res = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(product),
    );
    return res.statusCode == 201;
  }

  Future<bool> updateProduct(String id, Map<String, dynamic> product) async {
    final res = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(product),
    );
    return res.statusCode == 200;
  }

  Future<bool> deleteProduct(String id) async {
    final res = await http.delete(Uri.parse('$baseUrl/$id'));
    return res.statusCode == 200;
  }
} 