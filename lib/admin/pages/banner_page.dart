import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../services/admin_banner_service.dart';

class BannerPage extends StatefulWidget {
  const BannerPage({Key? key}) : super(key: key);

  @override
  State<BannerPage> createState() => _BannerPageState();
}

class _BannerPageState extends State<BannerPage> {
  final AdminBannerService _service = AdminBannerService();
  List<Map<String, dynamic>> banners = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchBanners();
  }

  Future<void> _fetchBanners() async {
    setState(() => isLoading = true);
    try {
      final data = await _service.fetchBanners();
      setState(() => banners = data);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tải banner: $e'), backgroundColor: Colors.red),
      );
    }
    setState(() => isLoading = false);
  }

  Future<void> _addOrEditBanner({Map<String, dynamic>? banner, File? imageFile, bool isEdit = false}) async {
    bool success;
    if (isEdit && banner != null) {
      success = await _service.updateBanner(banner['id'], banner, imageFile);
    } else {
      success = await _service.addBanner(banner!, imageFile);
    }
    if (success) {
      _fetchBanners();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isEdit ? 'Cập nhật banner thành công!' : 'Thêm banner thành công!'), backgroundColor: Colors.green),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isEdit ? 'Cập nhật banner thất bại!' : 'Thêm banner thất bại!'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _deleteBanner(String id) async {
    final success = await _service.deleteBanner(id);
    if (success) {
      _fetchBanners();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Xóa banner thành công!'), backgroundColor: Colors.green),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Xóa banner thất bại!'), backgroundColor: Colors.red),
      );
    }
  }

  void _showBannerForm({Map<String, dynamic>? banner}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => BannerForm(
        banner: banner,
        onSave: (b, f) => _addOrEditBanner(banner: b, imageFile: f, isEdit: banner != null),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý Banner')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: banners.length,
              itemBuilder: (context, index) {
                final banner = banners[index];
                return Card(
                  margin: const EdgeInsets.all(12),
                  child: ListTile(
                    leading: banner['image'] != null
                        ? Image.network(banner['image'], width: 60, height: 60, fit: BoxFit.cover)
                        : const Icon(Icons.image, size: 60),
                    title: Text(banner['title'] ?? ''),
                    subtitle: Text(banner['desc'] ?? ''),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showBannerForm(banner: banner),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteBanner(banner['id']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showBannerForm(),
        child: const Icon(Icons.add),
        backgroundColor: Colors.brown,
      ),
    );
  }
}

class BannerForm extends StatefulWidget {
  final Map<String, dynamic>? banner;
  final Function(Map<String, dynamic>, File?) onSave;
  const BannerForm({Key? key, this.banner, required this.onSave}) : super(key: key);

  @override
  State<BannerForm> createState() => _BannerFormState();
}

class _BannerFormState extends State<BannerForm> {
  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final descController = TextEditingController();
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    if (widget.banner != null) {
      titleController.text = widget.banner!['title'] ?? '';
      descController.text = widget.banner!['desc'] ?? '';
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Thông tin Banner', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 16),
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Tiêu đề'),
                  validator: (v) => v == null || v.isEmpty ? 'Nhập tiêu đề' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Mô tả'),
                  validator: (v) => v == null || v.isEmpty ? 'Nhập mô tả' : null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _imageFile != null
                        ? Image.file(_imageFile!, width: 80, height: 80, fit: BoxFit.cover)
                        : (widget.banner?['image'] != null
                            ? Image.network(widget.banner!['image'], width: 80, height: 80, fit: BoxFit.cover)
                            : const Icon(Icons.image, size: 80)),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.upload),
                      label: const Text('Chọn ảnh'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final banner = {
                          'title': titleController.text,
                          'desc': descController.text,
                        };
                        widget.onSave(banner, _imageFile);
                      }
                    },
                    child: Text(widget.banner == null ? 'Thêm' : 'Cập nhật', style: const TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 