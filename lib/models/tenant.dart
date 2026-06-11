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

  factory Tenant.fromJson(Map<String, dynamic> json) {
    return Tenant(
      id: json['id'] ?? '',
      ownerId: json['ownerId'] ?? '',
      fullName: json['fullName'] ?? '',
      phone: json['phone'] ?? '',
      idCard: json['idCard'] ?? '',
      address: json['address'] ?? '',
      notes: json['notes'] ?? '',
      code: json['code'] ?? '',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ownerId': ownerId,
      'fullName': fullName,
      'phone': phone,
      'idCard': idCard,
      'address': address,
      'notes': notes,
      'code': code,
    };
  }
}
