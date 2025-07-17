import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:do_an_mobile_nc/config.dart';
import 'package:do_an_mobile_nc/models/feature_model.dart';

class BannerService {
  static Future<List<Feature>> getBanners() async {
    final res = await http.get(Uri.parse('${Config.baseUrl}/api/common/feature/get'));
    if (res.statusCode == 200) {
      final decoded = jsonDecode(res.body);
      if (decoded is List) {
        return decoded.map((e) => Feature.fromJson(e)).toList();
      } else if (decoded is Map<String, dynamic>) {
        final list = decoded['data'] ?? decoded['features'] ?? [];
        if (list is List) {
          return list.map((e) => Feature.fromJson(e)).toList();
        }
      }
    }
    return [];
  }

  static Future<bool> addBanner(String imageUrl) async {
    final res = await http.post(
      Uri.parse('${Config.baseUrl}/api/common/feature/add'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'image': imageUrl}),
    );
    return res.statusCode == 200;
  }

  static Future<bool> deleteBanner(String id) async {
    final res = await http.delete(Uri.parse('${Config.baseUrl}/api/common/feature/delete/$id'));
    return res.statusCode == 200;
  }
} 