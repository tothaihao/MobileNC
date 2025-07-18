import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../config/app_config.dart';
import '../models/admin_product_model.dart';

class AdminProductService {
  // Lấy danh sách tất cả sản phẩm
  static Future<List<Product>> getAllProducts() async {
    final res = await http.get(Uri.parse('${AppConfig.adminProducts}'));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      List products = data is List ? data : data['products'] ?? data['data'] ?? [];
      return products.map((e) => Product.fromJson(e)).toList();
    } else {
      throw Exception('Không thể tải sản phẩm: ${res.body}');
    }
  }

  // Thêm sản phẩm mới
  static Future<bool> addProduct(Product product) async {
    final res = await http.post(
      Uri.parse('${AppConfig.adminProducts}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(product.toJson()),
    );
    return res.statusCode == 200 || res.statusCode == 201;
  }

  // Cập nhật sản phẩm
  static Future<bool> updateProduct(String id, Product product) async {
    final res = await http.put(
      Uri.parse('${AppConfig.adminProducts}/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(product.toJson()),
    );
    return res.statusCode == 200;
  }

  // Xóa sản phẩm
  static Future<bool> deleteProduct(String id) async {
    final res = await http.delete(Uri.parse('${AppConfig.adminProducts}/$id'));
    return res.statusCode == 200;
  }

  // Upload hình ảnh sản phẩm
  static Future<String> uploadImage(File imageFile) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${AppConfig.adminProducts}/upload-image'),
    );
    request.files.add(await http.MultipartFile.fromPath('my_file', imageFile.path));
    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final decoded = jsonDecode(responseData);
      return decoded['url'] ?? decoded['secure_url'];
    } else {
      throw Exception('Lỗi upload hình: ${response.statusCode}');
    }
  }
}
