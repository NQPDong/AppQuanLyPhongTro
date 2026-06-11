class Room {
  final String id;
  final String propertyId;
  final String ownerId;
  final String roomNumber;
  final int floor;
  final double area;
  final double price;
  final String description;
  final String status; // available, rented, maintenance
  final DateTime createdAt;

  Room({
    required this.id,
    required this.propertyId,
    required this.ownerId,
    required this.roomNumber,
    required this.floor,
    required this.area,
    required this.price,
    this.description = '',
    this.status = 'available',
    required this.createdAt,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'] ?? '',
      propertyId: json['propertyId'] ?? '',
      ownerId: json['ownerId'] ?? '',
      roomNumber: json['roomNumber'] ?? '',
      floor: json['floor'] ?? 1,
      area: (json['area'] ?? 0).toDouble(),
      price: (json['price'] ?? 0).toDouble(),
      description: json['description'] ?? '',
      status: json['status'] ?? 'available',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'propertyId': propertyId,
      'ownerId': ownerId,
      'roomNumber': roomNumber,
      'floor': floor,
      'area': area,
      'price': price,
      'description': description,
      'status': status,
    };
  }
}
