import 'package:flutter/material.dart';
import '../models/voucher_model.dart';
import '../services/voucher_service.dart';

class VoucherProvider with ChangeNotifier {
  List<Voucher> _vouchers = [];
  Voucher? _checkedVoucher;
  bool _isLoading = false;
  String? _error;

  List<Voucher> get vouchers => _vouchers;
  Voucher? get checkedVoucher => _checkedVoucher;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final VoucherService _voucherService = VoucherService();

  Future<void> fetchVouchers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _vouchers = await _voucherService.fetchVouchers();
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> checkVoucher(String code) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _checkedVoucher = await _voucherService.checkVoucher(code);
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }
} 