import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/cart_model.dart';

class CartService {
  final String baseUrl = AppConfig.cart;

  Future<Cart> fetchCart(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/$userId'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // Sửa ở đây: lấy data['data'] thay vì data
      return Cart.fromJson(data['data']);
    } else {
      throw Exception('Failed to load cart');
    }
  }

  Future<bool> addToCart(String userId, String productId, int quantity) async {
    final response = await http.post(
      Uri.parse('$baseUrl/add'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'userId': userId,
        'productId': productId,
        'quantity': quantity,
      }),
    );
    return response.statusCode == 200;
  }

  Future<bool> removeFromCart(String userId, String productId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/delete/$userId/$productId'),
      headers: {'Content-Type': 'application/json'},
    );
    return response.statusCode == 200;
  }

  Future<bool> updateCart(String userId, String productId, int quantity) async {
    final response = await http.put(
      Uri.parse('$baseUrl/update'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'userId': userId,
        'productId': productId,
        'quantity': quantity,
      }),
    );
    return response.statusCode == 200;
  }
} 