import '../models/vote.dart';
import '../services/firestore_service.dart';
class VotesRepository {
  final FirestoreService _firestoreService;

  VotesRepository({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  Future<void> vote({
    required String pollId,
    required List<int> optionIndexes,
  }) {
    return _firestoreService.vote(
      pollId: pollId,
      optionIndexes: optionIndexes,
    );
  }

  Future<bool> hasUserVoted(String pollId) {
    return _firestoreService.hasUserVoted(pollId);
  }

  Future<List<int>?> getUserVote(String pollId) {
    return _firestoreService.getUserVote(pollId);
  }

  Future<List<Vote>> getVotesForPoll(String pollId) async {
    return [];
  }

  Future<Map<int, int>> getVotesCount(String pollId) async {
    try {
      final stats = await _firestoreService.getPollStats(pollId);
      final votesCount = stats['votesCount'] as Map<String, int>;
      
      return votesCount.map((key, value) => MapEntry(int.parse(key), value));
    } catch (e) {
      throw Exception('Failed to get votes count: $e');
    }
  }
}
