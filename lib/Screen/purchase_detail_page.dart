import 'package:flutter/material.dart';
import 'package:do_an_mobile_nc/Layout/masterlayout.dart';

class PurchaseDetailPage extends StatelessWidget {
  final Map<String, dynamic> purchase;

  const PurchaseDetailPage({super.key, required this.purchase});

  @override
  Widget build(BuildContext context) {
    return MasterLayout(
      currentIndex: 1, // 🧭 đặt index phù hợp tab menu nếu cần
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Chi tiết đơn hàng cafe'),
          backgroundColor: Colors.brown.shade400,
          foregroundColor: Colors.white,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Thông tin đơn hàng cafe',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Text('Ngày mua: ${purchase['date']}', style: const TextStyle(fontSize: 16)),
              Text('Tên món: ${purchase['item']}', style: const TextStyle(fontSize: 16)),
              Text('Số lượng: ${purchase['amount']}', style: const TextStyle(fontSize: 16)),
              Text('Thành tiền: ${purchase['price']} đ', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 24),
              const Text(
                'Cảm ơn bạn đã mua cafe tại quán!',
                style: TextStyle(fontSize: 15, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
