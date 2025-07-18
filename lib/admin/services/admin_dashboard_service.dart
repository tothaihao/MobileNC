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
}
