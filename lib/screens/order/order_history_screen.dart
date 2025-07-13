import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/order_model.dart';
import '../../Layout/masterlayout.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({Key? key}) : super(key: key);

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().user;
      if (user != null) {
        context.read<OrderProvider>().fetchOrders(user.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final user = Provider.of<AuthProvider>(context).user;

    return MasterLayout(
      currentIndex: 2, // Order history tab
      child: orderProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : orderProvider.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      Text('Lỗi: ${orderProvider.error}', style: TextStyle(fontSize: 16)),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          final user = Provider.of<AuthProvider>(context, listen: false).user;
                          if (user != null) {
                            context.read<OrderProvider>().fetchOrders(user.id);
                          }
                        },
                        icon: Icon(Icons.refresh),
                        label: Text('Thử lại'),
                      ),
                    ],
                  ),
                )
              : user == null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person_outline, color: Colors.grey, size: 48),
                          const SizedBox(height: 16),
                          const Text('Bạn chưa đăng nhập', style: TextStyle(fontSize: 16)),
                        ],
                      ),
                    )
                  : orderProvider.orders.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.receipt_long, color: Colors.grey, size: 48),
                              const SizedBox(height: 16),
                              const Text('Chưa có đơn hàng nào', style: TextStyle(fontSize: 16)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: orderProvider.orders.length,
                          itemBuilder: (context, index) {
                            final order = orderProvider.orders[index];
                            return _buildOrderCard(order);
                          },
                        ),
    );
  }

  Widget _buildOrderCard(Order order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          context.read<OrderProvider>().fetchOrderDetail(order.id);
          _showOrderDetail(order);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Đơn hàng #${order.id.substring(0, 8)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  _buildStatusChip(order.orderStatus),
                ],
              ),
              const SizedBox(height: 8),
              Text('Số lượng sản phẩm: ${order.cartItems.length}'),
              const SizedBox(height: 8),
              Text(
                'Tổng tiền: ${order.totalAmount.toStringAsFixed(0)} VNĐ',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              // Bỏ phần địa chỉ vì không có trường address trong model Order
              // if (order.address != null) ...[
              //   const SizedBox(height: 8),
              //   Text('Địa chỉ: ${order.address}'),
              // ],
              if (order.createdAt != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Ngày đặt: ${_formatDate(order.createdAt!)}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String text;

    switch (status.toLowerCase()) {
      case 'pending':
        color = Colors.orange;
        text = 'Chờ xử lý';
        break;
      case 'processing':
        color = Colors.blue;
        text = 'Đang xử lý';
        break;
      case 'shipped':
        color = Colors.purple;
        text = 'Đang giao';
        break;
      case 'delivered':
        color = Colors.green;
        text = 'Đã giao';
        break;
      case 'cancelled':
        color = Colors.red;
        text = 'Đã hủy';
        break;
      default:
        color = Colors.grey;
        text = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 12),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }

  void _showOrderDetail(Order order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Chi tiết đơn hàng #${order.id.substring(0, 8)}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    ...order.cartItems.map((item) => _buildOrderItem(item)),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Tổng cộng:', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                          '${order.totalAmount.toStringAsFixed(0)} VNĐ',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Bỏ phần note vì không có trường note trong model Order
                    // if (order.note != null) ...[
                    //   const Text('Ghi chú:', style: TextStyle(fontWeight: FontWeight.bold)),
                    //   Text(order.note!),
                    //   const SizedBox(height: 16),
                    // ],
                    _buildStatusChip(order.orderStatus),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderItem(OrderItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: NetworkImage(item.image),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('Số lượng: ${item.quantity}'),
                Text('${item.price.toStringAsFixed(0)} VNĐ'),
              ],
            ),
          ),
          Text(
            '${(item.price * item.quantity).toStringAsFixed(0)} VNĐ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
} 