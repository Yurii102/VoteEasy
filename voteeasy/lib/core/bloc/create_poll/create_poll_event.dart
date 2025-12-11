import 'package:equatable/equatable.dart';

abstract class CreatePollEvent extends Equatable {
  const CreatePollEvent();

  @override
  List<Object?> get props => [];
}

class CreatePollSubmitted extends CreatePollEvent {
  final String question;
  final String? description;
  final List<String> options;
  final String category;
  final int durationDays;
  final bool allowMultipleVotes;
  final bool showResultsBeforeEnd;
  final bool isPrivate;
  final String? password;

  const CreatePollSubmitted({
    required this.question,
    this.description,
    required this.options,
    required this.category,
    required this.durationDays,
    required this.allowMultipleVotes,
    required this.showResultsBeforeEnd,
    required this.isPrivate,
    this.password,
  });

  @override
  List<Object?> get props => [
        question,
        description,
        options,
        category,
        durationDays,
        allowMultipleVotes,
        showResultsBeforeEnd,
        isPrivate,
        password,
      ];
}

class CreatePollReset extends CreatePollEvent {
  const CreatePollReset();
}
