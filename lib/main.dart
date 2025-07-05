import 'package:flutter/material.dart';
import 'Screen/home.dart';
import 'Screen/product.dart';
import 'Screen/user_profile_page.dart';
import 'Screen/purchase_history_page.dart';
import 'package:do_an_mobile_nc/Screen/search_screen.dart';
import 'package:do_an_mobile_nc/Screen/product_detail.dart'; // Thêm import


void main() {
  runApp(CoffeeApp());
}

class CoffeeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Coffee Shop',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(),
        '/products': (context) => ProductListScreen(),
        '/Profile': (context) => UserProfilePage(),
        '/history': (context) => PurchaseHistoryPage(),
        '/search': (context) => SearchScreen(), // Sửa thành '/search'
        '/product-detail': (context) => ProductDetailPage(
              productId: ModalRoute.of(context)?.settings.arguments as String?,
            ), // Thêm route cho ProductDetailPage
      },
    );
  }
}