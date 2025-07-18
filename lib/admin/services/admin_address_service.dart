import '../models/admin_address_model.dart';
import '../../config/app_config.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AdminAddressService {
  static Future<Address?> getAddressById(String id) async {
  final res = await http.get(Uri.parse('${AppConfig.address}/$id'));
  if (res.statusCode == 200) {
    final data = jsonDecode(res.body);
    print('DEBUG: API address raw response: $data');

    if (data is Map<String, dynamic>) {
      if (data.containsKey('data')) return Address.fromJson(data['data']);
      if (data.containsKey('address')) return Address.fromJson(data['address']);
      return Address.fromJson(data); // fallback
    }
  }
  return null;
}

} 