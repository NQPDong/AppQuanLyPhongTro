import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';

class AppUser {
  final String uid;
  final String email;
  final String displayName;
  AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      uid: json['id'] ?? '',
      email: json['email'] ?? '',
      displayName: json['fullName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': uid,
      'email': email,
      'fullName': displayName,
    };
  }
}

class AuthService {
  static AppUser? currentUser;

  // 1. Đăng nhập
  Future<AppUser?> signInWithEmail(String email, String password) async {
    try {
      final response = await ApiConfig.request(() => http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ));

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        currentUser = AppUser.fromJson(userData);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('currentUser', jsonEncode(currentUser!.toJson()));
        return currentUser;
      } else {
        final errorMsg = jsonDecode(response.body)['message'] ?? 'Sai mật khẩu hoặc tài khoản không tồn tại.';
        throw Exception(errorMsg);
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // 2. Đăng ký
  Future<AppUser?> registerWithEmail(String email, String password, {String fullName = ''}) async {
    try {
      final response = await ApiConfig.request(() => http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'fullName': fullName.isNotEmpty ? fullName : email.split('@')[0],
        }),
      ));

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        currentUser = AppUser.fromJson(userData);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('currentUser', jsonEncode(currentUser!.toJson()));
        return currentUser;
      } else {
        final errorMsg = jsonDecode(response.body)['message'] ?? 'Email đã tồn tại.';
        throw Exception(errorMsg);
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // 3. Đăng xuất
  Future<void> signOut() async {
    currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('currentUser');
  }

  // Tự động đăng nhập
  static Future<bool> tryAutoLogin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userStr = prefs.getString('currentUser');
      if (userStr != null) {
        final userData = jsonDecode(userStr);
        currentUser = AppUser.fromJson(userData);
        return true;
      }
    } catch (e) {
      print('Lỗi auto login: $e');
    }
    return false;
  }

  // 4. Quên mật khẩu
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      final response = await ApiConfig.request(() => http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      ));

      if (response.statusCode != 200) {
        final errorMsg = jsonDecode(response.body)['message'] ?? 'Lỗi không xác định.';
        throw Exception(errorMsg);
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // 5. Cập nhật tên hiển thị
  Future<void> updateCurrentUserDisplayName(String newName) async {
    if (currentUser == null) return;
    try {
      final response = await ApiConfig.request(() => http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/update-name'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': currentUser!.uid,
          'fullName': newName,
        }),
      ));

      if (response.statusCode == 200) {
        currentUser = AppUser(
          uid: currentUser!.uid,
          email: currentUser!.email,
          displayName: newName,
        );
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('currentUser', jsonEncode(currentUser!.toJson()));
      } else {
        final errorMsg = jsonDecode(response.body)['message'] ?? 'Cập nhật không thành công.';
        throw Exception(errorMsg);
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // 6. Đổi mật khẩu
  Future<void> changePassword(String oldPassword, String newPassword) async {
    if (currentUser == null) return;
    try {
      final response = await ApiConfig.request(() => http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/change-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': currentUser!.uid,
          'oldPassword': oldPassword,
          'newPassword': newPassword,
        }),
      ));

      if (response.statusCode != 200) {
        final errorMsg = jsonDecode(response.body)['message'] ?? 'Đổi mật khẩu không thành công.';
        throw Exception(errorMsg);
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }
}
