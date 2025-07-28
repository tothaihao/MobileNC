import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:do_an_mobile_nc/config.dart';

class DashboardService {
  static Future<int> getOrderCount() async {
    final res = await http.get(Uri.parse('${Config.baseUrl}/api/admin/orders/count'));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data['count'] ?? 0;
    }
    return 0;
  }

  static Future<int> getUserCount() async {
    final res = await http.get(Uri.parse('${Config.baseUrl}/api/admin/users/count?role=user'));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data['count'] ?? 0;
    }
    return 0;
  }

  static Future<int> getAdminCount() async {
    final res = await http.get(Uri.parse('${Config.baseUrl}/api/admin/users/count?role=admin'));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data['count'] ?? 0;
    }
    return 0;
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
