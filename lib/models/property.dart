class Property {
  final String id;
  final String ownerId;
  final String name;
  final String address;
  final String imageUrl;
  final int roomCount;
  final DateTime createdAt;

  Property({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.address,
    this.imageUrl = '',
    this.roomCount = 0,
    required this.createdAt,
  });

  // Alias cho các screen sử dụng tên totalRooms
  int get totalRooms => roomCount;

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['id'] ?? '',
      ownerId: json['ownerId'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      roomCount: json['roomCount'] ?? json['totalRooms'] ?? 0,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ownerId': ownerId,
      'name': name,
      'address': address,
      'imageUrl': imageUrl,
      'roomCount': roomCount,
    };
  }
}