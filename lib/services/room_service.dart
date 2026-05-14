import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/room.dart';
import 'property_service.dart';

class RoomService {
  final CollectionReference _roomsCollection = FirebaseFirestore.instance.collection('rooms');
  final String? _currentUserId = FirebaseAuth.instance.currentUser?.uid;
  final PropertyService _propertyService = PropertyService();

  // Lấy danh sách phòng theo propertyId
  Stream<List<Room>> getRoomsByProperty(String propertyId) {
    if (_currentUserId == null) return const Stream.empty();
    
    return _roomsCollection
        .where('propertyId', isEqualTo: propertyId)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs.map((doc) => Room.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
      list.sort((a, b) => a.roomNumber.compareTo(b.roomNumber)); // Sắp xếp client-side
      return list;
    });
  }

  // Lọc phòng theo giá, diện tích, tầng, trạng thái
  static List<Room> filterRooms({
    required List<Room> rooms,
    double? minPrice,
    double? maxPrice,
    double? minArea,
    double? maxArea,
    int? floor,
    String? status,
  }) {
    return rooms.where((room) {
      if (minPrice != null && room.price < minPrice) return false;
      if (maxPrice != null && room.price > maxPrice) return false;
      if (minArea != null && room.area < minArea) return false;
      if (maxArea != null && room.area > maxArea) return false;
      if (floor != null && room.floor != floor) return false;
      if (status != null && status != 'Tất cả' && room.status != status) {
        return false;
      }
      return true;
    }).toList();
  }

  // Thêm phòng mới
  Future<void> addRoom(Room room) async {
    await _roomsCollection
        .doc(room.id.isNotEmpty ? room.id : null)
        .set(room.toMap());
  }

  // Cập nhật thông tin phòng 
  Future<void> updateRoom(Room room) async {
    await _roomsCollection.doc(room.id).update(room.toMap());
  }

  // Cập nhật trạng thái phòng (available/rented/maintenance)
  Future<void> updateRoomStatus(String roomId, String status) async {
    await _roomsCollection.doc(roomId).update({
      'status': status,
    });
  }

  // Xóa phòng
  Future<void> deleteRoom(String roomId, [String? propertyId]) async {
    await _roomsCollection.doc(roomId).delete();
    // Giảm roomCount ở property nếu có propertyId
    if (propertyId != null) {
      await _propertyService.updateRoomCount(propertyId, -1);
    }
  }
}
