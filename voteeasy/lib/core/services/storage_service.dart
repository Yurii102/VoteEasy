import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> uploadUserAvatar(File imageFile) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final fileName = 'avatar_${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storageRef = _storage.ref().child('avatars/$fileName');

      final uploadTask = storageRef.putFile(
        imageFile,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'userId': user.uid,
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      final snapshot = await uploadTask;

      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload avatar: $e');
    }
  }

  Future<void> deleteAvatarByUrl(String avatarUrl) async {
    try {
      final ref = _storage.refFromURL(avatarUrl);
      await ref.delete();
    } catch (e) {
      print('Failed to delete avatar: $e');
    }
  }

  Future<String?> getUserAvatarUrl(String userId) async {
    try {
      final listResult = await _storage.ref().child('avatars').listAll();
      
      for (var item in listResult.items) {
        if (item.name.startsWith('avatar_$userId')) {
          return await item.getDownloadURL();
        }
      }
      
      return null;
    } catch (e) {
      print('Failed to get user avatar: $e');
      return null;
    }
  }

  Future<String> uploadPollImage(File imageFile, String pollId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final fileName = 'poll_${pollId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storageRef = _storage.ref().child('poll_images/$fileName');

      final uploadTask = storageRef.putFile(
        imageFile,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'pollId': pollId,
            'userId': user.uid,
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload poll image: $e');
    }
  }
}
