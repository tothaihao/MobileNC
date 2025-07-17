import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:do_an_mobile_nc/config.dart';

class DashboardService {
  static Future<int> getOrderCount() async {
    final res = await http.get(Uri.parse('${Config.baseUrl}/api/admin/orders/total-orders'));
    print('OrderCount response: ${res.body}');
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data['totalOrders'] ?? 0;
    }
    return 0;
  }

  static Future<Map<String, int>> getUserAndAdminCount() async {
    final res = await http.get(Uri.parse('${Config.baseUrl}/api/admin/users/'));
    if (res.statusCode == 200) {
      final List users = jsonDecode(res.body);
      int userCount = users.where((u) => u['role'] == 'user').length;
      int adminCount = users.where((u) => u['role'] == 'admin').length;
      return {'user': userCount, 'admin': adminCount};
    }
    return {'user': 0, 'admin': 0};
  }

  static Future<int> getTotalRevenue() async {
    final res = await http.get(Uri.parse('${Config.baseUrl}/api/admin/orders/total-revenue'));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data['totalRevenue'] ?? 0;
    }
    return 0;
  }
}
