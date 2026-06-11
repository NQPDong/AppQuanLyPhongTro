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

  factory Contract.fromJson(Map<String, dynamic> json) {
    return Contract(
      id: json['id'] ?? '',
      ownerId: json['ownerId'] ?? '',
      propertyId: json['propertyId'] ?? '',
      roomId: json['roomId'] ?? '',
      tenantId: json['tenantId'] ?? '',
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate']) : DateTime.now(),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : DateTime.now(),
      depositAmount: (json['depositAmount'] ?? 0).toDouble(),
      status: json['status'] ?? 'active',
      code: json['code'] ?? '',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ownerId': ownerId,
      'propertyId': propertyId,
      'roomId': roomId,
      'tenantId': tenantId,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'depositAmount': depositAmount,
      'status': status,
      'code': code,
    };
  }
}
