# 🏛️ Architecture Documentation

This document explains the architectural decisions and patterns used in this boilerplate.

## Table of Contents

1. [Clean Architecture Layers](#clean-architecture-layers)
2. [MVVM Pattern](#mvvm-pattern)
3. [Dependency Flow](#dependency-flow)
4. [Error Handling Strategy](#error-handling-strategy)
5. [State Management](#state-management)
6. [Navigation & Routing](#navigation--routing)
7. [Dependency Injection](#dependency-injection)
8. [Network Layer](#network-layer)
9. [Testing Strategy](#testing-strategy)
10. [Design Patterns Used](#design-patterns-used)

---

## 1. Clean Architecture Layers

### Domain Layer (Business Logic)
**Location:** `lib/features/*/domain/`

**Responsibilities:**
- Define business entities
- Define repository interfaces
- Contain use cases (business logic)

**Dependencies:** NONE (pure Dart, no Flutter imports)

**Example:**
```dart
// Entity
class User {
  final String id;
  final String email;
  final String name;
}

// Repository Interface
abstract class AuthRepository {
  FutureEither<User> login(String email, String password);
}

// Use Case
class LoginUseCase {
  final AuthRepository repository;

  FutureEither<User> call(String email, String password) {
    return repository.login(email, password);
  }
}
```

**Why?**
- Business logic is independent of UI and data sources
- Can be reused in different platforms (mobile, web, CLI)
- Easy to test without mocking external dependencies

### Data Layer (Implementation Details)
**Location:** `lib/features/*/data/`

**Responsibilities:**
- Implement repository interfaces
- Handle API calls (remote data source)
- Handle local storage (local data source)
- Map between models and entities

**Dependencies:** Domain layer

**Example:**
```dart
// Model (API structure)
@freezed
class UserModel with _$UserModel {
  factory UserModel.fromJson(Map<String, dynamic> json);

  User toEntity() => User(...);
}

// Remote Data Source
class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password) {
    final response = await dio.post('/login', data: {...});
    return UserModel.fromJson(response.data);
  }
}

// Repository Implementation
class AuthRepositoryImpl implements AuthRepository {
  @override
  FutureEither<User> login(String email, String password) async {
    try {
      final userModel = await remoteDataSource.login(email, password);
      return Right(userModel.toEntity());
    } on AppException catch (e) {
      return Left(_mapException(e));
    }
  }
}
```

**Why?**
- Isolates implementation details (API structure, storage format)
- Easy to swap data sources (REST → GraphQL)
- Converts exceptions to domain failures

### Presentation Layer (UI)
**Location:** `lib/features/*/presentation/`

**Responsibilities:**
- Display UI
- Manage UI state
- Handle user interactions
- Call use cases

**Dependencies:** Domain layer only (NOT data layer)

**Example:**
```dart
// State
@freezed
class AuthState with _$AuthState {
  const factory AuthState.authenticated(User user) = _Authenticated;
  const factory AuthState.unauthenticated() = _Unauthenticated;
}

// Provider (ViewModel)
@riverpod
class AuthNotifier extends _$AuthNotifier {
  Future<void> login(String email, String password) async {
    state = AuthState.loading();

    final result = await loginUseCase(email, password);

    result.fold(
      (failure) => state = AuthState.error(failure),
      (user) => state = AuthState.authenticated(user),
    );
  }
}

// View
class LoginScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(authNotifierProvider);

    return state.when(
      authenticated: (user) => HomeScreen(),
      unauthenticated: () => LoginForm(),
    );
  }
}
```

**Why?**
- UI is completely decoupled from data sources
- State changes automatically trigger UI rebuilds
- Easy to test UI logic

---

## 2. MVVM Pattern

### Model
- **Domain Entities** and **Data Models**
- Represents data structure

### View
- **Flutter Widgets** (Screens, Widgets)
- Displays UI based on state
- Sends user actions to ViewModel

### ViewModel
- **Riverpod Providers** (Notifiers)
- Manages UI state
- Executes business logic (via use cases)
- Notifies View of state changes

**Flow:**
```
User Action → View → ViewModel → UseCase → Repository → DataSource
                ↑                                            ↓
                └────────────────────────────────────────────┘
                           (State Update)
```

---

## 3. Dependency Flow

**The Dependency Rule:** Source code dependencies must point inward only.

```
Presentation ──depends on──> Domain <──depends on── Data
     ↑                                                 ↓
     └─────────────────────────────────────────────────┘
                    (via interfaces)
```

**Key Points:**
- Presentation imports Domain (entities, repositories, use cases)
- Data imports Domain (implements repository interfaces)
- Domain imports NOTHING
- Data never imported by Presentation

**Why?**
- Domain layer is the most stable (changes least often)
- UI and API can change without affecting business logic
- Can swap implementations easily

---

## 4. Error Handling Strategy

### Exception → Failure Conversion

**Data Layer throws Exceptions:**
```dart
// Data Source
throw ServerException(message: 'Network error');
throw UnauthorizedException();
```

**Repository catches and converts to Failures:**
```dart
// Repository
try {
  final user = await dataSource.login(email, password);
  return Right(user.toEntity());
} on ServerException catch (e) {
  return Left(Failure.server(message: e.message));
} on UnauthorizedException {
  return Left(Failure.unauthorized());
}
```

**Presentation handles Failures:**
```dart
// ViewModel
result.fold(
  (failure) => state = AuthState.error(failure),
  (user) => state = AuthState.authenticated(user),
);

// View
state.when(
  error: (failure) => showDialog(context, failure.userMessage),
  ...
);
```

### Why Either<Failure, Data>?

**Instead of throwing exceptions:**
```dart
❌ try {
  final user = await repository.login(email, password);
} catch (e) {
  // Easy to forget error handling
}
```

**Use Either for explicit error handling:**
```dart
✅ final result = await repository.login(email, password);
result.fold(
  (failure) => handleError(failure),  // Compiler forces you to handle
  (user) => handleSuccess(user),
);
```

**Benefits:**
- Compile-time safety (can't forget to handle errors)
- Clear method signatures (caller knows operation can fail)
- No try-catch hell
- Functional programming style

---

## 5. State Management

### Why Riverpod over BLoC?

| Feature | Riverpod | BLoC |
|---------|----------|------|
| Boilerplate | Low | High |
| Learning Curve | Medium | Steep |
| Compile-time Safety | ✅ Yes (with codegen) | ⚠️ Partial |
| DevTools | ✅ Excellent | ✅ Excellent |
| Testing | ✅ Easy | ⚠️ Moderate |
| Event-based | ❌ No | ✅ Yes |

**Decision:** Riverpod chosen for:
- Less boilerplate (no events, no mappers)
- Better type safety with code generation
- Simpler mental model for most use cases
- Easier to refactor

**When to use BLoC instead:**
- Need explicit event tracking
- Team already experienced with BLoC
- Complex event transformation needed

### State Pattern

**Using Freezed sealed classes:**
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

**Benefits:**
- Exhaustive pattern matching (compiler error if missing case)
- Type-safe state transitions
- Immutability (can't accidentally modify state)
- Clear state representation

---

## 6. Navigation & Routing

### GoRouter Configuration

**Authentication-aware routing:**
```dart
redirect: (context, state) {
  return authState.when(
    initial: () => RouteNames.splash,
    loading: () => RouteNames.splash,
    unauthenticated: () => RouteNames.login,
    authenticated: (_) => null,  // Allow navigation
    error: (_) => RouteNames.login,
  );
}
```

**Why GoRouter?**
- Declarative routing (all routes in one place)
- Type-safe navigation
- Deep linking support
- Web URL support
- Nested navigation
- Redirection logic (auth guards)

**Alternative:** AutoRoute (more type-safe, but more boilerplate)

---

## 7. Dependency Injection

### GetIt + Injectable

**Registration (automatic):**
```dart
@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);
}
```

**Generated code:**
```dart
// injection.config.dart
getIt.registerLazySingleton<AuthRepository>(
  () => AuthRepositoryImpl(getIt<AuthRemoteDataSource>()),
);
```

**Usage:**
```dart
final repository = getIt<AuthRepository>();
```

**Why GetIt?**
- Service locator pattern (access anywhere)
- Lazy initialization
- Simple setup
- Works well with code generation

**Alternative:** Pure Riverpod DI (more pure, but verbose)

---

## 8. Network Layer

### Dio + Interceptors

**Architecture:**
```
NetworkClient (wrapper)
    ├── AuthInterceptor (token injection + refresh)
    ├── LoggingInterceptor (request/response logs)
    └── Dio (HTTP client)
```

**Token Refresh Flow:**
```
1. Request fails with 401
2. AuthInterceptor detects
3. Lock queue (prevent concurrent refreshes)
4. Call refresh endpoint
5. Save new tokens
6. Retry original request
7. Unlock queue
8. Retry queued requests
```

**Why wrapper?**
- Centralized error handling
- Easy to mock in tests
- Can swap HTTP library if needed
- Converts DioException to AppException

---

## 9. Testing Strategy

### Unit Tests
- Test use cases in isolation
- Mock repositories
- Test business logic

```dart
test('should return User when login succeeds', () async {
  // Arrange
  when(() => mockRepo.login(any(), any()))
      .thenAnswer((_) async => Right(tUser));

  // Act
  final result = await useCase(email: email, password: password);

  // Assert
  expect(result, Right(tUser));
});
```

### Widget Tests
- Test UI logic
- Test state transitions
- Mock providers

```dart
testWidgets('should show error when login fails', (tester) async {
  final container = ProviderContainer(
    overrides: [
      authNotifierProvider.overrideWith(() => MockAuthNotifier()),
    ],
  );

  await tester.pumpWidget(ProviderScope(
    parent: container,
    child: LoginScreen(),
  ));

  // Test assertions...
});
```

### Integration Tests
- Test full flows
- Test with real dependencies
- Test API integration

---

## 10. Design Patterns Used

### 1. Repository Pattern
- Abstracts data sources
- Single source of truth for data access

### 2. Dependency Inversion
- High-level modules don't depend on low-level
- Both depend on abstractions

### 3. Factory Pattern
- `UserModel.fromJson()`
- `User.toEntity()`

### 4. Observer Pattern
- Riverpod providers notify listeners

### 5. Strategy Pattern
- Different data sources (Remote, Local)
- Swappable implementations

### 6. Singleton Pattern
- Service locator (GetIt)
- Single instances of repositories

### 7. Adapter Pattern
- Models adapt API structure to domain entities

### 8. Chain of Responsibility
- Dio interceptors

---

## Interview Defense Points

**Q: Why Clean Architecture?**
A: Separation of concerns, testability, flexibility to swap implementations, and scalability.

**Q: Why not just put everything in a single layer?**
A: When API changes, you'd have to modify business logic and UI. With layers, changes are isolated.

**Q: Why use Either instead of exceptions?**
A: Compile-time safety, explicit error handling, no try-catch hell, functional approach.

**Q: Why Riverpod over Provider?**
A: Better compile-time safety, code generation, more features, better DevTools.

**Q: Why GetIt when Riverpod has DI?**
A: GetIt is more familiar to teams, works outside widgets, simpler for non-providers.

**Q: Isn't this over-engineered for a simple app?**
A: For simple apps, yes. But this scales. Adding features follows established patterns. No refactoring needed as app grows.

**Q: How do you test this?**
A: Each layer independently. Mock repositories for use cases, mock providers for UI, mock data sources for repositories.

---

## Key Takeaways

1. **Separation of Concerns**: Each layer has one job
2. **Dependency Rule**: Dependencies point inward
3. **Testability**: Every component can be tested in isolation
4. **Flexibility**: Easy to swap implementations
5. **Type Safety**: Compile-time errors over runtime crashes
6. **Scalability**: Patterns scale from small to large apps

---

This architecture is production-ready and has been battle-tested in real-world applications. It provides a solid foundation for building maintainable, testable, and scalable Flutter apps.
