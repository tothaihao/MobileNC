import 'package:flutter/material.dart';
import '../../Layout/masterlayout.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({Key? key}) : super(key: key);

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MasterLayout(
      currentIndex: 3, // Contact tab
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Contact Information
            const Text(
              'Thông tin liên hệ',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildContactItem(
                      icon: Icons.location_on,
                      title: 'Địa chỉ',
                      content: '123 Đường ABC, Quận 1, TP.HCM',
                    ),
                    const Divider(),
                    _buildContactItem(
                      icon: Icons.phone,
                      title: 'Điện thoại',
                      content: '0123 456 789',
                    ),
                    const Divider(),
                    _buildContactItem(
                      icon: Icons.email,
                      title: 'Email',
                      content: 'info@coffeeshop.com',
                    ),
                    const Divider(),
                    _buildContactItem(
                      icon: Icons.access_time,
                      title: 'Giờ làm việc',
                      content: '7:00 - 22:00 (Thứ 2 - Chủ nhật)',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Contact Form
            const Text(
              'Gửi tin nhắn cho chúng tôi',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Họ và tên',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Nhập họ và tên' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Nhập email' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      labelText: 'Nội dung tin nhắn',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 4,
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Nhập nội dung' : null,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // TODO: Implement send message functionality
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Tin nhắn đã được gửi!'),
                            ),
                          );
                          _nameController.clear();
                          _emailController.clear();
                          _messageController.clear();
                        }
                      },
                      child: const Text('Gửi tin nhắn'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Store Information
            const Text(
              'Về chúng tôi',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Coffee Shop',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Chúng tôi là một cửa hàng cà phê chất lượng cao, chuyên phục vụ những tách cà phê ngon nhất với nguyên liệu tươi mới và công thức độc đáo.',
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Dịch vụ của chúng tôi:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    _buildServiceItem('• Cà phê chất lượng cao'),
                    _buildServiceItem('• Giao hàng tận nơi'),
                    _buildServiceItem('• Phục vụ 24/7'),
                    _buildServiceItem('• Khuyến mãi thường xuyên'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.green),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(content),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildServiceItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(text),
    );
  }
} 