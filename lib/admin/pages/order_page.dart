import 'package:flutter/material.dart';
import 'order_detail_page.dart';
import 'package:do_an_mobile_nc/admin/models/admin_order_model.dart';
import 'package:do_an_mobile_nc/admin/services/admin_order_service.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({Key? key}) : super(key: key);

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  List<Order> orders = [];
  bool isLoading = true;
  String selectedStatus = 'all';

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
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    setState(() => isLoading = true);
    try {
      print('DEBUG: Fetching orders...');
      orders = await AdminOrderService.getAllOrders();
      print('DEBUG: Successfully fetched ${orders.length} orders');
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

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'inShipping':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Chờ xác nhận';
      case 'confirmed':
        return 'Đã xác nhận';
      case 'inShipping':
        return 'Đang giao';
      case 'delivered':
        return 'Hoàn thành';
      case 'rejected':
        return 'Đã hủy';
      default:
        return status.toUpperCase();
    }
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

  @override
  Widget build(BuildContext context) {
    final filtered = selectedStatus == 'all'
        ? orders
        : orders.where((o) => o.orderStatus == selectedStatus).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý đơn hàng'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchOrders,
          )
        ],
      ),
      body: Column(
        children: [
          // Bộ lọc
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: statusList.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final status = statusList[index];
                final isSelected = selectedStatus == status['key'];
                return ChoiceChip(
                  label: Text(status['label']!),
                  selected: isSelected,
                  selectedColor: Colors.brown,
                  labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.brown),
                  onSelected: (_) => setState(() => selectedStatus = status['key']!),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                    ? const Center(child: Text('Không có đơn hàng'))
                    : ListView.separated(
                        padding: const EdgeInsets.all(12),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final o = filtered[index];
                          final first = o.cartItems.isNotEmpty ? o.cartItems[0] : null;

                          return Card(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 3,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => OrderDetailPage(orderId: o.id),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    if (first != null)
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.network(
                                          first.image,
                                          width: 60,
                                          height: 60,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Container(
                                            width: 60,
                                            height: 60,
                                            color: Colors.grey[200],
                                            child: const Icon(Icons.image_not_supported),
                                          ),
                                        ),
                                      ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Mã: ${o.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                          Text('Ngày: ${_formatDate(o.orderDate)}'),
                                          if (first != null)
                                            Text('${first.title} x${first.quantity}'),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: _statusColor(o.orderStatus).withOpacity(0.15),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  _getStatusLabel(o.orderStatus),
                                                  style: TextStyle(
                                                    color: _statusColor(o.orderStatus),
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                              const Spacer(),
                                              Text(
                                                _formatCurrency(o.totalAmount),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  color: Colors.brown,
                                                ),
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}