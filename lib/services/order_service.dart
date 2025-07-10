import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/order_model.dart';

class OrderService {
  final String baseUrl = AppConfig.order;

  Future<List<Order>> fetchOrders(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/user/$userId'));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => Order.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load orders');
    }
  }

  Future<Order> fetchOrderDetail(String orderId) async {
    final response = await http.get(Uri.parse('$baseUrl/$orderId'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Order.fromJson(data);
    } else {
      throw Exception('Failed to load order detail');
    }
  }

  Future<bool> createOrder(Order order) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(order.toJson()),
    );
    return response.statusCode == 201;
  }
} 