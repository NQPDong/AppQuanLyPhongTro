import 'package:cloud_firestore/cloud_firestore.dart';

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

  factory Room.fromMap(Map<String, dynamic> data, String id) {
    return Room(
      id: id,
      propertyId: data['propertyId'] ?? '',
      ownerId: data['ownerId'] ?? '',
      roomNumber: data['roomNumber'] ?? '',
      floor: data['floor'] ?? 1,
      area: (data['area'] ?? 0).toDouble(),
      price: (data['price'] ?? 0).toDouble(),
      description: data['description'] ?? '',
      status: data['status'] ?? 'available',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'propertyId': propertyId,
      'ownerId': ownerId,
      'roomNumber': roomNumber,
      'floor': floor,
      'area': area,
      'price': price,
      'description': description,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

