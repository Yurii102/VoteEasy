import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/polls_repository.dart';
import 'update_poll_event.dart';
import 'update_poll_state.dart';

class UpdatePollBloc extends Bloc<UpdatePollEvent, UpdatePollState> {
  final PollsRepository _pollsRepository;

  UpdatePollBloc({PollsRepository? pollsRepository})
      : _pollsRepository = pollsRepository ?? PollsRepository(),
        super(const UpdatePollInitial()) {
    on<UpdatePollSubmitted>(_onUpdatePollSubmitted);
    on<UpdatePollReset>(_onUpdatePollReset);
  }

  Future<void> _onUpdatePollSubmitted(
    UpdatePollSubmitted event,
    Emitter<UpdatePollState> emit,
  ) async {
    emit(const PollUpdating());

    try {
      if (event.question.trim().isEmpty) {
        emit(const PollUpdateError('Question is required'));
        return;
      }

      if (event.options.length < 2) {
        emit(const PollUpdateError('At least 2 options are required'));
        return;
      }

      if (event.options.length > 10) {
        emit(const PollUpdateError('Maximum 10 options allowed'));
        return;
      }

      await _pollsRepository.updatePoll(
        pollId: event.pollId,
        question: event.question.trim(),
        description: event.description?.trim(),
        category: event.category,
      );

      final updatedPoll = await _pollsRepository.getPollById(event.pollId);
      if (updatedPoll != null) {
        emit(PollUpdateSuccess(updatedPoll));
      } else {
        emit(const PollUpdateError('Failed to load updated poll'));
      }
    } catch (e) {
      emit(PollUpdateError('Failed to update poll: ${e.toString()}'));
    }
  }

  void _onUpdatePollReset(
    UpdatePollReset event,
    Emitter<UpdatePollState> emit,
  ) {
    emit(const UpdatePollInitial());
  }
}
