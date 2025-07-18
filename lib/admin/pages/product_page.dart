import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/admin_product_model.dart'; // ✅ Use admin version
import '../services/admin_product_service.dart'; // ✅ Use admin service

class ProductPage extends StatefulWidget {
  const ProductPage({Key? key}) : super(key: key);

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  List<Product> products = []; // ✅ Now matches admin Product type
  bool isLoading = true;
  String selectedCategory = 'Tất cả';
  String searchText = '';
  final List<String> categories = [
    'Tất cả', 'Đá xay', 'Trà sữa', 'Cà phê', 'Bánh ngọt', 'Best Seller'
  ];

  // Map label tiếng Việt sang id backend
  static const Map<String, String> categoryLabelToId = {
    'Trà sữa': 'traSua',
    'Cà phê': 'caPhe',
    'Bánh ngọt': 'banhNgot',
    'Đá xay': 'daXay',
  };

  bool isBestSeller(Product p) {
    return p.stockStatus == 'bestSeller' || p.averageReview >= 3.0;
  }

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    setState(() => isLoading = true);
    try {
      final list = await AdminProductService.getAllProducts();
      setState(() {
        products = list;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tải sản phẩm: $e')),
      );
    }
  }

  void _showAddProductForm() async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => ProductForm(),
    );
    if (result == true) fetchProducts();
  }

  void _showEditProductForm(Product product) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => ProductForm(product: product),
    );
    if (result == true) fetchProducts();
  }

  void _deleteProduct(Product product) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa sản phẩm "${product.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      final ok = await AdminProductService.deleteProduct(product.id);
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xóa sản phẩm!')),
        );
        fetchProducts();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Xóa thất bại!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi xóa: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isSmall = width < 400;
    final filteredProducts = products.where((p) {
      final matchCategory = selectedCategory == 'Tất cả'
          ? true
          : (selectedCategory == 'Best Seller'
              ? isBestSeller(p)
              : p.category == categoryLabelToId[selectedCategory]);
      final matchSearch = p.title.toLowerCase().contains(searchText.toLowerCase());
      return matchCategory && matchSearch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý sản phẩm'),
      ),
      body: SafeArea(
        child: Column(
          children: [
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _statCard('Tổng sản phẩm', products.length.toString()),
                  _statCard('Best Seller', products.where((p) => isBestSeller(p)).length.toString()),
                  _statCard('Sắp hết hàng', products.where((p) => p.totalStock < 5 && p.totalStock > 0).length.toString()),
                ],
              ),
            ),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredProducts.isEmpty
                      ? const Center(child: Text('Không có sản phẩm nào'))
                      : GridView.builder(
                          padding: const EdgeInsets.all(12),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: isSmall ? 2 : 2,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: filteredProducts.length,
                          itemBuilder: (context, index) {
                            final product = filteredProducts[index];
                            return ProductCard(
                              product: product,
                              onEdit: () => _showEditProductForm(product),
                              onDelete: () => _deleteProduct(product),
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
  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ProductCard({
    Key? key,
    required this.product,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  bool isBestSeller(Product p) {
    return p.stockStatus == 'bestSeller' || p.averageReview >= 3.0;
  }

  @override
  Widget build(BuildContext context) {
    final isLowStock = product.totalStock < 5 && product.totalStock > 0;
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
                    child: product.image.startsWith('http')
                        ? Image.network(
                            product.image,
                            height: 90,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              height: 90,
                              color: Colors.grey[200],
                              child: const Icon(Icons.broken_image, color: Colors.grey, size: 40),
                            ),
                          )
                        : Image.asset(
                            product.image,
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
                    product.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${product.price}đ',
                    style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                  // Hiển thị hết hàng hoặc số lượng
                  product.totalStock == 0
                    ? const Text('Hết hàng', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))
                    : Text(
                        'SL: ${product.totalStock}',
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
        if (isBestSeller(product))
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
        if (product.totalStock < 5 && product.totalStock > 0)
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
        if (product.totalStock == 0)
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
                'Hết hàng',
                style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ),
      ],
    );
  }
}

class ProductForm extends StatefulWidget {
  final Product? product;
  const ProductForm({Key? key, this.product}) : super(key: key);

  @override
  State<ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  final _formKey = GlobalKey<FormState>();
  File? _imageFile;
  final picker = ImagePicker();

  late TextEditingController titleController;
  late TextEditingController descController;
  late TextEditingController priceController;
  late TextEditingController salePriceController;
  late TextEditingController stockController;

  String? _selectedCategory;
  String? _selectedSize;
  final List<String> categories = ['Đá xay', 'Trà sữa', 'Cà phê', 'Bánh ngọt'];
  final List<String> sizes = ['S', 'M', 'L'];

  // Map id backend sang label tiếng Việt
  String? _categoryIdToLabel(String? id) {
    if (id == null) return null;
    return _ProductPageState.categoryLabelToId.entries
        .firstWhere((e) => e.value == id, orElse: () => const MapEntry('', '')).key;
  }

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.product?.title ?? '');
    descController = TextEditingController(text: widget.product?.description ?? '');
    priceController = TextEditingController(text: widget.product?.price.toString() ?? '');
    salePriceController = TextEditingController(text: widget.product?.salePrice?.toString() ?? '');
    stockController = TextEditingController(text: widget.product?.totalStock.toString() ?? '');
    // Nếu là sửa, map id category sang label để hiển thị đúng dropdown
    _selectedCategory = widget.product?.category != null
        ? _categoryIdToLabel(widget.product!.category)
        : null;
    _selectedSize = widget.product?.size;
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    String imageUrl = widget.product?.image ?? '';
    if (_imageFile != null) {
      try {
        imageUrl = await AdminProductService.uploadImage(_imageFile!);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi upload ảnh: $e')),
        );
        return;
      }
    }
    final product = Product(
      id: widget.product?.id ?? '',
      image: imageUrl,
      title: titleController.text.trim(),
      description: descController.text.trim(),
      // Map label sang id khi submit
      category: _ProductPageState.categoryLabelToId[_selectedCategory!]!,
      size: _selectedSize!,
      price: int.tryParse(priceController.text) ?? 0,
      salePrice: salePriceController.text.isNotEmpty ? int.tryParse(salePriceController.text) : null,
      totalStock: int.tryParse(stockController.text) ?? 0,
      averageReview: widget.product?.averageReview ?? 0.0,
      stockStatus: widget.product?.stockStatus ?? '',
      createdAt: widget.product?.createdAt,
      updatedAt: widget.product?.updatedAt,
    );
    bool ok = false;
    if (widget.product == null) {
      ok = await AdminProductService.addProduct(product);
    } else {
      ok = await AdminProductService.updateProduct(product.id, product);
    }
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.product == null ? 'Đã thêm sản phẩm!' : 'Đã cập nhật sản phẩm!')),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Thao tác thất bại!')),
      );
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
              Text(
                widget.product == null ? 'Thêm sản phẩm mới' : 'Cập nhật sản phẩm',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _pickImage,
                child: _imageFile == null && (widget.product?.image == null || widget.product!.image.isEmpty)
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
                      child: _imageFile != null
                        ? Image.file(_imageFile!, width: 120, height: 120, fit: BoxFit.cover)
                        : Image.network(widget.product!.image, width: 120, height: 120, fit: BoxFit.cover),
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
                  onPressed: _submit,
                  child: Text(widget.product == null ? 'Thêm' : 'Cập nhật', style: const TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
