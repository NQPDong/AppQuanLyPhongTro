import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/contract.dart';
import 'room_service.dart';

class ContractService {
  final CollectionReference _contractsCollection = FirebaseFirestore.instance.collection('contracts');
  final String? _currentUserId = FirebaseAuth.instance.currentUser?.uid;
  final RoomService _roomService = RoomService();

  Future<String> _generateCode() async {
    if (_currentUserId == null) return 'HD001';
    final snapshot = await _contractsCollection.where('ownerId', isEqualTo: _currentUserId).get();
    int maxNumber = 0;
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final code = data['code'] as String?;
      if (code != null && code.startsWith('HD')) {
        final numberPart = code.substring(2);
        final number = int.tryParse(numberPart) ?? 0;
        if (number > maxNumber) maxNumber = number;
      }
    }
    return 'HD${(maxNumber + 1).toString().padLeft(3, '0')}';
  }

  // Lấy danh sách hợp đồng (Realtime)
  Stream<List<Contract>> getContracts() {
    if (_currentUserId == null) return const Stream.empty();
    
    return _contractsCollection
        .where('ownerId', isEqualTo: _currentUserId)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs.map((doc) => Contract.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Mới nhất lên đầu
      return list;
    });
  }

  // Lấy hợp đồng theo roomId
  Future<Contract?> getActiveContractByRoom(String roomId) async {
    final snapshot = await _contractsCollection
        .where('roomId', isEqualTo: roomId)
        .where('status', isEqualTo: 'active')
        .limit(1)
        .get();
        
    if (snapshot.docs.isNotEmpty) {
      return Contract.fromMap(snapshot.docs.first.data() as Map<String, dynamic>, snapshot.docs.first.id);
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

    // 1. Tạo hợp đồng mới
    final newContract = Contract(
      id: '',
      ownerId: _currentUserId,
      propertyId: propertyId,
      roomId: roomId,
      tenantId: tenantId,
      startDate: startDate,
      endDate: endDate,
      depositAmount: depositAmount,
      status: 'active',
      code: await _generateCode(),
      createdAt: DateTime.now(),
    );

    await _contractsCollection.add(newContract.toMap());

    // 2. Cập nhật trạng thái phòng thành 'rented'
    await _roomService.updateRoomStatus(roomId, 'rented');
  }

  // Thanh lý hợp đồng
  Future<void> terminateContract(String contractId, String roomId) async {
    // 1. Chuyển status hợp đồng thành terminated
    await _contractsCollection.doc(contractId).update({'status': 'terminated'});
    
    // 2. Chuyển trạng thái phòng thành available
    await _roomService.updateRoomStatus(roomId, 'available');
  }
}
