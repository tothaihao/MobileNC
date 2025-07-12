import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart'; // Thêm để dùng kDebugMode
import 'package:do_an_mobile_nc/models/product_model.dart';
import 'package:do_an_mobile_nc/config.dart';

// Hàm loại bỏ dấu tiếng Việt
String removeDiacritics(String str) {
  const Map<String, String> diacriticsMap = {
    'à': 'a', 'á': 'a', 'ạ': 'a', 'ả': 'a', 'ã': 'a', 'â': 'a', 'ầ': 'a', 'ấ': 'a', 'ậ': 'a', 'ẩ': 'a', 'ẫ': 'a',
    'ă': 'a', 'ằ': 'a', 'ắ': 'a', 'ặ': 'a', 'ẳ': 'a', 'ẵ': 'a',
    'è': 'e', 'é': 'e', 'ẹ': 'e', 'ẻ': 'e', 'ẽ': 'e', 'ê': 'e', 'ề': 'e', 'ế': 'e', 'ệ': 'e', 'ể': 'e', 'ễ': 'e',
    'ì': 'i', 'í': 'i', 'ị': 'i', 'ỉ': 'i', 'ĩ': 'i',
    'ò': 'o', 'ó': 'o', 'ọ': 'o', 'ỏ': 'o', 'õ': 'o', 'ô': 'o', 'ồ': 'o', 'ố': 'o', 'ộ': 'o', 'ổ': 'o', 'ỗ': 'o',
    'ơ': 'o', 'ờ': 'o', 'ớ': 'o', 'ợ': 'o', 'ở': 'o', 'ỡ': 'o',
    'ù': 'u', 'ú': 'u', 'ụ': 'u', 'ủ': 'u', 'ũ': 'u', 'ư': 'u', 'ừ': 'u', 'ứ': 'u', 'ự': 'u', 'ử': 'u', 'ữ': 'u',
    'ỳ': 'y', 'ý': 'y', 'ỵ': 'y', 'ỷ': 'y', 'ỹ': 'y',
    'đ': 'd',
    'À': 'A', 'Á': 'A', 'Ạ': 'A', 'Ả': 'A', 'Ã': 'A', 'Â': 'A', 'Ầ': 'A', 'Ấ': 'A', 'Ậ': 'A', 'Ẩ': 'A', 'Ẫ': 'A',
    'Ă': 'A', 'Ằ': 'A', 'Ắ': 'A', 'Ặ': 'A', 'Ẳ': 'A', 'Ẵ': 'A',
    'È': 'E', 'É': 'E', 'Ẹ': 'E', 'Ẻ': 'E', 'Ẽ': 'E', 'Ê': 'E', 'Ề': 'E', 'Ế': 'E', 'Ệ': 'E', 'Ể': 'E', 'Ễ': 'E',
    'Ì': 'I', 'Í': 'I', 'Ị': 'I', 'Ỉ': 'I', 'Ĩ': 'I',
    'Ò': 'O', 'Ó': 'O', 'Ọ': 'O', 'Ỏ': 'O', 'Õ': 'O', 'Ô': 'O', 'Ồ': 'O', 'Ố': 'O', 'Ộ': 'O', 'Ổ': 'O', 'Ỗ': 'O',
    'Ơ': 'O', 'Ờ': 'O', 'Ớ': 'O', 'Ợ': 'O', 'Ở': 'O', 'Ỡ': 'O',
    'Ù': 'U', 'Ú': 'U', 'Ụ': 'U', 'Ủ': 'U', 'Ũ': 'U', 'Ư': 'U', 'Ừ': 'U', 'Ứ': 'U', 'Ự': 'U', 'Ử': 'U', 'Ữ': 'U',
    'Ỳ': 'Y', 'Ý': 'Y', 'Ỵ': 'Y', 'Ỷ': 'Y', 'Ỹ': 'Y',
    'Đ': 'D',
  };

  return str.split('').map((char) => diacriticsMap[char] ?? char).join('');
}

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  List<Product> _allProducts = []; // Lưu tất cả sản phẩm thô
  Product? _selectedProduct;
  bool _isLoading = false;
  String _selectedCategory = 'Tất cả';
  final Map<String, String> _categoryMap = {
    'Tất cả': '',
    'Cà phê': 'caPhe',
    'Trà sữa': 'traSua',
    'Bánh ngọt': 'banhNgot',
    'Đá xay': 'daXay',
    'Sản phẩm bán chạy': 'bestSeller',
  };

  List<Product> get products => _products;
  List<Product> get bestSellerProducts => _allProducts.where((product) => product.category?.toLowerCase() == 'bestseller').toList();
  Product? get selectedProduct => _selectedProduct;
  bool get isLoading => _isLoading;
  String get selectedCategory => _selectedCategory;

  // Getter public cho danh sách category
  List<String> get categoryOptions => _categoryMap.keys.toList();

  Future<void> fetchProducts({String category = 'Tất cả', BuildContext? context}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final query = _categoryMap[category] ?? '';
      final response = await http.get(Uri.parse('${Config.baseUrl}/api/shop/products/get?category=$query'));
      if (kDebugMode) print('API Response: ${response.body}'); // Log toàn bộ response
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null) {
          _allProducts = (data['data'] as List).map((json) => Product.fromJson(json)).toList(); // Lưu tất cả sản phẩm
          _products = _allProducts.where((product) {
            final productCategory = product.category?.toLowerCase() ?? '';
            final targetCategory = _categoryMap[category]?.toLowerCase() ?? '';
            if (kDebugMode) print('Filtering: $productCategory for category $category (target: $targetCategory)');
            if (category == 'Tất cả') {
              return productCategory != 'bestseller'; // Loại bỏ "bestSeller" khi là "Tất cả"
            } else if (category == 'Sản phẩm bán chạy') {
              return productCategory == 'bestseller';
            }
            return productCategory == targetCategory || (query.isEmpty && category == 'Tất cả');
          }).toList();
        } else {
          _allProducts = [];
          _products = [];
        }
      } else {
        throw Exception('Failed to load products, status: ${response.statusCode}');
      }
    } catch (e) {
      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchProductDetails(String productId, {BuildContext? context}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse('${Config.baseUrl}/api/shop/products/get/$productId'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null) {
          _selectedProduct = Product.fromJson(data['data']);
        } else {
          _selectedProduct = null;
        }
      } else {
        throw Exception('Failed to load product details');
      }
    } catch (e) {
      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  void updateCategory(String category, {BuildContext? context}) {
    _selectedCategory = category;
    if (kDebugMode) print('Updating category to: $category');
    fetchProducts(category: category, context: context);
  }

  Future<void> searchProducts(String query, {BuildContext? context}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final normalizedQuery = query.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '');
      final queryWithoutDiacritics = removeDiacritics(query.toLowerCase());
      if (kDebugMode) print('Searching with query: "$query", normalized: "$normalizedQuery", without diacritics: "$queryWithoutDiacritics"');

      // Lọc cục bộ từ _allProducts và loại bỏ "bestSeller"
      _products = _allProducts.where((product) {
        final title = product.title.toLowerCase();
        final titleWithoutDiacritics = removeDiacritics(title);
        final productCategory = product.category?.toLowerCase() ?? '';
        if (kDebugMode) print('Checking product: ${product.title}, title: "$title", without diacritics: "$titleWithoutDiacritics", category: "$productCategory"');
        return (title.contains(normalizedQuery) || titleWithoutDiacritics.contains(queryWithoutDiacritics)) && productCategory != 'bestseller';
      }).toList();
    } catch (e) {
      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }

    _isLoading = false;
    notifyListeners();
  }
}