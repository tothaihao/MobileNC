import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/support_chat_provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/colors.dart';

class SupportChatScreen extends StatefulWidget {
  const SupportChatScreen({Key? key}) : super(key: key);

  @override
  State<SupportChatScreen> createState() => _SupportChatScreenState();
}

class _SupportChatScreenState extends State<SupportChatScreen> {
  final _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null) {
      Provider.of<SupportChatProvider>(context, listen: false).loadThread(user.email);
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<SupportChatProvider>(context);
    final user = Provider.of<AuthProvider>(context).user;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat hỗ trợ'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: user == null
          ? const Center(child: Text('Bạn cần đăng nhập để chat với admin.'))
          : Column(
              children: [
                Expanded(
                  child: chatProvider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : chatProvider.thread == null
                          ? const Center(child: Text('Chưa có hội thoại nào.'))
                          : ListView.builder(
                              reverse: true,
                              itemCount: chatProvider.thread!.messages.length,
                              itemBuilder: (context, index) {
                                final msg = chatProvider.thread!.messages.reversed.toList()[index];
                                final isUser = msg.sender == 'user';
                                return Align(
                                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isUser ? AppColors.primaryLight : AppColors.secondaryLight,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(msg.content),
                                  ),
                                );
                              },
                            ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: const InputDecoration(
                            hintText: 'Nhập tin nhắn...'
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send, color: AppColors.primary),
                        onPressed: chatProvider.isLoading
                            ? null
                            : () async {
                                if (_messageController.text.trim().isNotEmpty && user != null) {
                                  await chatProvider.sendUserMessage(
                                    user.email,
                                    user.userName,
                                    _messageController.text.trim(),
                                  );
                                  _messageController.clear();
                                }
                              },
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
} 