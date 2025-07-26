import 'package:flutter/material.dart';
import 'package:do_an_mobile_nc/admin/models/admin_order_model.dart';
import 'package:do_an_mobile_nc/admin/models/admin_address_model.dart';
import 'package:do_an_mobile_nc/admin/services/admin_order_service.dart';
import 'package:do_an_mobile_nc/admin/services/admin_address_service.dart';

class OrderDetailPage extends StatefulWidget {
  final String orderId;
  const OrderDetailPage({super.key, required this.orderId});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  Order? order;
  bool isLoading = true;
  Address? shippingAddress;

  @override
  void initState() {
    super.initState();
    fetchOrder();
  }

  Future<void> fetchOrder() async {
    setState(() => isLoading = true);
    try {
      print('DEBUG: Fetching order details for ID: ${widget.orderId}');
      final result = await AdminOrderService.getOrderDetails(widget.orderId);
      print('DEBUG: order = ${result.toJson()}');
      setState(() {
        order = result;
        isLoading = false;
      });

      if (order != null && order!.addressId.isNotEmpty) {
        print('DEBUG: order!.addressId = ${order!.addressId}');
        try {
          final addr = await AdminAddressService.getAddressById(order!.addressId);
          print('DEBUG: address response = $addr');
          setState(() {
            shippingAddress = addr;
          });
        } catch (addressError) {
          print('DEBUG: Error fetching address: $addressError');
          // Không hiển thị lỗi address vì không quan trọng lắm
        }
      }
    } catch (e) {
      print('DEBUG: Error fetching order: $e');
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi tải chi tiết đơn hàng: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> updateStatus(String newStatus) async {
    try {
      print('DEBUG: Updating order ${order!.id} to status: $newStatus');
      final success = await AdminOrderService.updateOrderStatus(order!.id, newStatus);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật trạng thái thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        fetchOrder(); // Reload để cập nhật UI
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật thất bại. Vui lòng thử lại.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('DEBUG: Error updating status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi cập nhật: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatCurrency(int amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M VND';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K VND';
    } else {
      return '$amount VND';
    }
  }

  List<String> getNextValidStatuses(String currentStatus) {
    switch (currentStatus) {
      case 'pending':
        return ['confirmed', 'rejected', 'inShipping'];
      case 'confirmed':
        return ['inShipping', 'rejected'];
      case 'inShipping':
        return ['delivered'];
      case 'delivered':
        return ['completed'];
      default:
        return [];
    }
  }

  String getStatusLabel(String status) {
    switch (status) {
      case 'pending': return 'Chờ xác nhận';
      case 'confirmed': return 'Đã xác nhận';
      case 'inShipping': return 'Đang giao';
      case 'delivered': return 'Hoàn thành';
      case 'rejected': return 'Đã hủy';
      case 'completed': return 'Đã hoàn tất';
      default: return status;
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'pending': return Colors.orange;
      case 'confirmed': return Colors.blue;
      case 'inShipping': return Colors.purple;
      case 'delivered': return Colors.green;
      case 'rejected': return Colors.red;
      case 'completed': return Colors.teal;
      default: return Colors.grey;
    }
  }

  IconData getStatusIcon(String status) {
    switch (status) {
      case 'pending': return Icons.hourglass_empty;
      case 'confirmed': return Icons.verified;
      case 'inShipping': return Icons.local_shipping;
      case 'delivered': return Icons.check_circle;
      case 'rejected': return Icons.cancel;
      case 'completed': return Icons.verified_user;
      default: return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final address = shippingAddress;

    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết đơn hàng')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : order == null
              ? const Center(child: Text('Không tìm thấy đơn hàng'))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: ListView(
                    children: [
                      Text('Mã đơn hàng: ${order!.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('Ngày đặt: ${_formatDate(order!.orderDate)}'),
                      const SizedBox(height: 4),
                      Text('Trạng thái: ${getStatusLabel(order!.orderStatus)}',
                          style: TextStyle(color: getStatusColor(order!.orderStatus))),
                      const SizedBox(height: 4),
                      Text('Phương thức thanh toán: ${order!.paymentMethod.toUpperCase()}'),
                      const SizedBox(height: 4),
                      Text('Trạng thái thanh toán: ${order!.paymentStatus}'),
                      if (order!.voucherCode != null && order!.voucherCode!.isNotEmpty)
                        Text('Mã giảm giá: ${order!.voucherCode}', style: const TextStyle(color: Colors.green)),

                      const Divider(height: 32),
                      const Text('Sản phẩm:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ...order!.cartItems.map(
                        (item) => ListTile(
                          leading: Image.network(
                            item.image,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 50,
                              height: 50,
                              color: Colors.grey[200],
                              child: const Icon(Icons.image_not_supported),
                            ),
                          ),
                          title: Text(item.title),
                          subtitle: Text('Giá: ${_formatCurrency(item.price)} | SL: ${item.quantity}'),
                        ),
                      ),

                      const Divider(height: 32),
                      const Text('Địa chỉ giao hàng:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      if (address != null) ...[
                        Text('Địa chỉ: ${address.address ?? '(trống)'}'),
                        Text('Thành phố: ${address.city ?? '(trống)'}'),
                        Text('Mã vùng: ${address.pincode ?? '(trống)'}'),
                        Text('SĐT: ${address.phone ?? '(trống)'}'),
                        if (address.notes != null && address.notes!.isNotEmpty)
                          Text('Ghi chú: ${address.notes!}', style: const TextStyle(color: Colors.blueGrey)),
                      ] else ...[
                        Text('Không có thông tin địa chỉ hoặc địa chỉ rỗng', style: TextStyle(color: Colors.red)),
                      ],

                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Tổng tiền:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Text('${_formatCurrency(order!.totalAmount)}',
                              style: const TextStyle(fontSize: 16, color: Colors.brown, fontWeight: FontWeight.bold)),
                        ],
                      ),

                      const Divider(height: 32),
                      const Text('Cập nhật trạng thái đơn hàng', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(getStatusIcon(order!.orderStatus), color: getStatusColor(order!.orderStatus), size: 32),
                          const SizedBox(width: 12),
                          Text(
                            getStatusLabel(order!.orderStatus),
                            style: TextStyle(
                              color: getStatusColor(order!.orderStatus),
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Chọn trạng thái tiếp theo để cập nhật. Chỉ các trạng thái hợp lệ mới được phép chuyển.',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                      const SizedBox(height: 16),
                      Builder(
                        builder: (context) {
                          final nextStatuses = getNextValidStatuses(order!.orderStatus);
                          if (nextStatuses.isEmpty) {
                            return const Text('Đơn hàng đã ở trạng thái cuối cùng.', style: TextStyle(color: Colors.grey));
                          }
                          return Wrap(
                            spacing: 16,
                            runSpacing: 12,
                            children: nextStatuses.map((status) {
                              return ElevatedButton.icon(
                                icon: Icon(getStatusIcon(status)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: getStatusColor(status),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                onPressed: () => updateStatus(status),
                                label: Text(getStatusLabel(status)),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
    );
  }
}
