import 'package:flutter/material.dart';
import 'package:do_an_mobile_nc/theme/colors.dart'; // Import file color.dart

class MasterLayout extends StatelessWidget {
  final Widget child;
  final int currentIndex;

  const MasterLayout({
    super.key,
    required this.child,
    this.currentIndex = 0,
  });

  void _onTabTapped(BuildContext context, int index) {
    if (index == currentIndex) return;

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/products');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/history');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/contact');
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold, // Thay Colors.brown[50]
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Coffee shop',
                    style: TextStyle(
                      fontFamily: 'Pacifico', // Custom font nếu có
                      fontSize: 24,
                      color: AppColors.primary, // Thay Colors.brown[700]
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.shopping_cart, color: AppColors.primary), // Thay Colors.brown[700]
                    onPressed: () {
                      Navigator.pushNamed(context, '/cart');
                    },
                  ),
                ],
              ),
            ),
            // Main content
            Expanded(child: child),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.primary, // Thay Color.fromRGBO(156, 107, 83, 1)
        selectedItemColor: AppColors.white,
        unselectedItemColor: AppColors.white.withOpacity(0.6),
        currentIndex: currentIndex,
        onTap: (index) => _onTabTapped(context, index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.local_bar), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
      ),
    );
  }
}