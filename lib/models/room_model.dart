class RoomModel {
  String id;
  String propertyId; // Thuộc cơ sở nào
  String roomNumber;
  int floor;
  double area;
  double price;
  String status; // 'available', 'rented', 'maintenance'
  String description;

  RoomModel({required this.id, required this.propertyId, required this.roomNumber, required this.floor, required this.area, required this.price, required this.status, required this.description});

  Map<String, dynamic> toMap() => {'id': id, 'propertyId': propertyId, 'roomNumber': roomNumber, 'floor': floor, 'area': area, 'price': price, 'status': status, 'description': description};

  factory RoomModel.fromMap(Map<String, dynamic> map) => RoomModel(id: map['id'] ?? '', propertyId: map['propertyId'] ?? '', roomNumber: map['roomNumber'] ?? '', floor: map['floor'] ?? 1, area: (map['area'] ?? 0).toDouble(), price: (map['price'] ?? 0).toDouble(), status: map['status'] ?? 'available', description: map['description'] ?? '');
}
