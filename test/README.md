# 🧪 Testing Guide

Comprehensive testing guide for Flutter Clean MVVM Starter.

## 📋 Table of Contents

- [Test Types](#test-types)
- [Running Tests](#running-tests)
- [Test Structure](#test-structure)
- [Testing Best Practices](#testing-best-practices)
- [Examples](#examples)

---

## 🎯 Test Types

### 1. Unit Tests

**Purpose:** Test individual units of code in isolation

**What to test:**
- Use cases (business logic)
- Repositories (data layer logic)
- Utilities and helpers
- Data transformations

**Location:** `test/features/*/domain/` and `test/features/*/data/`

**Example:**
```dart
test('should return User when login is successful', () async {
  // Arrange
  when(() => mockRepository.login(any(), any()))
      .thenAnswer((_) async => Right(tUser));

  // Act
  final result = await useCase(email: tEmail, password: tPassword);

  // Assert
  expect(result, Right(tUser));
});
```

### 2. Widget Tests

**Purpose:** Test UI components and user interactions

**What to test:**
- Widget rendering
- User interactions (tap, input)
- State-driven UI changes
- Form validation
- Navigation

**Location:** `test/features/*/presentation/`

**Example:**
```dart
testWidgets('should show error when email is empty', (tester) async {
  // Arrange
  await tester.pumpWidget(createTestWidget());

  // Act
  final loginButton = find.byType(ElevatedButton);
  await tester.tap(loginButton);
  await tester.pump();

  // Assert
  expect(find.text('Please enter your email'), findsOneWidget);
});
```

### 3. Integration Tests

**Purpose:** Test complete user flows with real dependencies

**What to test:**
- Complete user journeys
- Navigation flows
- State persistence
- API integration (with test backend)

**Location:** `integration_test/`

**Example:**
```dart
testWidgets('Complete login flow', (tester) async {
  // Launch app
  await tester.pumpWidget(const App());

  // Enter credentials
  await tester.enterText(find.byType(TextField).first, 'test@test.com');

  // Tap login
  await tester.tap(find.text('Login'));

  // Verify navigation to home
  expect(find.text('Home'), findsOneWidget);
});
```

---

## 🚀 Running Tests

### Run All Tests

```bash
# Run all unit and widget tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/features/auth/domain/usecases/login_usecase_test.dart
```

### Run Integration Tests

```bash
# Run integration tests
flutter test integration_test/app_test.dart

# Run on specific device
flutter test integration_test/app_test.dart -d chrome
```

### Generate Coverage Report

```bash
# Generate coverage
flutter test --coverage

# Generate HTML report (requires lcov)
genhtml coverage/lcov.info -o coverage/html

# Open report
open coverage/html/index.html
```

---

## 📁 Test Structure

```
test/
├── features/
│   └── auth/
│       ├── data/
│       │   └── repositories/
│       │       └── auth_repository_impl_test.dart
│       ├── domain/
│       │   └── usecases/
│       │       ├── login_usecase_test.dart
│       │       ├── logout_usecase_test.dart
│       │       └── get_current_user_usecase_test.dart
│       └── presentation/
│           └── screens/
│               └── login_screen_test.dart
│
├── helpers/
│   └── test_helpers.dart                 # Reusable test utilities
│
└── README.md

integration_test/
└── app_test.dart                         # Full app integration tests
```

---

## ✅ Testing Best Practices

### 1. Follow AAA Pattern

```dart
test('description', () {
  // ARRANGE - Setup test data and mocks
  when(() => mockRepo.getData()).thenAnswer((_) async => testData);

  // ACT - Execute the code under test
  final result = await sut.execute();

  // ASSERT - Verify the results
  expect(result, expectedResult);
});
```

### 2. Use Descriptive Test Names

```dart
// ❌ Bad
test('test login', () { ... });

// ✅ Good
test('should return User when login is successful', () { ... });
test('should return NetworkFailure when there is no internet', () { ... });
```

### 3. Test One Thing Per Test

```dart
// ❌ Bad - Testing multiple things
test('login functionality', () {
  // Tests success case
  // Tests failure case
  // Tests validation
});

// ✅ Good - Separate tests
test('should return User when credentials are valid', () { ... });
test('should return Failure when credentials are invalid', () { ... });
test('should validate email format', () { ... });
```

### 4. Use Test Groups

```dart
group('LoginUseCase', () {
  group('Success Cases', () {
    test('should return User when login succeeds', () { ... });
  });

  group('Failure Cases', () {
    test('should return NetworkFailure when offline', () { ... });
    test('should return UnauthorizedFailure when invalid', () { ... });
  });

  group('Edge Cases', () {
    test('should handle empty email', () { ... });
  });
});
```

### 5. Clean Up After Tests

```dart
group('TestGroup', () {
  late MyClass sut;
  late MockDependency mockDep;

  setUp(() {
    mockDep = MockDependency();
    sut = MyClass(mockDep);
  });

  tearDown(() {
    // Clean up resources
    mockDep.reset();
  });
});
```

---

## 📚 Testing Each Layer

### Domain Layer (Use Cases)

**Focus:** Business logic, validation, orchestration

```dart
class LoginUseCaseTest {
  late LoginUseCase loginUseCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    loginUseCase = LoginUseCase(mockRepository);
  });

  test('should return User when login is successful', () async {
    // Mock repository behavior
    when(() => mockRepository.login(any(), any()))
        .thenAnswer((_) async => Right(tUser));

    // Execute use case
    final result = await loginUseCase(email: tEmail, password: tPassword);

    // Verify result
    expect(result, Right(tUser));
    verify(() => mockRepository.login(tEmail, tPassword)).called(1);
  });
}
```

### Data Layer (Repositories)

**Focus:** Exception → Failure conversion, Model → Entity conversion

```dart
test('should return NetworkFailure when NetworkException is thrown', () async {
  // Arrange
  when(() => mockRemoteDataSource.login(any(), any()))
      .thenThrow(NetworkException());

  // Act
  final result = await repository.login(email, password);

  // Assert - Verify exception was converted to failure
  expect(result.isLeft(), true);
  result.fold(
    (failure) => expect(failure, isA<NetworkFailure>()),
    (_) => fail('Should return failure'),
  );
});
```

### Presentation Layer (Widgets)

**Focus:** UI rendering, user interactions, state changes

```dart
testWidgets('should call login when form is valid', (tester) async {
  // Arrange
  when(() => mockNotifier.login(any(), any())).thenAnswer((_) async {});

  await tester.pumpWidget(createTestWidget());

  // Act - Fill form
  await tester.enterText(find.byType(TextField).first, 'test@test.com');
  await tester.enterText(find.byType(TextField).last, 'password');
  await tester.tap(find.text('Login'));
  await tester.pump();

  // Assert - Verify login was called
  verify(() => mockNotifier.login('test@test.com', 'password')).called(1);
});
```

---

## 🛠️ Mocking Dependencies

### Using Mocktail

```dart
import 'package:mocktail/mocktail.dart';

// Create mock
class MockAuthRepository extends Mock implements AuthRepository {}

// Use in test
final mockRepo = MockAuthRepository();

// Stub method
when(() => mockRepo.login(any(), any()))
    .thenAnswer((_) async => Right(user));

// Verify call
verify(() => mockRepo.login(email, password)).called(1);

// Verify never called
verifyNever(() => mockRepo.logout());

// Verify order
verifyInOrder([
  () => mockRepo.login(email, password),
  () => mockRepo.getCurrentUser(),
]);
```

---

## 📊 Coverage Goals

- **Overall Coverage:** >80%
- **Domain Layer:** >90% (critical business logic)
- **Data Layer:** >85%
- **Presentation Layer:** >70%

---

## 🎓 Learning Resources

- [Flutter Testing Documentation](https://docs.flutter.dev/testing)
- [Mocktail Package](https://pub.dev/packages/mocktail)
- [Widget Testing Guide](https://docs.flutter.dev/cookbook/testing/widget/introduction)
- [Integration Testing Guide](https://docs.flutter.dev/testing/integration-tests)

---

## 💡 Tips

1. **Test behavior, not implementation**
2. **Keep tests independent** (don't rely on test order)
3. **Use factories** for test data
4. **Mock external dependencies** (API, storage)
5. **Test edge cases** (null, empty, invalid)
6. **Use `pumpAndSettle()`** for animations
7. **Avoid testing framework code** (e.g., Riverpod internals)
8. **Write tests before fixing bugs** (TDD for bug fixes)

---

Happy Testing! 🎉
