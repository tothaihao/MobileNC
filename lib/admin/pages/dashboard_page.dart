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

class DashboardPage extends StatelessWidget {
  const DashboardPage({Key? key}) : super(key: key);

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
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
              },
              icon: const Icon(Icons.home),
              label: const Text('Quay lại mua hàng'),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const SizedBox(height: 8),
            StatisticCard(
              title: 'Tổng doanh thu',
              value: '8,662,219 VND',
              icon: Icons.attach_money,
              iconColor: Colors.green,
            ),
            const SizedBox(height: 16),
            StatisticCard(
              title: 'Tổng đơn đặt hàng',
              value: '230',
              icon: Icons.shopping_cart,
              iconColor: Colors.blue,
            ),
            const SizedBox(height: 16),
            StatisticCard(
              title: 'Tổng số Account',
              value: 'Admin: 1 | User: 4',
              icon: Icons.person,
              iconColor: Colors.purple,
            ),
            const SizedBox(height: 32),
            const Text(
              'Biểu đồ bán hàng (24)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: SalesChart(),
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