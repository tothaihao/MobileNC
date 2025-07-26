import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_support_chat_provider.dart';
import '../../models/support_chat_model.dart';
import '../../theme/colors.dart';
import '../widgets/chat_stats_widget.dart';

class SupportChatPage extends StatefulWidget {
  const SupportChatPage({Key? key}) : super(key: key);

  @override
  State<SupportChatPage> createState() => _SupportChatPageState();
}

class _SupportChatPageState extends State<SupportChatPage> {
  SupportThread? selectedThread;
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AdminSupportChatProvider>();
      provider.loadAllThreads();
      provider.startAutoRefresh();
    });
  }

  @override
  void dispose() {
    context.read<AdminSupportChatProvider>().stopAutoRefresh();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F3),
      appBar: AppBar(
        title: const Text('Quản lý Chat Hỗ trợ'),
        backgroundColor: const Color(0xFF9C6B53),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<AdminSupportChatProvider>().loadAllThreads();
            },
          ),
        ],
      ),
      body: Consumer<AdminSupportChatProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // Chat Statistics
              ChatStatsWidget(
                threads: provider.threads,
                isLoading: provider.isLoading,
              ),
              // Main Chat Interface
              Expanded(
                child: Row(
                  children: [
                    // Thread List (Left Panel)
                    Expanded(
                      flex: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(right: BorderSide(color: Colors.grey.shade300)),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.chat_bubble_outline, color: AppColors.primary),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Cuộc trò chuyện (${provider.threads.length})',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: provider.threads.isEmpty
                                  ? const Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                                          SizedBox(height: 16),
                                          Text('Chưa có cuộc trò chuyện nào'),
                                        ],
                                      ),
                                    )
                                  : ListView.builder(
                                      itemCount: provider.threads.length,
                                      itemBuilder: (context, index) {
                                        final thread = provider.threads[index];
                                        final isSelected = selectedThread?.id == thread.id;
                                        final lastMessage = thread.messages.isNotEmpty ? thread.messages.last : null;
                                        final hasUnreadFromUser = lastMessage?.sender == 'user';

                                        return Container(
                                          decoration: BoxDecoration(
                                            color: isSelected ? AppColors.primary.withOpacity(0.1) : null,
                                            border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                                          ),
                                          child: ListTile(
                                            onTap: () {
                                              setState(() {
                                                selectedThread = thread;
                                              });
                                            },
                                            leading: Stack(
                                              children: [
                                                CircleAvatar(
                                                  backgroundColor: AppColors.primary,
                                                  child: Text(
                                                    thread.userName.isNotEmpty ? thread.userName[0].toUpperCase() : 'U',
                                                    style: const TextStyle(color: Colors.white),
                                                  ),
                                                ),
                                                if (hasUnreadFromUser)
                                                  Positioned(
                                                    right: 0,
                                                    top: 0,
                                                    child: Container(
                                                      width: 12,
                                                      height: 12,
                                                      decoration: const BoxDecoration(
                                                        color: Colors.red,
                                                        shape: BoxShape.circle,
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            title: Text(
                                              thread.userName.isNotEmpty ? thread.userName : 'Khách hàng',
                                              style: TextStyle(
                                                fontWeight: hasUnreadFromUser ? FontWeight.bold : FontWeight.normal,
                                              ),
                                            ),
                                            subtitle: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  thread.userEmail,
                                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                                ),
                                                if (lastMessage != null)
                                                  Text(
                                                    '${lastMessage.sender == 'user' ? '👤' : '👨‍💼'} ${lastMessage.content}',
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight: hasUnreadFromUser ? FontWeight.bold : FontWeight.normal,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            trailing: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  _formatDate(thread.updatedAt),
                                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                                ),
                                                if (hasUnreadFromUser)
                                                  Container(
                                                    margin: const EdgeInsets.only(top: 4),
                                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: Colors.red,
                                                      borderRadius: BorderRadius.circular(10),
                                                    ),
                                                    child: const Text(
                                                      'NEW',
                                                      style: TextStyle(color: Colors.white, fontSize: 10),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Chat Area (Right Panel)
                    Expanded(
                      flex: 2,
                      child: selectedThread == null
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.chat, size: 64, color: Colors.grey),
                                  SizedBox(height: 16),
                                  Text(
                                    'Chọn một cuộc trò chuyện để bắt đầu',
                                    style: TextStyle(fontSize: 16, color: Colors.grey),
                                  ),
                                ],
                              ),
                            )
                          : _buildChatArea(provider),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildChatArea(AdminSupportChatProvider provider) {
    return Column(
      children: [
        // Chat Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primary,
                child: Text(
                  selectedThread!.userName.isNotEmpty ? selectedThread!.userName[0].toUpperCase() : 'U',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedThread!.userName.isNotEmpty ? selectedThread!.userName : 'Khách hàng',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      selectedThread!.userEmail,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Online',
                  style: TextStyle(color: Colors.green, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        // Messages
        Expanded(
          child: Container(
            color: Colors.grey.shade50,
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.all(16),
              itemCount: selectedThread!.messages.length,
              itemBuilder: (context, index) {
                final messages = selectedThread!.messages.reversed.toList();
                final message = messages[index];
                final isAdmin = message.sender == 'admin';
                
                return Align(
                  alignment: isAdmin ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isAdmin ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 3,
                        ),
                      ],
                    ),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.7,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              isAdmin ? Icons.admin_panel_settings : Icons.person,
                              size: 16,
                              color: isAdmin ? Colors.white70 : Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isAdmin ? 'Admin' : 'Khách hàng',
                              style: TextStyle(
                                fontSize: 12,
                                color: isAdmin ? Colors.white70 : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          message.content,
                          style: TextStyle(
                            color: isAdmin ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          message.createdAt != null ? _formatTime(message.createdAt!) : '',
                          style: TextStyle(
                            fontSize: 11,
                            color: isAdmin ? Colors.white60 : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        // Message Input
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Colors.grey.shade300)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    hintText: 'Nhập phản hồi...',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onFieldSubmitted: (_) => _sendAdminMessage(provider),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: const Icon(Icons.send, color: Colors.white),
                  onPressed: provider.isSending ? null : () => _sendAdminMessage(provider),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _sendAdminMessage(AdminSupportChatProvider provider) async {
    if (_messageController.text.trim().isNotEmpty && selectedThread != null) {
      final success = await provider.sendAdminMessage(
        selectedThread!.id,
        _messageController.text.trim(),
      );
      
      if (success) {
        _messageController.clear();
        setState(() {
          selectedThread = provider.threads.firstWhere((t) => t.id == selectedThread!.id);
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(provider.error ?? 'Gửi tin nhắn thất bại'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inDays > 0) {
      return '${diff.inDays}d';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m';
    } else {
      return 'Now';
    }
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
