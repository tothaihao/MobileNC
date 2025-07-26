import 'package:flutter/material.dart';
import 'order_detail_page.dart';
import 'user_page.dart';
import 'package:do_an_mobile_nc/admin/models/admin_order_model.dart';
import 'package:do_an_mobile_nc/admin/services/admin_order_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config/app_config.dart';
import '../../models/user_model.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({Key? key}) : super(key: key);

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> with TickerProviderStateMixin {
  List<Order> orders = [];
  List<Order> filteredOrders = [];
  Map<String, User> users = {}; // Cache users by ID
  bool isLoading = true;
  String selectedStatus = 'all';
  String selectedUserId = 'all';
  String searchQuery = '';
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, String>> statusList = [
    {'key': 'all', 'label': 'Tất cả'},
    {'key': 'pending', 'label': 'Chờ xác nhận'},
    {'key': 'confirmed', 'label': 'Đã xác nhận'},
    {'key': 'inShipping', 'label': 'Đang giao'},
    {'key': 'delivered', 'label': 'Hoàn thành'},
    {'key': 'rejected', 'label': 'Đã hủy'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: statusList.length, vsync: this);
    fetchOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchOrders() async {
    setState(() => isLoading = true);
    try {
      print('DEBUG: Fetching orders...');
      orders = await AdminOrderService.getAllOrders();
      print('DEBUG: Successfully fetched ${orders.length} orders');
      
      // Fetch all users to get their names
      await _fetchUsers();
      
      // Apply current filters
      _applyFilters();
      
    } catch (e) {
      print('DEBUG: Error fetching orders: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi tải đơn hàng: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _fetchUsers() async {
    try {
      final response = await http.get(Uri.parse(AppConfig.adminUsers));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> usersJson = data['data'] ?? data;
        
        for (var userJson in usersJson) {
          final user = User.fromJson(userJson);
          users[user.id] = user;
        }
      }
    } catch (e) {
      print('DEBUG: Error fetching users: $e');
    }
  }

  void _applyFilters() {
    List<Order> result = orders;

    // Filter by status
    if (selectedStatus != 'all') {
      result = result.where((order) => order.orderStatus == selectedStatus).toList();
    }

    // Filter by user
    if (selectedUserId != 'all') {
      result = result.where((order) => order.userId == selectedUserId).toList();
    }

    // Filter by search query (user name)
    if (searchQuery.isNotEmpty) {
      result = result.where((order) {
        final user = users[order.userId];
        if (user != null) {
          return user.userName.toLowerCase().contains(searchQuery.toLowerCase()) ||
                 user.email.toLowerCase().contains(searchQuery.toLowerCase()) ||
                 order.id.toLowerCase().contains(searchQuery.toLowerCase());
        }
        return order.id.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
    }

    setState(() {
      filteredOrders = result;
    });
  }

  void _onStatusChanged(String status) {
    setState(() {
      selectedStatus = status;
    });
    _applyFilters();
  }

  void _onSearchChanged(String query) {
    setState(() {
      searchQuery = query;
    });
    _applyFilters();
  }

  void _onUserChanged(String userId) {
    setState(() {
      selectedUserId = userId;
    });
    _applyFilters();
  }

  int _getActiveFilterCount() {
    int count = 0;
    if (selectedStatus != 'all') count++;
    if (selectedUserId != 'all') count++;
    if (searchQuery.isNotEmpty) count++;
    return count;
  }

  void _showFilterSummary() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bộ lọc đang áp dụng'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (selectedStatus != 'all') ...[
              Row(
                children: [
                  const Icon(Icons.circle, size: 8, color: Colors.brown),
                  const SizedBox(width: 8),
                  Text('Trạng thái: ${statusList.firstWhere((s) => s['key'] == selectedStatus)['label']}'),
                ],
              ),
              const SizedBox(height: 8),
            ],
            if (selectedUserId != 'all') ...[
              Row(
                children: [
                  const Icon(Icons.circle, size: 8, color: Colors.brown),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('Khách hàng: ${users[selectedUserId]?.userName ?? "N/A"}'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            if (searchQuery.isNotEmpty) ...[
              Row(
                children: [
                  const Icon(Icons.circle, size: 8, color: Colors.brown),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('Tìm kiếm: "$searchQuery"'),
                  ),
                ],
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Clear all filters
              _searchController.clear();
              _onSearchChanged('');
              _onStatusChanged('all');
              _onUserChanged('all');
              _tabController.animateTo(0);
            },
            child: const Text('Xóa tất cả'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Quản lý đơn hàng',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          // Filter indicator
          if (selectedUserId != 'all' || searchQuery.isNotEmpty || selectedStatus != 'all')
            Container(
              margin: const EdgeInsets.only(right: 8),
              child: Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.filter_list),
                    tooltip: 'Đang lọc dữ liệu',
                    onPressed: () {
                      // Show filter summary dialog
                      _showFilterSummary();
                    },
                  ),
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        _getActiveFilterCount().toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          IconButton(
            icon: const Icon(Icons.people),
            tooltip: 'Quản lý người dùng',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UserPage(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchOrders,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm theo tên người dùng hoặc mã đơn hàng...',
                prefixIcon: const Icon(Icons.search, color: Colors.brown),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.brown.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.brown, width: 2),
                ),
                filled: true,
                fillColor: Colors.grey[50],
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          
          // User Filter Dropdown
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(
                  Icons.person_outline,
                  size: 20,
                  color: Colors.brown,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Lọc theo khách hàng:',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.brown.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[50],
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedUserId,
                        isExpanded: true,
                        icon: Icon(Icons.arrow_drop_down, color: Colors.brown),
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                        ),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            _onUserChanged(newValue);
                          }
                        },
                        items: _buildUserDropdownItems(),
                      ),
                    ),
                  ),
                ),
                if (selectedUserId != 'all') ...[
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.clear, color: Colors.red, size: 20),
                    tooltip: 'Xóa lọc khách hàng',
                    onPressed: () => _onUserChanged('all'),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                ],
              ],
            ),
          ),
          
          // Status Tabs
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: Colors.brown,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.brown,
              indicatorWeight: 3,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              onTap: (index) {
                final statusKey = statusList[index]['key']!;
                _onStatusChanged(statusKey);
              },
              tabs: statusList.map((status) {
                final count = _getStatusCount(status['key']!);
                return Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(status['label']!),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: selectedStatus == status['key']
                              ? Colors.brown
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          count.toString(),
                          style: TextStyle(
                            color: selectedStatus == status['key']
                                ? Colors.white
                                : Colors.grey[600],
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          
          // Results Info
          if (searchQuery.isNotEmpty || selectedStatus != 'all' || selectedUserId != 'all')
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Wrap(
                      children: [
                        Text(
                          'Tìm thấy ${filteredOrders.length} đơn hàng',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        if (selectedUserId != 'all') ...[
                          const SizedBox(width: 4),
                          Text(
                            'của ${users[selectedUserId]?.userName ?? "khách hàng"}',
                            style: TextStyle(
                              color: Colors.brown,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                        if (searchQuery.isNotEmpty) ...[
                          const SizedBox(width: 4),
                          Text(
                            'cho "$searchQuery"',
                            style: TextStyle(
                              color: Colors.grey[800],
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          
          const Divider(height: 1),
          
          // Orders List
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.brown),
                  )
                : filteredOrders.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: fetchOrders,
                        color: Colors.brown,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredOrders.length,
                          itemBuilder: (context, index) {
                            final order = filteredOrders[index];
                            return _buildOrderCard(order);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  int _getStatusCount(String statusKey) {
    if (statusKey == 'all') return orders.length;
    return orders.where((order) => order.orderStatus == statusKey).length;
  }

  List<DropdownMenuItem<String>> _buildUserDropdownItems() {
    List<DropdownMenuItem<String>> items = [
      const DropdownMenuItem<String>(
        value: 'all',
        child: Text('Tất cả khách hàng'),
      ),
    ];

    // Get unique users from orders
    Set<String> userIds = orders.map((order) => order.userId).toSet();
    
    for (String userId in userIds) {
      final user = users[userId];
      if (user != null) {
        final orderCount = orders.where((order) => order.userId == userId).length;
        items.add(
          DropdownMenuItem<String>(
            value: userId,
            child: Text(
              '${user.userName} ($orderCount đơn)',
              overflow: TextOverflow.ellipsis,
            ),
          ),
        );
      }
    }

    // Sort by user name (except 'all' option)
    items.skip(1).toList().sort((a, b) {
      final userA = users[a.value];
      final userB = users[b.value];
      if (userA != null && userB != null) {
        return userA.userName.compareTo(userB.userName);
      }
      return 0;
    });

    return items;
  }

  Widget _buildEmptyState() {
    String message;
    IconData icon;
    
    if (searchQuery.isNotEmpty) {
      message = 'Không tìm thấy đơn hàng nào\nphù hợp với từ khóa "$searchQuery"';
      icon = Icons.search_off;
    } else if (selectedUserId != 'all') {
      final userName = users[selectedUserId]?.userName ?? 'khách hàng';
      message = 'Không có đơn hàng nào\ncủa khách hàng "$userName"';
      icon = Icons.person_off;
    } else if (selectedStatus != 'all') {
      final statusLabel = statusList.firstWhere((s) => s['key'] == selectedStatus)['label'];
      message = 'Không có đơn hàng nào\nở trạng thái "$statusLabel"';
      icon = Icons.filter_list_off;
    } else {
      message = 'Chưa có đơn hàng nào';
      icon = Icons.receipt_long_outlined;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          if (searchQuery.isNotEmpty || selectedStatus != 'all' || selectedUserId != 'all') ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                _searchController.clear();
                _onSearchChanged('');
                _onStatusChanged('all');
                _onUserChanged('all');
                _tabController.animateTo(0);
              },
              icon: const Icon(Icons.clear, size: 18),
              label: const Text('Xóa tất cả bộ lọc'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    final user = users[order.userId];
    final firstItem = order.cartItems.isNotEmpty ? order.cartItems.first : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailPage(orderId: order.id),
          ),
        ),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Đơn hàng #${order.id.substring(0, 8).toUpperCase()}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (user != null) ...[
                          GestureDetector(
                            onTap: () => _onUserChanged(user.id),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: selectedUserId == user.id 
                                    ? Colors.brown.withOpacity(0.1)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(4),
                                border: selectedUserId == user.id 
                                    ? Border.all(color: Colors.brown.withOpacity(0.3))
                                    : null,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.person,
                                    size: 14,
                                    color: selectedUserId == user.id 
                                        ? Colors.brown 
                                        : Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      user.userName,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: selectedUserId == user.id 
                                            ? Colors.brown 
                                            : Colors.grey[600],
                                        fontWeight: selectedUserId == user.id 
                                            ? FontWeight.w600 
                                            : FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (selectedUserId == user.id)
                                    Icon(
                                      Icons.filter_alt,
                                      size: 12,
                                      color: Colors.brown,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  _buildStatusBadge(order.orderStatus),
                ],
              ),
              const SizedBox(height: 12),
              
              // Order Info
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(order.orderDate),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.payment,
                    size: 14,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _getPaymentMethodText(order.paymentMethod),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Product Preview & Total
              Row(
                children: [
                  if (firstItem != null) ...[
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        color: Colors.grey[200],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.network(
                          firstItem.image,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.image_not_supported,
                            color: Colors.grey[400],
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        order.cartItems.length == 1
                            ? '${firstItem.title} x${firstItem.quantity}'
                            : '${firstItem.title} và ${order.cartItems.length - 1} sản phẩm khác',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ] else ...[
                    Expanded(
                      child: Text(
                        'Đơn hàng trống',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                  
                  Text(
                    _formatCurrency(order.totalAmount),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String label;

    switch (status) {
      case 'pending':
        color = Colors.orange;
        label = 'Chờ xác nhận';
        break;
      case 'confirmed':
        color = Colors.blue;
        label = 'Đã xác nhận';
        break;
      case 'inShipping':
        color = Colors.purple;
        label = 'Đang giao';
        break;
      case 'delivered':
        color = Colors.green;
        label = 'Hoàn thành';
        break;
      case 'rejected':
        color = Colors.red;
        label = 'Đã hủy';
        break;
      default:
        color = Colors.grey;
        label = status.toUpperCase();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
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

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _getPaymentMethodText(String method) {
    switch (method) {
      case 'cash':
        return 'Tiền mặt';
      case 'momo':
        return 'MoMo';
      case 'paypal':
        return 'PayPal';
      default:
        return method.toUpperCase();
    }
  }
}
