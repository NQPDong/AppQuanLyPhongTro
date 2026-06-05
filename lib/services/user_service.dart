import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';

class UserService {
  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('users');

  // Lấy thông tin user profile từ Firestore
  Future<UserProfile> getUserProfile(String uid, String defaultEmail) async {
    try {
      final doc = await _usersCollection.doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserProfile.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return UserProfile(id: uid, fullName: '', phone: '', zalo: '', email: defaultEmail);
    } catch (e) {
      return UserProfile(id: uid, fullName: '', phone: '', zalo: '', email: defaultEmail);
    }
  }

  // Cập nhật thông tin profile lên Firestore
  Future<void> updateUserProfile(UserProfile profile) async {
    await _usersCollection.doc(profile.id).set(profile.toMap(), SetOptions(merge: true));
  }
}
