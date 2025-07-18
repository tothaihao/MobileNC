import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/app_config.dart';
import '../models/admin_order_model.dart';

class AdminOrderService {
  /// Lấy tất cả đơn hàng
  static Future<List<Order>> getAllOrders() async {
    final res = await http.get(Uri.parse('${AppConfig.adminOrders}'));

    if (res.statusCode == 200) {
      final decoded = jsonDecode(res.body);
      print('Order list response: $decoded');

      // Nếu backend trả về { data: [...] }
      if (decoded is Map<String, dynamic> && decoded['data'] is List) {
        final list = decoded['data'] as List;
        for (var e in list) {
          print('Order element: $e, type: ${e.runtimeType}');
        }
        return list
            .where((e) => e is Map<String, dynamic> && e.containsKey('_id'))
            .map((e) => Order.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      // Nếu backend trả về mảng đơn hàng trực tiếp
      if (decoded is List) {
        for (var e in decoded) {
          print('Order element: $e, type: ${e.runtimeType}');
        }
        return decoded
            .where((e) => e is Map<String, dynamic> && e.containsKey('_id'))
            .map((e) => Order.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      // Nếu backend trả về object đơn lẻ (không phải List)
      if (decoded is Map<String, dynamic> && decoded.containsKey('_id')) {
        return [Order.fromJson(decoded)];
      }

      throw Exception('Phản hồi API không hợp lệ: $decoded');
    } else {
      throw Exception('Lỗi khi lấy danh sách đơn hàng: ${res.body}');
    }
  }

  /// Lấy chi tiết đơn hàng
  static Future<Order> getOrderDetails(String id) async {
    final res = await http.get(Uri.parse('${AppConfig.adminOrders}/$id'));

    if (res.statusCode == 200) {
      final decoded = jsonDecode(res.body);

      // Nếu trả về trực tiếp là object đơn hàng
      if (decoded is Map<String, dynamic> && decoded.containsKey('cartItems')) {
        return Order.fromJson(decoded);
      }

      // Nếu trả về trong key 'data' hoặc 'order'
      final orderData = decoded['data'] ?? decoded['order'];
      if (orderData is Map<String, dynamic>) {
        return Order.fromJson(orderData);
      }

      throw Exception('Phản hồi API không hợp lệ: $decoded');
    } else {
      throw Exception('Lỗi khi lấy chi tiết đơn hàng: ${res.body}');
    }
  }

  /// Cập nhật trạng thái đơn hàng
  static Future<bool> updateOrderStatus(String id, String status) async {
    final res = await http.put(
      Uri.parse('${AppConfig.adminOrders}/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'status': status}),
    );

    return res.statusCode == 200;
  }
}
