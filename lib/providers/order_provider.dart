import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../services/order_service.dart';

class OrderProvider with ChangeNotifier {
  List<Order> _orders = [];
  Order? _selectedOrder;
  bool _isLoading = false;
  String? _error;

  List<Order> get orders => _orders;
  Order? get selectedOrder => _selectedOrder;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final OrderService _orderService = OrderService();

  Future<void> fetchOrders(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _orders = await _orderService.fetchOrders(userId);
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchOrderDetail(String orderId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _selectedOrder = await _orderService.fetchOrderDetail(orderId);
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createOrder(Order order) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final result = await _orderService.createOrder(order);
      await fetchOrders(order.userId);
      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
} 