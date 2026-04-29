class Room {
  String id;
  String propertyId; // Thuộc cơ sở nào
  String roomNumber;
  int floor;
  double area;
  double price;
  String status; // 'available', 'rented', 'maintenance'
  String description;

  Room({required this.id, ...});

  factory Room.fromMap(Map<String, dynamic> data, String documentId) {
    return Room(
      id: documentId,
      propertyId: data['propertyId'] ?? '',
      roomNumber: data['roomNumber'] ?? '',
      status: data['status'] ?? 'available',
    );
  }
}