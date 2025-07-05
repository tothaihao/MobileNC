import 'package:flutter/material.dart';
import 'purchase_detail_page.dart';
import 'package:do_an_mobile_nc/Layout/masterlayout.dart';

class PurchaseHistoryPage extends StatelessWidget {
  const PurchaseHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Dữ liệu mẫu cho lịch sử mua cafe
    final purchases = [
      {'date': '2025-06-01', 'item': 'Cà phê sữa đá', 'amount': 2, 'price': 35000},
      {'date': '2025-05-28', 'item': 'Cà phê đen', 'amount': 1, 'price': 25000},
      {'date': '2025-05-20', 'item': 'Bạc xỉu', 'amount': 1, 'price': 40000},
      {'date': '2025-05-15', 'item': 'Cappuccino', 'amount': 1, 'price': 55000},
    ];

    return MasterLayout(
      currentIndex: 2,
      
      child: 
      ListView.separated(
        itemCount: purchases.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final purchase = purchases[index];
          return ListTile(
            leading: const Icon(Icons.shopping_bag),
            title: Text(purchase['item'].toString()),
            subtitle: Text('Ngày: ${purchase['date']}\nSố lượng: ${purchase['amount']}'),
            trailing: Text('${purchase['price']} đ'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PurchaseDetailPage(purchase: purchase),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class PurchaseDetailPage extends StatelessWidget {
  final Map<String, dynamic> purchase;

  const PurchaseDetailPage({super.key, required this.purchase});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết đơn hàng'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Thông tin đơn hàng',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Text('Ngày: ${purchase['date']}'),
            Text('Sản phẩm: ${purchase['item']}'),
            Text('Số lượng: ${purchase['amount']}'),
            Text('Giá: ${purchase['price']} đ'),
          ],
        ),
      ),
    );
  }
}
