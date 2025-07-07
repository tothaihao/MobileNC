import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:do_an_mobile_nc/models/product_model.dart';
import 'package:do_an_mobile_nc/theme/colors.dart'; // Import file color.dart

class ProductDetailPage extends StatefulWidget {
  final String? productId;

  ProductDetailPage({this.productId});

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  Product? product;
  bool isLoading = true;
  double userRating = 3.0;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.productId != null) {
      fetchProductDetails();
    }
  }

  Future<void> fetchProductDetails() async {
    try {
      final response = await http.get(Uri.parse('http://10.21.5.195:5000/api/shop/products/get/${widget.productId}'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          product = Product.fromJson(data['data']);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load product details');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold, // Thay Colors.white
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.white), // Thay màu mặc định
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Chi tiết sản phẩm', style: TextStyle(color: AppColors.white)), // Thay màu mặc định
        backgroundColor: AppColors.primary, // Thay Colors.brown[300]
        foregroundColor: AppColors.white,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.primary)) // Thay màu mặc định
          : product == null
              ? Center(child: Text('Product not found', style: TextStyle(color: AppColors.textSecondary)))
              : Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 5,
                      color: AppColors.white, // Thay màu mặc định
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  product!.image,
                                  width: 200,
                                  height: 200,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Icon(Icons.error, color: AppColors.textSecondary),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              product!.title,
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              product!.description ?? 'No description available',
                              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${product!.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} đ',
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                ),
                                Row(
                                  children: [
                                    RatingBarIndicator(
                                      rating: product!.averageReview,
                                      itemBuilder: (context, index) => Icon(Icons.star, color: Colors.amber), // Giữ màu amber vì chưa có hằng số
                                      itemCount: 5,
                                      itemSize: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      '(${product!.averageReview.toStringAsFixed(2)})',
                                      style: TextStyle(color: AppColors.textSecondary),
                                    ),
                                  ],
                                )
                              ],
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary, // Thay Colors.brown[300]
                                minimumSize: Size(double.infinity, 48),
                              ),
                              onPressed: () {},
                              child: Text("THÊM SẢN PHẨM", style: TextStyle(color: AppColors.white)),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Đánh giá',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            ),
                            Row(
                              children: [
                                RatingBarIndicator(
                                  rating: 4.0,
                                  itemBuilder: (context, index) => Icon(Icons.star, color: Colors.amber), // Giữ màu amber
                                  itemCount: 5,
                                  itemSize: 20,
                                ),
                                SizedBox(width: 8),
                                Text('rất ngon', style: TextStyle(color: AppColors.textSecondary)),
                              ],
                            ),
                            Divider(height: 30, color: AppColors.textSecondary.withOpacity(0.3)),
                            Text(
                              'Viết đánh giá',
                              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 8),
                            RatingBar.builder(
                              initialRating: userRating,
                              minRating: 1,
                              direction: Axis.horizontal,
                              allowHalfRating: true,
                              itemCount: 5,
                              itemSize: 40,
                              itemBuilder: (context, _) => Icon(Icons.star, color: Colors.amber), // Giữ màu amber
                              onRatingUpdate: (rating) {
                                setState(() {
                                  userRating = rating;
                                });
                              },
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _commentController,
                              decoration: InputDecoration(
                                hintText: "Hãy viết đánh giá của bạn cho sản phẩm...",
                                border: OutlineInputBorder(),
                                hintStyle: TextStyle(color: AppColors.textSecondary),
                              ),
                              maxLines: 3,
                              style: TextStyle(color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: () {
                                // handle submit
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryLight, // Thay Colors.brown[200]
                                minimumSize: Size(double.infinity, 48),
                              ),
                              child: Text("LƯU ĐÁNH GIÁ", style: TextStyle(color: AppColors.textPrimary)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
    );
  }
}