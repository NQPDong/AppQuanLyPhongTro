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

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'] ?? '',
      ownerId: json['ownerId'] ?? '',
      contractId: json['contractId'] ?? '',
      roomId: json['roomId'] ?? '',
      tenantId: json['tenantId'] ?? '',
      month: json['month'] ?? 1,
      year: json['year'] ?? 2024,
      oldElec: (json['oldElec'] ?? 0).toDouble(),
      newElec: (json['newElec'] ?? 0).toDouble(),
      elecPrice: (json['elecPrice'] ?? 0).toDouble(),
      oldWater: (json['oldWater'] ?? 0).toDouble(),
      newWater: (json['newWater'] ?? 0).toDouble(),
      waterPrice: (json['waterPrice'] ?? 0).toDouble(),
      serviceFee: (json['serviceFee'] ?? 0).toDouble(),
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      isPaid: json['isPaid'] ?? false,
      paidDate: json['paidDate'] != null ? DateTime.parse(json['paidDate']) : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
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
    };
  }
}
