import 'package:equatable/equatable.dart';
import '../../models/models.dart';

abstract class CreatePollState extends Equatable {
  const CreatePollState();

  @override
  List<Object?> get props => [];
}

class CreatePollInitial extends CreatePollState {
  const CreatePollInitial();
}

class PollCreating extends CreatePollState {
  const PollCreating();
}

class PollCreateSuccess extends CreatePollState {
  final Poll poll;

  const PollCreateSuccess(this.poll);

  @override
  List<Object?> get props => [poll];
}

class PollCreateError extends CreatePollState {
  final String message;

  const PollCreateError(this.message);

  @override
  List<Object?> get props => [message];
}
