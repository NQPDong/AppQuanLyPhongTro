import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/property_model.dart';

class PropertyService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Thêm cơ sở mới
  Future<void> addProperty(PropertyModel property) {
    return _db.collection('properties').doc(property.id).set(property.toMap());
  }

  // Cập nhật thông tin cơ sở
  Future<void> updateProperty(PropertyModel property) {
    return _db.collection('properties').doc(property.id).update(property.toMap());
  }

  // Xóa cơ sở
  Future<void> deleteProperty(String propertyId) {
    return _db.collection('properties').doc(propertyId).delete();
  }

  // Lấy danh sách cơ sở theo ownerId (Realtime)
  Stream<List<PropertyModel>> getProperties(String ownerId) {
    return _db.collection('properties').where('ownerId', isEqualTo: ownerId).snapshots().map((snapshot) => snapshot.docs.map((doc) => PropertyModel.fromMap(doc.data(), doc.id)).toList());
  }

  // Cập nhật số lượng phòng
  Future<void> updateRoomCount(String propertyId, int change) {
    return _db.collection('properties').doc(propertyId).update({
      'totalRooms': FieldValue.increment(change),
    });
  }
}
