import 'Screen/cart_screen.dart';
import 'Screen/checkout_screen.dart';
import 'Screen/contact_screen.dart';
import 'Screen/login_screen.dart';
import 'Screen/register_screen.dart';
import 'Screen/success_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:do_an_mobile_nc/provider/product_provider.dart';
import 'chatbot/chat_bot.dart';

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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductProvider()),
      ],
      child: MaterialApp(
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
          '/chatbot': (context) => const ChatbotPage(),
          '/home': (context) => const HomeScreen(),
          '/products': (context) => const ProductListScreen(),
          '/profile': (context) => const UserProfilePage(),
          '/history': (context) => const PurchaseHistoryPage(),
          '/search': (context) => const SearchScreen(),
          '/product-detail': (context) => ProductDetailPage(
                productId: ModalRoute.of(context)?.settings.arguments as String?,
              ),
          '/': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/cart': (context) => const CartScreen(),
          '/checkout': (context) => const CheckoutScreen(),
          '/success': (context) => const SuccessScreen(),
          '/contact': (context) => const ContactScreen(),
          // ADMIN ROUTE
          '/admin': (context) => const DashboardPage(),
        },
      ),
    );
  }
}