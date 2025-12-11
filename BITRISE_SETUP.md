# Bitrise Setup Instructions для VoteEasy

## Крок 1: Додати Secrets в Bitrise

Перейдіть: **Bitrise Dashboard ? Workflow Editor ? Secrets**

### 1. FIREBASE_APP_ID_ANDROID
```
Key: FIREBASE_APP_ID_ANDROID
Value: 1:768252539367:android:3d680b29de0c2cbe4a0d42
Expose for Pull Requests: NO (unchecked)
```

### 2. FIREBASE_TOKEN
Згенеруйте токен локально:
```bash
npm install -g firebase-tools
firebase login:ci
```

Скопіюйте токен та додайте:
```
Key: FIREBASE_TOKEN
Value: <your-token-from-firebase-login-ci>
Expose for Pull Requests: NO (unchecked)
```

### 3. GOOGLE_SERVICES_JSON
Відкрийте файл `voteeasy/android/app/google-services.json` локально та скопіюйте **весь вміст**:

```
Key: GOOGLE_SERVICES_JSON
Value: <paste entire content of google-services.json>
Expose for Pull Requests: NO (unchecked)
```

### 4. FIREBASE_OPTIONS_DART
Відкрийте файл `voteeasy/lib/firebase_options.dart` локально та скопіюйте **весь вміст**:

```
Key: FIREBASE_OPTIONS_DART
Value: <paste entire content of firebase_options.dart>
Expose for Pull Requests: NO (unchecked)
```

## Крок 2: Створити групу тестерів в Firebase

1. Перейдіть в Firebase Console: https://console.firebase.google.com/project/voteeasy-app1/appdistribution
2. Натисніть **Testers & Groups**
3. Створіть нову групу: **testers**
4. Додайте email адреси тестерів

## Крок 3: Запустити білд

1. Зробіть push в `main` branch
2. Або в Bitrise Dashboard натисніть **Start/Schedule a Build**
3. Виберіть branch `main`
4. Виберіть workflow `android_firebase`
5. Натисніть **Start Build**

## Troubleshooting

### Помилка: "GOOGLE_SERVICES_JSON secret is not set"
- Переконайтеся що ви додали secret з правильною назвою (великі літери)
- Перевірте що значення містить валідний JSON

### Помилка: "Firebase upload failed"
- Перевірте що FIREBASE_TOKEN дійсний (можливо потрібно згенерувати новий)
- Перевірте що група "testers" існує в Firebase Console
- Перевірте що FIREBASE_APP_ID_ANDROID правильний

### Firebase CLI не працює
Локально виконайте:
```bash
firebase login
firebase projects:list
```

## Готово!

Після успішного білду тестери отримають email з посиланням на завантаження APK через Firebase App Distribution.
