import 'package:equatable/equatable.dart';
import '../../models/models.dart';

abstract class UpdatePollState extends Equatable {
  const UpdatePollState();

  @override
  List<Object?> get props => [];
}

class UpdatePollInitial extends UpdatePollState {
  const UpdatePollInitial();
}

class PollUpdating extends UpdatePollState {
  const PollUpdating();
}

class PollUpdateSuccess extends UpdatePollState {
  final Poll poll;

  const PollUpdateSuccess(this.poll);

  @override
  List<Object?> get props => [poll];
}

class PollUpdateError extends UpdatePollState {
  final String message;

  const PollUpdateError(this.message);

  @override
  List<Object?> get props => [message];
}
