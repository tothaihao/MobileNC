import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/voucher_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/order_model.dart';
import '../../models/cart_model.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({Key? key}) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _noteController = TextEditingController();
  final _voucherController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().user;
      if (user != null) {
        context.read<CartProvider>().fetchCart(user.id);
        context.read<VoucherProvider>().fetchVouchers();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final voucherProvider = Provider.of<VoucherProvider>(context);
    final user = Provider.of<AuthProvider>(context).user;
    final cart = cartProvider.cart;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Thanh toán')),
        body: const Center(child: Text('Bạn chưa đăng nhập')),
      );
    }

    if (cart == null || cart.items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Thanh toán')),
        body: const Center(child: Text('Giỏ hàng trống')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Thanh toán')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Summary
              const Text(
                'Thông tin đơn hàng',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...cart.items.map((item) => _buildOrderItem(item)),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Tổng cộng:'),
                  Text(
                    '${cart.totalPrice.toStringAsFixed(0)} VNĐ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Delivery Information
              const Text(
                'Thông tin giao hàng',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Địa chỉ giao hàng',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Nhập địa chỉ' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Số điện thoại',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Nhập số điện thoại' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'Ghi chú (tùy chọn)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              // Voucher Section
              const Text(
                'Mã giảm giá',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _voucherController,
                      decoration: const InputDecoration(
                        labelText: 'Nhập mã giảm giá',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (_voucherController.text.isNotEmpty) {
                        voucherProvider.checkVoucher(_voucherController.text);
                      }
                    },
                    child: const Text('Áp dụng'),
                  ),
                ],
              ),
              if (voucherProvider.checkedVoucher != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    voucherProvider.checkedVoucher!.type == 'percent'
                      ? 'Giảm ${voucherProvider.checkedVoucher!.value}%'
                      : 'Giảm ${voucherProvider.checkedVoucher!.value} VNĐ',
                    style: const TextStyle(color: Colors.green),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              // Place Order Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _placeOrder(cart),
                  child: const Text('Đặt hàng'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderItem(CartItem item) {
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

  void _placeOrder(Cart cart) async {
    if (!_formKey.currentState!.validate()) return;

    final user = context.read<AuthProvider>().user!;
    // TODO: Lấy addressId thực tế từ user/address provider, hiện tại chỉ demo bằng null
    final String? addressId = null; // Thay bằng id thực tế nếu có
    final String paymentMethod = 'cash'; // Hoặc cho user chọn
    final String? voucherCode = _voucherController.text.isNotEmpty ? _voucherController.text : null;

    if (addressId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn địa chỉ giao hàng!')),
      );
      return;
    }

    final order = Order(
      id: '',
      userId: user.id,
      cartItems: cart.items.map((item) => OrderItem(
        productId: item.productId,
        title: item.title,
        image: item.image,
        price: item.price,
        quantity: item.quantity,
      )).toList(),
      totalAmount: cart.totalPrice,
      orderStatus: 'pending',
      addressId: addressId,
      voucherCode: voucherCode,
      paymentMethod: paymentMethod,
      paymentStatus: 'pending',
    );

    final success = await context.read<OrderProvider>().createOrder(order);
    if (success && mounted) {
      Navigator.pushReplacementNamed(context, '/success');
    }
  }
}