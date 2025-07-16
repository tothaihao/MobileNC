import 'package:flutter/material.dart';
import 'user_detail_page.dart';
import '../../services/admin_user_service.dart';

class UserPage extends StatefulWidget {
  const UserPage({Key? key}) : super(key: key);

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final AdminUserService _service = AdminUserService();
  List<Map<String, dynamic>> users = [];

  String searchText = '';
  String selectedRole = 'Tất cả';

  final List<String> roles = ['Tất cả', 'admin', 'user'];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      final data = await _service.fetchUsers();
      setState(() => users = data);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tải user: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _deleteUser(String id) async {
    final success = await _service.deleteUser(id);
    if (success) {
      _fetchUsers();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Xóa user thành công!'), backgroundColor: Colors.green),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Xóa user thất bại!'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredUsers = users.where((u) {
      final matchRole = selectedRole == 'Tất cả' ? true : u['role'] == selectedRole;
      final matchSearch = u['name'].toString().toLowerCase().contains(searchText.toLowerCase()) ||
          u['email'].toString().toLowerCase().contains(searchText.toLowerCase());
      return matchRole && matchSearch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('User List'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Thanh tìm kiếm
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm tên, email...',
                  prefixIcon: const Icon(Icons.search),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                onChanged: (value) => setState(() => searchText = value),
              ),
            ),
            // Filter vai trò
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: roles.map((role) {
                  final isSelected = selectedRole == role;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    child: ChoiceChip(
                      label: Text(role[0].toUpperCase() + role.substring(1)),
                      selected: isSelected,
                      selectedColor: Colors.brown[200],
                      onSelected: (_) => setState(() => selectedRole = role),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.brown,
                        fontWeight: FontWeight.bold,
                      ),
                      backgroundColor: Colors.brown[50],
                    ),
                  );
                }).toList(),
              ),
            ),
            // Danh sách user
            Expanded(
              child: filteredUsers.isEmpty
                  ? const Center(child: Text('Không có người dùng nào'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemCount: filteredUsers.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final user = filteredUsers[index];
                        return UserCard(
                          user: user,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => UserDetailPage(user: user),
                              ),
                            );
                          },
                          onDelete: () => _deleteUser(user['id']),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Xử lý thêm user
        },
        child: const Icon(Icons.person_add),
        backgroundColor: Colors.brown,
        tooltip: 'Thêm người dùng',
      ),
    );
  }
}

class UserCard extends StatelessWidget {
  final Map<String, dynamic> user;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const UserCard({
    Key? key,
    required this.user,
    required this.onTap,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isAdmin = user['role'] == 'admin';
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        leading: user['avatar'] != null
            ? CircleAvatar(
                backgroundImage: NetworkImage(user['avatar']),
                radius: 26,
              )
            : CircleAvatar(
                backgroundColor: Colors.brown[100],
                radius: 26,
                child: Text(
                  user['name'][0].toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.brown),
                ),
              ),
        title: Text(
          user['name'],
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user['email'], style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 2),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isAdmin ? Colors.red[200] : Colors.green[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    user['role'],
                    style: TextStyle(
                      color: isAdmin ? Colors.red[900] : Colors.green[900],
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'ID: ${user['id']}',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red, size: 22),
          onPressed: onDelete,
          tooltip: 'Xóa',
        ),
      ),
    );
  }
}
