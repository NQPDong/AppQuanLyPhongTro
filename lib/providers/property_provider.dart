import 'package:flutter/material.dart';
import '../models/property_model.dart';
import '../services/property_service.dart';

class PropertyProvider with ChangeNotifier {
  final PropertyService _propertyService = PropertyService();
  List<PropertyModel> _properties = [];

  List<PropertyModel> get properties => _properties;

  // Hàm này để khởi tạo việc lắng nghe dữ liệu từ Firebase
  void init(String ownerId) {
    _propertyService.getProperties(ownerId).listen((data) {
      _properties = data;
      notifyListeners(); // Thông báo cho UI vẽ lại khi có cơ sở mới
    });
  }

  PropertyModel? _selectedProperty;
  PropertyModel? get selectedProperty => _selectedProperty;

  void selectProperty(PropertyModel property) {
    _selectedProperty = property;
    notifyListeners();
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
}