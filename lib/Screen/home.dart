import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart' as cs;
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart'; // Thêm để dùng kDebugMode
import 'package:do_an_mobile_nc/models/product_model.dart';
import 'package:do_an_mobile_nc/Screen/product_detail.dart';
import 'package:do_an_mobile_nc/Layout/masterlayout.dart';
import 'package:do_an_mobile_nc/provider/product_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> bannerImages = [
    'https://upload.wikimedia.org/wikipedia/commons/e/e4/Latte_and_dark_coffee.jpg',
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT0RyiFla98L-B6yXCLbOiELZktX5jHkwQdZw&s',
    'https://enjoycoffee.vn/wp-content/uploads/2020/01/coffee.2-810x524-1.jpg',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final provider = Provider.of<ProductProvider>(context, listen: false);
        provider.fetchProducts(context: context);
      }
    });
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

  Widget _buildSectionWithFilter(BuildContext context, String category) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, category, category),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String category, String title) {
    String filter = category == 'Sản phẩm bán chạy' ? 'bestSeller' : 'sale';
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
                arguments: {'filter': filter},
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
            height: 307.0,
            enlargeCenterPage: false,
            enableInfiniteScroll: false,
            viewportFraction: 0.5,
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
    String variant = product.description?.split(' ').firstWhere((word) => ['iced', 'frozen', 'chilled'].contains(word.toLowerCase()), orElse: () => '') ?? '';
    String displayTitle = variant.isNotEmpty ? '$variant ${product.title}' : product.title;

    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: GestureDetector(
        onTap: () {
          Provider.of<ProductProvider>(context, listen: false).fetchProductDetails(product.id, context: context);
          Navigator.pushNamed(context, '/product-detail', arguments: product.id);
        },
        child: Container(
          width: MediaQuery.of(context).size.width * 0.6,
          padding: EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      product.image,
                      height: 120,
                      width: double.infinity,
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
                  if (useSalePrice && product.salePrice != null && product.salePrice! > 0)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${product.salePrice!.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} đ',
                          style: TextStyle(color: Colors.green, fontSize: 14),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '${product.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} đ',
                          style: TextStyle(
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    )
                  else
                    Text(
                      '${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} đ',
                      style: TextStyle(color: Colors.green, fontSize: 14),
                    ),
                ],
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
    final provider = Provider.of<ProductProvider>(context);
    final bestSellerProducts = provider.bestSellerProducts; // Sử dụng getter mới
    final hotDealProducts = provider.products.where((product) => product.salePrice != null && product.salePrice! > 0).toList();

    if (kDebugMode) {
      print('Best Seller Products: ${bestSellerProducts.length} items');
      print('Hot Deal Products: ${hotDealProducts.length} items');
      provider.bestSellerProducts.forEach((product) {
        print('Product: ${product.title}, Category: ${product.category}, Raw Category: ${product.category?.toLowerCase()}');
      });
    }

    return MasterLayout(
      currentIndex: 0,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBanner(),
            if (!provider.isLoading) _buildSectionWithFilter(context, 'Sản phẩm bán chạy'),
            if (!provider.isLoading && bestSellerProducts.isNotEmpty)
              _buildProductSlider(context, bestSellerProducts, false),
            if (!provider.isLoading) _buildSectionWithFilter(context, 'Ưu đãi hot'),
            if (!provider.isLoading && hotDealProducts.isNotEmpty)
              _buildProductSlider(context, hotDealProducts, true),
          ],
        ),
      ),
    );
  }
}