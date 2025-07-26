import '../pages/blog_page.dart';
import '../pages/order_page.dart';
import '../pages/product_page.dart';
import '../pages/user_page.dart';
import '../pages/voucher_page.dart';
import '../pages/banner_page.dart';
import '../pages/support_chat_page.dart';
import 'package:flutter/material.dart';
import '../widgets/sidebar.dart';
import '../widgets/header.dart';
import '../widgets/statistic_card.dart';
import '../widgets/sales_chart.dart';
import '../../config/app_config.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/admin_dashboard_service.dart';
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
  int todayOrders = 0;
  int pendingOrders = 0;
  int completedOrders = 0;
  int todayRevenue = 0;
  bool isLoading = true;
  List<Map<String, dynamic>> recentOrders = [];
  List<Map<String, dynamic>> topProducts = [];

  @override
  void initState() {
    super.initState();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    setState(() => isLoading = true);
    try {
      // Fetch basic stats
      adminCount = await AdminDashboardService.getAdminCount();
      userCount = await AdminDashboardService.getUserCount();
      orderCount = await AdminDashboardService.getOrderCount();
      totalRevenue = await AdminDashboardService.getTotalRevenue();
      
      // Fetch additional detailed stats
      final dashboardStats = await AdminDashboardService.getDashboardStats();
      todayOrders = dashboardStats['todayOrders'] ?? 0;
      pendingOrders = dashboardStats['pendingOrders'] ?? 0;
      completedOrders = dashboardStats['completedOrders'] ?? 0;
      todayRevenue = dashboardStats['todayRevenue'] ?? 0;
      recentOrders = List<Map<String, dynamic>>.from(dashboardStats['recentOrders'] ?? []);
      topProducts = List<Map<String, dynamic>>.from(dashboardStats['topProducts'] ?? []);
      
    } catch (e) {
      print('Error fetching dashboard data: $e');
    }
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
              icon: const Icon(Icons.home),
              label: const Text('Về trang chủ'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD7B7A3),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              onPressed: () {
                // Quay về trang home
                Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
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
            _drawerItem(Icons.image, 'Banner', context, onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => BannerPage()));
            }),
             _drawerItem(Icons.article, 'Blog', context, onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => BlogPage()));
            }),
            _drawerItem(Icons.support_agent, 'Chat Hỗ trợ', context, onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SupportChatPage()));
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
                // Overview Stats Row
                Row(
                  children: [
                    Expanded(
                      child: StatisticCard(
                        title: 'Doanh thu hôm nay',
                        value: '${_formatCurrency(todayRevenue)}',
                        icon: Icons.today,
                        iconColor: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatisticCard(
                        title: 'Đơn hàng hôm nay',
                        value: '$todayOrders',
                        icon: Icons.shopping_cart_outlined,
                        iconColor: Colors.blue,
                      ),
                    ),
                  ],
                ),
                
                Row(
                  children: [
                    Expanded(
                      child: StatisticCard(
                        title: 'Đơn chờ xử lý',
                        value: '$pendingOrders',
                        icon: Icons.pending_actions,
                        iconColor: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatisticCard(
                        title: 'Đơn hoàn thành',
                        value: '$completedOrders',
                        icon: Icons.check_circle,
                        iconColor: Colors.green,
                      ),
                    ),
                  ],
                ),

                // Total Stats Row
                Row(
                  children: [
                    Expanded(
                      child: StatisticCard(
                        title: 'Tổng doanh thu',
                        value: '${_formatCurrency(totalRevenue)}',
                        icon: Icons.attach_money,
                        iconColor: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatisticCard(
                        title: 'Tổng đơn hàng',
                        value: '$orderCount',
                        icon: Icons.shopping_cart,
                        iconColor: Colors.blue,
                      ),
                    ),
                  ],
                ),

                Row(
                  children: [
                    Expanded(
                      child: StatisticCard(
                        title: 'Số admin',
                        value: '$adminCount',
                        icon: Icons.admin_panel_settings,
                        iconColor: Colors.red,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatisticCard(
                        title: 'Số user',
                        value: '$userCount',
                        icon: Icons.person,
                        iconColor: Colors.purple,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Recent Orders Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Đơn hàng gần đây',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const OrderPage()),
                                );
                              },
                              child: const Text('Xem tất cả'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...recentOrders.take(5).map((order) => 
                          _buildOrderItem(order),
                        ).toList(),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Top Products Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Sản phẩm bán chạy',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const ProductPage()),
                                );
                              },
                              child: const Text('Xem tất cả'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...topProducts.take(5).map((product) => 
                          _buildProductItem(product),
                        ).toList(),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
    );
  }

  String _formatCurrency(int amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M VND';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K VND';
    } else {
      return '$amount VND';
    }
  }

  Widget _buildOrderItem(Map<String, dynamic> order) {
    Color statusColor;
    String statusText;
    
    switch (order['status']) {
      case 'completed':
        statusColor = Colors.green;
        statusText = 'Hoàn thành';
        break;
      case 'pending':
        statusColor = Colors.orange;
        statusText = 'Chờ xử lý';
        break;
      case 'processing':
        statusColor = Colors.blue;
        statusText = 'Đang xử lý';
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'Khác';
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: statusColor.withOpacity(0.1),
            child: Text(
              '#${order['id']}',
              style: TextStyle(
                color: statusColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order['customer'] ?? 'N/A',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${_formatCurrency(order['amount'] ?? 0)}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                color: statusColor,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductItem(Map<String, dynamic> product) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.brown[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.coffee,
              color: Colors.brown[600],
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['name'] ?? 'N/A',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Đã bán: ${product['sold']} | ${_formatCurrency(product['revenue'] ?? 0)}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.trending_up,
            color: Colors.green[600],
            size: 20,
          ),
        ],
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