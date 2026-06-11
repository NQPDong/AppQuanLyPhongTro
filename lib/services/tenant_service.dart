import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import '../models/tenant.dart';
import 'api_config.dart';

class TenantService {
  String? get _currentUserId => AuthService.currentUser?.uid;

  static final StreamController<List<Tenant>> _tenantsController = StreamController<List<Tenant>>.broadcast();
  static List<Tenant> _cachedTenants = [];

  // Lấy danh sách khách thuê (Realtime)
  Stream<List<Tenant>> getTenants() {
    if (_currentUserId == null) return const Stream.empty();
    _fetchTenants();
    return _tenantsController.stream;
  }

  Future<void> _fetchTenants() async {
    if (_currentUserId == null) return;
    try {
      final response = await ApiConfig.request(() => http.get(
        Uri.parse('${ApiConfig.baseUrl}/tenants?ownerId=$_currentUserId'),
      ));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _cachedTenants = data.map((json) => Tenant.fromJson(json)).toList();
        _tenantsController.add(_cachedTenants);
      } else {
        _tenantsController.addError('Không thể tải danh sách khách thuê (Mã lỗi: ${response.statusCode})');
      }
    } catch (e) {
      print('Lỗi tải khách thuê: $e');
      _tenantsController.addError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // Thêm khách thuê mới
  Future<void> addTenant({
    required String fullName,
    required String phone,
    required String idCard,
    String address = '',
    String notes = '',
  }) async {
    if (_currentUserId == null) throw Exception('Vui lòng đăng nhập!');

    try {
      final response = await ApiConfig.request(() => http.post(
        Uri.parse('${ApiConfig.baseUrl}/tenants'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'ownerId': _currentUserId,
          'fullName': fullName,
          'phone': phone,
          'idCard': idCard,
          'address': address,
          'notes': notes,
        }),
      ));

      if (response.statusCode == 200) {
        await _fetchTenants();
      } else {
        final errorMsg = jsonDecode(response.body)['message'] ?? 'Lỗi thêm khách thuê mới.';
        throw Exception(errorMsg);
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // Cập nhật thông tin khách thuê
  Future<void> updateTenant(String tenantId, {
    required String fullName,
    required String phone,
    required String idCard,
    required String address,
    required String notes,
  }) async {
    try {
      final response = await ApiConfig.request(() => http.put(
        Uri.parse('${ApiConfig.baseUrl}/tenants/$tenantId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'fullName': fullName,
          'phone': phone,
          'idCard': idCard,
          'address': address,
          'notes': notes,
        }),
      ));

      if (response.statusCode == 200) {
        await _fetchTenants();
      } else {
        final errorMsg = jsonDecode(response.body)['message'] ?? 'Lỗi cập nhật khách thuê.';
        throw Exception(errorMsg);
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // Xóa khách thuê
  Future<void> deleteTenant(String tenantId) async {
    try {
      final response = await ApiConfig.request(() => http.delete(
        Uri.parse('${ApiConfig.baseUrl}/tenants/$tenantId'),
      ));

      if (response.statusCode == 200) {
        await _fetchTenants();
      } else {
        final errorMsg = jsonDecode(response.body)['message'] ?? 'Lỗi xóa khách thuê.';
        throw Exception(errorMsg);
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // Lấy chi tiết khách thuê theo ID
  Future<Tenant?> getTenantById(String tenantId) async {
    try {
      final response = await ApiConfig.request(() => http.get(Uri.parse('${ApiConfig.baseUrl}/tenants/$tenantId')));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return Tenant.fromJson(json);
      }
    } catch (e) {
      print('Lỗi lấy khách thuê theo ID: $e');
    }
    return null;
  }
}
