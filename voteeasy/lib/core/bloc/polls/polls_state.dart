import 'package:equatable/equatable.dart';
import 'package:voteeasy/core/models/poll.dart';

abstract class PollsState extends Equatable {
  final List<Poll> data;

  const PollsState({required this.data});
//wdqwd
  @override
  List<Object?> get props => [data];
}

class PollsInitialState extends PollsState {
  const PollsInitialState() : super(data: const []);
}

class PollsLoadingState extends PollsState {
  const PollsLoadingState({required super.data});
}

class PollsLoadedState extends PollsState {
  const PollsLoadedState({required super.data});
}

class PollsErrorState extends PollsState {
  final String error;

  const PollsErrorState({
    required this.error,
    required super.data,
  });

  @override
  List<Object?> get props => [error, data];
}

