import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:do_an_mobile_nc/models/product_model.dart';
import 'package:do_an_mobile_nc/Screen/product_detail.dart';
import 'package:do_an_mobile_nc/config.dart';
import 'dart:async';
import 'dart:developer' as developer;
import 'package:diacritic/diacritic.dart' as diacritic; // Thêm package diacritic

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Product> products = [];
  bool isLoading = false;
  Timer? _debounce;

  // Chuẩn hóa chuỗi, loại bỏ dấu
  String _normalize(String input) {
    return diacritic.removeDiacritics(input.toLowerCase());
  }

  Future<void> fetchProducts(String query) async {
    setState(() {
      isLoading = true;
    });
    try {
      final normalizedQuery = _normalize(query); // Chuẩn hóa query
      final encodedQuery = Uri.encodeComponent(query); // Mã hóa query để tránh lỗi ký tự đặc biệt
      final response = await http.get(Uri.parse('${Config.baseUrl}/api/shop/products/get?title=$encodedQuery'));
      developer.log('API Request: ${Config.baseUrl}/api/shop/products/get?title=$encodedQuery', name: 'SearchScreen');
      developer.log('API Response: ${response.body}', name: 'SearchScreen');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null) {
          setState(() {
            products = (data['data'] as List)
                .map((json) => Product.fromJson(json))
                .where((product) {
                  final category = product.category?.toLowerCase() ?? '';
                  final normalizedTitle = _normalize(product.title ?? '');
                  final titleMatch = normalizedTitle.contains(normalizedQuery);
                  developer.log('Product: ${product.title}, Normalized Title: $normalizedTitle, Category: $category, Title Match: $titleMatch', name: 'SearchScreen');
                  return category != 'bestseller' && titleMatch;
                })
                .toList();
            isLoading = false;
          });
        } else {
          setState(() {
            products = [];
            isLoading = false;
          });
          developer.log('No data in API response', name: 'SearchScreen');
        }
      } else {
        throw Exception('Failed to load products, status: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      developer.log('Error fetching products: $e', name: 'SearchScreen');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  void initState() {
    super.initState();
    fetchProducts('');
    _searchController.addListener(() {
      if (_debounce?.isActive ?? false) _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 500), () {
        final query = _searchController.text; // Sử dụng text trực tiếp từ Unikey
        fetchProducts(query);
      });
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Coffee shop', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart, color: Colors.brown),
            onPressed: () {
              // Điều hướng đến màn hình giỏ hàng
              Navigator.pushNamed(context, '/cart'); // Thay '/cart' bằng route của CartScreen
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm sản phẩm',
                prefixIcon: Icon(Icons.search, color: Colors.brown),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              // Lưu ý: Bật Unikey trong bàn phím hệ thống để nhập tiếng Việt có dấu
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.75,
                      children: products.map((product) {
                        return ProductCard(product: product);
                      }).toList(),
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Text('<1, 2, 3>', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProductDetailPage(productId: product.id)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.brown.shade100),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              product.image,
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Icon(Icons.error),
            ),
            SizedBox(height: 8),
            Text(
              product.title,
              style: TextStyle(fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '${product.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} đ',
              style: TextStyle(color: Colors.green),
            ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.yellow, size: 16),
                    Text(
                      '${product.averageReview}',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.favorite_border, color: Colors.grey),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Đã thêm ${product.title} vào yêu thích!')),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.add_shopping_cart, color: Colors.brown),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Đã thêm ${product.title} vào giỏ hàng!')),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}