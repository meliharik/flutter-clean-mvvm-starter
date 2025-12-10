# Contributing to Flutter Clean MVVM Starter

First off, thank you for considering contributing to Flutter Clean MVVM Starter! 🎉

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How Can I Contribute?](#how-can-i-contribute)
- [Development Setup](#development-setup)
- [Pull Request Process](#pull-request-process)
- [Coding Standards](#coding-standards)
- [Commit Messages](#commit-messages)

## 📜 Code of Conduct

This project and everyone participating in it is governed by our commitment to create a welcoming and inclusive environment. Please be respectful and constructive in all interactions.

## 🤝 How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check existing issues. When you create a bug report, include as many details as possible:

- **Use a clear and descriptive title**
- **Describe the exact steps to reproduce the problem**
- **Provide specific examples**
- **Describe the behavior you observed** and what behavior you expected
- **Include screenshots** if relevant
- **Include your environment details** (Flutter version, OS, etc.)

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion, include:

- **Use a clear and descriptive title**
- **Provide a detailed description** of the suggested enhancement
- **Explain why this enhancement would be useful**
- **List any alternatives** you've considered

### Pull Requests

- Fill in the required template
- Follow the coding standards
- Include appropriate test cases
- Update documentation as needed
- End all files with a newline

## 🛠️ Development Setup

1. **Fork and Clone**
   ```bash
   git clone https://github.com/your-username/flutter-clean-mvvm-starter.git
   cd flutter-clean-mvvm-starter
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Run Code Generation**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Create a Branch**
   ```bash
   git checkout -b feature/amazing-feature
   ```

## 🔄 Pull Request Process

1. **Update the README.md** with details of changes if applicable
2. **Update the CHANGELOG.md** with a note describing your changes
3. **Ensure all tests pass**
   ```bash
   flutter test
   flutter analyze
   ```
4. **Update documentation** for any changed functionality
5. **Request review** from maintainers
6. **Address feedback** and make requested changes
7. **Squash commits** before merging (if requested)

## 📝 Coding Standards

### Architecture

- Follow Clean Architecture principles
- Maintain the 3-layer structure (Data, Domain, Presentation)
- Keep business logic in use cases
- Use repository pattern consistently
- Follow feature-first organization

### Dart/Flutter

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use `flutter analyze` and fix all warnings
- Format code with `dart format .`
- Use meaningful variable and function names
- Add comments explaining **WHY**, not just WHAT

### Code Style

```dart
// ✅ Good - Explains WHY
/// Uses sealed classes for exhaustive pattern matching
/// WHY: Compiler ensures all states are handled, preventing runtime errors
@freezed
class State with _$State { ... }

// ❌ Bad - Just explains WHAT
/// A class for state
class State { ... }
```

### File Organization

```
features/
  └── feature_name/
      ├── data/
      │   ├── datasources/
      │   ├── models/
      │   └── repositories/
      ├── domain/
      │   ├── entities/
      │   ├── repositories/
      │   └── usecases/
      └── presentation/
          ├── providers/
          ├── screens/
          └── widgets/
```

### Testing

- Write tests for all new features
- Maintain >80% code coverage
- Use meaningful test descriptions
- Follow AAA pattern (Arrange, Act, Assert)

```dart
test('should return User when login is successful', () async {
  // Arrange
  when(() => mockRepository.login(any(), any()))
      .thenAnswer((_) async => Right(tUser));

  // Act
  final result = await useCase(email: tEmail, password: tPassword);

  // Assert
  expect(result, Right(tUser));
  verify(() => mockRepository.login(tEmail, tPassword));
});
```

## 💬 Commit Messages

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
type(scope): subject

body

footer
```

### Types

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

### Examples

```bash
feat(auth): add biometric authentication support

Implements fingerprint and face recognition for login.
Uses local_auth package for platform integration.

Closes #123
```

```bash
fix(network): handle connection timeout correctly

Previously, timeouts weren't being caught properly.
Now using Dio's timeout configuration.

Fixes #456
```

## 🎯 Areas for Contribution

Looking for places to contribute? Check out:

- 📝 Documentation improvements
- 🐛 Bug fixes
- ✨ New features
- 🧪 Test coverage
- 🌐 Internationalization
- ♿ Accessibility improvements
- 🎨 UI/UX enhancements
- 📱 Platform-specific features

## 📚 Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Riverpod Documentation](https://riverpod.dev/)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Effective Dart](https://dart.dev/guides/language/effective-dart)

## ❓ Questions?

Feel free to:
- Open an issue for discussion
- Reach out to maintainers
- Check existing documentation

---

Thank you for contributing to Flutter Clean MVVM Starter! 🚀
