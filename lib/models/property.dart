import 'package:cloud_firestore/cloud_firestore.dart';

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

  factory Property.fromMap(Map<String, dynamic> data, String id) {
    return Property(
      id: id,
      ownerId: data['ownerId'] ?? '',
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      roomCount: data['roomCount'] ?? data['totalRooms'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'name': name,
      'address': address,
      'imageUrl': imageUrl,
      'roomCount': roomCount,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}