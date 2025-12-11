import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/polls_repository.dart';
import 'create_poll_event.dart';
import 'create_poll_state.dart';

class CreatePollBloc extends Bloc<CreatePollEvent, CreatePollState> {
  final PollsRepository _pollsRepository;

  CreatePollBloc({PollsRepository? pollsRepository})
      : _pollsRepository = pollsRepository ?? PollsRepository(),
        super(const CreatePollInitial()) {
    on<CreatePollSubmitted>(_onCreatePollSubmitted);
    on<CreatePollReset>(_onCreatePollReset);
  }

  Future<void> _onCreatePollSubmitted(
    CreatePollSubmitted event,
    Emitter<CreatePollState> emit,
  ) async {
    emit(const PollCreating());

    try {
      // Валідація
      if (event.question.trim().isEmpty) {
        emit(const PollCreateError('Question is required'));
        return;
      }

      if (event.options.length < 2) {
        emit(const PollCreateError('At least 2 options are required'));
        return;
      }

      if (event.options.length > 10) {
        emit(const PollCreateError('Maximum 10 options allowed'));
        return;
      }

      // Створення опитування через репозиторій
      final pollId = await _pollsRepository.createPoll(
        question: event.question.trim(),
        description: event.description?.trim(),
        options: event.options.map((o) => o.trim()).toList(),
        category: event.category,
        durationDays: event.durationDays,
        allowMultipleVotes: event.allowMultipleVotes,
        showResultsBeforeEnd: event.showResultsBeforeEnd,
        isPrivate: event.isPrivate,
        password: event.password?.trim(),
      );

      // Завантажити створене опитування
      final poll = await _pollsRepository.getPollById(pollId);
      if (poll != null) {
        emit(PollCreateSuccess(poll));
      } else {
        emit(const PollCreateError('Failed to load created poll'));
      }
    } catch (e) {
      emit(PollCreateError('Failed to create poll: ${e.toString()}'));
    }
  }

  void _onCreatePollReset(
    CreatePollReset event,
    Emitter<CreatePollState> emit,
  ) {
    emit(const CreatePollInitial());
  }
}
