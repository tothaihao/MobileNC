import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/voucher_model.dart';

class VoucherService {
  final String baseUrl = AppConfig.adminVoucher;

  Future<List<Voucher>> fetchVouchers() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => Voucher.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load vouchers');
    }
  }

  Future<Voucher?> checkVoucher(String code) async {
    final response = await http.get(Uri.parse('$baseUrl/check/$code'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Voucher.fromJson(data);
    } else {
      return null;
    }
  }
} 