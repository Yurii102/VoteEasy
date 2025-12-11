import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/poll.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference get _pollsCollection => _firestore.collection('polls');
  CollectionReference get _usersCollection => _firestore.collection('users');

  Future<String> createPoll({
    required String question,
    String? description,
    required List<String> options,
    required String category,
    required int durationDays,
    required bool allowMultipleVotes,
    required bool showResultsBeforeEnd,
    required bool isPrivate,
    String? password,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final now = DateTime.now();
      final endDate = durationDays > 0 
          ? now.add(Duration(days: durationDays))
          : null; 

      final pollData = {
        'question': question,
        'description': description,
        'authorId': user.uid,
        'authorName': user.displayName ?? 'Anonymous',
        'authorEmail': user.email,
        'category': category,
        'options': options,
        'allowMultipleVotes': allowMultipleVotes,
        'showResultsBeforeEnd': showResultsBeforeEnd,
        'isPrivate': isPrivate,
        'password': password, 
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'endDate': endDate != null ? Timestamp.fromDate(endDate) : null,
        'status': 'active',
        'totalVotes': 0,
        'votesCount': <String, int>{}, 
      };

      final votesCount = pollData['votesCount'] as Map<String, int>;
      for (int i = 0; i < options.length; i++) {
        votesCount['$i'] = 0;
      }

      final docRef = await _pollsCollection.add(pollData);
      
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create poll: $e');
    }
  }

  Stream<List<Poll>> getActivePolls() {
    return _pollsCollection
        .where('status', isEqualTo: 'active')
        .snapshots()
        .map((snapshot) {
      final polls = snapshot.docs
          .map((doc) => Poll.fromFirestore(doc))
          .toList();
      
      polls.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return polls;
    });
  }

  Stream<List<Poll>> getPollsByCategory(String category) {
    return _pollsCollection
        .where('status', isEqualTo: 'active')
        .where('category', isEqualTo: category)
        .snapshots()
        .map((snapshot) {
      final polls = snapshot.docs
          .map((doc) => Poll.fromFirestore(doc))
          .toList();
      
      polls.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return polls;
    });
  }

  Stream<List<Poll>> getUserPolls(String userId) {
    return _pollsCollection
        .where('authorId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final polls = snapshot.docs
          .map((doc) => Poll.fromFirestore(doc))
          .toList();
      
      polls.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return polls;
    });
  }

  Future<Poll?> getPollById(String pollId) async {
    try {
      final doc = await _pollsCollection.doc(pollId).get();
      if (doc.exists) {
        return Poll.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get poll: $e');
    }
  }

  Future<void> vote({
    required String pollId,
    required List<int> optionIndexes, 
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final pollDoc = _pollsCollection.doc(pollId);
      final votesCollection = pollDoc.collection('votes');

      final existingVote = await votesCollection.doc(user.uid).get();
      if (existingVote.exists) {
        throw Exception('User already voted in this poll');
      }

      await votesCollection.doc(user.uid).set({
        'userId': user.uid,
        'userName': user.displayName ?? 'Anonymous',
        'optionIndexes': optionIndexes,
        'votedAt': FieldValue.serverTimestamp(),
      });

      await _firestore.runTransaction((transaction) async {
        final pollSnapshot = await transaction.get(pollDoc);
        if (!pollSnapshot.exists) {
          throw Exception('Poll does not exist');
        }

        final data = pollSnapshot.data() as Map<String, dynamic>;
        final votesCount = Map<String, int>.from(data['votesCount'] ?? {});
        int totalVotes = data['totalVotes'] ?? 0;

        for (final index in optionIndexes) {
          final key = '$index';
          votesCount[key] = (votesCount[key] ?? 0) + 1;
        }

        totalVotes += 1;

        transaction.update(pollDoc, {
          'votesCount': votesCount,
          'totalVotes': totalVotes,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      throw Exception('Failed to vote: $e');
    }
  }

  Future<bool> hasUserVoted(String pollId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final voteDoc = await _pollsCollection
          .doc(pollId)
          .collection('votes')
          .doc(user.uid)
          .get();

      return voteDoc.exists;
    } catch (e) {
      return false;
    }
  }

  Future<List<int>?> getUserVote(String pollId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final voteDoc = await _pollsCollection
          .doc(pollId)
          .collection('votes')
          .doc(user.uid)
          .get();

      if (voteDoc.exists) {
        final data = voteDoc.data() as Map<String, dynamic>;
        return List<int>.from(data['optionIndexes'] ?? []);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> updatePoll({
    required String pollId,
    String? question,
    String? description,
    String? category,
    String? status,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final pollDoc = await _pollsCollection.doc(pollId).get();
      if (!pollDoc.exists) {
        throw Exception('Poll does not exist');
      }

      final data = pollDoc.data() as Map<String, dynamic>;
      if (data['authorId'] != user.uid) {
        throw Exception('Only author can update poll');
      }

      final updateData = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (question != null) updateData['question'] = question;
      if (description != null) updateData['description'] = description;
      if (category != null) updateData['category'] = category;
      if (status != null) updateData['status'] = status;

      await _pollsCollection.doc(pollId).update(updateData);
    } catch (e) {
      throw Exception('Failed to update poll: $e');
    }
  }

  Future<void> closePoll(String pollId) async {
    await updatePoll(pollId: pollId, status: 'closed');
  }

  Future<void> deletePoll(String pollId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Перевірка що користувач є автором
      final pollDoc = await _pollsCollection.doc(pollId).get();
      if (!pollDoc.exists) {
        throw Exception('Poll does not exist');
      }

      final data = pollDoc.data() as Map<String, dynamic>;
      if (data['authorId'] != user.uid) {
        throw Exception('Only author can delete poll');
      }

      final votesSnapshot = await _pollsCollection
          .doc(pollId)
          .collection('votes')
          .get();

      for (final voteDoc in votesSnapshot.docs) {
        await voteDoc.reference.delete();
      }

      await _pollsCollection.doc(pollId).delete();
    } catch (e) {
      throw Exception('Failed to delete poll: $e');
    }
  }

  Future<void> updateUserProfile({
    required String userId,
    String? displayName,
    String? photoUrl,
    String? email,
  }) async {
    try {
      final userDoc = _usersCollection.doc(userId);
      final snapshot = await userDoc.get();

      final userData = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (displayName != null) userData['displayName'] = displayName;
      if (photoUrl != null) userData['photoUrl'] = photoUrl;
      if (email != null) userData['email'] = email;

      if (snapshot.exists) {
        await userDoc.update(userData);
      } else {
        userData['createdAt'] = FieldValue.serverTimestamp();
        userData['userId'] = userId;
        await userDoc.set(userData);
      }
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  Future<Map<String, dynamic>> getPollStats(String pollId) async {
    try {
      final pollDoc = await _pollsCollection.doc(pollId).get();
      if (!pollDoc.exists) {
        throw Exception('Poll does not exist');
      }

      final data = pollDoc.data() as Map<String, dynamic>;
      final totalVotes = data['totalVotes'] ?? 0;
      final votesCount = Map<String, int>.from(data['votesCount'] ?? {});

      return {
        'totalVotes': totalVotes,
        'votesCount': votesCount,
      };
    } catch (e) {
      throw Exception('Failed to get poll stats: $e');
    }
  }

  Future<DocumentSnapshot?> getUserById(String userId) async {
    try {
      final userDoc = await _usersCollection.doc(userId).get();
      return userDoc.exists ? userDoc : null;
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  Stream<DocumentSnapshot> getUserStream(String userId) {
    return _usersCollection.doc(userId).snapshots();
  }
}
