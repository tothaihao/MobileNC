import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/voucher_model.dart';

class VoucherService {
  final String baseUrl = AppConfig.adminVoucher;

  Future<List<Voucher>> fetchVouchers() async {
    final response = await http.get(Uri.parse('$baseUrl/available'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        final List voucherList = data['data'];
        return voucherList.map((e) => Voucher.fromJson(e)).toList();
      }
    }
    throw Exception('Failed to load vouchers');
  }

  Future<Voucher?> checkVoucher(String code) async {
    final response = await http.get(Uri.parse('$baseUrl/check/$code'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true && data['data'] != null) {
        return Voucher.fromJson(data['data']);
      }
    }
    return null;
  }

  Future<Map<String, dynamic>> applyVoucher(String code, int totalAmount) async {
    final response = await http.post(
      Uri.parse('$baseUrl/apply'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'code': code,
        'totalAmount': totalAmount,
      }),
    );
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to apply voucher');
    }
  }
} 