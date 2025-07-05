
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// USER SCREEN
import 'Screen/home.dart';
import 'Screen/product.dart';
import 'Screen/user_profile_page.dart';
import 'Screen/purchase_history_page.dart';
import 'Screen/search_screen.dart';
import 'Screen/product_detail.dart';

// ADMIN SCREEN
import 'package:do_an_mobile_nc/admin/pages/dashboard_page.dart';
void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Coffee Shop & Admin Panel',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.brown,
        textTheme: GoogleFonts.robotoTextTheme(Theme.of(context).textTheme),
        scaffoldBackgroundColor: const Color(0xFFF7F7F7),
      ),
      initialRoute: '/', // Bạn có thể đổi thành '/admin' nếu muốn vào admin trước
      routes: {
        // USER ROUTES
        '/': (context) =>  HomeScreen(),
        '/products': (context) =>  ProductListScreen(),
        '/profile': (context) =>  UserProfilePage(),
        '/history': (context) =>  PurchaseHistoryPage(),
        '/search': (context) =>  SearchScreen(),
        '/product-detail': (context) => ProductDetailPage(
              productId: ModalRoute.of(context)?.settings.arguments as String?,
            ),

        // ADMIN ROUTE
        '/admin': (context) => const DashboardPage(),
      },
    );
  }
}
