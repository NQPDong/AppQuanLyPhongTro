import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/tenant.dart';

class TenantService {
  final CollectionReference _tenantsCollection = FirebaseFirestore.instance.collection('tenants');
  final String? _currentUserId = FirebaseAuth.instance.currentUser?.uid;

  Future<String> _generateCode() async {
    if (_currentUserId == null) return 'KH001';
    final snapshot = await _tenantsCollection.where('ownerId', isEqualTo: _currentUserId).get();
    int maxNumber = 0;
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final code = data['code'] as String?;
      if (code != null && code.startsWith('KH')) {
        final numberPart = code.substring(2);
        final number = int.tryParse(numberPart) ?? 0;
        if (number > maxNumber) maxNumber = number;
      }
    }
    return 'KH${(maxNumber + 1).toString().padLeft(3, '0')}';
  }

  // Lấy danh sách khách thuê (Realtime)
  Stream<List<Tenant>> getTenants() {
    if (_currentUserId == null) return const Stream.empty();
    
    return _tenantsCollection
        .where('ownerId', isEqualTo: _currentUserId)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs.map((doc) => Tenant.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
      list.sort((a, b) => a.fullName.compareTo(b.fullName)); // Sắp xếp theo tên A-Z
      return list;
    });
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

    // Check trùng CMND/CCCD
    final checkSnapshot = await _tenantsCollection
      .where('ownerId', isEqualTo: _currentUserId)
      .where('idCard', isEqualTo: idCard)
      .get();
      
    if (checkSnapshot.docs.isNotEmpty) {
      throw Exception('Khách hàng với số CMND/CCCD này đã tồn tại!');
    }

    final newTenant = Tenant(
      id: '',
      ownerId: _currentUserId,
      fullName: fullName,
      phone: phone,
      idCard: idCard,
      address: address,
      notes: notes,
      code: await _generateCode(),
      createdAt: DateTime.now(),
    );

    await _tenantsCollection.add(newTenant.toMap());
  }

  // Cập nhật thông tin khách thuê
  Future<void> updateTenant(String tenantId, {
    required String fullName,
    required String phone,
    required String idCard,
    required String address,
    required String notes,
  }) async {
    await _tenantsCollection.doc(tenantId).update({
      'fullName': fullName,
      'phone': phone,
      'idCard': idCard,
      'address': address,
      'notes': notes,
    });
  }

  // Xóa khách thuê
  Future<void> deleteTenant(String tenantId) async {
    await _tenantsCollection.doc(tenantId).delete();
  }
}
