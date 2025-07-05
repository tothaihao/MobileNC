import 'package:flutter/material.dart';

class ReportPage extends StatelessWidget {
  const ReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Dữ liệu mẫu cho báo cáo bán cafe
    final totalOrders = 120;
    final totalRevenue = 18500000;
    final bestSeller = 'Cà phê sữa đá';
    final bestSellerCount = 45;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Báo cáo bán cafe'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Container(
            width: 350,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Thống kê bán cafe',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Tổng số đơn cafe:', style: TextStyle(fontSize: 16)),
                    Text('$totalOrders', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Tổng doanh thu:', style: TextStyle(fontSize: 16)),
                    Text('$totalRevenue đ', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Cafe bán chạy nhất:', style: TextStyle(fontSize: 16)),
                    Text('$bestSeller ($bestSellerCount ly)', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 24),
                const Text('Cảm ơn bạn đã đồng hành cùng quán cafe!', style: TextStyle(fontSize: 15, fontStyle: FontStyle.italic)),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: const Color(0xFFF8F8F8),
    );
  }
}
