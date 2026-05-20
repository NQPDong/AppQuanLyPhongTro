import 'package:cloud_firestore/cloud_firestore.dart';

class Contract {
  final String id;
  final String ownerId;
  final String propertyId;
  final String roomId;
  final String tenantId;
  final DateTime startDate;
  final DateTime endDate;
  final double depositAmount;
  final String status; // active, expired, terminated
  final String code;
  final DateTime createdAt;

  Contract({
    required this.id,
    required this.ownerId,
    required this.propertyId,
    required this.roomId,
    required this.tenantId,
    required this.startDate,
    required this.endDate,
    required this.depositAmount,
    this.status = 'active',
    this.code = '',
    required this.createdAt,
  });

  factory Contract.fromMap(Map<String, dynamic> data, String id) {
    return Contract(
      id: id,
      ownerId: data['ownerId'] ?? '',
      propertyId: data['propertyId'] ?? '',
      roomId: data['roomId'] ?? '',
      tenantId: data['tenantId'] ?? '',
      startDate: (data['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (data['endDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      depositAmount: (data['depositAmount'] ?? 0).toDouble(),
      status: data['status'] ?? 'active',
      code: data['code'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'propertyId': propertyId,
      'roomId': roomId,
      'tenantId': tenantId,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'depositAmount': depositAmount,
      'status': status,
      'code': code,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
