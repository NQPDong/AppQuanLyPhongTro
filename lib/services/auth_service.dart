import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Xử lý lỗi Firebase
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Không tìm thấy tài khoản với email này.';
      case 'wrong-password':
        return 'Sai mật khẩu. Vui lòng thử lại.';
      case 'email-already-in-use':
        return 'Email này đã được sử dụng cho một tài khoản khác.';
      case 'invalid-email':
        return 'Định dạng email không hợp lệ.';
      case 'user-disabled':
        return 'Tài khoản này đã bị vô hiệu hóa.';
      case 'too-many-requests':
        return 'Quá nhiều yêu cầu. Vui lòng thử lại sau.';
      case 'operation-not-allowed':
        return 'Đăng nhập bằng Email/Mật khẩu chưa được bật trong Firebase.';
      default:
        return 'Đã xảy ra lỗi: ${e.message}';
    }
  }

  // 1. Đăng nhập
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      if (e is FirebaseAuthException) throw Exception(_handleAuthException(e));
      throw Exception('Lỗi hệ thống: $e');
    }
  }

  // 2. Đăng ký
  Future<User?> registerWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      if (e is FirebaseAuthException) throw Exception(_handleAuthException(e));
      throw Exception('Lỗi hệ thống: $e');
    }
  }

  // 3. Đăng xuất
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Không thể đăng xuất: $e');
    }
  }

  // 4. Quên mật khẩu
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      if (e is FirebaseAuthException) throw Exception(_handleAuthException(e));
      throw Exception('Lỗi hệ thống: $e');
    }
  }

  // Stream lắng nghe trạng thái đăng nhập
  Stream<User?> get userStatus {
    return _auth.authStateChanges();
  }
}
