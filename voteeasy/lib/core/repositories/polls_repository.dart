import '../models/poll.dart';
import '../services/firestore_service.dart';

class PollsRepository {
  final FirestoreService _firestoreService;

  PollsRepository({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  Stream<List<Poll>> getActivePolls() {
    return _firestoreService.getActivePolls();
  }

  Stream<List<Poll>> getPollsByCategory(String category) {
    return _firestoreService.getPollsByCategory(category);
  }

  Stream<List<Poll>> getUserPolls(String userId) {
    return _firestoreService.getUserPolls(userId);
  }

  Future<Poll?> getPollById(String pollId) {
    return _firestoreService.getPollById(pollId);
  }

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
  }) {
    return _firestoreService.createPoll(
      question: question,
      description: description,
      options: options,
      category: category,
      durationDays: durationDays,
      allowMultipleVotes: allowMultipleVotes,
      showResultsBeforeEnd: showResultsBeforeEnd,
      isPrivate: isPrivate,
      password: password,
    );
  }

  Future<void> updatePoll({
    required String pollId,
    String? question,
    String? description,
    String? category,
    String? status,
  }) {
    return _firestoreService.updatePoll(
      pollId: pollId,
      question: question,
      description: description,
      category: category,
      status: status,
    );
  }

  Future<void> closePoll(String pollId) {
    return _firestoreService.closePoll(pollId);
  }

  Future<void> deletePoll(String pollId) {
    return _firestoreService.deletePoll(pollId);
  }

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

  Future<Map<String, dynamic>> getPollStats(String pollId) {
    return _firestoreService.getPollStats(pollId);
  }
}
