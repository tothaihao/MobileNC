import 'package:flutter/material.dart';
import 'order_detail_page.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({Key? key}) : super(key: key);

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final List<Map<String, dynamic>> orders = [
    {
      'id': '67e7b5e6f2ea9e6eec8b9cde',
      'date': '2025-03-29',
      'status': 'pending',
      'price': 44000,
      'voucher': 'GIAM20%',
      'items': [
        {
          'title': 'Freeze Trà Xanh',
          'image': 'https://product.hstatic.net/1000075078/product/1656_freese_traxanh_1_8e2e7e2e2e2e4e2e8e2e.jpg',
          'quantity': 1
        }
      ]
    },
    // ... Thêm đơn hàng khác
  ];

  final List<Map<String, String>> statusList = [
    {'key': 'all', 'label': 'Tất cả'},
    {'key': 'pending', 'label': 'Chờ xác nhận'},
    {'key': 'completed', 'label': 'Hoàn thành'},
    {'key': 'cancelled', 'label': 'Đã hủy'},
  ];

  String selectedStatus = 'all';

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredOrders = selectedStatus == 'all'
        ? orders
        : orders.where((o) => o['status'] == selectedStatus).toList();

    final width = MediaQuery.of(context).size.width;
    final isSmall = width < 400;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý đơn hàng'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Thanh filter trạng thái
            SizedBox(
              height: 48,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: isSmall ? 4 : 12, vertical: 8),
                itemCount: statusList.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final status = statusList[index];
                  final isSelected = selectedStatus == status['key'];
                  return ChoiceChip(
                    label: Text(
                      status['label']!,
                      style: TextStyle(
                        fontSize: isSmall ? 13 : 15,
                        color: isSelected ? Colors.white : Colors.brown,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: Colors.brown[200],
                    onSelected: (_) {
                      setState(() {
                        selectedStatus = status['key']!;
                      });
                    },
                    backgroundColor: Colors.brown[50],
                  );
                },
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: filteredOrders.isEmpty
                  ? const Center(child: Text('Không có đơn hàng nào'))
                  : ListView.separated(
                      padding: EdgeInsets.all(isSmall ? 6 : 12),
                      itemCount: filteredOrders.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final order = filteredOrders[index];
                        final firstItem = order['items'][0];
                        return Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 3,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => OrderDetailPage(orderId: order['id']),
                                ),
                              );
                            },
                            child: Padding(
                              padding: EdgeInsets.all(isSmall ? 10 : 16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      firstItem['image'],
                                      width: isSmall ? 44 : 60,
                                      height: isSmall ? 44 : 60,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Container(
                                        width: isSmall ? 44 : 60,
                                        height: isSmall ? 44 : 60,
                                        color: Colors.grey[200],
                                        child: const Icon(Icons.broken_image, color: Colors.grey, size: 28),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Thông tin đơn
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Mã: ${order['id']}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: isSmall ? 13 : 15,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          'Ngày: ${order['date']}',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: isSmall ? 11 : 13,
                                          ),
                                        ),
                                        Text(
                                          '${firstItem['title']} (x${firstItem['quantity']})',
                                          style: TextStyle(fontSize: isSmall ? 11 : 13),
                                        ),
                                        Row(
                                          children: [
                                            Container(
                                              margin: const EdgeInsets.only(top: 4, right: 8),
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: _statusColor(order['status']).withOpacity(0.15),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                order['status'].toString().toUpperCase(),
                                                style: TextStyle(
                                                  color: _statusColor(order['status']),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: isSmall ? 10 : 12,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              '${order['price']}đ',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.brown,
                                                fontSize: isSmall ? 12 : 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(Icons.chevron_right, color: Colors.brown[300], size: isSmall ? 20 : 28),
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
      ),
    );
  }
}
