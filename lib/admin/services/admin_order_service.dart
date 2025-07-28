import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/app_config.dart';
import '../models/admin_order_model.dart';

class AdminOrderService {
  /// Lấy tất cả đơn hàng
  static Future<List<Order>> getAllOrders() async {
    try {
      print('DEBUG: Calling API: ${AppConfig.adminOrders}/get');
      final res = await http.get(Uri.parse('${AppConfig.adminOrders}/get'));

      print('DEBUG: Response status: ${res.statusCode}');
      print('DEBUG: Response body: ${res.body}');

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        print('Order list response: $decoded');

        List<dynamic> ordersList = [];

        // Xử lý nhiều định dạng response từ backend
        if (decoded is Map<String, dynamic>) {
          // Case 1: { success: true, data: [...] } ✅ BACKEND FORMAT
          if (decoded.containsKey('data') && decoded['data'] is List) {
            ordersList = decoded['data'] as List;
          }
          // Case 2: { success: true, orders: [...] }
          else if (decoded.containsKey('orders') && decoded['orders'] is List) {
            ordersList = decoded['orders'] as List;
          }
          // Case 3: { success: true, results: [...] }
          else if (decoded.containsKey('results') && decoded['results'] is List) {
            ordersList = decoded['results'] as List;
          }
          // Case 4: Response có order đơn lẻ
          else if (decoded.containsKey('_id') || decoded.containsKey('id')) {
            ordersList = [decoded];
          }
          // Case 5: Response trực tiếp là object thành công
          else if (decoded['success'] == true) {
            print('DEBUG: Success response but no data array found');
            return []; // Return empty list instead of throwing error
          }
        }
        // Case 6: Response là mảng đơn hàng trực tiếp
        else if (decoded is List) {
          ordersList = decoded;
        }

        print('DEBUG: Found ${ordersList.length} orders in response');
        
        // Parse orders với error handling tốt hơn
        List<Order> orders = [];
        for (var orderData in ordersList) {
          try {
            if (orderData is Map<String, dynamic>) {
              // Validate required fields
              if (orderData.containsKey('_id') || orderData.containsKey('id')) {
                final order = Order.fromJson(orderData);
                orders.add(order);
                print('✅ Successfully parsed order: ${order.id}');
              } else {
                print('⚠️ Skipping invalid order data (missing ID): $orderData');
              }
            }
          } catch (e) {
            print('❌ Error parsing order: $e');
            print('❌ Order data: $orderData');
            // Continue with other orders instead of failing completely
          }
        }

        print('DEBUG: Successfully parsed ${orders.length} valid orders');
        return orders;
      } else {
        throw Exception('API Error: ${res.statusCode} - ${res.body}');
      }
    } catch (e) {
      print('❌ Error in getAllOrders: $e');
      // Return empty list instead of throwing error để không crash app
      return [];
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
