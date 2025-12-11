import 'package:equatable/equatable.dart';

abstract class UpdatePollEvent extends Equatable {
  const UpdatePollEvent();

  @override
  List<Object?> get props => [];
}

class UpdatePollSubmitted extends UpdatePollEvent {
  final String pollId;
  final String question;
  final String? description;
  final List<String> options;
  final String category;
  final bool allowMultipleVotes;
  final bool showResultsBeforeEnd;
  final bool isPrivate;
  final String? password;

  const UpdatePollSubmitted({
    required this.pollId,
    required this.question,
    this.description,
    required this.options,
    required this.category,
    required this.allowMultipleVotes,
    required this.showResultsBeforeEnd,
    required this.isPrivate,
    this.password,
  });

  @override
  List<Object?> get props => [
        pollId,
        question,
        description,
        options,
        category,
        allowMultipleVotes,
        showResultsBeforeEnd,
        isPrivate,
        password,
      ];
}

class UpdatePollReset extends UpdatePollEvent {
  const UpdatePollReset();
}
