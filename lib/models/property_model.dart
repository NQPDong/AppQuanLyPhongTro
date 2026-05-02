class PropertyModel {
  String id;
  String name;
  String address;
  String imageUrl;
  int totalRooms;
  String ownerId; // Link tới ID của chủ trọ

  PropertyModel({required this.id, required this.name, required this.address, required this.imageUrl, required this.totalRooms, required this.ownerId});

  // Chuyển từ JSON (Firestore) sang Object
  factory PropertyModel.fromMap(Map<String, dynamic> data, String documentId) {
    return PropertyModel(id: documentId, name: data['name'] ?? '', address: data['address'] ?? '', imageUrl: data['imageUrl'] ?? '', totalRooms: data['totalRooms'] ?? 0, ownerId: data['ownerId'] ?? '');
  }

  // Chuyển từ Object sang Map để lưu lên Firestore
  Map<String, dynamic> toMap() {
    return {'name': name, 'address': address, 'imageUrl': imageUrl, 'totalRooms': totalRooms, 'ownerId': ownerId};
  }
}
