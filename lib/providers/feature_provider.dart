import 'package:flutter/material.dart';
import '../models/feature_banner_model.dart';
import '../services/feature_service.dart';

class FeatureProvider with ChangeNotifier {
  List<FeatureBanner> _banners = [];
  bool _isLoading = false;
  String? _error;

  List<FeatureBanner> get banners => _banners;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final FeatureService _service = FeatureService();

  Future<void> fetchBanners() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _banners = await _service.fetchBanners();
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }
} 