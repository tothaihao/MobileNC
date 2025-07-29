import 'dart:io';

class AppConfig {
  // Environment configuration
  static const String _production = 'production';
  static const String _development = 'development';
  
  // Cấu hình environment hiện tại
  static const String currentEnv = _development; // Sử dụng server Render hoặc local server tùy vào platform và mục đích phát triển.
  
  // Tự động detect platform và environment để sử dụng URL phù hợp
  static String get baseUrl {
    String url;
    if (currentEnv == _production) {
      // Production API - Render server
      url = 'https://mobilenc.onrender.com/api';
    } else {
      // Development environment
      if (Platform.isAndroid) {
        // Android Emulator sử dụng 10.0.2.2 để truy cập localhost của host machine
        url = 'http://10.0.2.2:5000/api';
      } else if (Platform.isIOS) {
        // iOS Simulator có thể sử dụng localhost trực tiếp
        url = 'http://localhost:5000/api';
      } else {
        // Web và các platform khác
        url = 'http://localhost:5000/api';
      }
    }
    
    // Debug log
    print('🌐 Using API URL: $url');
    return url;
  }
  
  // Debug info - để developers biết đang dùng environment nào
  static String get environmentInfo {
    return 'Environment: $currentEnv | Platform: ${Platform.operatingSystem} | BaseURL: $baseUrl';
  }

  // Auth
  static String get auth => '$baseUrl/auth';
  static String get avatar => '$baseUrl/avatar';

  // Shop
  static String get products => '$baseUrl/shop/products';
  static String get cart => '$baseUrl/shop/cart';
  static String get order => '$baseUrl/shop/order';
  static String get review => '$baseUrl/shop/review';
  static String get search => '$baseUrl/shop/search';
  static String get address => '$baseUrl/shop/address';

  // Admin
  static String get adminProducts => '$baseUrl/admin/products';
  static String get adminOrders => '$baseUrl/admin/orders';
  static String get adminUsers => '$baseUrl/admin/users';
  static String get adminBlog => '$baseUrl/admin/blog';
  static String get adminVoucher => '$baseUrl/admin/voucher';

  // Common
  static String get feature => '$baseUrl/common/feature';
  static String get payment => '$baseUrl/common/payment';
  static String get supportRequest => '$baseUrl/common/supportRequest';
  static String get supportChat => '$baseUrl/common/supportChat';
}