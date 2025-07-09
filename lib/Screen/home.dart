import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart' as cs;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:do_an_mobile_nc/Layout/masterlayout.dart';
import 'package:do_an_mobile_nc/models/product_model.dart';
import 'package:do_an_mobile_nc/Screen/product_detail.dart';
import 'package:do_an_mobile_nc/config.dart'; // Import config.dart

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> bannerImages = [
    'https://upload.wikimedia.org/wikipedia/commons/e/e4/Latte_and_dark_coffee.jpg',
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT0RyiFla98L-B6yXCLbOiELZktX5jHkwQdZw&s',
    'https://enjoycoffee.vn/wp-content/uploads/2020/01/coffee.2-810x524-1.jpg',
  ];
  
  List<Product> bestSellerProducts = [];
  List<Product> hotDealProducts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse('${Config.baseUrl}/api/shop/products/get')); // Sử dụng Config.baseUrl
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final allProducts = (data['data'] as List).map((json) => Product.fromJson(json)).toList();
        
        // Lọc sản phẩm bestseller
        bestSellerProducts = allProducts
            .where((product) => product.category.toLowerCase() == 'bestseller')
            .toList();

        // Lọc sản phẩm ưu đãi (có salePrice)
        hotDealProducts = allProducts
            .where((product) => product.salePrice != null && product.salePrice! > 0)
            .toList();

        setState(() {
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load products, status: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Widget _buildBanner() {
    return cs.CarouselSlider(
      options: cs.CarouselOptions(height: 180.0, autoPlay: true),
      items: bannerImages.map((url) {
        return Builder(
          builder: (BuildContext context) {
            return Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.symmetric(horizontal: 5.0),
              decoration: BoxDecoration(color: Colors.amber),
              child: Image.network(url, fit: BoxFit.cover),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildSectionWithFilter(BuildContext context, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, title),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    String filter = title == 'Sản phẩm bán chạy' ? 'bestSeller' : 'sale'; // Đặt filter dựa trên title
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.brown[800],
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.pushReplacementNamed(
                context,
                '/products',
                arguments: {'filter': filter}, // Truyền filter làm tham số
              );
            },
            child: Text(
              'Tất cả',
              style: TextStyle(
                fontSize: 14,
                color: Colors.orange,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductSlider(BuildContext context, List<Product> products, bool useSalePrice) {
    return Column(
      children: [
        cs.CarouselSlider(
          options: cs.CarouselOptions(
            height: 290.0, // Giữ chiều cao khung
            enlargeCenterPage: false, // Xóa hiệu ứng phóng to
            enableInfiniteScroll: false,
            viewportFraction: 0.5, // Tăng để hiển thị nhiều card hơn
          ),
          items: products.map((product) {
            return Builder(
              builder: (BuildContext context) {
                return _buildProductCard(product, useSalePrice);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildProductCard(Product product, bool useSalePrice) {
    final price = useSalePrice && product.salePrice != null ? product.salePrice! : product.price;
    // Giả định thêm variant từ description hoặc title (nếu có)
    String variant = product.description?.split(' ').firstWhere((word) => ['iced', 'frozen', 'chilled'].contains(word.toLowerCase()), orElse: () => '') ?? '';
    String displayTitle = variant.isNotEmpty ? '$variant ${product.title}' : product.title;

    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProductDetailPage(productId: product.id)),
          );
        },
        child: Container(
          width: MediaQuery.of(context).size.width * 0.6, // Điều chỉnh kích thước card
          padding: EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  product.image,
                  height: 120,
                  width: double.infinity, // Sửa lại để khớp với Container
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Icon(Icons.error, size: 50),
                ),
              ),
              SizedBox(height: 8),
              Text(
                displayTitle,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (variant.isNotEmpty) SizedBox(height: 4),
              if (variant.isNotEmpty)
                Text(
                  variant,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              SizedBox(height: 4),
              Text(
                '${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} đ',
                style: TextStyle(color: Colors.green, fontSize: 14),
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(Icons.star, color: Colors.yellow, size: 20),
                  SizedBox(width: 4),
                  Text(
                    product.averageReview.toStringAsFixed(1),
                    style: TextStyle(fontSize: 16),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.favorite_border, color: Colors.grey),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Đã thêm ${product.title} vào yêu thích!')),
                      );
                    },
                    iconSize: 24,
                  ),
                  IconButton(
                    icon: Icon(Icons.add_shopping_cart, color: Colors.brown),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Đã thêm ${product.title} vào giỏ hàng!')),
                      );
                    },
                    iconSize: 24,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MasterLayout(
      currentIndex: 0,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBanner(),
            if (!isLoading) _buildSectionWithFilter(context, 'Sản phẩm bán chạy'),
            if (!isLoading) _buildProductSlider(context, bestSellerProducts, false),
            if (!isLoading) _buildSectionWithFilter(context, 'Ưu đãi hot'),
            if (!isLoading) _buildProductSlider(context, hotDealProducts, true),
          ],
        ),
      ),
    );
  }
}