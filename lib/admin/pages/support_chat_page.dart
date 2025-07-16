import 'package:flutter/material.dart';
import '../../services/admin_support_chat_service.dart';

class SupportChatPage extends StatefulWidget {
  const SupportChatPage({Key? key}) : super(key: key);

  @override
  State<SupportChatPage> createState() => _SupportChatPageState();
}

class _SupportChatPageState extends State<SupportChatPage> {
  final AdminSupportChatService _service = AdminSupportChatService();
  List<Map<String, dynamic>> threads = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchThreads();
  }

  Future<void> _fetchThreads() async {
    setState(() => isLoading = true);
    try {
      final data = await _service.fetchThreads();
      setState(() => threads = data);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tải danh sách chat: $e'), backgroundColor: Colors.red),
      );
    }
    setState(() => isLoading = false);
  }

  void _openThread(Map<String, dynamic> thread) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SupportChatDetailPage(threadId: thread['id'], userName: thread['userName']),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý Chat/Support')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: threads.length,
              itemBuilder: (context, index) {
                final thread = threads[index];
                return ListTile(
                  leading: const Icon(Icons.chat_bubble_outline),
                  title: Text(thread['userName'] ?? ''),
                  subtitle: Text(thread['lastMessage'] ?? ''),
                  trailing: Text(thread['updatedAt']?.toString().substring(0, 16) ?? ''),
                  onTap: () => _openThread(thread),
                );
              },
            ),
    );
  }
}

class SupportChatDetailPage extends StatefulWidget {
  final String threadId;
  final String userName;
  const SupportChatDetailPage({Key? key, required this.threadId, required this.userName}) : super(key: key);

  @override
  State<SupportChatDetailPage> createState() => _SupportChatDetailPageState();
}

class _SupportChatDetailPageState extends State<SupportChatDetailPage> {
  final AdminSupportChatService _service = AdminSupportChatService();
  Map<String, dynamic>? threadDetail;
  bool isLoading = false;
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchThreadDetail();
  }

  Future<void> _fetchThreadDetail() async {
    setState(() => isLoading = true);
    try {
      final data = await _service.fetchThreadDetail(widget.threadId);
      setState(() => threadDetail = data);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tải chi tiết chat: $e'), backgroundColor: Colors.red),
      );
    }
    setState(() => isLoading = false);
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;
    final success = await _service.sendMessage(widget.threadId, message);
    if (success) {
      _messageController.clear();
      _fetchThreadDetail();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gửi tin nhắn thất bại!'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat với ${widget.userName}')),
      body: isLoading || threadDetail == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: (threadDetail!['messages'] as List).length,
                    itemBuilder: (context, index) {
                      final msg = threadDetail!['messages'][index];
                      final isAdmin = msg['sender'] == 'admin';
                      return Align(
                        alignment: isAdmin ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isAdmin ? Colors.brown[100] : Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(msg['message'] ?? ''),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: const InputDecoration(
                            hintText: 'Nhập tin nhắn...',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _sendMessage,
                        child: const Icon(Icons.send),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.brown,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
} 