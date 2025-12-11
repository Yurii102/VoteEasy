# Лабораторна робота: Інтеграція Cloud Firestore

## Завдання
Додайте у застосунок пакет для роботи із Cloud Firebase. Реалізуйте репозиторії із методами для роботи із відповідними колекціями даних, а також, напишіть відповідні моделі даних.

## Виконана робота

### 1. Додано пакет Cloud Firestore

У файлі `pubspec.yaml` додано залежність:
```yaml
cloud_firestore: ^5.4.4
```

### 2. Створено моделі даних

#### 2.1 Poll (lib/core/models/poll.dart)
Модель опитування з повним набором полів:
- `id` - унікальний ідентифікатор
- `question` - текст питання
- `description` - опис опитування (опціонально)
- `authorId`, `authorName`, `authorEmail` - інформація про автора
- `category` - категорія (General, Technology, Entertainment, Sports, Politics, Science, Education, Other)
- `options` - список варіантів відповіді (2-10 опцій)
- `allowMultipleVotes` - дозволити множинний вибір
- `showResultsBeforeEnd` - показувати результати до завершення
- `isAnonymous` - анонімне опитування
- `createdAt`, `updatedAt` - мітки часу
- `endDate` - дата закінчення (може бути null для необмежених опитувань)
- `status` - статус (active, closed)
- `totalVotes` - загальна кількість голосів
- `votesCount` - Map з кількістю голосів для кожної опції

**Методи:**
- `fromFirestore()` - створення з Firestore DocumentSnapshot
- `toMap()` - конвертація у Map для збереження
- `fromMap()` - створення з Map (зворотня сумісність)
- `copyWith()` - копіювання з можливістю зміни полів
- `getOptionPercentage()` - обчислення відсотка голосів для опції
- `isExpired` getter - перевірка чи опитування закінчилось
- `timeAgo` getter - обчислення часу створення

#### 2.2 User (lib/core/models/user.dart)
Модель користувача:
- `userId` - унікальний ідентифікатор
- `displayName` - ім'я користувача
- `email` - електронна пошта
- `photoUrl` - URL фото профілю
- `createdAt`, `updatedAt` - мітки часу

**Методи:**
- `fromFirestore()` - створення з Firestore DocumentSnapshot
- `toMap()` - конвертація у Map
- `fromMap()` - створення з Map
- `copyWith()` - копіювання з можливістю зміни полів

#### 2.3 Vote (lib/core/models/vote.dart)
Модель голосу:
- `userId` - ID користувача який проголосував
- `userName` - ім'я користувача
- `optionIndexes` - індекси обраних опцій (для множинного вибору)
- `votedAt` - час голосування

**Методи:**
- `fromFirestore()` - створення з Firestore DocumentSnapshot
- `toMap()` - конвертація у Map
- `fromMap()` - створення з Map
- `copyWith()` - копіювання з можливістю зміни полів

### 3. Створено FirestoreService (lib/core/services/firestore_service.dart)

Singleton сервіс для прямої роботи з Firestore. Містить методи:

**Робота з опитуваннями:**
- `createPoll()` - створення нового опитування
- `getActivePolls()` - Stream активних опитувань
- `getPollsByCategory()` - Stream опитувань за категорією
- `getUserPolls()` - Stream опитувань користувача
- `getPollById()` - отримання одного опитування
- `updatePoll()` - оновлення опитування
- `closePoll()` - закриття опитування
- `deletePoll()` - видалення опитування
- `getPollStats()` - отримання статистики

**Робота з голосами:**
- `vote()` - голосування в опитуванні
- `hasUserVoted()` - перевірка чи користувач голосував
- `getUserVote()` - отримання голосу користувача

**Робота з користувачами:**
- `updateUserProfile()` - створення/оновлення профілю
- `getUserById()` - отримання користувача за ID
- `getUserStream()` - Stream даних користувача

### 4. Створено Repository шар

#### 4.1 PollsRepository (lib/core/repositories/polls_repository.dart)
Репозиторій для роботи з опитуваннями. Надає абстракцію між BLoC та Firestore.

**Методи:**
- `getActivePolls()` - отримати потік активних опитувань
- `getPollsByCategory()` - отримати опитування за категорією
- `getUserPolls()` - отримати опитування користувача
- `getPollById()` - отримати одне опитування
- `createPoll()` - створити нове опитування
- `updatePoll()` - оновити опитування
- `closePoll()` - закрити опитування
- `deletePoll()` - видалити опитування
- `vote()` - проголосувати
- `hasUserVoted()` - перевірити чи користувач голосував
- `getUserVote()` - отримати голос користувача
- `getPollStats()` - отримати статистику

#### 4.2 UserRepository (lib/core/repositories/user_repository.dart)
Репозиторій для роботи з користувачами.

**Методи:**
- `updateUserProfile()` - оновити профіль користувача
- `getUserById()` - отримати користувача за ID
- `getUserStream()` - отримати потік даних користувача

#### 4.3 VotesRepository (lib/core/repositories/votes_repository.dart)
Репозиторій для роботи з голосами.

**Методи:**
- `vote()` - проголосувати
- `hasUserVoted()` - перевірити чи користувач голосував
- `getUserVote()` - отримати голос користувача
- `getVotesForPoll()` - отримати всі голоси для опитування
- `getVotesCount()` - отримати кількість голосів для кожної опції

#### 4.4 AuthRepository (lib/core/repositories/auth_repository.dart)
Репозиторій для роботи з аутентифікацією (вже існував).

### 5. Інтегровано Repository з BLoC

Оновлено `PollsBloc` (lib/core/bloc/polls/polls_bloc.dart):
- Замінено прямий виклик `FirestoreService` на `PollsRepository`
- Додано Dependency Injection через конструктор
- Підписка на Stream з repository замість прямого виклику сервісу

### 6. Оновлено CreatePollScreen

Замінено `FirestoreService` на `PollsRepository` для створення опитувань.

### 7. Структура Firestore колекцій

```
?? polls (collection)
  ??? ?? {pollId} (document)
      ??? question: string
      ??? description: string?
      ??? authorId: string
      ??? authorName: string
      ??? authorEmail: string?
      ??? category: string
      ??? options: array<string>
      ??? allowMultipleVotes: boolean
      ??? showResultsBeforeEnd: boolean
      ??? isAnonymous: boolean
      ??? createdAt: timestamp
      ??? updatedAt: timestamp
      ??? endDate: timestamp?
      ??? status: string
      ??? totalVotes: number
      ??? votesCount: map<string, number>
      ??? ?? votes (subcollection)
          ??? ?? {userId} (document)
              ??? userId: string
              ??? userName: string
              ??? optionIndexes: array<number>
              ??? votedAt: timestamp

?? users (collection)
  ??? ?? {userId} (document)
      ??? userId: string
      ??? displayName: string?
      ??? email: string?
      ??? photoUrl: string?
      ??? createdAt: timestamp
      ??? updatedAt: timestamp
```

### 8. Security Rules (firestore.rules)

Налаштовано правила безпеки:
- **users**: користувачі можуть читати всі профілі, але редагувати тільки свій
- **polls**: всі можуть читати, створювати може будь-який авторизований користувач, редагувати/видаляти тільки автор
- **votes**: читати можуть всі, створювати тільки один раз, редагувати/видаляти заборонено
- Додано валідацію: питання >= 10 символів, опцій від 2 до 10

## Архітектура

```
???????????????????
?   Presentation  ?  (BLoC, Screens)
???????????????????
         ?
???????????????????
?   Repository    ?  (PollsRepository, UserRepository, VotesRepository)
???????????????????
         ?
???????????????????
?     Service     ?  (FirestoreService)
???????????????????
         ?
???????????????????
?    Firestore    ?  (Cloud Database)
???????????????????
```

**Переваги такої архітектури:**
1. **Separation of Concerns** - кожен шар має свою відповідальність
2. **Testability** - легко тестувати кожен шар окремо
3. **Flexibility** - легко замінити джерело даних без зміни BLoC
4. **Reusability** - репозиторії можна використовувати в різних BLoC

## Barrel files

Створено barrel files для зручного імпорту:
- `lib/core/models/models.dart` - експорт всіх моделей
- `lib/core/repositories/repositories.dart` - експорт всіх репозиторіїв

## Висновки

? Додано пакет `cloud_firestore: ^5.4.4`
? Створено 3 моделі даних: Poll, User, Vote
? Створено FirestoreService з повним набором методів
? Створено 4 репозиторії: PollsRepository, UserRepository, VotesRepository, AuthRepository
? Інтегровано Repository pattern з BLoC
? Налаштовано Security Rules
? Створено структуру колекцій Firestore
? Впроваджено Clean Architecture

Застосунок тепер працює з Cloud Firestore через правильну архітектуру Repository pattern.
