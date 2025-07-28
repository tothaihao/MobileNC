import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/review_model.dart';

class ReviewService {
  final String baseUrl = AppConfig.review;

  Future<List<Review>> fetchReviews(String productId) async {
    final response = await http.get(Uri.parse('$baseUrl/$productId'));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => Review.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load reviews');
    }
  }

  Future<bool> addReview(Review review) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(review.toJson()),
    );
    return response.statusCode == 201;
  }
} 