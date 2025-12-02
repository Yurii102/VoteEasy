import 'package:equatable/equatable.dart';

abstract class PollsEvent extends Equatable {
  const PollsEvent();

  @override
  List<Object?> get props => [];
}

class LoadPollsEvent extends PollsEvent {
  const LoadPollsEvent();
}

class RefreshPollsEvent extends PollsEvent {
  const RefreshPollsEvent();
}

class FilterPollsEvent extends PollsEvent {
  final String filter;

  const FilterPollsEvent(this.filter);

  @override
  List<Object?> get props => [filter];
}

class SearchPollsEvent extends PollsEvent {
  final String query;

  const SearchPollsEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class TestErrorEvent extends PollsEvent {
  const TestErrorEvent();
}
