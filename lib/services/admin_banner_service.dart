import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';
import 'dart:io';

class AdminBannerService {
  final String baseUrl = '${Config.baseUrl}/api/admin/banner';

  Future<List<Map<String, dynamic>>> fetchBanners() async {
    final res = await http.get(Uri.parse(baseUrl));
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      return List<Map<String, dynamic>>.from(data['data']);
    } else {
      throw Exception('Lỗi lấy danh sách banner: ${res.body}');
    }
  }

  Future<bool> addBanner(Map<String, dynamic> banner, File? imageFile) async {
    var request = http.MultipartRequest('POST', Uri.parse(baseUrl));
    banner.forEach((key, value) {
      request.fields[key] = value.toString();
    });
    if (imageFile != null) {
      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
    }
    final streamedResponse = await request.send();
    final res = await http.Response.fromStream(streamedResponse);
    return res.statusCode == 201;
  }

  Future<bool> updateBanner(String id, Map<String, dynamic> banner, File? imageFile) async {
    var request = http.MultipartRequest('PUT', Uri.parse('$baseUrl/$id'));
    banner.forEach((key, value) {
      request.fields[key] = value.toString();
    });
    if (imageFile != null) {
      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
    }
    final streamedResponse = await request.send();
    final res = await http.Response.fromStream(streamedResponse);
    return res.statusCode == 200;
  }

  Future<bool> deleteBanner(String id) async {
    final res = await http.delete(Uri.parse('$baseUrl/$id'));
    return res.statusCode == 200;
  }
} 