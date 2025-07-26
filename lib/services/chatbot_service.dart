import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:do_an_mobile_nc/models/product_model.dart';
import 'package:do_an_mobile_nc/models/order_model.dart';
import 'package:do_an_mobile_nc/models/voucher_model.dart';
import 'package:do_an_mobile_nc/config/app_config.dart';

class DataService {
  Future<List<Product>> getProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final response = await http.get(
        Uri.parse(AppConfig.products),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Không thể tải sản phẩm: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi khi lấy sản phẩm: $e');
    }
  }

  Future<List<Voucher>> getVouchers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final response = await http.get(
        Uri.parse(AppConfig.adminVoucher),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Voucher.fromJson(json)).toList();
      } else {
        throw Exception('Không thể tải voucher: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi khi lấy voucher: $e');
    }
  }

  Future<List<Order>> getOrderHistory(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        throw Exception('Chưa đăng nhập');
      }
      final response = await http.get(
        Uri.parse('${AppConfig.order}?userId=$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Order.fromJson(json)).toList();
      } else {
        throw Exception('Không thể tải lịch sử đơn hàng: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi khi lấy lịch sử đơn hàng: $e');
    }
  }

  Future<List<Product>> searchProducts(List<String> keywords) async {
    final products = await getProducts();
    return products.where((product) {
      final searchText = '${product.title} ${product.description ?? ''} ${product.category}'.toLowerCase();
      return keywords.any((keyword) => searchText.contains(keyword.toLowerCase()));
    }).toList();
  }

  Future<List<Product>> searchProductsByCategory(String category) async {
    final products = await getProducts();
    if (category.isEmpty) {
      return products; // Trả về tất cả sản phẩm nếu danh mục là "Tất cả"
    }
    return products.where((product) => product.category.toLowerCase() == category.toLowerCase()).toList();
  }
}