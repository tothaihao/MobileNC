import 'package:flutter/material.dart';
import '../../services/admin_voucher_service.dart';

class VoucherPage extends StatefulWidget {
  const VoucherPage({Key? key}) : super(key: key);

  @override
  State<VoucherPage> createState() => _VoucherPageState();
}

class _VoucherPageState extends State<VoucherPage> {
  final AdminVoucherService _service = AdminVoucherService();
  List<Map<String, dynamic>> vouchers = [];

  @override
  void initState() {
    super.initState();
    _fetchVouchers();
  }

  Future<void> _fetchVouchers() async {
    try {
      final data = await _service.fetchVouchers();
      setState(() => vouchers = data);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tải voucher: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _addVoucher(Map<String, dynamic> voucher) async {
    final success = await _service.addVoucher(voucher);
    if (success) {
      _fetchVouchers();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Thêm voucher thành công!'), backgroundColor: Colors.green),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Thêm voucher thất bại!'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _updateVoucher(String id, Map<String, dynamic> voucher) async {
    final success = await _service.updateVoucher(id, voucher);
    if (success) {
      _fetchVouchers();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cập nhật voucher thành công!'), backgroundColor: Colors.green),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cập nhật voucher thất bại!'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _deleteVoucher(String id) async {
    final success = await _service.deleteVoucher(id);
    if (success) {
      _fetchVouchers();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Xóa voucher thành công!'), backgroundColor: Colors.green),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Xóa voucher thất bại!'), backgroundColor: Colors.red),
      );
    }
  }

  void _showVoucherForm([Map<String, dynamic>? voucher]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => VoucherForm(
        voucher: voucher,
        onSave: (v) => voucher == null ? _addVoucher(v) : _updateVoucher(v['id'], v),
        onDelete: (v) => _deleteVoucher(v['id']),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Voucher'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Hướng dẫn
            Card(
              color: Colors.brown[50],
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: const [
                    Icon(Icons.info, color: Colors.brown),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Nhập mã voucher, loại giảm giá, giá trị, điều kiện tối thiểu, hạn sử dụng và trạng thái hoạt động.',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Danh sách voucher
            const Text('Danh sách Voucher', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            ...vouchers.map((voucher) => ModernVoucherCard(
                  voucher: voucher,
                  onEdit: () => _showVoucherForm(voucher),
                  onDelete: () {
                    _deleteVoucher(voucher['id']);
                  },
                )),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showVoucherForm(),
        child: const Icon(Icons.add),
        backgroundColor: Colors.brown,
        tooltip: 'Tạo voucher mới',
      ),
    );
  }
}

class ModernVoucherCard extends StatelessWidget {
  final Map<String, dynamic> voucher;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ModernVoucherCard({
    Key? key,
    required this.voucher,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isActive = voucher['active'] == true;
    final isPercent = voucher['type'] == 'percent';
    final gradient = isActive
        ? [Colors.green[200]!, Colors.green[50]!]
        : [Colors.grey[300]!, Colors.grey[100]!];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        leading: CircleAvatar(
          backgroundColor: isActive ? Colors.green[400] : Colors.grey[400],
          child: Icon(
            isPercent ? Icons.percent : Icons.confirmation_number,
            color: Colors.white,
          ),
        ),
        title: Row(
          children: [
            Text(
              voucher['code'],
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isActive ? Colors.green[100] : Colors.red[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isActive ? 'Hoạt động' : 'Tạm dừng',
                style: TextStyle(
                  color: isActive ? Colors.green[900] : Colors.red[900],
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  _infoChip(
                    isPercent
                        ? 'Giảm ${voucher['value']}% (max ${voucher['maxValue']}đ)'
                        : 'Giảm ${voucher['value']}đ',
                    color: Colors.orange[100],
                    textColor: Colors.orange[900],
                  ),
                  _infoChip('Min Order: ${voucher['minOrder']}đ'),
                  _infoChip('Hạn: ${voucher['expire']}'),
                ],
              ),
            ],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue, size: 22),
              onPressed: onEdit,
              tooltip: 'Sửa',
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red, size: 22),
              onPressed: onDelete,
              tooltip: 'Xóa',
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(String text, {Color? color, Color? textColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color ?? Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor ?? Colors.brown,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class VoucherForm extends StatefulWidget {
  final Map<String, dynamic>? voucher;
  final Function(Map<String, dynamic>) onSave;
  final Function(Map<String, dynamic>) onDelete;
  const VoucherForm({Key? key, this.voucher, required this.onSave, required this.onDelete}) : super(key: key);

  @override
  State<VoucherForm> createState() => _VoucherFormState();
}

class _VoucherFormState extends State<VoucherForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController codeController;
  late TextEditingController valueController;
  late TextEditingController maxValueController;
  late TextEditingController minOrderController;
  late TextEditingController expireController;
  String type = 'percent';
  bool active = true;

  @override
  void initState() {
    super.initState();
    codeController = TextEditingController(text: widget.voucher?['code'] ?? '');
    valueController = TextEditingController(text: widget.voucher?['value']?.toString() ?? '');
    maxValueController = TextEditingController(text: widget.voucher?['maxValue']?.toString() ?? '');
    minOrderController = TextEditingController(text: widget.voucher?['minOrder']?.toString() ?? '');
    expireController = TextEditingController(text: widget.voucher?['expire'] ?? '');
    type = widget.voucher?['type'] ?? 'percent';
    active = widget.voucher?['active'] ?? true;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.card_giftcard, color: Colors.brown[300]),
                    const SizedBox(width: 8),
                    Text(
                      widget.voucher == null ? 'Tạo mới voucher' : 'Sửa voucher',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: codeController,
                  decoration: const InputDecoration(
                    labelText: 'Mã voucher',
                    prefixIcon: Icon(Icons.confirmation_number),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Nhập mã voucher' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: type,
                  items: const [
                    DropdownMenuItem(value: 'percent', child: Text('Giảm theo %')),
                    DropdownMenuItem(value: 'fixed', child: Text('Giảm cố định')),
                  ],
                  onChanged: (v) => setState(() => type = v ?? 'percent'),
                  decoration: const InputDecoration(
                    labelText: 'Loại giảm giá',
                    prefixIcon: Icon(Icons.percent),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: valueController,
                  decoration: InputDecoration(
                    labelText: type == 'percent' ? 'Giá trị giảm (%)' : 'Giá trị giảm (VNĐ)',
                    prefixIcon: Icon(type == 'percent' ? Icons.percent : Icons.money),
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) => value == null || value.isEmpty ? 'Nhập giá trị giảm' : null,
                ),
                const SizedBox(height: 12),
                if (type == 'percent')
                  TextFormField(
                    controller: maxValueController,
                    decoration: const InputDecoration(
                      labelText: 'Giảm tối đa (VNĐ)',
                      prefixIcon: Icon(Icons.money),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                if (type == 'percent') const SizedBox(height: 12),
                TextFormField(
                  controller: minOrderController,
                  decoration: const InputDecoration(
                    labelText: 'Tối thiểu đơn hàng (VNĐ)',
                    prefixIcon: Icon(Icons.shopping_cart),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: expireController,
                  decoration: const InputDecoration(
                    labelText: 'Hạn sử dụng (dd/mm/yyyy)',
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Checkbox(
                      value: active,
                      onChanged: (v) => setState(() => active = v ?? true),
                    ),
                    const Text('Đang hoạt động'),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.save, color: Colors.white),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final newVoucher = {
                          'code': codeController.text,
                          'type': type,
                          'value': double.tryParse(valueController.text) ?? 0,
                          'maxValue': type == 'percent' ? (double.tryParse(maxValueController.text) ?? 0) : 0,
                          'minOrder': double.tryParse(minOrderController.text) ?? 0,
                          'expire': expireController.text,
                          'active': active,
                        };
                        if (widget.voucher == null) {
                          widget.onSave(newVoucher);
                        } else {
                          widget.onSave(newVoucher);
                        }
                      }
                    },
                    label: Text(widget.voucher == null ? 'Tạo mới' : 'Cập nhật',
                        style: const TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 10),
                if (widget.voucher != null)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.delete, color: Colors.white),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Xác nhận xóa voucher'),
                              content: Text('Bạn có chắc chắn muốn xóa voucher "${widget.voucher?['code']}"?'),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text('Hủy'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: const Text('Xóa'),
                                  onPressed: () {
                                    widget.onDelete(widget.voucher!);
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                      label: const Text('Xóa voucher', style: TextStyle(fontSize: 16, color: Colors.white)),
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
