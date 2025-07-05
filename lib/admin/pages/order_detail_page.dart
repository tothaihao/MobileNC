import 'package:flutter/material.dart';

class OrderDetailPage extends StatelessWidget {
  final String orderId;
  const OrderDetailPage({Key? key, required this.orderId}) : super(key: key);

  // Dữ liệu mẫu
  final Map<String, dynamic> order = const {
    'id': '67e7b5e6f2ea9e6eec8b9cde',
    'date': '2025-03-29',
    'amount': 44000,
    'paymentMethod': 'cash',
    'paymentStatus': 'pending',
    'status': 'pending',
    'voucher': 'GIAM20%',
    'items': [
      {'title': 'Freeze Trà Xanh', 'quantity': 1, 'price': 55000}
    ],
    'shipping': {
      'name': 'Cộng Hòa',
      'address': 'p2, Tân bình, Hồ Chí Minh',
      'phone': '0901064407',
      'zip': '123123'
    }
  };

  @override
  Widget build(BuildContext context) {
    final shipping = order['shipping'] as Map<String, dynamic>;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết đơn hàng'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Mã đơn: ${order['id']}', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: Text('Ngày đặt: ${order['date']}')),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  order['status'].toString().toUpperCase(),
                  style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Tổng tiền:', style: TextStyle(fontWeight: FontWeight.w500)),
              Text('${order['amount']}đ', style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Phương thức:', style: TextStyle(fontWeight: FontWeight.w500)),
              Text(order['paymentMethod']),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Thanh toán:', style: TextStyle(fontWeight: FontWeight.w500)),
              Text(order['paymentStatus']),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Voucher:', style: TextStyle(fontWeight: FontWeight.w500)),
              Text(
                order['voucher'],
                style: TextStyle(
                  color: order['voucher'] == 'KHÔNG CÓ' ? Colors.grey : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          const Text('Sản phẩm:', style: TextStyle(fontWeight: FontWeight.bold)),
          ...((order['items'] as List).map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${item['title']} (x${item['quantity']})'),
                    Text('${item['price']}đ'),
                  ],
                ),
              ))),
          const Divider(height: 24),
          const Text('Thông tin giao hàng:', style: TextStyle(fontWeight: FontWeight.bold)),
          Text('${shipping['name']}'),
          Text('${shipping['address']}'),
          Text('${shipping['phone']}'),
          Text('${shipping['zip']}'),
          const Divider(height: 24),
          const Text('Cập nhật trạng thái:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: order['status'],
            items: const [
              DropdownMenuItem(value: 'pending', child: Text('Pending')),
              DropdownMenuItem(value: 'completed', child: Text('Completed')),
              DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
            ],
            onChanged: (v) {
              // Xử lý cập nhật trạng thái
            },
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                // Xử lý cập nhật trạng thái
              },
              child: const Text('CẬP NHẬT TRẠNG THÁI', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
