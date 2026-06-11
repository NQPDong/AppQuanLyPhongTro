import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import '../models/room.dart';
import 'property_service.dart';
import 'api_config.dart';

class RoomService {
  String? get _currentUserId => AuthService.currentUser?.uid;
  final PropertyService _propertyService = PropertyService();

  static final Map<String, StreamController<List<Room>>> _controllers = {};

  StreamController<List<Room>> _getOrCreateController(String propertyId) {
    if (!_controllers.containsKey(propertyId)) {
      _controllers[propertyId] = StreamController<List<Room>>.broadcast();
    }
    return _controllers[propertyId]!;
  }

  Stream<List<Room>> getRoomsByProperty(String propertyId) {
    if (_currentUserId == null) return const Stream.empty();
    _fetchRooms(propertyId);
    return _getOrCreateController(propertyId).stream;
  }

  Stream<List<Room>> getAllRooms() {
    if (_currentUserId == null) return const Stream.empty();
    final controller = StreamController<List<Room>>.broadcast();
    _fetchAllRooms(controller);
    return controller.stream;
  }

  Future<void> _fetchAllRooms(StreamController<List<Room>> controller) async {
    try {
      final response = await ApiConfig.request(() => http.get(
        Uri.parse('${ApiConfig.baseUrl}/rooms?ownerId=$_currentUserId'),
      ));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final rooms = data.map((json) => Room.fromJson(json)).toList();
        controller.add(rooms);
      } else {
        controller.addError('Lỗi tải phòng: ${response.statusCode}');
      }
    } catch (e) {
      controller.addError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> _fetchRooms(String propertyId) async {
    try {
      final response = await ApiConfig.request(() => http.get(
        Uri.parse('${ApiConfig.baseUrl}/rooms?propertyId=$propertyId'),
      ));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final rooms = data.map((json) => Room.fromJson(json)).toList();
        _getOrCreateController(propertyId).add(rooms);
      } else {
        _getOrCreateController(propertyId).addError('Lỗi tải phòng: ${response.statusCode}');
      }
    } catch (e) {
      _getOrCreateController(propertyId).addError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<List<Room>> filterRooms(String propertyId, {String? query, String? status, double? minPrice, double? maxPrice}) async {
    String url = '${ApiConfig.baseUrl}/rooms?propertyId=$propertyId';
    if (status != null && status != 'all') url += '&status=$status';
    if (query != null && query.isNotEmpty) url += '&query=${Uri.encodeComponent(query)}';
    if (minPrice != null) url += '&minPrice=$minPrice';
    if (maxPrice != null) url += '&maxPrice=$maxPrice';

    final response = await ApiConfig.request(() => http.get(Uri.parse(url)));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Room.fromJson(json)).toList();
    }
    return [];
  }

  Future<void> addRoom({
    required String propertyId,
    required String roomNumber,
    required int floor,
    required double area,
    required double price,
    String description = '',
  }) async {
    if (_currentUserId == null) throw Exception('Vui lòng đăng nhập!');
    final response = await ApiConfig.request(() => http.post(
      Uri.parse('${ApiConfig.baseUrl}/rooms'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'propertyId': propertyId, 'ownerId': _currentUserId,
        'roomNumber': roomNumber, 'floor': floor,
        'area': area, 'price': price, 'description': description,
      }),
    ));
    if (response.statusCode == 200) {
      await _fetchRooms(propertyId);
      await _propertyService.updateRoomCount(propertyId, 1);
    } else {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Lỗi thêm phòng.');
    }
  }

  Future<void> updateRoom(String roomId, {
    required String roomNumber, required int floor,
    required double area, required double price, required String description,
  }) async {
    final response = await ApiConfig.request(() => http.put(
      Uri.parse('${ApiConfig.baseUrl}/rooms/$roomId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'roomNumber': roomNumber, 'floor': floor,
        'area': area, 'price': price, 'description': description,
      }),
    ));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await _fetchRooms(data['propertyId']);
    } else {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Lỗi cập nhật phòng.');
    }
  }

  Future<void> updateRoomStatus(String roomId, String status) async {
    final response = await ApiConfig.request(() => http.put(
      Uri.parse('${ApiConfig.baseUrl}/rooms/$roomId/status'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'status': status}),
    ));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await _fetchRooms(data['propertyId']);
    }
  }

  Future<void> deleteRoom(String roomId, String propertyId) async {
    final response = await ApiConfig.request(() => http.delete(
      Uri.parse('${ApiConfig.baseUrl}/rooms/$roomId'),
    ));
    if (response.statusCode == 200) {
      await _fetchRooms(propertyId);
      await _propertyService.updateRoomCount(propertyId, -1);
    } else {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Lỗi xóa phòng.');
    }
  }

  Future<Room?> getRoomById(String roomId) async {
    try {
      final response = await ApiConfig.request(() => http.get(Uri.parse('${ApiConfig.baseUrl}/rooms/$roomId')));
      if (response.statusCode == 200) {
        return Room.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      print('Lỗi lấy phòng theo ID: $e');
    }
    return null;
  }
}
