import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;
  String? _successMessage;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get successMessage => _successMessage;

  final AuthService _authService = AuthService();

  void resetMessages() {
    _error = null;
    _successMessage = null;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    _successMessage = null;
    notifyListeners();
    final res = await _authService.login(email, password);
    if (res['success'] == true && res['user'] != null) {
      _user = User.fromJson(res['user']);
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _error = res['message'] ?? 'Đăng nhập thất bại';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    _error = null;
    _successMessage = null;
    notifyListeners();
    final res = await _authService.register(name, email, password);
    if (res['message']?.contains('thành công') == true) {
      _successMessage = 'Đăng ký thành công';
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _error = res['message'] ?? 'Đăng ký thất bại';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    await _authService.logout();
    _user = null;
    _isLoading = false;
    notifyListeners();
  }
} 