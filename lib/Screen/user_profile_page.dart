import 'package:do_an_mobile_nc/Layout/masterlayout.dart';
import 'package:flutter/material.dart';
import 'purchase_history_page.dart';
import 'package:do_an_mobile_nc/admin/report_page.dart';


class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});

  @override
Widget build(BuildContext context) {
  return MasterLayout(
    currentIndex: 4,
    
    child: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          width: 350,
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
            children: [
              const SizedBox(height: 12,),
              const Text('Profile', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              // Avatar
              CircleAvatar(
                radius: 48,
                backgroundImage: NetworkImage('https://images.unsplash.com/photo-1504674900247-0877df9cc836'),
              ),
              const SizedBox(height: 16),
              // Name
              const Text(
                'Tan',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              // Email
              const Text(
                'nhuttan288204@gmail.com',
                style: TextStyle(fontSize: 15, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              // Role
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Color(0xFFF5E6D8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Role: user',
                  style: TextStyle(fontSize: 13, color: Color(0xFFB48A64)),
                ),
              ),
              const SizedBox(height: 24),
              // Upload avatar section
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Color(0xFFF5E6D8),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Icon(Icons.person_add, size: 48, color: Color(0xFFB48A64)),
              ),
              const SizedBox(height: 16),
              // Upload box
              DottedBorderBox(),
              const SizedBox(height: 16),
              // Upload button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFD6BFA7),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {},
                  child: const Text('Upload Avatar'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    ),
  );
}}


class DottedBorderBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFD6BFA7),
          width: 1.5,
          style: BorderStyle.solid,
        ),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.cloud_upload_outlined, color: Color(0xFFB48A64)),
            SizedBox(width: 8),
            Text(
              'Drag & drop or click to upload image',
              style: TextStyle(color: Color(0xFFB48A64)),
            ),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trang chủ')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UserProfilePage()),
                );
              },
              child: const Text('Xem thông tin cá nhân'),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PurchaseHistoryPage()),
                );
              },
              child: const Text('Xem lịch sử mua hàng'),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ReportPage()),
                );
              },
              child: const Text('Xem báo cáo thống kê'),
            ),
          ),
        ],
      ),
    );
  }
}
