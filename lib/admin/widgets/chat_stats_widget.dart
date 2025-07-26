import 'package:flutter/material.dart';
import '../../models/support_chat_model.dart';
import '../../theme/colors.dart';

class ChatStatsWidget extends StatelessWidget {
  final List<SupportThread> threads;
  final bool isLoading;

  const ChatStatsWidget({
    Key? key,
    required this.threads,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final stats = _calculateStats();
    
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.primary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: isLoading 
        ? _buildLoadingStats()
        : _buildStatsContent(stats),
    );
  }

  Widget _buildLoadingStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(4, (index) => _buildLoadingStatItem()),
    );
  }

  Widget _buildLoadingStatItem() {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 60,
          height: 12,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsContent(ChatStats stats) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem(
          'Tổng Chat',
          stats.totalChats.toString(),
          Icons.chat_bubble_outline,
          AppColors.primary,
        ),
        _buildStatItem(
          'Chờ Phản Hồi',
          stats.pendingChats.toString(),
          Icons.schedule,
          Colors.orange,
        ),
        _buildStatItem(
          'Đã Xử Lý',
          stats.resolvedChats.toString(),
          Icons.check_circle_outline,
          Colors.green,
        ),
        _buildStatItem(
          'Hôm Nay',
          stats.todayChats.toString(),
          Icons.today,
          Colors.blue,
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  ChatStats _calculateStats() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    final totalChats = threads.length;
    
    final pendingChats = threads.where((thread) {
      if (thread.messages.isEmpty) return false;
      final lastMessage = thread.messages.last;
      return lastMessage.sender != 'admin';
    }).length;
    
    final resolvedChats = threads.where((thread) {
      if (thread.messages.isEmpty) return false;
      final lastMessage = thread.messages.last;
      return lastMessage.sender == 'admin';
    }).length;
    
    final todayChats = threads.where((thread) {
      if (thread.updatedAt == null) return false;
      final threadDate = DateTime(
        thread.updatedAt!.year,
        thread.updatedAt!.month,
        thread.updatedAt!.day,
      );
      return threadDate.isAtSameMomentAs(today);
    }).length;

    return ChatStats(
      totalChats: totalChats,
      pendingChats: pendingChats,
      resolvedChats: resolvedChats,
      todayChats: todayChats,
    );
  }
}

class ChatStats {
  final int totalChats;
  final int pendingChats;
  final int resolvedChats;
  final int todayChats;

  ChatStats({
    required this.totalChats,
    required this.pendingChats,
    required this.resolvedChats,
    required this.todayChats,
  });
}
