import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';

class AdminOrderService {
  final String baseUrl = '${Config.baseUrl}/api/admin/orders';

  Future<List<Map<String, dynamic>>> fetchOrders() async {
    final res = await http.get(Uri.parse(baseUrl));
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      return List<Map<String, dynamic>>.from(data['data']);
    } else {
      throw Exception('Lỗi lấy danh sách đơn hàng: ${res.body}');
    }
  }

  Future<Map<String, dynamic>> fetchOrderDetail(String id) async {
    final res = await http.get(Uri.parse('$baseUrl/$id'));
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      return data['data'];
    } else {
      throw Exception('Lỗi lấy chi tiết đơn hàng: ${res.body}');
    }
  }

  Future<bool> updateOrderStatus(String id, String status) async {
    final res = await http.put(
      Uri.parse('$baseUrl/$id/status'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'status': status}),
    );
    return res.statusCode == 200;
  }
} 