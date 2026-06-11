import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import '../models/property.dart';
import 'api_config.dart';

class PropertyService {
  String? get _currentUserId => AuthService.currentUser?.uid;
  
  static final StreamController<List<Property>> _propertiesController = StreamController<List<Property>>.broadcast();
  static List<Property> _cachedProperties = [];

  Stream<List<Property>> getProperties([String? ownerId]) {
    final uid = ownerId ?? _currentUserId;
    if (uid == null) return const Stream.empty();
    _fetchProperties(uid);
    return _propertiesController.stream;
  }

  Future<void> _fetchProperties([String? ownerId]) async {
    final uid = ownerId ?? _currentUserId;
    if (uid == null) return;
    try {
      final response = await ApiConfig.request(() => http.get(
        Uri.parse('${ApiConfig.baseUrl}/properties?ownerId=$uid'),
      ));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _cachedProperties = data.map((json) => Property.fromJson(json)).toList();
        _propertiesController.add(_cachedProperties);
      } else {
        _propertiesController.addError('Lỗi tải cơ sở trọ: ${response.statusCode}');
      }
    } catch (e) {
      _propertiesController.addError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> addProperty(String name, String address, String imageUrl) async {
    if (_currentUserId == null) throw Exception('Vui lòng đăng nhập!');
    final response = await ApiConfig.request(() => http.post(
      Uri.parse('${ApiConfig.baseUrl}/properties'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'ownerId': _currentUserId, 'name': name, 'address': address, 'imageUrl': imageUrl}),
    ));
    if (response.statusCode == 200) {
      await _fetchProperties();
    } else {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Lỗi thêm cơ sở trọ.');
    }
  }

  Future<void> updateProperty(String propertyId, String name, String address, String imageUrl) async {
    final response = await ApiConfig.request(() => http.put(
      Uri.parse('${ApiConfig.baseUrl}/properties/$propertyId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'address': address, 'imageUrl': imageUrl}),
    ));
    if (response.statusCode == 200) {
      await _fetchProperties();
    } else {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Lỗi cập nhật.');
    }
  }

  Future<void> updateRoomCount(String propertyId, int countDelta) async {
    await _fetchProperties();
  }

  Future<void> deleteProperty(String propertyId) async {
    final response = await ApiConfig.request(() => http.delete(
      Uri.parse('${ApiConfig.baseUrl}/properties/$propertyId'),
    ));
    if (response.statusCode == 200) {
      await _fetchProperties();
    } else {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Lỗi xóa cơ sở trọ.');
    }
  }
}
