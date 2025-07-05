import 'package:flutter/material.dart';
import 'package:do_an_mobile_nc/theme/colors.dart';
import 'package:do_an_mobile_nc/widgets/gradient_button.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        title: const Text('Giỏ hàng của bạn'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        centerTitle: true,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  _buildCartItem(
                    imageUrl: 'https://th.bing.com/th/id/OIP.cD30UqWHlkezHRo3Dy6yUAHaIX?rs=1&pid=ImgDetMain',
                    title: 'PhinDi Choco',
                    price: '45.000đ',
                    quantity: 1,
                  ),
                  const Divider(),
                  _buildCartItem(
                    imageUrl: 'https://th.bing.com/th/id/OIP.cD30UqWHlkezHRo3Dy6yUAHaIX?rs=1&pid=ImgDetMain',
                    title: 'Bánh mì cuộn chà bông',
                    price: '45.000đ',
                    quantity: 1,
                  ),
                  const Divider(),
                  _buildCartItem(
                    imageUrl: 'https://th.bing.com/th/id/OIP.cD30UqWHlkezHRo3Dy6yUAHaIX?rs=1&pid=ImgDetMain',
                    title: 'Bánh Croissant Plain',
                    price: '29.000đ',
                    quantity: 1,
                  ),
                  const Divider(),
                  _buildCartItem(
                    imageUrl: 'https://th.bing.com/th/id/OIP.cD30UqWHlkezHRo3Dy6yUAHaIX?rs=1&pid=ImgDetMain',
                    title: 'Freeze Trà Xanh',
                    price: '55.000đ',
                    quantity: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildTotalSection(totalPrice: '174.000đ'),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: GradientButton(
                text: 'Thanh toán',
                onPressed: () {
                  Navigator.pushNamed(context, '/checkout');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItem({
    required String imageUrl,
    required String title,
    required String price,
    required int quantity,
  }) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            imageUrl,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                price,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Text(
          'x$quantity',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildTotalSection({required String totalPrice}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(30, 0, 0, 0),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Tổng cộng:',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            totalPrice,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
