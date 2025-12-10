# 🔧 Setup Guide

This guide will help you set up and run the Flutter Clean MVVM Starter project.

## 📋 Prerequisites

- Flutter SDK: `>=3.2.0`
- Dart SDK: `>=3.0.0`

Check your Flutter version:
```bash
flutter --version
```

## 🚀 Quick Start

Follow these steps in order:

### 1. Install Dependencies

```bash
flutter pub get
```

This will download all packages defined in `pubspec.yaml`.

### 2. Run Code Generation

This project uses code generation for several features. You **must** run this before the app will compile:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

This generates:
- `*.freezed.dart` - Freezed data classes
- `*.g.dart` - JSON serialization code
- `injection.config.dart` - Dependency injection code
- `*.g.dart` (Riverpod) - Provider code

**Expected output:**
```
[INFO] Generating build script completed, took 2.1s
[INFO] Reading cached asset graph completed, took 85ms
[INFO] Checking for updates since last build completed, took 501ms
[INFO] Running build completed, took 15.2s
[INFO] Caching finalized dependency graph completed, took 38ms
[INFO] Succeeded after 15.3s with 123 outputs
```

### 3. Verify Generated Files

Check that these files were created:

```bash
# Core files
lib/core/di/injection.config.dart
lib/core/error/failures.freezed.dart

# Auth feature files
lib/features/auth/data/models/user_model.freezed.dart
lib/features/auth/data/models/user_model.g.dart
lib/features/auth/presentation/providers/auth_state.freezed.dart
lib/features/auth/presentation/providers/auth_provider.g.dart
```

### 4. Bridge Riverpod and GetIt

The template has placeholder providers that need to be implemented. Update `lib/features/auth/presentation/providers/auth_provider.dart`:

Replace the placeholder providers (lines ~155-175) with:

```dart
@riverpod
LoginUseCase loginUseCase(LoginUseCaseRef ref) {
  return getIt<LoginUseCase>();
}

@riverpod
LogoutUseCase logoutUseCase(LogoutUseCaseRef ref) {
  return getIt<LogoutUseCase>();
}

@riverpod
GetCurrentUserUseCase getCurrentUserUseCase(GetCurrentUserUseCaseRef ref) {
  return getIt<GetCurrentUserUseCase>();
}

@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  return getIt<AuthRepository>();
}
```

Don't forget to import getIt:
```dart
import 'package:flutter_clean_mvvm_starter/core/di/injection.dart';
```

### 5. Run the App

```bash
flutter run
```

Or for a specific device:
```bash
flutter run -d chrome    # Web
flutter run -d macos     # macOS
flutter run -d ios       # iOS Simulator
```

## 🐛 Troubleshooting

### Build Runner Fails

**Problem:** `build_runner` fails with conflicts

**Solution:**
```bash
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

### Import Errors

**Problem:** Red squiggly lines on imports after generation

**Solution:** Restart your IDE or run:
```bash
flutter pub get
# In VS Code: Cmd+Shift+P → "Dart: Restart Analysis Server"
# In Android Studio: File → Invalidate Caches / Restart
```

### DI Not Working

**Problem:** `GetIt` can't find dependencies

**Solution:** Make sure:
1. You ran code generation
2. `injection.config.dart` exists
3. Classes are marked with `@injectable`, `@singleton`, or `@lazySingleton`
4. `configureDependencies()` is called in `main.dart`

### Connectivity Issues

**Problem:** `connectivity_plus` compatibility issues

**Solution:** The connectivity API changed. Update `lib/core/network/network_info.dart`:

```dart
@override
Future<bool> get isConnected async {
  final result = await _connectivity.checkConnectivity();
  return _isConnected(result);
}

@override
Stream<bool> get onConnectivityChanged {
  return _connectivity.onConnectivityChanged.map(_isConnected);
}

bool _isConnected(List<ConnectivityResult> results) {
  return results.any((result) =>
    result == ConnectivityResult.mobile ||
    result == ConnectivityResult.wifi ||
    result == ConnectivityResult.ethernet
  );
}
```

## 🔄 Development Workflow

### Watch Mode for Code Generation

Instead of manually running build_runner each time:

```bash
flutter pub run build_runner watch
```

This watches for file changes and regenerates code automatically.

### Clean Build

If you encounter strange errors:

```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter run
```

## 📱 Running Tests

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/features/auth/domain/usecases/login_usecase_test.dart
```

## 🌐 API Configuration

### Development Environment

By default, the app uses dev endpoints. Update in `lib/core/constants/api_constants.dart`:

```dart
static const String baseUrl = baseUrlDev;
```

### Production Environment

For production builds, use:

```dart
static const String baseUrl = baseUrlProd;
```

Or use build configurations:
```bash
flutter build apk --dart-define=ENV=prod
```

## 🔐 Secure Storage Setup

### iOS

Add to `ios/Runner/Info.plist`:
```xml
<key>NSFaceIDUsageDescription</key>
<string>We need to access Face ID for secure authentication</string>
```

### Android

No additional setup required. Uses `EncryptedSharedPreferences` by default.

## 📝 Next Steps

1. ✅ Run code generation
2. ✅ Update API endpoints in `api_constants.dart`
3. ✅ Implement actual API integration
4. ✅ Add your features in `lib/features/`
5. ✅ Customize theme in `lib/app.dart`
6. ✅ Add app icons and splash screen
7. ✅ Configure Firebase (if needed)
8. ✅ Set up CI/CD pipeline

## 📚 Useful Commands

```bash
# Get dependencies
flutter pub get

# Code generation
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode
flutter pub run build_runner watch

# Clean generated files
flutter pub run build_runner clean

# Clean Flutter cache
flutter clean

# Analyze code
flutter analyze

# Format code
dart format .

# Run app
flutter run

# Build APK
flutter build apk --release

# Build iOS
flutter build ios --release
```

## 🆘 Getting Help

1. Check the [README.md](README.md) for architecture overview
2. Review code comments (extensive documentation in each file)
3. Check [Flutter documentation](https://docs.flutter.dev)
4. Check [Riverpod documentation](https://riverpod.dev)
5. Open an issue on GitHub

---

**You're all set!** 🎉 Happy coding!
