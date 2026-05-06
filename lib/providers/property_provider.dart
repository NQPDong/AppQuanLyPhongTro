import 'dart:async';
import 'package:flutter/material.dart';
import '../models/property_model.dart';
import '../services/property_service.dart';

class PropertyProvider with ChangeNotifier {
  final PropertyService _propertyService = PropertyService();
  StreamSubscription<List<PropertyModel>>? _subscription;

  List<PropertyModel> _properties = [];
  bool _isLoading = true;
  String? _error;

  List<PropertyModel> get properties => _properties;
  bool get isLoading => _isLoading;
  String? get error => _error;

  PropertyModel? _selectedProperty;
  PropertyModel? get selectedProperty => _selectedProperty;

  void selectProperty(PropertyModel property) {
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
  Future<void> addProperty(PropertyModel property) async {
    await _propertyService.addProperty(property);
  }

  // Cập nhật cơ sở
  Future<void> updateProperty(PropertyModel property) async {
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