import 'package:flutter/material.dart';

class UserDetailPage extends StatelessWidget {
  final Map<String, dynamic> user;
  const UserDetailPage({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isAdmin = user['role'] == 'admin';

    // Lấy các trường, nếu không có thì để giá trị mặc định
    final String name = user['name'] ?? 'Chưa cập nhật';
    final String email = user['email'] ?? 'Chưa cập nhật';
    final String id = user['id'] ?? 'Chưa cập nhật';
    final String role = user['role'] ?? 'user';
    final String? avatar = user['avatar'];
    final String phone = user['phone'] ?? 'Chưa cập nhật';
    final String address = user['address'] ?? 'Chưa cập nhật';
    final String createdAt = user['createdAt'] ?? 'Chưa cập nhật';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết người dùng'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Center(
              child: avatar != null
                  ? CircleAvatar(
                      backgroundImage: NetworkImage(avatar),
                      radius: 48,
                    )
                  : CircleAvatar(
                      backgroundColor: Colors.brown[100],
                      radius: 48,
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : '?',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 36, color: Colors.brown),
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: isAdmin ? Colors.red[200] : Colors.green[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  role,
                  style: TextStyle(
                    color: isAdmin ? Colors.red[900] : Colors.green[900],
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _infoTile(Icons.email, 'Email', email),
            _infoTile(Icons.perm_identity, 'ID', id),
            _infoTile(Icons.phone, 'Số điện thoại', phone),
            _infoTile(Icons.home, 'Địa chỉ', address),
            _infoTile(Icons.calendar_today, 'Ngày tạo', createdAt),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(IconData icon, String title, String value) {
    return ListTile(
      leading: Icon(icon, color: Colors.brown),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(value),
      contentPadding: const EdgeInsets.symmetric(vertical: 2, horizontal: 0),
    );
  }
}
