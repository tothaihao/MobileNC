import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/voucher_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/address_provider.dart';
import '../../models/order_model.dart';
import '../../models/cart_model.dart';
import '../../theme/colors.dart';
import '../../widgets/district_ward_picker.dart';
import 'package:intl/intl.dart';
import '../../services/momo_service.dart';
import '../../services/paypal_service.dart';

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
                  const Text('Tạm tính:', style: TextStyle(fontSize: 16)),
                  Text(
                    _formatCurrency(cart.totalPrice),
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
              if (voucherProvider.appliedVoucher != null) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Giảm giá:', style: TextStyle(fontSize: 16, color: Colors.green)),
                    Text(
                      '-${_formatCurrency(voucherProvider.discountAmount)}',
                      style: const TextStyle(fontSize: 16, color: Colors.green),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Tổng cộng:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(
                    _formatCurrency(_calculateFinalTotal(cart, voucherProvider)),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
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
                    onPressed: voucherProvider.isLoading ? null : () async {
                      if (_voucherController.text.isNotEmpty) {
                        voucherProvider.clearMessages();
                        final success = await voucherProvider.applyVoucher(
                          _voucherController.text, 
                          cart.totalPrice
                        );
                        if (mounted) {
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(voucherProvider.successMessage ?? 'Áp dụng mã giảm giá thành công!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(voucherProvider.error ?? 'Không thể áp dụng mã giảm giá'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      }
                    },
                    child: voucherProvider.isLoading 
                      ? const SizedBox(
                          width: 16, height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2)
                        )
                      : const Text('Áp dụng'),
                  ),
                ],
              ),
              if (voucherProvider.appliedVoucher != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Mã: ${voucherProvider.appliedVoucher!.code}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Giảm: ${voucherProvider.discountAmount.toStringAsFixed(0)} VNĐ',
                              style: const TextStyle(color: Colors.green),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () {
                          voucherProvider.clearAppliedVoucher();
                          _voucherController.clear();
                        },
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              // Phương thức thanh toán
              const Text('Phương thức thanh toán', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Column(
                children: [
                  RadioListTile<String>(
                    title: const Text('Thanh toán khi nhận hàng'),
                    value: 'cash',
                    groupValue: _selectedPaymentMethod,
                    onChanged: (value) {
                      setState(() {
                        _selectedPaymentMethod = value;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Thanh toán MoMo'),
                    value: 'momo',
                    groupValue: _selectedPaymentMethod,
                    onChanged: (value) {
                      setState(() {
                        _selectedPaymentMethod = value;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Thanh toán PayPal'),
                    value: 'paypal',
                    groupValue: _selectedPaymentMethod,
                    onChanged: (value) {
                      setState(() {
                        _selectedPaymentMethod = value;
                      });
                    },
                  ),
                ],
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
            _formatCurrency(item.price * item.quantity),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  double _calculateFinalTotal(Cart cart, VoucherProvider voucherProvider) {
    double total = cart.totalPrice.toDouble();
    if (voucherProvider.appliedVoucher != null) {
      total -= voucherProvider.discountAmount;
    }
    return total > 0 ? total : 0;
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
    final voucherProvider = context.read<VoucherProvider>();
    final String? voucherCode = voucherProvider.appliedVoucher?.code;
    final finalTotal = _calculateFinalTotal(cart, voucherProvider);
    
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
      totalAmount: finalTotal.toInt(),
      orderStatus: 'pending',
      addressId: _selectedAddressId,
      address: null,
      voucherCode: voucherCode,
      paymentMethod: _selectedPaymentMethod ?? 'cash',
      paymentStatus: 'pending',
    );

    // Handle different payment methods
    if (_selectedPaymentMethod == 'cash') {
      await _processCashOrder(order, cart, user.id);
    } else if (_selectedPaymentMethod == 'momo') {
      await _processMomoPayment(order, cart, user.id, finalTotal);
    } else if (_selectedPaymentMethod == 'paypal') {
      await _processPayPalPayment(order, cart, user.id, finalTotal);
    }
  }

  Future<void> _processCashOrder(Order order, Cart cart, String userId) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final success = await context.read<OrderProvider>().createOrder(order);
    Navigator.of(context).pop(); // Close loading

    if (success && mounted) {
      await context.read<CartProvider>().fetchCart(userId);
      Navigator.pushReplacementNamed(context, '/success');
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đặt hàng thất bại!'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _processMomoPayment(Order order, Cart cart, String userId, double finalTotal) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final payUrl = await MomoService.createMomoPayment(
        amount: finalTotal.toInt(),
        orderInfo: 'Thanh toán đơn hàng #${DateTime.now().millisecondsSinceEpoch}',
        redirectUrl: 'https://example.com/success',
      );

      Navigator.of(context).pop(); // Close loading

      if (payUrl != null) {
        // Create order first
        final success = await context.read<OrderProvider>().createOrder(order);
        if (success && mounted) {
          // TODO: Open MoMo payment URL in webview or external browser
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Chuyển hướng đến MoMo để thanh toán...'),
              backgroundColor: Colors.blue,
            ),
          );
          // For now, navigate to success since we can't open webview
          await context.read<CartProvider>().fetchCart(userId);
          Navigator.pushReplacementNamed(context, '/success');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể tạo thanh toán MoMo!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi thanh toán MoMo: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _processPayPalPayment(Order order, Cart cart, String userId, double finalTotal) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final approvalUrl = await PayPalService.createPayPalPayment(
        amount: finalTotal,
        currency: 'USD',
        description: 'Coffee Shop Order Payment',
      );

      Navigator.of(context).pop(); // Close loading

      if (approvalUrl != null) {
        // Create order first
        final success = await context.read<OrderProvider>().createOrder(order);
        if (success && mounted) {
          // TODO: Open PayPal payment URL in webview
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Chuyển hướng đến PayPal để thanh toán...'),
              backgroundColor: Colors.blue,
            ),
          );
          // For now, navigate to success since we can't open webview
          await context.read<CartProvider>().fetchCart(userId);
          Navigator.pushReplacementNamed(context, '/success');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể tạo thanh toán PayPal!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi thanh toán PayPal: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Helper function to format currency
  String _formatCurrency(dynamic amount) {
    if (amount == null) return '0 VNĐ';
    
    int value;
    if (amount is double) {
      value = amount.round();
    } else if (amount is int) {
      value = amount;
    } else {
      value = int.tryParse(amount.toString()) ?? 0;
    }
    
    final formatter = NumberFormat('#,###');
    return '${formatter.format(value)} VNĐ';
  }
}