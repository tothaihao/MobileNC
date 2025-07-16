import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';

class AdminVoucherService {
  final String baseUrl = '${Config.baseUrl}/api/admin/voucher';

  Future<List<Map<String, dynamic>>> fetchVouchers() async {
    final res = await http.get(Uri.parse(baseUrl));
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      return List<Map<String, dynamic>>.from(data['data']);
    } else {
      throw Exception('Lỗi lấy danh sách voucher: ${res.body}');
    }
  }

  Future<bool> addVoucher(Map<String, dynamic> voucher) async {
    final res = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(voucher),
    );
    return res.statusCode == 201;
  }

  Future<bool> updateVoucher(String id, Map<String, dynamic> voucher) async {
    final res = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(voucher),
    );
    return res.statusCode == 200;
  }

  Future<bool> deleteVoucher(String id) async {
    final res = await http.delete(Uri.parse('$baseUrl/$id'));
    return res.statusCode == 200;
  }
} 