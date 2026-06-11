import 'auth_service.dart';

class UserService {
  // Lấy thông tin user profile từ AuthService (không cần gọi API riêng)
  Future<UserProfile> getUserProfile(String uid, String defaultEmail) async {
    final user = AuthService.currentUser;
    if (user != null) {
      return UserProfile(
        id: user.uid,
        fullName: user.displayName,
        phone: '',
        zalo: '',
        email: user.email,
      );
    }
    return UserProfile(id: uid, fullName: '', phone: '', zalo: '', email: defaultEmail);
  }

  // Cập nhật tên hiển thị
  Future<void> updateUserProfile(UserProfile profile) async {
    final authService = AuthService();
    await authService.updateCurrentUserDisplayName(profile.fullName);
  }
}

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
}
