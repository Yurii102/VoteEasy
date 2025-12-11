import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Модель голосу в опитуванні
class Vote extends Equatable {
  final String userId;
  final String userName;
  final List<int> optionIndexes;
  final DateTime votedAt;

  const Vote({
    required this.userId,
    required this.userName,
    required this.optionIndexes,
    required this.votedAt,
  });

  /// Конвертувати в Map для Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'optionIndexes': optionIndexes,
      'votedAt': Timestamp.fromDate(votedAt),
    };
  }

  /// Створити з Firestore DocumentSnapshot
  factory Vote.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Vote(
      userId: data['userId'] as String,
      userName: data['userName'] as String? ?? 'Anonymous',
      optionIndexes: List<int>.from(data['optionIndexes'] ?? []),
      votedAt: (data['votedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Створити з Map
  factory Vote.fromMap(Map<String, dynamic> map) {
    return Vote(
      userId: map['userId'] as String,
      userName: map['userName'] as String? ?? 'Anonymous',
      optionIndexes: List<int>.from(map['optionIndexes'] ?? []),
      votedAt: map['votedAt'] is DateTime
          ? map['votedAt'] as DateTime
          : DateTime.now(),
    );
  }

  /// Copy with method
  Vote copyWith({
    String? userId,
    String? userName,
    List<int>? optionIndexes,
    DateTime? votedAt,
  }) {
    return Vote(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      optionIndexes: optionIndexes ?? this.optionIndexes,
      votedAt: votedAt ?? this.votedAt,
    );
  }

  @override
  List<Object?> get props => [
        userId,
        userName,
        optionIndexes,
        votedAt,
      ];
}
