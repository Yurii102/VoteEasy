import 'package:equatable/equatable.dart';

class Poll extends Equatable {
  final String id;
  final String question;
  final String author;
  final String timeAgo;
  final int votes;
  final String status;

  const Poll({
    required this.id,
    required this.question,
    required this.author,
    required this.timeAgo,
    required this.votes,
    required this.status,
  });

  // Convert to Map for easy usage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'author': author,
      'timeAgo': timeAgo,
      'votes': votes,
      'status': status,
    };
  }

  // Create from Map
  factory Poll.fromMap(Map<String, dynamic> map) {
    return Poll(
      id: map['id'] as String,
      question: map['question'] as String,
      author: map['author'] as String,
      timeAgo: map['timeAgo'] as String,
      votes: map['votes'] as int,
      status: map['status'] as String,
    );
  }

  @override
  List<Object?> get props => [id, question, author, timeAgo, votes, status];
}
