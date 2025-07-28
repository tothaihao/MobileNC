import 'package:do_an_mobile_nc/models/address_model.dart';
import 'package:do_an_mobile_nc/config.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AddressService {
  static Future<Address?> getAddressById(String id) async {
  final res = await http.get(Uri.parse('${Config.baseUrl}/api/address/$id'));
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