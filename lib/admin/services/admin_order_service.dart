import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/app_config.dart';
import '../models/admin_order_model.dart';

class AdminOrderService {
  /// Lấy tất cả đơn hàng
  static Future<List<Order>> getAllOrders() async {
    print('DEBUG: Calling API: ${AppConfig.adminOrders}/get');
    final res = await http.get(Uri.parse('${AppConfig.adminOrders}/get'));

    print('DEBUG: Response status: ${res.statusCode}');
    print('DEBUG: Response body: ${res.body}');

    if (res.statusCode == 200) {
      final decoded = jsonDecode(res.body);
      print('Order list response: $decoded');

      // Nếu backend trả về { data: [...] }
      if (decoded is Map<String, dynamic> && decoded['data'] is List) {
        final list = decoded['data'] as List;
        print('DEBUG: Found ${list.length} orders in data array');
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
        print('DEBUG: Found ${decoded.length} orders in direct array');
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
      throw Exception('Lỗi khi lấy danh sách đơn hàng: ${res.statusCode} - ${res.body}');
    }
  }

  /// Lấy chi tiết đơn hàng
  static Future<Order> getOrderDetails(String id) async {
    print('DEBUG: Calling API: ${AppConfig.adminOrders}/details/$id');
    final res = await http.get(Uri.parse('${AppConfig.adminOrders}/details/$id'));

    print('DEBUG: Response status: ${res.statusCode}');
    print('DEBUG: Response body: ${res.body}');

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
      throw Exception('Lỗi khi lấy chi tiết đơn hàng: ${res.statusCode} - ${res.body}');
    }
  }

  /// Cập nhật trạng thái đơn hàng
  static Future<bool> updateOrderStatus(String id, String status) async {
    print('DEBUG: Calling API: ${AppConfig.adminOrders}/update/$id');
    print('DEBUG: Status to update: $status');
    
    final res = await http.put(
      Uri.parse('${AppConfig.adminOrders}/update/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'status': status}),
    );

    print('DEBUG: Update response status: ${res.statusCode}');
    print('DEBUG: Update response body: ${res.body}');

    return res.statusCode == 200;
  }
}