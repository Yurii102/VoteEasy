import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Poll extends Equatable {
  final String id;
  final String question;
  final String? description;
  final String authorId;
  final String authorName;
  final String? authorEmail;
  final String category;
  final List<String> options;
  final bool allowMultipleVotes;
  final bool showResultsBeforeEnd;
  final bool isPrivate; 
  final String? password; 
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? endDate;
  final String status;
  final int totalVotes;
  final Map<String, int> votesCount; 

  const Poll({
    required this.id,
    required this.question,
    this.description,
    required this.authorId,
    required this.authorName,
    this.authorEmail,
    required this.category,
    required this.options,
    required this.allowMultipleVotes,
    required this.showResultsBeforeEnd,
    required this.isPrivate,
    this.password,
    required this.createdAt,
    required this.updatedAt,
    this.endDate,
    required this.status,
    required this.totalVotes,
    required this.votesCount,
  });

  String get author => authorName;
  
  int get votes => totalVotes;

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '${years}y ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '${months}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'just now';
    }
  }

  bool get isExpired {
    if (endDate == null) return false;
    return DateTime.now().isAfter(endDate!);
  }

  double getOptionPercentage(int optionIndex) {
    if (totalVotes == 0) return 0.0;
    final count = votesCount['$optionIndex'] ?? 0;
    return (count / totalVotes) * 100;
  }

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'description': description,
      'authorId': authorId,
      'authorName': authorName,
      'authorEmail': authorEmail,
      'category': category,
      'options': options,
      'allowMultipleVotes': allowMultipleVotes,
      'showResultsBeforeEnd': showResultsBeforeEnd,
      'isPrivate': isPrivate,
      'password': password,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'status': status,
      'totalVotes': totalVotes,
      'votesCount': votesCount,
    };
  }

  factory Poll.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return Poll(
      id: doc.id,
      question: data['question'] as String? ?? 'Untitled Poll',
      description: data['description'] as String?,
      authorId: data['authorId'] as String? ?? '',
      authorName: data['authorName'] as String? ?? 'Unknown',
      authorEmail: data['authorEmail'] as String?,
      category: data['category'] as String? ?? 'General',
      options: List<String>.from(data['options'] ?? []),
      allowMultipleVotes: data['allowMultipleVotes'] as bool? ?? false,
      showResultsBeforeEnd: data['showResultsBeforeEnd'] as bool? ?? true,
      isPrivate: data['isPrivate'] as bool? ?? data['isAnonymous'] as bool? ?? false,
      password: data['password'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (data['endDate'] as Timestamp?)?.toDate(),
      status: data['status'] as String? ?? 'active',
      totalVotes: data['totalVotes'] as int? ?? 0,
      votesCount: Map<String, int>.from(data['votesCount'] ?? {}),
    );
  }

  factory Poll.fromMap(Map<String, dynamic> map) {
    return Poll(
      id: map['id'] as String,
      question: map['question'] as String,
      description: map['description'] as String?,
      authorId: map['authorId'] as String? ?? '',
      authorName: map['author'] as String? ?? map['authorName'] as String? ?? 'Unknown',
      authorEmail: map['authorEmail'] as String?,
      category: map['category'] as String? ?? 'General',
      options: map['options'] != null ? List<String>.from(map['options']) : [],
      allowMultipleVotes: map['allowMultipleVotes'] as bool? ?? false,
      showResultsBeforeEnd: map['showResultsBeforeEnd'] as bool? ?? true,
      isPrivate: map['isPrivate'] as bool? ?? map['isAnonymous'] as bool? ?? false,
      password: map['password'] as String?,
      createdAt: map['createdAt'] is DateTime 
          ? map['createdAt'] as DateTime 
          : DateTime.now(),
      updatedAt: map['updatedAt'] is DateTime 
          ? map['updatedAt'] as DateTime 
          : DateTime.now(),
      endDate: map['endDate'] is DateTime ? map['endDate'] as DateTime : null,
      status: map['status'] as String? ?? 'active',
      totalVotes: map['votes'] as int? ?? map['totalVotes'] as int? ?? 0,
      votesCount: map['votesCount'] != null 
          ? Map<String, int>.from(map['votesCount']) 
          : {},
    );
  }

  Poll copyWith({
    String? id,
    String? question,
    String? description,
    String? authorId,
    String? authorName,
    String? authorEmail,
    String? category,
    List<String>? options,
    bool? allowMultipleVotes,
    bool? showResultsBeforeEnd,
    bool? isPrivate,
    String? password,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? endDate,
    String? status,
    int? totalVotes,
    Map<String, int>? votesCount,
  }) {
    return Poll(
      id: id ?? this.id,
      question: question ?? this.question,
      description: description ?? this.description,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorEmail: authorEmail ?? this.authorEmail,
      category: category ?? this.category,
      options: options ?? this.options,
      allowMultipleVotes: allowMultipleVotes ?? this.allowMultipleVotes,
      showResultsBeforeEnd: showResultsBeforeEnd ?? this.showResultsBeforeEnd,
      isPrivate: isPrivate ?? this.isPrivate,
      password: password ?? this.password,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      totalVotes: totalVotes ?? this.totalVotes,
      votesCount: votesCount ?? this.votesCount,
    );
  }

  @override
  List<Object?> get props => [
        id,
        question,
        description,
        authorId,
        authorName,
        authorEmail,
        category,
        options,
        allowMultipleVotes,
        showResultsBeforeEnd,
        isPrivate,
        password,
        createdAt,
        updatedAt,
        endDate,
        status,
        totalVotes,
        votesCount,
      ];
}
