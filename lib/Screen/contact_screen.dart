import 'package:flutter/material.dart';
import 'package:do_an_mobile_nc/theme/colors.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 1,
        centerTitle: true,
        title: const Text('Contact Us', style: TextStyle(color: AppColors.textPrimary)),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 800;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildMap(),
                const SizedBox(height: 24),
                isWide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildContactInfo()),
                          const SizedBox(width: 24),
                          Expanded(child: _buildSupportForm(context)),
                        ],
                      )
                    : Column(
                        children: [
                          _buildContactInfo(),
                          const SizedBox(height: 24),
                          _buildSupportForm(context),
                        ],
                      ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMap() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[300],
        image: const DecorationImage(
          image: NetworkImage('https://tile.openstreetmap.org/13/3733/2475.png'),
          fit: BoxFit.cover,
        ),
      ),
      alignment: Alignment.center,
      child: const Text(
        'Map Placeholder',
        style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildContactInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'THÔNG TIN LIÊN HỆ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 16),
          ListTile(
            leading: Icon(Icons.phone, color: AppColors.primary),
            title: Text('1800-123-4567', style: TextStyle(color: AppColors.textPrimary)),
          ),
          ListTile(
            leading: Icon(Icons.email, color: AppColors.primary),
            title: Text('info@example.com', style: TextStyle(color: AppColors.textPrimary)),
          ),
          ListTile(
            leading: Icon(Icons.location_on, color: AppColors.primary),
            title: Text('Huflit Campus HocMon University',
                style: TextStyle(color: AppColors.textPrimary)),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportForm(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide.none,
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'HỖ TRỢ KHÁCH HÀNG',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              hintText: 'Your name',
              filled: true,
              fillColor: AppColors.background,
              border: border,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: InputDecoration(
              hintText: 'Email',
              filled: true,
              fillColor: AppColors.background,
              border: border,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'What do you need our support for?',
              filled: true,
              fillColor: AppColors.background,
              border: border,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('GỬI'),
            ),
          ),
        ],
      ),
    );
  }
}
// This file defines the ContactScreen widget, which displays a contact form and information.