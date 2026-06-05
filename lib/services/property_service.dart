import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/property.dart';

class PropertyService {
  final CollectionReference _propertiesCollection = FirebaseFirestore.instance.collection('properties');
  final String? _currentUserId = FirebaseAuth.instance.currentUser?.uid;

  // Lấy danh sách cơ sở (Realtime qua Stream)
  Stream<List<Property>> getProperties([String? ownerId]) {
    final uid = ownerId ?? _currentUserId;
    if (uid == null) return const Stream.empty();
    
    return _propertiesCollection
        .where('ownerId', isEqualTo: uid)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs.map((doc) => Property.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Sắp xếp giảm dần ở phía client
      return list;
    });
  }

  // Thêm cơ sở mới 
  Future<void> addProperty(Property property) async {
    await _propertiesCollection
        .doc(property.id.isNotEmpty ? property.id : null)
        .set(property.toMap());
  }

  // Cập nhật cơ sở
  Future<void> updateProperty(Property property) async {
    await _propertiesCollection.doc(property.id).update(property.toMap());
  }

  // Cập nhật số lượng phòng của cơ sở
  Future<void> updateRoomCount(String propertyId, int countDelta) async {
    await _propertiesCollection.doc(propertyId).update({
      'roomCount': FieldValue.increment(countDelta),
    });
  }

  // Xóa cơ sở
  Future<void> deleteProperty(String propertyId) async {
    await _propertiesCollection.doc(propertyId).delete();
  }
}
