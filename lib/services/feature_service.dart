import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/feature_banner_model.dart';

class FeatureService {
  final String baseUrl = AppConfig.feature;

  Future<List<FeatureBanner>> fetchBanners() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true && data['data'] is List) {
        return (data['data'] as List).map((e) => FeatureBanner.fromJson(e)).toList();
      } else {
        throw Exception('Invalid response format');
      }
    } else {
      throw Exception('Failed to load banners');
    }
  }
} 