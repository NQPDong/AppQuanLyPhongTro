import 'package:cloud_firestore/cloud_firestore.dart';

class Invoice {
  final String id;
  final String ownerId;
  final String contractId;
  final String roomId;
  final String tenantId;
  final int month;
  final int year;
  final double oldElec;
  final double newElec;
  final double elecPrice;
  final double oldWater;
  final double newWater;
  final double waterPrice;
  final double serviceFee;
  final double totalAmount;
  final bool isPaid;
  final DateTime? paidDate;
  final DateTime createdAt;

  Invoice({
    required this.id,
    required this.ownerId,
    required this.contractId,
    required this.roomId,
    required this.tenantId,
    required this.month,
    required this.year,
    required this.oldElec,
    required this.newElec,
    required this.elecPrice,
    required this.oldWater,
    required this.newWater,
    required this.waterPrice,
    this.serviceFee = 0,
    required this.totalAmount,
    this.isPaid = false,
    this.paidDate,
    required this.createdAt,
  });

  factory Invoice.fromMap(Map<String, dynamic> data, String id) {
    return Invoice(
      id: id,
      ownerId: data['ownerId'] ?? '',
      contractId: data['contractId'] ?? '',
      roomId: data['roomId'] ?? '',
      tenantId: data['tenantId'] ?? '',
      month: data['month'] ?? 1,
      year: data['year'] ?? 2024,
      oldElec: (data['oldElec'] ?? 0).toDouble(),
      newElec: (data['newElec'] ?? 0).toDouble(),
      elecPrice: (data['elecPrice'] ?? 0).toDouble(),
      oldWater: (data['oldWater'] ?? 0).toDouble(),
      newWater: (data['newWater'] ?? 0).toDouble(),
      waterPrice: (data['waterPrice'] ?? 0).toDouble(),
      serviceFee: (data['serviceFee'] ?? 0).toDouble(),
      totalAmount: (data['totalAmount'] ?? 0).toDouble(),
      isPaid: data['isPaid'] ?? false,
      paidDate: (data['paidDate'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'contractId': contractId,
      'roomId': roomId,
      'tenantId': tenantId,
      'month': month,
      'year': year,
      'oldElec': oldElec,
      'newElec': newElec,
      'elecPrice': elecPrice,
      'oldWater': oldWater,
      'newWater': newWater,
      'waterPrice': waterPrice,
      'serviceFee': serviceFee,
      'totalAmount': totalAmount,
      'isPaid': isPaid,
      'paidDate': paidDate != null ? Timestamp.fromDate(paidDate!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
