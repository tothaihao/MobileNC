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
import 'package:do_an_mobile_nc/admin/pages/banner_page.dart';

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
  // Dữ liệu doanh số từng tháng (giả lập, sẽ fetch sau)
  List<double> monthlySales = [2,2,6,4,5,7,6,7,5,6,4,2];

  @override
  void initState() {
    super.initState();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    setState(() => isLoading = true);
    final userAdminMap = await DashboardService.getUserAndAdminCount();
    adminCount = userAdminMap['admin'] ?? 0;
    userCount = userAdminMap['user'] ?? 0;
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
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD7B7A3),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              onPressed: () {},
              icon: const Icon(Icons.logout),
              label: const Text('LOGOUT'),
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
            _drawerItem(Icons.image, 'Banner', context, onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const BannerPage()));
            }),
            _drawerItem(Icons.person, 'User', context, onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const UserPage()));
            }),
            _drawerItem(Icons.article, 'Blog', context, onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => BlogPage()));
            }),
            _drawerItem(Icons.card_giftcard, 'Vouchers', context, onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const VoucherPage()));
            }),
          ],
        ),
      ),
      body: isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Dashboard', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 600;
                    return Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        SizedBox(
                          width: isMobile ? constraints.maxWidth : (constraints.maxWidth - 32) / 3,
                          child: StatisticCard(
                            title: 'Tổng doanh thu',
                            value: '$totalRevenue VND',
                            icon: Icons.attach_money,
                            iconColor: Colors.green,
                          ),
                        ),
                        SizedBox(
                          width: isMobile ? constraints.maxWidth : (constraints.maxWidth - 32) / 3,
                          child: StatisticCard(
                            title: 'Tổng đơn đặt hàng',
                            value: '$orderCount',
                            icon: Icons.shopping_cart,
                            iconColor: Colors.blue,
                          ),
                        ),
                        SizedBox(
                          width: isMobile ? constraints.maxWidth : (constraints.maxWidth - 32) / 3,
                          child: StatisticCard(
                            title: 'Tổng số Account',
                            value: 'Admin: $adminCount | User: $userCount',
                            icon: Icons.person,
                            iconColor: Colors.purple,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Color(0xFFE0E0E0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.07),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Biểu đồ bán hàng ( 24)', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 220,
                        child: SalesChart(), // Sẽ truyền dữ liệu sau
                      ),
                    ],
                  ),
                ),
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