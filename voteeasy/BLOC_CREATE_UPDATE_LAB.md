# Лабораторна робота: Реалізація BLoC для створення та редагування записів

## Огляд

Реалізовано повноцінну BLoC архітектуру для управління процесами створення та редагування опитувань (polls) в застосунку VoteEasy відповідно до патерну, вибраного в лабораторній роботі №5.

## Реалізовані компоненти

### 1. CreatePollBloc - Створення опитувань

#### Події (Events)
**Файл**: `lib/core/bloc/create_poll/create_poll_event.dart`

- `CreatePollSubmitted` - Подія для створення нового опитування
  - Parameters:
    - `question` (String) - Питання опитування
    - `description` (String?) - Опціональний опис
    - `options` (List<String>) - Варіанти відповідей
    - `category` (String) - Категорія опитування
    - `durationDays` (int) - Тривалість в днях
    - `allowMultipleVotes` (bool) - Дозволити множинний вибір
    - `showResultsBeforeEnd` (bool) - Показувати результати до завершення
    - `isAnonymous` (bool) - Анонімне голосування

- `CreatePollReset` - Скидання стану BLoC до початкового

#### Стани (States)
**Файл**: `lib/core/bloc/create_poll/create_poll_state.dart`

- `CreatePollInitial` - Початковий стан
- `PollCreating` - Процес створення опитування
- `PollCreateSuccess` - Успішне створення опитування
  - Contains: `Poll poll` - створене опитування
- `PollCreateError` - Помилка створення
  - Contains: `String message` - повідомлення про помилку

#### Логіка (Bloc)
**Файл**: `lib/core/bloc/create_poll/create_poll_bloc.dart`

```dart
class CreatePollBloc extends Bloc<CreatePollEvent, CreatePollState> {
  final PollsRepository _pollsRepository;
  
  CreatePollBloc({PollsRepository? pollsRepository})
      : _pollsRepository = pollsRepository ?? PollsRepository(),
        super(const CreatePollInitial());
```

**Валідація**:
- Перевірка обов'язковості питання
- Мінімум 2 опції
- Максимум 10 опцій

**Обробка помилок**:
- Try-catch блок з детальним повідомленням про помилку

---

### 2. UpdatePollBloc - Редагування опитувань

#### Події (Events)
**Файл**: `lib/core/bloc/update_poll/update_poll_event.dart`

- `UpdatePollSubmitted` - Подія для оновлення існуючого опитування
  - Parameters:
    - `pollId` (String) - ID опитування для оновлення
    - `question` (String) - Оновлене питання
    - `description` (String?) - Оновлений опис
    - `options` (List<String>) - Оновлені варіанти
    - `category` (String) - Оновлена категорія
    - `allowMultipleVotes` (bool) - Налаштування множинного вибору
    - `showResultsBeforeEnd` (bool) - Налаштування відображення результатів
    - `isAnonymous` (bool) - Налаштування анонімності

- `UpdatePollReset` - Скидання стану BLoC до початкового

#### Стани (States)
**Файл**: `lib/core/bloc/update_poll/update_poll_state.dart`

- `UpdatePollInitial` - Початковий стан
- `PollUpdating` - Процес оновлення опитування
- `PollUpdateSuccess` - Успішне оновлення
  - Contains: `Poll poll` - оновлене опитування
- `PollUpdateError` - Помилка оновлення
  - Contains: `String message` - повідомлення про помилку

#### Логіка (Bloc)
**Файл**: `lib/core/bloc/update_poll/update_poll_bloc.dart`

```dart
class UpdatePollBloc extends Bloc<UpdatePollEvent, UpdatePollState> {
  final PollsRepository _pollsRepository;
  
  UpdatePollBloc({PollsRepository? pollsRepository})
      : _pollsRepository = pollsRepository ?? PollsRepository(),
        super(const UpdatePollInitial());
```

**Особливості**:
- Валідація аналогічна до CreatePollBloc
- Після оновлення завантажує свіже опитування з Firestore
- Обробка помилок з детальними повідомленнями

---

### 3. Інтеграція в UI

#### CreatePollScreen
**Файл**: `lib/screens/create_poll_screen.dart`

**Зміни**:
- Перетворено з StatefulWidget на StatelessWidget з BlocProvider
- Додано `BlocListener` для реакції на зміни стану
- Додано `BlocBuilder` для відображення індикатора завантаження
- Видалено прямі виклики Repository, тепер через BLoC

**Приклад використання**:
```dart
context.read<CreatePollBloc>().add(
  CreatePollSubmitted(
    question: _questionController.text.trim(),
    options: options,
    // ... інші параметри
  ),
);
```

**Обробка станів**:
```dart
BlocListener<CreatePollBloc, CreatePollState>(
  listener: (context, state) {
    if (state is PollCreateSuccess) {
      // Показати повідомлення про успіх
      // Скинути форму
      // Повернутися назад
    } else if (state is PollCreateError) {
      // Показати повідомлення про помилку
    }
  },
  child: // UI
);
```

---

#### EditPollScreen (новий екран)
**Файл**: `lib/screens/edit_poll_screen.dart`

**Функціонал**:
- Завантаження існуючих даних опитування в форму
- Попередження користувача про вплив на існуючі голоси
- Повна валідація перед відправкою
- Індикатор завантаження під час оновлення

**Архітектура**:
```dart
class EditPollScreen extends StatelessWidget {
  final Poll poll;
  
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UpdatePollBloc(),
      child: _EditPollScreenContent(poll: poll),
    );
  }
}
```

**UI Features**:
- Всі поля форми попередньо заповнені
- Можливість додавання/видалення опцій (2-10)
- Dropdown для категорії
- Switch toggles для налаштувань
- Кнопка "Save" з індикатором завантаження

---

#### ProfileScreen - Додано функції редагування
**Файл**: `lib/screens/profile_screen.dart`

**Зміни**:
- Переписано `_buildPollItem` для прийому об'єкта `Poll`
- Додано кнопки "Edit" та "Delete" для кожного опитування користувача
- Додано метод `_showDeleteConfirmation` з діалогом підтвердження
- Інтеграція з `EditPollScreen` через Navigation

**Кнопка редагування**:
```dart
OutlinedButton.icon(
  onPressed: () async {
    final result = await Navigator.push<Poll>(
      context,
      MaterialPageRoute(
        builder: (context) => EditPollScreen(poll: poll),
      ),
    );
    
    // Перезавантажити список якщо оновлено
    if (result != null && mounted) {
      _loadUserPolls();
    }
  },
  icon: Icon(Icons.edit),
  label: Text('Edit'),
)
```

**Кнопка видалення**:
```dart
OutlinedButton.icon(
  onPressed: () => _showDeleteConfirmation(poll),
  icon: Icon(Icons.delete_outline),
  label: Text('Delete'),
)
```

---

## Архітектурні рішення

### 1. Dependency Injection
Кожен BLoC приймає опціональний `Repository` через конструктор:
```dart
CreatePollBloc({PollsRepository? pollsRepository})
    : _pollsRepository = pollsRepository ?? PollsRepository()
```

Це дозволяє:
- Легке тестування з mock repositories
- Гнучка конфігурація

### 2. Валідація на рівні BLoC
Вся бізнес-логіка та валідація виконується в BLoC:
- UI залишається "dumb" (без складної логіки)
- Легке тестування валідації
- Консистентність правил по всьому застосунку

### 3. Separation of Concerns
- **UI Layer** (Screens): Тільки відображення та користувацький ввід
- **BLoC Layer**: Бізнес-логіка, валідація, управління станом
- **Repository Layer**: Абстракція доступу до даних
- **Service Layer** (Firestore): Прямі операції з базою даних

### 4. State Management Flow
```
User Action (UI)
    ?
Event dispatched to BLoC
    ?
BLoC validates and processes
    ?
BLoC calls Repository
    ?
Repository calls FirestoreService
    ?
Firestore operation
    ?
New State emitted
    ?
UI rebuilds with BlocBuilder/BlocListener
```

---

## Analytics Integration

Кожна дія користувача логується:

**Створення опитування**:
```dart
_analyticsService.logEvent(
  name: 'poll_creation_attempted',
  parameters: {
    'question_length': _questionController.text.length.toString(),
    'options_count': options.length.toString(),
    'category': _selectedCategory,
  },
);
```

**Успішне створення**:
```dart
_analyticsService.logEvent(
  name: 'poll_created',
  parameters: {
    'poll_id': state.poll.id,
    'question': state.poll.question,
    'options_count': state.poll.options.length.toString(),
  },
);
```

---

## Обробка помилок

### 1. Валідаційні помилки
Перевіряються в BLoC і повертаються як `CreateError`/`UpdateError`:
```dart
if (event.question.trim().isEmpty) {
  emit(const PollCreateError('Question is required'));
  return;
}
```

### 2. Помилки Repository/Firestore
Ловляться в try-catch і передаються в UI:
```dart
try {
  final poll = await _pollsRepository.createPoll(...);
  emit(PollCreateSuccess(poll));
} catch (e) {
  emit(PollCreateError('Failed to create poll: ${e.toString()}'));
}
```

### 3. UI Response
BlocListener реагує на помилки:
```dart
if (state is PollCreateError) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(state.message),
      backgroundColor: AppColors.error,
    ),
  );
}
```

---

## Тестування

### Можливості для Unit Tests

**CreatePollBloc**:
```dart
test('emits PollCreating then PollCreateSuccess when successful', () async {
  // Arrange
  final mockRepository = MockPollsRepository();
  when(() => mockRepository.createPoll(...)).thenAnswer((_) async => mockPoll);
  
  // Act & Assert
  blocTest<CreatePollBloc, CreatePollState>(
    'emits [PollCreating, PollCreateSuccess]',
    build: () => CreatePollBloc(pollsRepository: mockRepository),
    act: (bloc) => bloc.add(CreatePollSubmitted(...)),
    expect: () => [
      const PollCreating(),
      PollCreateSuccess(mockPoll),
    ],
  );
});
```

---

## Відповідність вимогам лабораторної

? **Створення нових записів керується BLoC**
- `CreatePollBloc` з подіями `CreatePollEvent`
- Стани: `CreatePollInitial`, `PollCreating`, `PollCreateSuccess`, `PollCreateError`

? **Редагування існуючих записів керується BLoC**
- `UpdatePollBloc` з подіями `UpdatePollEvent`
- Стани: `UpdatePollInitial`, `PollUpdating`, `PollUpdateSuccess`, `PollUpdateError`

? **Інтеграція з UI**
- `CreatePollScreen` використовує `CreatePollBloc`
- `EditPollScreen` використовує `UpdatePollBloc`
- `ProfileScreen` інтегровано з функціями редагування/видалення

? **BLoC Pattern**
- Використано flutter_bloc пакет
- Proper separation of Events, States, and Bloc logic
- Dependency injection для Repository

---

## Переваги реалізації

1. **Testability**: Легке тестування завдяки чіткому розділенню відповідальностей
2. **Maintainability**: Логіка відокремлена від UI
3. **Scalability**: Легко додавати нові функції
4. **Reusability**: BLoC можна переісполь використовувати в різних частинах застосунку
5. **Error Handling**: Централізована обробка помилок
6. **Loading States**: Явне управління станом завантаження

---

## Файлова структура

```
lib/
??? core/
?   ??? bloc/
?   ?   ??? create_poll/
?   ?   ?   ??? create_poll_bloc.dart
?   ?   ?   ??? create_poll_event.dart
?   ?   ?   ??? create_poll_state.dart
?   ?   ??? update_poll/
?   ?       ??? update_poll_bloc.dart
?   ?       ??? update_poll_event.dart
?   ?       ??? update_poll_state.dart
?   ??? repositories/
?   ?   ??? polls_repository.dart
?   ??? services/
?   ?   ??? firestore_service.dart
?   ??? models/
?       ??? poll.dart
??? screens/
    ??? create_poll_screen.dart (оновлено)
    ??? edit_poll_screen.dart (новий)
    ??? profile_screen.dart (оновлено)
```

---

## Висновок

Реалізовано повноцінну BLoC архітектуру для створення та редагування опитувань згідно з вимогами лабораторної роботи. Архітектура забезпечує:
- Чітке розділення відповідальностей
- Легке тестування
- Масштабованість
- Proper state management
- Error handling
- User feedback

Всі компоненти інтегровані в існуючий застосунок VoteEasy з підтримкою Firestore та Firebase Analytics.
