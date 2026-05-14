import 'package:cloud_firestore/cloud_firestore.dart';

class Tenant {
  final String id;
  final String ownerId;
  final String fullName;
  final String phone;
  final String idCard;
  final String address;
  final String notes;
  final String code;
  final DateTime createdAt;

  Tenant({
    required this.id,
    required this.ownerId,
    required this.fullName,
    required this.phone,
    required this.idCard,
    this.address = '',
    this.notes = '',
    this.code = '',
    required this.createdAt,
  });

  factory Tenant.fromMap(Map<String, dynamic> data, String id) {
    return Tenant(
      id: id,
      ownerId: data['ownerId'] ?? '',
      fullName: data['fullName'] ?? '',
      phone: data['phone'] ?? '',
      idCard: data['idCard'] ?? '',
      address: data['address'] ?? '',
      notes: data['notes'] ?? '',
      code: data['code'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'fullName': fullName,
      'phone': phone,
      'idCard': idCard,
      'address': address,
      'notes': notes,
      'code': code,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
