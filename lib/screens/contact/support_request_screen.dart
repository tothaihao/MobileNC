import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/support_request_provider.dart';
import '../../models/support_request_model.dart';
import '../../theme/colors.dart';

class SupportRequestScreen extends StatefulWidget {
  const SupportRequestScreen({Key? key}) : super(key: key);

  @override
  State<SupportRequestScreen> createState() => _SupportRequestScreenState();
}

class _SupportRequestScreenState extends State<SupportRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SupportRequestProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gửi yêu cầu hỗ trợ'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Tên của bạn'),
                validator: (value) => value == null || value.isEmpty ? 'Nhập tên' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) => value == null || value.isEmpty ? 'Nhập email' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _messageController,
                decoration: const InputDecoration(labelText: 'Nội dung yêu cầu'),
                maxLines: 5,
                validator: (value) => value == null || value.isEmpty ? 'Nhập nội dung' : null,
              ),
              const SizedBox(height: 24),
              provider.isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          final request = SupportRequest(
                            userEmail: _emailController.text,
                            userName: _nameController.text,
                            message: _messageController.text,
                          );
                          final success = await provider.sendRequest(request);
                          if (success && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Gửi yêu cầu thành công!')),
                            );
                            _formKey.currentState!.reset();
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Gửi yêu cầu'),
                    ),
              if (provider.error != null) ...[
                const SizedBox(height: 16),
                Text(provider.error!, style: const TextStyle(color: Colors.red)),
              ],
              if (provider.successMessage != null) ...[
                const SizedBox(height: 16),
                Text(provider.successMessage!, style: const TextStyle(color: Colors.green)),
              ],
            ],
          ),
        ),
      ),
    );
  }
} 