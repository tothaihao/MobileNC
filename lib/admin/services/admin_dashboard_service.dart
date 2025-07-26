import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/app_config.dart';

class AdminDashboardService {
  static Future<int> getOrderCount() async {
    final res = await http.get(Uri.parse('${AppConfig.adminOrders}/count'));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data['count'] ?? 0;
    }
    return 0;
  }

  static Future<int> getUserCount() async {
    final res = await http.get(Uri.parse('${AppConfig.adminUsers}/count?role=user'));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data['count'] ?? 0;
    }
    return 0;
  }

  static Future<int> getAdminCount() async {
    final res = await http.get(Uri.parse('${AppConfig.adminUsers}/count?role=admin'));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data['count'] ?? 0;
    }
    return 0;
  }

  static Future<int> getTotalRevenue() async {
    final res = await http.get(Uri.parse('${AppConfig.adminOrders}/total-revenue'));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data['totalRevenue'] ?? 0;
    }
    return 0;
  }

  static Future<Map<String, dynamic>> getDashboardStats() async {
    final res = await http.get(Uri.parse('${AppConfig.adminOrders}/dashboard-stats'));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data is Map<String, dynamic> ? data : {};
    }
    // Return mock data if API not available
    return {
      'todayOrders': 12,
      'pendingOrders': 5,
      'completedOrders': 45,
      'todayRevenue': 2500000,
      'recentOrders': [
        {'id': '001', 'customer': 'Nguyễn Văn A', 'amount': 125000, 'status': 'completed'},
        {'id': '002', 'customer': 'Trần Thị B', 'amount': 89000, 'status': 'pending'},
        {'id': '003', 'customer': 'Lê Văn C', 'amount': 156000, 'status': 'processing'},
        {'id': '004', 'customer': 'Phạm Thị D', 'amount': 97000, 'status': 'completed'},
        {'id': '005', 'customer': 'Hoàng Văn E', 'amount': 234000, 'status': 'pending'},
      ],
      'topProducts': [
        {'name': 'Americano', 'sold': 145, 'revenue': 3625000},
        {'name': 'Cappuccino', 'sold': 98, 'revenue': 2940000},
        {'name': 'Latte', 'sold': 87, 'revenue': 2871000},
        {'name': 'Espresso', 'sold': 76, 'revenue': 1824000},
        {'name': 'Mocha', 'sold': 65, 'revenue': 2275000},
      ],
    };
  }
}
