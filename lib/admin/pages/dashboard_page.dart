import 'package:do_an_mobile_nc/admin/pages/blog_page.dart';
import 'package:do_an_mobile_nc/admin/pages/order_page.dart';
import 'package:do_an_mobile_nc/admin/pages/product_page.dart';
import 'package:do_an_mobile_nc/admin/pages/user_page.dart';
import 'package:do_an_mobile_nc/admin/pages/voucher_page.dart';
import 'package:flutter/material.dart';
import '../widgets/sidebar.dart';
import '../widgets/header.dart';
import '../widgets/statistic_card.dart';
import '../widgets/sales_chart.dart';
import 'package:do_an_mobile_nc/config.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:do_an_mobile_nc/admin/services/dashboard_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int adminCount = 0;
  int userCount = 0;
  int orderCount = 0;
  int totalRevenue = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    setState(() => isLoading = true);
    adminCount = await DashboardService.getAdminCount();
    userCount = await DashboardService.getUserCount();
    orderCount = await DashboardService.getOrderCount();
    totalRevenue = await DashboardService.getTotalRevenue();
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text('Đăng xuất'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD7B7A3),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              onPressed: () async {
  // Xóa token trong SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('token');
  await prefs.remove('user');
  // Chuyển về trang đăng nhập
  Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
},
            ),
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
        titleTextStyle: const TextStyle(color: Colors.black87, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFFF7F7F7),
              ),
              child: Row(
                children: [
                  Icon(Icons.show_chart, size: 28, color: Colors.black87),
                  SizedBox(width: 8),
                  Text('Admin Panel', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                ],
              ),
            ),
            _drawerItem(Icons.dashboard, 'Dashboard', context, onTap: () {
              Navigator.pop(context);
            }),
            _drawerItem(Icons.shopping_bag, 'Products', context, onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductPage()));
            }),
            _drawerItem(Icons.receipt_long, 'Orders', context, onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const OrderPage()));
            }),
            _drawerItem(Icons.person, 'User', context, onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const UserPage()));
            }),
            // _drawerItem(Icons.image, 'Banner', context),
             _drawerItem(Icons.article, 'Blog', context, onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => BlogPage()));
            }),
            // _drawerItem(Icons.support_agent, 'support customers', context),
            // _drawerItem(Icons.chat, 'Chat', context),
            _drawerItem(Icons.card_giftcard, 'Vouchers', context, onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const VoucherPage()));
            }),
          ],
        ),
      ),
      body: isLoading
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                StatisticCard(
                  title: 'Tổng doanh thu',
                  value: '$totalRevenue VND',
                  icon: Icons.attach_money,
                  iconColor: Colors.green,
                ),
                StatisticCard(
                  title: 'Tổng số đơn hàng',
                  value: '$orderCount',
                  icon: Icons.shopping_cart,
                  iconColor: Colors.blue,
                ),
                StatisticCard(
                  title: 'Số admin',
                  value: '$adminCount',
                  icon: Icons.admin_panel_settings,
                  iconColor: Colors.red,
                ),
                StatisticCard(
                  title: 'Số user',
                  value: '$userCount',
                  icon: Icons.person,
                  iconColor: Colors.purple,
                ),
                // ... có thể thêm biểu đồ hoặc các mục khác nếu muốn ...
              ],
            ),
          ),
    );
  }
}

Widget _drawerItem(IconData icon, String label, BuildContext context, {VoidCallback? onTap}) {
  return ListTile(
    leading: Icon(icon, color: Colors.grey[700]),
    title: Text(label, style: const TextStyle(fontSize: 16)),
    onTap: onTap,
  );
} 