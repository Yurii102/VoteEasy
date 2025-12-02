import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/poll.dart';
import 'polls_event.dart';
import 'polls_state.dart';

class PollsBloc extends Bloc<PollsEvent, PollsState> {
  bool _isErrorMode = false;
  
  PollsBloc() : super(const PollsInitialState()) {
    on<LoadPollsEvent>(_onLoadPollsEvent);
    on<RefreshPollsEvent>(_onRefreshPollsEvent);
    on<TestErrorEvent>(_onTestErrorEvent);
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
      
      await Future.delayed(const Duration(seconds: 1));

      final result = [
        const Poll(
          id: '#VP001',
          question: 'What is your favorite cider brand?',
          author: 'Yurii Surniak',
          timeAgo: '2 hours ago',
          votes: 11,
          status: 'OPEN',
        ),
        const Poll(
          id: '#VP002',
          question: 'Which beer do you prefer?',
          author: 'Jane Smith',
          timeAgo: '5 hours ago',
          votes: 123,
          status: 'CLOSED',
        ),
        const Poll(
          id: '#VP003',
          question: 'Best operating system for development?',
          author: 'Mike Johnson',
          timeAgo: '1 day ago',
          votes: 321,
          status: 'OPEN',
        ),
        const Poll(
          id: '#VP004',
          question: 'Favorite web development framework?',
          author: 'Yurii Surniak',
          timeAgo: '3 days ago',
          votes: 423,
          status: 'MINE',
        ),
      ];

      emit(PollsLoadedState(data: result));
    } catch (e) {
      emit(PollsErrorState(
        error: 'An unexpected error occurred: ${e.toString()}',
        data: state.data,
      ));
    }
  }

  Future<void> _onRefreshPollsEvent(
    RefreshPollsEvent event,
    Emitter<PollsState> emit,
  ) async {
    emit(PollsLoadingState(data: state.data));

    try {
      if (_isErrorMode) {
        throw 'Test error';
      }
      
      await Future.delayed(const Duration(seconds: 1));

      final result = [
        const Poll(
          id: '#VP001',
          question: 'What is your favorite cider brand?',
          author: 'Yurii Surniak',
          timeAgo: '2 hours ago',
          votes: 11,
          status: 'OPEN',
        ),
        const Poll(
          id: '#VP002',
          question: 'Which beer do you prefer?',
          author: 'Jane Smith',
          timeAgo: '5 hours ago',
          votes: 123,
          status: 'CLOSED',
        ),
        const Poll(
          id: '#VP003',
          question: 'Best operating system for development?',
          author: 'Mike Johnson',
          timeAgo: '1 day ago',
          votes: 321,
          status: 'OPEN',
        ),
        const Poll(
          id: '#VP004',
          question: 'Favorite web development framework?',
          author: 'Yurii Surniak',
          timeAgo: '3 days ago',
          votes: 423,
          status: 'MINE',
        ),
      ];

      emit(PollsLoadedState(data: result));
    } catch (e) {
      emit(PollsErrorState(
        error: 'Failed to refresh polls: ${e.toString()}',
        data: state.data,
      ));
    }
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
}
