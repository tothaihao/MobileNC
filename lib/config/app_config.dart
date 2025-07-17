class AppConfig {
  static const String baseUrl = 'http://localhost:5000/api';

  // Auth
  static const String auth = '$baseUrl/auth';
  static const String avatar = '$baseUrl/avatar';

  // Shop
  static const String products = '$baseUrl/shop/products';
  static const String cart = '$baseUrl/shop/cart';
  static const String order = '$baseUrl/shop/order';
  static const String review = '$baseUrl/shop/review';
  static const String search = '$baseUrl/shop/search';
  static const String address = '$baseUrl/shop/address';

  // Admin
  static const String adminProducts = '$baseUrl/admin/products';
  static const String adminOrders = '$baseUrl/admin/orders';
  static const String adminUsers = '$baseUrl/admin/users';
  static const String adminBlog = '$baseUrl/admin/blog';
  static const String adminVoucher = '$baseUrl/admin/voucher';

  // Common
  static const String feature = '$baseUrl/common/feature';
  static const String payment = '$baseUrl/common/payment';
  static const String supportRequest = '$baseUrl/supportRequest';
  static const String supportChat = '$baseUrl/supportChat';
} 