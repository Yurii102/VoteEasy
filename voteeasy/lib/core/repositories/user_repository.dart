import '../models/user.dart';
import '../services/firestore_service.dart';

class UserRepository {
  final FirestoreService _firestoreService;

  UserRepository({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  Future<void> updateUserProfile({
    required String userId,
    String? displayName,
    String? photoUrl,
    String? email,
  }) {
    return _firestoreService.updateUserProfile(
      userId: userId,
      displayName: displayName,
      photoUrl: photoUrl,
      email: email,
    );
  }

  Future<User?> getUserById(String userId) async {
    try {
      final doc = await _firestoreService.getUserById(userId);
      if (doc == null || !doc.exists) {
        return null;
      }
      return User.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  Stream<User?> getUserStream(String userId) {
    return _firestoreService.getUserStream(userId).map((doc) {
      if (!doc.exists) {
        return null;
      }
      return User.fromFirestore(doc);
    });
  }
}
