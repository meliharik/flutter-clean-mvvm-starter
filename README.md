# 🚀 Flutter Clean MVVM Starter

A production-ready Flutter boilerplate implementing **Clean Architecture** with **MVVM** pattern. This starter kit provides a robust, scalable, and testable foundation for building complex Flutter applications.

## 📋 Table of Contents

- [Architecture](#architecture)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Code Generation](#code-generation)
- [Key Concepts](#key-concepts)
- [Testing](#testing)
- [Best Practices](#best-practices)

## 🏗️ Architecture

This project follows **Clean Architecture** principles with three distinct layers:

```
┌─────────────────────────────────────────┐
│         Presentation Layer              │
│   (UI, State Management, Providers)     │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│          Domain Layer                   │
│  (Entities, Repository Interfaces,      │
│   Use Cases, Business Logic)            │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│           Data Layer                    │
│  (Repository Implementations,           │
│   Data Sources, Models, API Clients)    │
└─────────────────────────────────────────┘
```

### Why Clean Architecture?

1. **Separation of Concerns**: Each layer has a specific responsibility
2. **Testability**: Business logic can be tested without UI or external dependencies
3. **Flexibility**: Easy to swap implementations (REST → GraphQL, SQLite → Hive)
4. **Scalability**: New features follow established patterns
5. **Maintainability**: Changes in one layer don't affect others

## 🛠️ Tech Stack

### State Management
- **Riverpod** (with code generation) - Chosen for:
  - Compile-time safety
  - Better DevTools integration
  - Simpler testing than BLoC
  - Less boilerplate

### Networking
- **Dio** - HTTP client with interceptors
- Custom `NetworkClient` wrapper for:
  - Centralized error handling
  - Automatic token refresh
  - Request/response logging

### Dependency Injection
- **get_it** + **injectable** - Service locator pattern with code generation

### Data Classes
- **freezed** - Immutable data classes with:
  - Union types (sealed classes)
  - Pattern matching
  - copyWith functionality
- **json_serializable** - JSON parsing

### Routing
- **GoRouter** - Declarative routing with:
  - Type-safe navigation
  - Authentication guards
  - Deep linking support

### Error Handling
- **fpdart** - Functional programming with `Either<Failure, Data>`
  - Forces explicit error handling
  - No try-catch hell
  - Type-safe error propagation

### Storage
- **flutter_secure_storage** - For tokens (encrypted)
- **shared_preferences** - For user preferences

## 📁 Project Structure

```
lib/
├── core/                           # Core infrastructure
│   ├── constants/                  # API endpoints, app constants
│   ├── di/                         # Dependency injection setup
│   ├── error/                      # Failures and exceptions
│   ├── network/                    # HTTP client and interceptors
│   ├── router/                     # Navigation configuration
│   ├── storage/                    # Secure & local storage
│   ├── types/                      # Type definitions
│   └── utils/                      # Logger, extensions
│
├── features/                       # Feature modules (feature-first)
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/        # Remote & local data sources
│   │   │   ├── models/             # JSON serializable models
│   │   │   └── repositories/       # Repository implementations
│   │   ├── domain/
│   │   │   ├── entities/           # Business entities
│   │   │   ├── repositories/       # Repository interfaces
│   │   │   └── usecases/           # Business logic
│   │   └── presentation/
│   │       ├── providers/          # Riverpod state management
│   │       ├── screens/            # UI screens
│   │       └── widgets/            # Reusable widgets
│   └── home/                       # Example feature
│
├── app.dart                        # Root widget
└── main.dart                       # Entry point
```

## 🚦 Getting Started

### Prerequisites

- Flutter SDK (>=3.2.0)
- Dart SDK (>=3.0.0)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/flutter-clean-mvvm-starter.git
   cd flutter-clean-mvvm-starter
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run code generation**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

## ⚙️ Code Generation

This project uses code generation for:
- **Freezed**: Data classes and sealed classes
- **JSON Serializable**: JSON parsing
- **Injectable**: Dependency injection
- **Riverpod**: Provider generation

### Commands

```bash
# One-time generation
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode (regenerates on file changes)
flutter pub run build_runner watch --delete-conflicting-outputs

# Clean generated files
flutter pub run build_runner clean
```

## 💡 Key Concepts

### 1. Error Handling with Either

```dart
// Repository returns Either<Failure, Data>
FutureEither<User> login(String email, String password);

// Presentation layer handles both cases
final result = await loginUseCase(email: email, password: password);

result.fold(
  (failure) => showError(failure.userMessage),  // Left = Error
  (user) => navigateToHome(user),               // Right = Success
);
```

**Why?** Compile-time safety - can't forget to handle errors!

### 2. Sealed Classes for States

```dart
@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;
  const factory AuthState.loading() = _Loading;
  const factory AuthState.authenticated(User user) = _Authenticated;
  const factory AuthState.unauthenticated() = _Unauthenticated;
  const factory AuthState.error(Failure failure) = _Error;
}
```

**Why?** Exhaustive pattern matching - compiler ensures all states are handled!

### 3. Token Refresh Interceptor

```dart
// AuthInterceptor automatically:
// 1. Appends Bearer token to requests
// 2. Detects 401 errors
// 3. Refreshes token
// 4. Retries original request
// 5. Queues concurrent requests during refresh
```

**Why?** Seamless token refresh without user intervention!

### 4. Feature-First Structure

```dart
features/
  ├── auth/          # All auth-related code in one place
  ├── profile/       # All profile-related code
  └── dashboard/     # All dashboard-related code
```

**Why?** Easier to navigate and scale than layer-first (data/, domain/, presentation/)

## 🧪 Testing

### Unit Tests

```bash
flutter test
```

### Test Structure

```
test/
├── core/
│   ├── network/
│   └── error/
└── features/
    └── auth/
        ├── data/
        ├── domain/
        └── presentation/
```

### Example Test

```dart
// Test use case
test('should return User when login is successful', () async {
  // Arrange
  when(() => mockRepository.login(email: any(), password: any()))
      .thenAnswer((_) async => Right(tUser));

  // Act
  final result = await loginUseCase(email: 'test@test.com', password: 'password');

  // Assert
  expect(result, Right(tUser));
  verify(() => mockRepository.login(email: 'test@test.com', password: 'password'));
});
```

## 📖 Best Practices

### 1. Naming Conventions

- **Entities**: `User`, `Product` (domain layer)
- **Models**: `UserModel`, `ProductModel` (data layer)
- **Use Cases**: `LoginUseCase`, `GetUserUseCase`
- **Providers**: `authNotifierProvider`, `userProvider`
- **States**: `AuthState`, `ProductState`

### 2. File Organization

- One class per file
- File name matches class name (snake_case)
- Group related files in folders

### 3. Dependency Flow

```
Presentation → Domain ← Data
```

- Presentation depends on Domain (use cases, entities)
- Data depends on Domain (implements repositories)
- Domain depends on NOTHING (pure business logic)

### 4. Error Handling

- **Exceptions**: Thrown in Data layer (network errors, parsing errors)
- **Failures**: Returned in Domain layer (business errors)
- **UI Messages**: Handled in Presentation layer

### 5. State Management

- Use `@riverpod` for providers with code generation
- Keep state classes immutable (freezed)
- Listen to state changes with `ref.listen()`
- Read state for one-time access with `ref.read()`

## 🔐 Authentication Flow

1. App starts → Check token in SecureStorage
2. Token exists → Fetch user from API
3. Success → Navigate to Home
4. Failure (401) → Attempt token refresh
5. Refresh success → Retry original request
6. Refresh failure → Navigate to Login

## 🌐 API Configuration

Update API endpoints in `lib/core/constants/api_constants.dart`:

```dart
static const String baseUrlDev = 'https://api-dev.yourapp.com';
static const String baseUrlProd = 'https://api.yourapp.com';
```

## 📝 Adding a New Feature

1. Create feature folder: `lib/features/new_feature/`
2. Create layers: `data/`, `domain/`, `presentation/`
3. Define entity in `domain/entities/`
4. Create repository interface in `domain/repositories/`
5. Implement repository in `data/repositories/`
6. Create use cases in `domain/usecases/`
7. Create state with freezed in `presentation/providers/`
8. Create provider in `presentation/providers/`
9. Create UI in `presentation/screens/`

## 🤝 Contributing

This is a boilerplate project. Feel free to:
- Fork and customize for your needs
- Submit issues for improvements
- Create PRs for bug fixes

## 📄 License

MIT License - feel free to use this for commercial projects!

## 🙏 Acknowledgments

Built with best practices from:
- Clean Architecture (Robert C. Martin)
- Flutter/Dart community
- Riverpod documentation
- Real-world production apps

---

**Happy Coding!** 🎉

For questions or suggestions, please open an issue.
