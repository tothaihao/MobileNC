import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/voucher_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/address_provider.dart'; // Added import for AddressProvider
import '../../models/order_model.dart';
import '../../models/cart_model.dart';
import '../../theme/colors.dart';
import '../../widgets/district_ward_picker.dart';

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

  String? _selectedDistrict;
  String? _selectedWard;
  String? _selectedAddressId;
  String? _selectedPaymentMethod = 'cash';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().user;
      if (user != null) {
        context.read<CartProvider>().fetchCart(user.id);
        context.read<VoucherProvider>().fetchVouchers();
        context.read<AddressProvider>().fetchAddresses(user.id); // Fetch addresses for dropdown
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
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Thanh toán', style: TextStyle(color: AppColors.textPrimary)), backgroundColor: AppColors.white, elevation: 0, iconTheme: IconThemeData(color: AppColors.primary)),
        body: const Center(child: Text('Bạn chưa đăng nhập', style: TextStyle(color: AppColors.textSecondary))),
      );
    }

    if (cart == null || cart.items.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Thanh toán', style: TextStyle(color: AppColors.textPrimary)), backgroundColor: AppColors.white, elevation: 0, iconTheme: IconThemeData(color: AppColors.primary)),
        body: const Center(child: Text('Giỏ hàng trống', style: TextStyle(color: AppColors.textSecondary))),
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
              // Địa chỉ giao hàng
              const Text(
                'Địa chỉ giao hàng',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Consumer<AddressProvider>(
                builder: (context, addressProvider, _) {
                  final addresses = addressProvider.addresses;
                  return DropdownButtonFormField<String>(
                    value: _selectedAddressId,
                    hint: const Text('Chọn địa chỉ đã lưu'),
                    items: addresses.map((address) => DropdownMenuItem(
                      value: address.id,
                      child: Text('${address.streetAddress}, ${address.ward}, ${address.district}, ${address.city}'),
                    )).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedAddressId = value;
                        if (value != null) {
                          final selected = addresses.firstWhere((a) => a.id == value);
                          _addressController.text = selected.streetAddress;
                          _selectedDistrict = selected.district;
                          _selectedWard = selected.ward;
                          _phoneController.text = selected.phone;
                        }
                      });
                    },
                    validator: (value) => value == null ? 'Vui lòng chọn địa chỉ giao hàng' : null,
                  );
                },
              ),
              const SizedBox(height: 16),
              // Ẩn các trường nhập địa chỉ chi tiết, quận, phường, số điện thoại (chỉ hiển thị, không cho sửa)
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Địa chỉ chi tiết',
                  border: OutlineInputBorder(),
                ),
                enabled: false,
              ),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: _selectedDistrict,
                decoration: const InputDecoration(
                  labelText: 'Quận/Huyện',
                  border: OutlineInputBorder(),
                ),
                enabled: false,
              ),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: _selectedWard,
                decoration: const InputDecoration(
                  labelText: 'Phường/Xã',
                  border: OutlineInputBorder(),
                ),
                enabled: false,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Số điện thoại',
                  border: OutlineInputBorder(),
                ),
                enabled: false,
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
              // Phương thức thanh toán
              const Text('Phương thức thanh toán', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedPaymentMethod,
                items: const [
                  DropdownMenuItem(value: 'cash', child: Text('Thanh toán khi nhận hàng')),
                  DropdownMenuItem(value: 'momo', child: Text('Momo')),
                  DropdownMenuItem(value: 'card', child: Text('Thẻ ngân hàng')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedPaymentMethod = value;
                  });
                },
              ),
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
    if (_selectedAddressId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn địa chỉ giao hàng!'), backgroundColor: Colors.red),
      );
      return;
    }
    final user = context.read<AuthProvider>().user!;
    final String? voucherCode = _voucherController.text.isNotEmpty ? _voucherController.text : null;
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
      addressId: _selectedAddressId,
      address: null,
      voucherCode: voucherCode,
      paymentMethod: _selectedPaymentMethod ?? 'cash',
      paymentStatus: 'pending',
    );
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    final success = await context.read<OrderProvider>().createOrder(order);
    Navigator.of(context).pop(); // Close loading
    if (success && mounted) {
      await context.read<CartProvider>().fetchCart(user.id);
      Navigator.pushReplacementNamed(context, '/success');
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đặt hàng thất bại!'), backgroundColor: Colors.red),
      );
    }
  }
}