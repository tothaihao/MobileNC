import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProductPage extends StatefulWidget {
  const ProductPage({Key? key}) : super(key: key);

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final List<Map<String, dynamic>> products = [
    {
      'name': 'Freeze Sô-cô-la',
      'price': '55.000đ',
      'quantity': 12,
      'image': '',
      'category': 'Đá xay',
      'bestSeller': true,
    },
    {
      'name': 'Freeze Trà Xanh',
      'price': '55.000đ',
      'quantity': 2,
      'image': 'https://product.hstatic.net/1000075078/product/1656_freese_traxanh_1_8e2e7e2e2e2e4e2e8e2e.jpg',
      'category': 'Đá xay',
      'bestSeller': false,
    },
    {
      'name': 'Cà phê sữa thạch Highlands',
      'price': '49.000đ',
      'quantity': 10,
      'image': 'assets/images/highlands_coffee.jpg',
      'category': 'Cà phê',
      'bestSeller': false,
    },
    // ... Thêm sản phẩm khác
  ];

  final List<String> categories = [
    'Tất cả', 'Đá xay', 'Trà sữa', 'Cà phê', 'Bánh ngọt', 'Best Seller'
  ];
  String selectedCategory = 'Tất cả';
  String searchText = '';

  // Hàm mở form thêm sản phẩm
  void _showAddProductForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const AddProductForm(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isSmall = width < 400;

    // Lọc sản phẩm theo danh mục và tìm kiếm
    final filteredProducts = products.where((p) {
      final matchCategory = selectedCategory == 'Tất cả'
          ? true
          : (selectedCategory == 'Best Seller'
              ? (p['bestSeller'] == true)
              : p['category'] == selectedCategory);
      final matchSearch = p['name']
          .toString()
          .toLowerCase()
          .contains(searchText.toLowerCase());
      return matchCategory && matchSearch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý sản phẩm'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Thanh tìm kiếm
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm sản phẩm...',
                  prefixIcon: const Icon(Icons.search),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                onChanged: (value) => setState(() => searchText = value),
              ),
            ),
            // Thanh filter danh mục
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: categories.map((cat) {
                  final isSelected = selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      selectedColor: Colors.brown[200],
                      onSelected: (_) => setState(() => selectedCategory = cat),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.brown,
                        fontWeight: FontWeight.bold,
                      ),
                      backgroundColor: Colors.brown[50],
                    ),
                  );
                }).toList(),
              ),
            ),
            // Thống kê tổng số lượng và các loại
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _statCard('Tổng sản phẩm', products.length.toString()),
                  _statCard('Best Seller', products.where((p) => p['bestSeller'] == true).length.toString()),
                  _statCard('Sắp hết hàng', products.where((p) => p['quantity'] < 5).length.toString()),
                ],
              ),
            ),
            // Danh sách sản phẩm
            Expanded(
              child: filteredProducts.isEmpty
                  ? const Center(child: Text('Không có sản phẩm nào'))
                  : GridView.builder(
                      padding: const EdgeInsets.all(12),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isSmall ? 2 : 3,
                        childAspectRatio: 0.65,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = filteredProducts[index];
                        return ProductCard(
                          product: product,
                          onEdit: () {},
                          onDelete: () {},
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddProductForm,
        child: const Icon(Icons.add),
        backgroundColor: Colors.brown,
      ),
    );
  }

  Widget _statCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: const TextStyle(fontSize: 13, color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ProductCard({
    Key? key,
    required this.product,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isLowStock = (product['quantity'] as int) < 5;
    return Stack(
      children: [
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 3,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              // Xem chi tiết sản phẩm
            },
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: product['image'].toString().startsWith('http')
                        ? Image.network(
                            product['image'],
                            height: 90,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              height: 90,
                              color: Colors.grey[200],
                              child: const Icon(Icons.broken_image, color: Colors.grey, size: 40),
                            ),
                          )
                        : Image.asset(
                            product['image'],
                            height: 90,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              height: 90,
                              color: Colors.grey[200],
                              child: const Icon(Icons.broken_image, color: Colors.grey, size: 40),
                            ),
                          ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product['name'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    product['price'],
                    style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'SL: ${product['quantity']}',
                    style: TextStyle(
                      color: isLowStock ? Colors.red : Colors.grey[700],
                      fontWeight: isLowStock ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                        onPressed: onEdit,
                        tooltip: 'Sửa',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                        onPressed: onDelete,
                        tooltip: 'Xóa',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        if (product['bestSeller'] == true)
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Best Seller',
                style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        if ((product['quantity'] as int) < 5)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Sắp hết hàng',
                style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ),
      ],
    );
  }
}

class AddProductForm extends StatefulWidget {
  const AddProductForm({Key? key}) : super(key: key);

  @override
  State<AddProductForm> createState() => _AddProductFormState();
}

class _AddProductFormState extends State<AddProductForm> {
  final _formKey = GlobalKey<FormState>();
  File? _imageFile;
  final picker = ImagePicker();

  // Controllers
  final titleController = TextEditingController();
  final descController = TextEditingController();
  final priceController = TextEditingController();
  final salePriceController = TextEditingController();
  final stockController = TextEditingController();

  String? _selectedCategory;
  String? _selectedSize;

  final List<String> categories = ['Đá xay', 'Trà sữa', 'Cà phê', 'Bánh ngọt'];
  final List<String> sizes = ['S', 'M', 'L'];

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16, right: 16,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Text(
                'Thêm sản phẩm mới',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _pickImage,
                child: _imageFile == null
                  ? Container(
                      width: 120, height: 120,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: const Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(_imageFile!, width: 120, height: 120, fit: BoxFit.cover),
                    ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Tên sản phẩm',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Nhập tên sản phẩm' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: 'Mô tả',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      items: categories.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (v) => setState(() => _selectedCategory = v),
                      decoration: const InputDecoration(
                        labelText: 'Danh mục',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v == null ? 'Chọn danh mục' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedSize,
                      items: sizes.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (v) => setState(() => _selectedSize = v),
                      decoration: const InputDecoration(
                        labelText: 'Size',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v == null ? 'Chọn size' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: priceController,
                decoration: const InputDecoration(
                  labelText: 'Giá',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.isEmpty ? 'Nhập giá' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: salePriceController,
                decoration: const InputDecoration(
                  labelText: 'Giá khuyến mãi (nếu có)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: stockController,
                decoration: const InputDecoration(
                  labelText: 'Tồn kho',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.isEmpty ? 'Nhập tồn kho' : null,
              ),
              const SizedBox(height: 20),
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
                      // Xử lý thêm sản phẩm ở đây
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Thêm', style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
