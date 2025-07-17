import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:do_an_mobile_nc/config.dart';
import 'package:do_an_mobile_nc/models/product_model.dart';

class ProductService {
  // Lấy danh sách tất cả sản phẩm
  static Future<List<Product>> getAllProducts() async {
    final res = await http.get(Uri.parse('${Config.baseUrl}/api/admin/products/get'));
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
      Uri.parse('${Config.baseUrl}/api/admin/products/add'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(product.toJson()),
    );
    return res.statusCode == 200 || res.statusCode == 201;
  }

  // Cập nhật sản phẩm
  static Future<bool> updateProduct(String id, Product product) async {
    final res = await http.put(
      Uri.parse('${Config.baseUrl}/api/admin/products/edit/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(product.toJson()),
    );
    return res.statusCode == 200;
  }

  // Xóa sản phẩm
  static Future<bool> deleteProduct(String id) async {
    final res = await http.delete(Uri.parse('${Config.baseUrl}/api/admin/products/delete/$id'));
    return res.statusCode == 200;
  }

  // Upload hình ảnh sản phẩm
  static Future<String> uploadImage(File imageFile) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${Config.baseUrl}/api/admin/products/upload-image'),
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
