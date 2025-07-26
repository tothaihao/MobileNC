import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/voucher_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/address_provider.dart';
import '../../models/order_model.dart';
import '../../models/cart_model.dart';
import '../../models/address_model.dart';
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
  bool _useSavedAddress = true;
  bool _saveNewAddress = false;
  String _city = 'TP. Hồ Chí Minh'; // Default city

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().user;
      if (user != null) {
        context.read<CartProvider>().fetchCart(user.id);
        context.read<VoucherProvider>().fetchVouchers();
        context.read<AddressProvider>().fetchAddresses(user.id);
      }
    });
  }

  @override
  void dispose() {
    _addressController.dispose();
    _phoneController.dispose();
    _noteController.dispose();
    _voucherController.dispose();
    super.dispose();
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
              
              // Toggle between saved addresses and new address
              Consumer<AddressProvider>(
                builder: (context, addressProvider, _) {
                  final addresses = addressProvider.addresses;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Toggle buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: addresses.isNotEmpty ? () {
                                setState(() {
                                  _useSavedAddress = true;
                                  _selectedAddressId = null;
                                  _clearAddressFields();
                                });
                              } : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _useSavedAddress ? AppColors.primary : Colors.grey[300],
                                foregroundColor: _useSavedAddress ? Colors.white : Colors.grey[600],
                              ),
                              child: Text('Địa chỉ đã lưu (${addresses.length})'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _useSavedAddress = false;
                                  _selectedAddressId = null;
                                  _clearAddressFields();
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: !_useSavedAddress ? AppColors.primary : Colors.grey[300],
                                foregroundColor: !_useSavedAddress ? Colors.white : Colors.grey[600],
                              ),
                              child: const Text('Địa chỉ mới'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Address selection/input based on toggle
                      if (_useSavedAddress && addresses.isNotEmpty) ...[
                        // Dropdown for saved addresses
                        DropdownButtonFormField<String>(
                    value: _selectedAddressId,
                    hint: const Text('Chọn địa chỉ đã lưu'),
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                    items: addresses.map((address) => DropdownMenuItem(
                      value: address.id,
                            child: Text(
                              '${address.streetAddress}, ${address.ward}, ${address.district}, ${address.city}',
                              overflow: TextOverflow.ellipsis,
                            ),
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
                                _city = selected.city;
                        }
                      });
                    },
                    validator: (value) => value == null ? 'Vui lòng chọn địa chỉ giao hàng' : null,
              ),
              const SizedBox(height: 16),
                        // Show selected address details (editable)
                        if (_selectedAddressId != null) ...[
                          const Text(
                            'Thông tin địa chỉ (có thể chỉnh sửa):',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ],
                      
                      // Address input fields (always visible when not using saved address or when editing)
                      if (!_useSavedAddress || _selectedAddressId != null) ...[
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                            labelText: 'Địa chỉ chi tiết *',
                  border: OutlineInputBorder(),
                            hintText: 'Ví dụ: 123 Đường ABC, Phường XYZ',
                          ),
                          validator: (value) => value?.trim().isEmpty == true ? 'Vui lòng nhập địa chỉ chi tiết' : null,
                        ),
                        const SizedBox(height: 16),
                        
                        DistrictWardPicker(
                          initialDistrict: _selectedDistrict,
                          initialWard: _selectedWard,
                          onChanged: (district, ward) {
                            setState(() {
                              _selectedDistrict = district;
                              _selectedWard = ward;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        
              TextFormField(
                          initialValue: _city,
                decoration: const InputDecoration(
                            labelText: 'Tỉnh/Thành phố *',
                  border: OutlineInputBorder(),
                ),
                          onChanged: (value) => _city = value,
                          validator: (value) => value?.trim().isEmpty == true ? 'Vui lòng nhập tỉnh/thành phố' : null,
              ),
                        const SizedBox(height: 16),
                        
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                            labelText: 'Số điện thoại *',
                  border: OutlineInputBorder(),
                            hintText: 'Ví dụ: 0123456789',
                          ),
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value?.trim().isEmpty == true) {
                              return 'Vui lòng nhập số điện thoại';
                            }
                            if (value != null && !RegExp(r'^[0-9]{10,11}$').hasMatch(value.trim())) {
                              return 'Số điện thoại không hợp lệ';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                      
                      // Option to save new address
                      if (!_useSavedAddress) ...[
                        Row(
                          children: [
                            Checkbox(
                              value: _saveNewAddress,
                              onChanged: (value) {
                                setState(() {
                                  _saveNewAddress = value ?? false;
                                });
                              },
                            ),
                            const Text('Lưu địa chỉ này cho lần sau'),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ],
                  );
                },
              ),
              
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'Ghi chú (tùy chọn)',
                  border: OutlineInputBorder(),
                  hintText: 'Hướng dẫn giao hàng, thời gian nhận hàng...',
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
              const SizedBox(height: 24),
              // Place Order Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _placeOrder(cart),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  child: const Text('Đặt hàng'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _clearAddressFields() {
    _addressController.clear();
    _phoneController.clear();
    _selectedDistrict = null;
    _selectedWard = null;
    _city = 'TP. Hồ Chí Minh';
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
    
    // Validate address fields
    if (_useSavedAddress && _selectedAddressId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn địa chỉ giao hàng!'), backgroundColor: Colors.red),
      );
      return;
    }
    
    if (!_useSavedAddress) {
      if (_addressController.text.trim().isEmpty || 
          _selectedDistrict == null || 
          _selectedWard == null || 
          _city.trim().isEmpty || 
          _phoneController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin địa chỉ!'), backgroundColor: Colors.red),
        );
        return;
      }
    }

    final user = context.read<AuthProvider>().user!;
    final voucherProvider = context.read<VoucherProvider>();
    final String? voucherCode = voucherProvider.appliedVoucher?.code;
    final finalTotal = _calculateFinalTotal(cart, voucherProvider);
    
    // Determine addressId for order
    String? orderAddressId;
    if (_useSavedAddress && _selectedAddressId != null) {
      orderAddressId = _selectedAddressId;
    } else {
      // For new addresses, we'll save them first and get the ID
      // This will be handled in the payment processing methods
      orderAddressId = null; // Will be set after saving address
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
      totalAmount: finalTotal.toInt(),
      orderStatus: 'pending',
      addressId: orderAddressId,
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

    try {
      String? finalAddressId = order.addressId;
      
      // If using new address, save it first and get the ID
      if (!_useSavedAddress) {
        final newAddress = Address(
          id: '',
          userId: userId,
          streetAddress: _addressController.text.trim(),
          ward: _selectedWard!,
          district: _selectedDistrict!,
          city: _city.trim(),
          phone: _phoneController.text.trim(),
          notes: _noteController.text.trim().isNotEmpty ? _noteController.text.trim() : null,
        );
        
        final addressProvider = context.read<AddressProvider>();
        final success = await addressProvider.addAddress(newAddress);
        
        if (success) {
          // Refresh addresses to get the new address ID
          await addressProvider.fetchAddresses(userId);
          // Find the newly added address (should be the last one)
          if (addressProvider.addresses.isNotEmpty) {
            finalAddressId = addressProvider.addresses.last.id;
          }
        } else {
          throw Exception('Không thể lưu địa chỉ mới');
        }
      }
      
      // Update order with the final addressId
      final updatedOrder = Order(
        id: order.id,
        userId: order.userId,
        cartItems: order.cartItems,
        totalAmount: order.totalAmount,
        orderStatus: order.orderStatus,
        addressId: finalAddressId,
        voucherCode: order.voucherCode,
        paymentMethod: order.paymentMethod,
        paymentStatus: order.paymentStatus,
        orderDate: order.orderDate,
        createdAt: order.createdAt,
        updatedAt: order.updatedAt,
      );

      final success = await context.read<OrderProvider>().createOrder(updatedOrder);
    Navigator.of(context).pop(); // Close loading

    if (success && mounted) {
      await context.read<CartProvider>().fetchCart(userId);
      Navigator.pushReplacementNamed(context, '/success');
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đặt hàng thất bại!'), backgroundColor: Colors.red),
      );
      }
    } catch (e) {
      Navigator.of(context).pop();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _processMomoPayment(Order order, Cart cart, String userId, double finalTotal) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      String? finalAddressId = order.addressId;
      
      // If using new address, save it first and get the ID
      if (!_useSavedAddress) {
        final newAddress = Address(
          id: '',
          userId: userId,
          streetAddress: _addressController.text.trim(),
          ward: _selectedWard!,
          district: _selectedDistrict!,
          city: _city.trim(),
          phone: _phoneController.text.trim(),
          notes: _noteController.text.trim().isNotEmpty ? _noteController.text.trim() : null,
        );
        
        final addressProvider = context.read<AddressProvider>();
        final success = await addressProvider.addAddress(newAddress);
        
        if (success) {
          // Refresh addresses to get the new address ID
          await addressProvider.fetchAddresses(userId);
          // Find the newly added address (should be the last one)
          if (addressProvider.addresses.isNotEmpty) {
            finalAddressId = addressProvider.addresses.last.id;
          }
        } else {
          throw Exception('Không thể lưu địa chỉ mới');
        }
      }
      
      // Update order with the final addressId
      final updatedOrder = Order(
        id: order.id,
        userId: order.userId,
        cartItems: order.cartItems,
        totalAmount: order.totalAmount,
        orderStatus: order.orderStatus,
        addressId: finalAddressId,
        voucherCode: order.voucherCode,
        paymentMethod: order.paymentMethod,
        paymentStatus: order.paymentStatus,
        orderDate: order.orderDate,
        createdAt: order.createdAt,
        updatedAt: order.updatedAt,
      );

      final payUrl = await MomoService.createMomoPayment(
        amount: finalTotal.toInt(),
        orderInfo: 'Thanh toán đơn hàng #${DateTime.now().millisecondsSinceEpoch}',
        redirectUrl: 'https://example.com/success',
      );

      Navigator.of(context).pop(); // Close loading

      if (payUrl != null) {
        // Create order first
        final success = await context.read<OrderProvider>().createOrder(updatedOrder);
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
      String? finalAddressId = order.addressId;
      
      // If using new address, save it first and get the ID
      if (!_useSavedAddress) {
        final newAddress = Address(
          id: '',
          userId: userId,
          streetAddress: _addressController.text.trim(),
          ward: _selectedWard!,
          district: _selectedDistrict!,
          city: _city.trim(),
          phone: _phoneController.text.trim(),
          notes: _noteController.text.trim().isNotEmpty ? _noteController.text.trim() : null,
        );
        
        final addressProvider = context.read<AddressProvider>();
        final success = await addressProvider.addAddress(newAddress);
        
        if (success) {
          // Refresh addresses to get the new address ID
          await addressProvider.fetchAddresses(userId);
          // Find the newly added address (should be the last one)
          if (addressProvider.addresses.isNotEmpty) {
            finalAddressId = addressProvider.addresses.last.id;
          }
        } else {
          throw Exception('Không thể lưu địa chỉ mới');
        }
      }
      
      // Update order with the final addressId
      final updatedOrder = Order(
        id: order.id,
        userId: order.userId,
        cartItems: order.cartItems,
        totalAmount: order.totalAmount,
        orderStatus: order.orderStatus,
        addressId: finalAddressId,
        voucherCode: order.voucherCode,
        paymentMethod: order.paymentMethod,
        paymentStatus: order.paymentStatus,
        orderDate: order.orderDate,
        createdAt: order.createdAt,
        updatedAt: order.updatedAt,
      );

      // Convert VND to USD (approximate rate 1 USD = 24,000 VND)
      final usdAmount = (finalTotal / 24000).toDouble();
      
      final approvalUrl = await PayPalService.createPayPalPayment(
        amount: double.parse(usdAmount.toStringAsFixed(2)), // Round to 2 decimal places
        currency: 'USD',
        description: 'Coffee Shop Order Payment',
      );

      Navigator.of(context).pop(); // Close loading

      if (approvalUrl != null) {
        // Create order first
        final success = await context.read<OrderProvider>().createOrder(updatedOrder);
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