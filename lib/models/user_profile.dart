class UserProfile {
  final String id;
  final String fullName;
  final String phone;
  final String zalo;
  final String email;

  UserProfile({
    required this.id,
    this.fullName = '',
    this.phone = '',
    this.zalo = '',
    this.email = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'phone': phone,
      'zalo': zalo,
      'email': email,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map, String id) {
    return UserProfile(
      id: id,
      fullName: map['fullName'] ?? '',
      phone: map['phone'] ?? '',
      zalo: map['zalo'] ?? '',
      email: map['email'] ?? '',
    );
  }
}
