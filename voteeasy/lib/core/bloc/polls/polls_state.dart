import 'package:equatable/equatable.dart';
import '../../models/poll.dart';

abstract class PollsState extends Equatable {
  final List<Poll> data;

  const PollsState({required this.data});
//wdqwd
  @override
  List<Object?> get props => [data];
}

// Початковий стан
class PollsInitialState extends PollsState {
  const PollsInitialState() : super(data: const []);
}

// Стан завантаження
class PollsLoadingState extends PollsState {
  const PollsLoadingState({required super.data});
}

// Стан успішного завантаження
class PollsLoadedState extends PollsState {
  const PollsLoadedState({required super.data});
}

// Стан помилки
class PollsErrorState extends PollsState {
  final String error;

  const PollsErrorState({
    required this.error,
    required super.data,
  });

  @override
  List<Object?> get props => [error, data];
}
