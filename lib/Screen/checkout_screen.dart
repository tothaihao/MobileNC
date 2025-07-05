import 'package:flutter/material.dart';
import 'package:do_an_mobile_nc/theme/colors.dart';
import 'package:do_an_mobile_nc/widgets/gradient_button.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        title: const Text(
          'Thanh toán',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        elevation: 1,
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWideScreen = constraints.maxWidth >= 800;

          final addressSection = _buildAddressSection(context);
          final summarySection = _buildSummarySection(context);

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: isWideScreen
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 2, child: addressSection),
                        const SizedBox(width: 24),
                        Expanded(flex: 1, child: summarySection),
                      ],
                    )
                  : Column(
                      children: [
                        addressSection,
                        const SizedBox(height: 24),
                        summarySection,
                      ],
                    ),
            ),
          );
        },
      ),
    );
  }

  // ĐỊA CHỈ
  Widget _buildAddressSection(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quản lý địa chỉ của bạn',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildAddressCard("Cộng Hòa", "Phường/Kx: P2\nTỉnh/Thành phố: HCM", "SĐT: 0901664407"),
            _buildAddressCard("Bến Vân Đồn", "Phường/Kx: Phường 3\nTỉnh/Thành phố: HCM", "SĐT: 0901664407"),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'Thêm địa chỉ mới',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        _buildTextField('Tỉnh/Thành phố'),
        _buildTextField('Quận/Huyện'),
        _buildTextField('Phường/Xã'),
        _buildTextField('Số nhà, Tên đường'),
        _buildTextField('Số điện thoại'),
        _buildTextField('Ghi chú (nếu có)'),
        const SizedBox(height: 12),
        GradientButton(
          text: 'Thêm mới',
          onPressed: () {},
        ),
      ],
    );
  }

  // TÓM TẮT ĐƠN HÀNG
  Widget _buildSummarySection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Freeze Sô-cô-la', style: TextStyle(color: AppColors.textPrimary)),
              Text('55.000đ', style: TextStyle(color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              hintText: 'Nhập mã voucher...',
              hintStyle: const TextStyle(color: AppColors.textSecondary),
              suffixIcon: TextButton(
                onPressed: () {},
                child: const Text('Áp dụng'),
              ),
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tổng cộng',
                  style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              Text('55.000đ',
                  style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 24),
          _buildPaymentButton('Thanh toán bằng PayPal', Colors.blue),
          _buildPaymentButton('Thanh toán bằng Momo', Colors.pink),
          _buildPaymentButton('Thanh toán khi nhận hàng', Colors.green),
          const SizedBox(height: 12),
          // ✅ Nút xác nhận thanh toán
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/success');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Xác nhận thanh toán',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(String title, String address, String phone) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Địa chỉ: $title',
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          Text(address, style: const TextStyle(color: AppColors.textSecondary)),
          Text(phone, style: const TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Row(
            children: [
              TextButton(onPressed: () {}, child: const Text('Chỉnh sửa')),
              TextButton(onPressed: () {}, child: const Text('Xoá')),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildTextField(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.textSecondary),
          filled: true,
          fillColor: AppColors.background,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _buildPaymentButton(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
      ),
    );
  }
}
