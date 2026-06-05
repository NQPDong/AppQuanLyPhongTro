import 'dart:async';
import 'package:flutter/material.dart';
import '../models/property.dart';
import '../services/property_service.dart';

class PropertyProvider with ChangeNotifier {
  final PropertyService _propertyService = PropertyService();
  StreamSubscription<List<Property>>? _subscription;

  List<Property> _properties = [];
  bool _isLoading = true;
  String? _error;

  List<Property> get properties => _properties;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Property? _selectedProperty;
  Property? get selectedProperty => _selectedProperty;

  void selectProperty(Property property) {
    _selectedProperty = property;
    notifyListeners();
  }

  // Hàm này để khởi tạo việc lắng nghe dữ liệu từ Firebase
  void init(String ownerId) {
    _isLoading = true;
    _error = null;
    notifyListeners();

    _subscription?.cancel();
    _subscription = _propertyService.getProperties(ownerId).listen(
      (data) {
        _properties = data;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // Thêm cơ sở mới
  Future<void> addProperty(Property property) async {
    await _propertyService.addProperty(property);
  }

  // Cập nhật cơ sở
  Future<void> updateProperty(Property property) async {
    await _propertyService.updateProperty(property);
  }

  // Xóa cơ sở
  Future<void> deleteProperty(String propertyId) async {
    await _propertyService.deleteProperty(propertyId);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}