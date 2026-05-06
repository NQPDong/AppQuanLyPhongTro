import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/room_model.dart';

class RoomService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Thêm phòng mới
  Future<void> addRoom(RoomModel room) {
    return _db.collection('rooms').doc(room.id).set(room.toMap());
  }

  // Cập nhật toàn bộ thông tin phòng
  Future<void> updateRoom(RoomModel room) {
    return _db.collection('rooms').doc(room.id).update(room.toMap());
  }

  // Xóa phòng
  Future<void> deleteRoom(String roomId) {
    return _db.collection('rooms').doc(roomId).delete();
  }

  // Lấy danh sách phòng theo PropertyId (Realtime)
  Stream<List<RoomModel>> getRoomsByProperty(String propertyId) {
    return _db
        .collection('rooms')
        .where('propertyId', isEqualTo: propertyId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RoomModel.fromMap(doc.data()))
            .toList());
  }

  // Cập nhật trạng thái phòng
  Future<void> updateRoomStatus(String roomId, String status) {
    return _db.collection('rooms').doc(roomId).update({'status': status});
  }

  // Lọc phòng theo giá, diện tích, tầng, trạng thái (phía client)
  // Firestore không hỗ trợ lọc phức tạp nhiều field cùng lúc,nên ta tải tất cả phòng rồi lọc phía client
  static List<RoomModel> filterRooms({
    required List<RoomModel> rooms,
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
}
