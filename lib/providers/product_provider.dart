import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  Product? _selectedProduct;
  bool _isLoading = false;
  String? _error;

  List<Product> get products => _products;
  Product? get selectedProduct => _selectedProduct;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final ProductService _productService = ProductService();

  // Mockup data
  List<Product> get mockProducts => [
    Product(
      id: '1',
      image: 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=400&q=80',
      title: 'Cà phê sữa đá',
      description: 'Cà phê truyền thống Việt Nam',
      category: 'Cà phê',
      size: 'M',
      price: 29000,
      salePrice: 25000,
      totalStock: 100,
      averageReview: 4.5,
      stockStatus: 'Còn hàng',
    ),
    Product(
      id: '2',
      image: 'https://images.unsplash.com/photo-1511920170033-f8396924c348?auto=format&fit=crop&w=400&q=80',
      title: 'Latte đá',
      description: 'Latte thơm ngon',
      category: 'Cà phê',
      size: 'L',
      price: 35000,
      salePrice: 32000,
      totalStock: 80,
      averageReview: 4.7,
      stockStatus: 'Còn hàng',
    ),
    Product(
      id: '3',
      image: 'https://images.unsplash.com/photo-1464983953574-0892a716854b?auto=format&fit=crop&w=400&q=80',
      title: 'Trà sữa matcha',
      description: 'Trà sữa vị matcha',
      category: 'Trà sữa',
      size: 'M',
      price: 32000,
      salePrice: 29000,
      totalStock: 60,
      averageReview: 4.3,
      stockStatus: 'Còn hàng',
    ),
    Product(
      id: '4',
      image: 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=400&q=80',
      title: 'Cappuccino',
      description: 'Cappuccino Ý',
      category: 'Cà phê',
      size: 'M',
      price: 39000,
      salePrice: 35000,
      totalStock: 50,
      averageReview: 4.8,
      stockStatus: 'Còn hàng',
    ),
  ];

  Future<void> fetchProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _products = await _productService.fetchProducts();
      if (_products.isEmpty) {
        _error = 'Không có sản phẩm nào.';
        _products = mockProducts;
      }
    } catch (e) {
      _error = e.toString();
      _products = mockProducts;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchProductDetail(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _selectedProduct = await _productService.fetchProductDetail(id);
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }
} 