import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/address_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/address_model.dart';
import '../../theme/colors.dart';
import '../../widgets/district_ward_picker.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({Key? key}) : super(key: key);

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null) {
      Provider.of<AddressProvider>(context, listen: false).fetchAddresses(user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final addressProvider = Provider.of<AddressProvider>(context);
    final user = Provider.of<AuthProvider>(context).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Địa chỉ giao hàng'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: addressProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : addressProvider.error != null
              ? Center(child: Text('Lỗi: ${addressProvider.error}'))
              : ListView.builder(
                  itemCount: addressProvider.addresses.length,
                  itemBuilder: (context, index) {
                    final address = addressProvider.addresses[index];
                    return ListTile(
                      title: Text(
                        '${address.streetAddress}, ${address.ward}, ${address.district}, ${address.city}',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      subtitle: Text(
                        'SĐT: ${address.phone}${address.notes != null ? '\nGhi chú: ${address.notes}' : ''}',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: AppColors.primary),
                            onPressed: () => _showAddressForm(context, user!.id, address: address),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: AppColors.error),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Xác nhận'),
                                  content: const Text('Bạn có chắc muốn xóa địa chỉ này?'),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
                                    TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Xóa')),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                await addressProvider.deleteAddress(user!.id, address.id);
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
      floatingActionButton: user == null
          ? null
          : FloatingActionButton(
              onPressed: () => _showAddressForm(context, user.id),
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add),
            ),
    );
  }

  void _showAddressForm(BuildContext context, String userId, {Address? address}) {
    final isEdit = address != null;
    final streetController = TextEditingController(text: address?.streetAddress ?? '');
    final wardController = TextEditingController(text: address?.ward ?? '');
    final districtController = TextEditingController(text: address?.district ?? '');
    final cityController = TextEditingController(text: address?.city ?? '');
    final phoneController = TextEditingController(text: address?.phone ?? '');
    final notesController = TextEditingController(text: address?.notes ?? '');
    String? selectedDistrict = districtController.text.isNotEmpty ? districtController.text : null;
    String? selectedWard = wardController.text.isNotEmpty ? wardController.text : null;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'Sửa địa chỉ' : 'Thêm địa chỉ'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: streetController,
                decoration: const InputDecoration(labelText: 'Địa chỉ'),
                maxLines: 1,
              ),
              DistrictWardPicker(
                initialDistrict: selectedDistrict,
                initialWard: selectedWard,
                onChanged: (district, ward) {
                  selectedDistrict = district;
                  selectedWard = ward;
                  districtController.text = district;
                  wardController.text = ward;
                },
              ),
              TextFormField(
                controller: districtController,
                decoration: const InputDecoration(labelText: 'Quận/Huyện'),
                maxLines: 1,
              ),
              TextField(
                controller: cityController,
                decoration: const InputDecoration(labelText: 'Tỉnh/Thành phố'),
                maxLines: 1,
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Số điện thoại'),
                maxLines: 1,
                keyboardType: TextInputType.phone,
              ),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(labelText: 'Ghi chú (tuỳ chọn)'),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              final newAddress = Address(
                id: address?.id ?? '',
                userId: userId,
                streetAddress: streetController.text,
                ward: wardController.text,
                district: districtController.text,
                city: cityController.text,
                phone: phoneController.text,
                notes: notesController.text.isNotEmpty ? notesController.text : null,
              );
              final provider = Provider.of<AddressProvider>(context, listen: false);
              bool success;
              if (isEdit) {
                success = await provider.updateAddress(newAddress);
              } else {
                success = await provider.addAddress(newAddress);
              }
              if (success && context.mounted) Navigator.pop(context);
            },
            child: Text(isEdit ? 'Lưu' : 'Thêm'),
          ),
        ],
      ),
    );
  }
}