import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:do_an_mobile_nc/Layout/masterlayout.dart';
import 'package:do_an_mobile_nc/screens/product/product_detail_screen.dart';
import 'package:do_an_mobile_nc/screens/search/search_screen.dart';
import 'package:do_an_mobile_nc/models/product_model.dart';
import 'package:do_an_mobile_nc/config.dart'; // Import config.dart

class ProductListScreen extends StatefulWidget {
  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  String selectedCategory = 'Tất cả';
  List<Product> products = [];
  bool isLoading = true;

  // Bản ánh xạ giữa tên hiển thị và giá trị category thực tế
  final Map<String, String> categoryMap = {
    'Tất cả': '',
    'Cà phê': 'caPhe',
    'Trà sữa': 'traSua',
    'Bánh ngọt': 'banhNgot',
    'Đá xay': 'daXay',
    'Sản phẩm bán chạy': 'bestSeller',
  };

  final List<String> categories = [
    'Tất cả',
    'Cà phê',
    'Trà sữa',
    'Bánh ngọt',
    'Đá xay',
    'Sản phẩm bán chạy',
  ];

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      final query = categoryMap[selectedCategory] ?? ''; // Lấy giá trị category từ map
      final response = await http.get(Uri.parse('${Config.baseUrl}/api/shop/products/get?category=$query')); // Sử dụng Config.baseUrl
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          // Lọc sản phẩm dựa trên selectedCategory
          products = (data['data'] as List)
              .map((json) => Product.fromJson(json))
              .where((product) {
                final category = product.category?.toLowerCase() ?? '';
                // Chỉ giữ bestSeller khi selectedCategory là 'Sản phẩm bán chạy', ngược lại loại bỏ
                return selectedCategory == 'Sản phẩm bán chạy'
                    ? category == 'bestseller'
                    : category != 'bestseller';
              })
              .toList();
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

  @override
  Widget build(BuildContext context) {
    return MasterLayout(
      currentIndex: 1,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Sản phẩm',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.search, color: Colors.brown),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SearchScreen()),
                        );
                      },
                    ),
                    DropdownButton<String>(
                      value: selectedCategory,
                      items: categories.map((cat) {
                        return DropdownMenuItem<String>(
                          value: cat,
                          child: Text(cat, style: TextStyle(color: Colors.grey)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCategory = value!;
                          isLoading = true;
                          fetchProducts();
                        });
                      },
                      icon: Icon(Icons.arrow_drop_down, color: Colors.grey),
                      underline: SizedBox(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : Column(
                      children: [
                        Expanded(
                          child: GridView.count(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.75,
                            children: products.map((product) {
                              return ProductCard(product: product);
                            }).toList(),
                          ),
                        ),
                        // Padding(
                        //   padding: const EdgeInsets.only(top: 8.0),
                        //   child: Text('<1, 2, 3>', style: TextStyle(color: Colors.grey)),
                        // ),
                      ],
                    ),
            ),
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
          MaterialPageRoute(builder: (context) => ProductDetailScreen(productId: product.id)),
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
              height: 110,
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
            if (product.salePrice != null && product.salePrice! > 0)
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
                '${product.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} đ',
                style: TextStyle(color: Colors.green, fontSize: 14),
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
                        // Placeholder action: Hiển thị thông báo
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Đã thêm ${product.title} vào yêu thích!')),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.add_shopping_cart, color: Colors.brown),
                      onPressed: () {
                        // Placeholder action: Hiển thị thông báo
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