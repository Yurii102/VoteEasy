import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/poll.dart';
import '../../repositories/polls_repository.dart';
import 'polls_event.dart';
import 'polls_state.dart';


class _PollsUpdatedEvent extends PollsEvent {
  final List<Poll> polls;

  const _PollsUpdatedEvent(this.polls);

  @override
  List<Object?> get props => [polls];
}

class PollsBloc extends Bloc<PollsEvent, PollsState> {
  final PollsRepository _pollsRepository;
  StreamSubscription<List<Poll>>? _pollsSubscription;
  bool _isErrorMode = false;
  
  PollsBloc({PollsRepository? pollsRepository})
      : _pollsRepository = pollsRepository ?? PollsRepository(),
        super(const PollsInitialState()) {
    on<LoadPollsEvent>(_onLoadPollsEvent);
    on<RefreshPollsEvent>(_onRefreshPollsEvent);
    on<TestErrorEvent>(_onTestErrorEvent);
    on<_PollsUpdatedEvent>(_onPollsUpdatedEvent);
  }

  Future<void> _onLoadPollsEvent(
    LoadPollsEvent event,
    Emitter<PollsState> emit,
  ) async {
    emit(PollsLoadingState(data: state.data));

    try {
      if (_isErrorMode) {
        throw 'Test error';
      }
      
      await _pollsSubscription?.cancel();
      
      await emit.forEach<List<Poll>>(
        _pollsRepository.getActivePolls(),
        onData: (polls) => PollsLoadedState(data: polls),
        onError: (error, stackTrace) => PollsErrorState(
          error: 'Failed to load polls: ${error.toString()}',
          data: state.data,
        ),
      );
    } catch (e) {
      emit(PollsErrorState(
        error: 'An unexpected error occurred: ${e.toString()}',
        data: state.data,
      ));
    }
  }

  Future<void> _onPollsUpdatedEvent(
    _PollsUpdatedEvent event,
    Emitter<PollsState> emit,
  ) async {
  }

  Future<void> _onRefreshPollsEvent(
    RefreshPollsEvent event,
    Emitter<PollsState> emit,
  ) async {
    add(LoadPollsEvent());
  }

  Future<void> _onTestErrorEvent(
    TestErrorEvent event,
    Emitter<PollsState> emit,
  ) async {
    _isErrorMode = true;
    
    emit(PollsLoadingState(data: state.data));
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      throw 'Test error';
    } catch (e) {
      emit(PollsErrorState(error: e.toString(), data: []));
    }
  }

  @override
  Future<void> close() {
    _pollsSubscription?.cancel();
    return super.close();
  }
}
