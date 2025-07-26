import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class PayPalService {
  static Future<String?> createPayPalPayment({
    required double amount,
    required String currency,
    required String description,
  }) async {
    final url = '${AppConfig.payment}/paypal/create';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'amount': amount,
          'currency': currency,
          'description': description,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['approvalUrl'];
        }
      }
      return null;
    } catch (e) {
      print('PayPal service error: $e');
      return null;
    }
  }

  static Future<bool> capturePayPalPayment({
    required String paymentId,
    required String payerId,
  }) async {
    final url = '${AppConfig.payment}/paypal/capture';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'paymentId': paymentId,
          'payerId': payerId,
        }),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('PayPal capture error: $e');
      return false;
    }
  }
}
