import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import '../models/contract.dart';
import 'room_service.dart';
import 'api_config.dart';

class ContractService {
  String? get _currentUserId => AuthService.currentUser?.uid;
  final RoomService _roomService = RoomService();

  static final StreamController<List<Contract>> _contractsController = StreamController<List<Contract>>.broadcast();
  static List<Contract> _cachedContracts = [];

  // Lấy danh sách hợp đồng (Realtime)
  Stream<List<Contract>> getContracts() {
    if (_currentUserId == null) return const Stream.empty();
    _fetchContracts();
    return _contractsController.stream;
  }

  Future<void> _fetchContracts() async {
    if (_currentUserId == null) return;
    try {
      final response = await ApiConfig.request(() => http.get(
        Uri.parse('${ApiConfig.baseUrl}/contracts?ownerId=$_currentUserId'),
      ));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _cachedContracts = data.map((json) => Contract.fromJson(json)).toList();
        _contractsController.add(_cachedContracts);
      } else {
        _contractsController.addError('Không thể tải danh sách hợp đồng (Mã lỗi: ${response.statusCode})');
      }
    } catch (e) {
      print('Lỗi tải hợp đồng: $e');
      _contractsController.addError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // Lấy hợp đồng theo roomId
  Future<Contract?> getActiveContractByRoom(String roomId) async {
    try {
      final response = await ApiConfig.request(() => http.get(
        Uri.parse('${ApiConfig.baseUrl}/contracts/active/$roomId'),
      ));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return Contract.fromJson(json);
      }
    } catch (e) {
      print('Lỗi lấy hợp đồng hiện tại: $e');
    }
    return null;
  }

  // Tạo hợp đồng mới
  Future<void> createContract({
    required String propertyId,
    required String roomId,
    required String tenantId,
    required DateTime startDate,
    required DateTime endDate,
    required double depositAmount,
  }) async {
    if (_currentUserId == null) throw Exception('Vui lòng đăng nhập!');

    try {
      final response = await ApiConfig.request(() => http.post(
        Uri.parse('${ApiConfig.baseUrl}/contracts'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'ownerId': _currentUserId,
          'propertyId': propertyId,
          'roomId': roomId,
          'tenantId': tenantId,
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
          'depositAmount': depositAmount,
        }),
      ));

      if (response.statusCode == 200) {
        await _fetchContracts();
        // Kích hoạt cập nhật stream phòng
        await _roomService.updateRoomStatus(roomId, 'rented');
      } else {
        final errorMsg = jsonDecode(response.body)['message'] ?? 'Lỗi tạo hợp đồng mới.';
        throw Exception(errorMsg);
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // Thanh lý hợp đồng
  Future<void> terminateContract(String contractId, String roomId) async {
    try {
      final response = await ApiConfig.request(() => http.post(
        Uri.parse('${ApiConfig.baseUrl}/contracts/terminate/$contractId'),
      ));

      if (response.statusCode == 200) {
        await _fetchContracts();
        // Kích hoạt cập nhật stream phòng thành available
        await _roomService.updateRoomStatus(roomId, 'available');
      } else {
        final errorMsg = jsonDecode(response.body)['message'] ?? 'Lỗi thanh lý hợp đồng.';
        throw Exception(errorMsg);
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }
}
