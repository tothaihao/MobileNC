import 'package:flutter/material.dart';
import '../models/voucher_model.dart';
import '../services/voucher_service.dart';

class VoucherProvider with ChangeNotifier {
  List<Voucher> _vouchers = [];
  Voucher? _checkedVoucher;
  Voucher? _appliedVoucher;
  bool _isLoading = false;
  String? _error;
  String? _successMessage;
  int _discountAmount = 0;

  List<Voucher> get vouchers => _vouchers;
  Voucher? get checkedVoucher => _checkedVoucher;
  Voucher? get appliedVoucher => _appliedVoucher;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get successMessage => _successMessage;
  int get discountAmount => _discountAmount;

  final VoucherService _voucherService = VoucherService();

  void clearMessages() {
    _error = null;
    _successMessage = null;
    notifyListeners();
  }

  void clearAppliedVoucher() {
    _appliedVoucher = null;
    _discountAmount = 0;
    _successMessage = null;
    notifyListeners();
  }

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

  Future<bool> checkVoucher(String code) async {
    _isLoading = true;
    _error = null;
    _successMessage = null;
    notifyListeners();
    try {
      _checkedVoucher = await _voucherService.checkVoucher(code);
      if (_checkedVoucher != null) {
        _successMessage = 'Mã giảm giá hợp lệ!';
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Mã giảm giá không hợp lệ hoặc đã hết hạn!';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> applyVoucher(String code, int totalAmount) async {
    _isLoading = true;
    _error = null;
    _successMessage = null;
    notifyListeners();
    try {
      final result = await _voucherService.applyVoucher(code, totalAmount);
      if (result['success'] == true) {
        _appliedVoucher = Voucher.fromJson(result['voucher']);
        _discountAmount = result['discountAmount'] ?? 0;
        _successMessage = 'Áp dụng mã giảm giá thành công!';
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = result['message'] ?? 'Không thể áp dụng mã giảm giá';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
} 