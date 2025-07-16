import 'package:flutter/material.dart';
import 'package:do_an_mobile_nc/models/user_model.dart';

class UserDetailPage extends StatelessWidget {
  final User user;

  const UserDetailPage({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isAdmin = user.role == 'admin';
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F3),
      appBar: AppBar(
        title: const Text('Chi tiết người dùng'),
        backgroundColor: const Color(0xFFD7B7A3),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: const Color(0xFFD7B7A3),
              backgroundImage: (user.avatar != null && user.avatar!.isNotEmpty)
                  ? NetworkImage(user.avatar!)
                  : null,
              child: (user.avatar == null || user.avatar!.isEmpty)
                  ? Text(
                      user.userName.isNotEmpty ? user.userName[0].toUpperCase() : '?',
                      style: const TextStyle(fontSize: 40, color: Colors.white),
                    )
                  : null,
            ),
            const SizedBox(height: 20),
            Text(
              user.userName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(user.email, style: const TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isAdmin ? Colors.red[100] : Colors.green[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isAdmin ? 'Quản trị viên' : 'Người dùng',
                style: TextStyle(
                  color: isAdmin ? Colors.red[800] : Colors.green[800],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Divider(thickness: 1),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Địa chỉ:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.brown[700]),
              ),
            ),
            const SizedBox(height: 6),
            if (user.addresses != null && user.addresses!.isNotEmpty)
              ...user.addresses!.map((address) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, size: 18, color: Colors.brown),
                        const SizedBox(width: 6),
                        Expanded(child: Text(address)),
                      ],
                    ),
                  ))
            else
              const Text('Không có địa chỉ nào.'),
          ],
        ),
      ),
    );
  }
}
