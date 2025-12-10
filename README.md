<div align="center">

# 🚀 Flutter Clean Architecture MVVM Starter

### Production-Ready Flutter Boilerplate with Clean Architecture & MVVM Pattern

[![Flutter Version](https://img.shields.io/badge/Flutter-3.2%2B-02569B?logo=flutter)](https://flutter.dev)
[![Dart Version](https://img.shields.io/badge/Dart-3.0%2B-0175C2?logo=dart)](https://dart.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](http://makeapullrequest.com)
[![Code Style](https://img.shields.io/badge/code%20style-effective__dart-40c4ff.svg)](https://dart.dev/guides/language/effective-dart)

**[Features](#-key-features) • [Architecture](#-architecture) • [Getting Started](#-getting-started) • [Documentation](#-documentation) • [Tech Stack](#-tech-stack)**

</div>

---

## 📖 About

A **production-ready Flutter boilerplate** implementing **Clean Architecture** with **MVVM** pattern. This starter kit provides a robust, scalable, and testable foundation for building complex Flutter applications with industry best practices.

Perfect for:
- 🏢 **Enterprise Applications** - Scalable architecture for large teams
- 🎓 **Learning Clean Architecture** - Extensive comments explaining WHY, not just WHAT
- 🚀 **Quick Project Kickstart** - Start building features immediately
- 💼 **Interview Preparation** - Architecture decisions fully documented

---

## ✨ Key Features

<table>
<tr>
<td>

### 🏗️ **Architecture**
- ✅ Clean Architecture (3 layers)
- ✅ MVVM Pattern with Riverpod
- ✅ Feature-First Structure
- ✅ Dependency Inversion
- ✅ Repository Pattern
- ✅ Use Case Pattern

</td>
<td>

### 🛡️ **Error Handling**
- ✅ Type-Safe Error Handling
- ✅ `Either<Failure, Data>` Pattern
- ✅ Sealed Classes with Freezed
- ✅ Exhaustive Pattern Matching
- ✅ Domain-Level Failures
- ✅ No Try-Catch Hell

</td>
</tr>
<tr>
<td>

### 🌐 **Networking**
- ✅ Dio HTTP Client
- ✅ **Automatic Token Refresh**
- ✅ Auth Interceptor (401 handling)
- ✅ Request/Response Logging
- ✅ Centralized Error Mapping
- ✅ Network Connectivity Checks

</td>
<td>

### 🎨 **State Management**
- ✅ Riverpod (Code Generation)
- ✅ Compile-Time Safety
- ✅ DevTools Integration
- ✅ Easy Testing
- ✅ Provider Composition
- ✅ State Notifiers

</td>
</tr>
<tr>
<td>

### 🔐 **Security**
- ✅ Secure Token Storage
- ✅ FlutterSecureStorage
- ✅ Encrypted SharedPreferences
- ✅ Token Auto-Refresh
- ✅ Secure API Communication

</td>
<td>

### 🧪 **Code Quality**
- ✅ Code Generation Ready
- ✅ Lint Rules Configured
- ✅ Extensive Documentation
- ✅ Test-Friendly Design
- ✅ Dart 3 Features
- ✅ Null Safety

</td>
</tr>
</table>

---

## 🏛️ Architecture

### Clean Architecture Layers

```
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                        │
│   ┌─────────────┐  ┌─────────────┐  ┌──────────────┐       │
│   │   Screens   │  │  Providers  │  │    State     │       │
│   │   Widgets   │  │ (ViewModels)│  │  (Freezed)   │       │
│   └─────────────┘  └─────────────┘  └──────────────┘       │
└────────────────────────┬────────────────────────────────────┘
                         │ depends on
┌────────────────────────▼────────────────────────────────────┐
│                     Domain Layer                             │
│   ┌─────────────┐  ┌─────────────┐  ┌──────────────┐       │
│   │  Entities   │  │  Use Cases  │  │ Repositories │       │
│   │   (Pure)    │  │   (Logic)   │  │ (Interfaces) │       │
│   └─────────────┘  └─────────────┘  └──────────────┘       │
└────────────────────────▲────────────────────────────────────┘
                         │ implements
┌────────────────────────┴────────────────────────────────────┐
│                      Data Layer                              │
│   ┌─────────────┐  ┌─────────────┐  ┌──────────────┐       │
│   │   Models    │  │ Data Sources│  │ Repositories │       │
│   │   (JSON)    │  │ (API/Local) │  │    (Impl)    │       │
│   └─────────────┘  └─────────────┘  └──────────────┘       │
└─────────────────────────────────────────────────────────────┘
```

### Why This Architecture?

| Benefit | Description |
|---------|-------------|
| 🧩 **Separation of Concerns** | Each layer has a single, well-defined responsibility |
| 🧪 **Testability** | Easy to test each layer in isolation |
| 🔄 **Flexibility** | Swap implementations without affecting other layers |
| 📈 **Scalability** | Patterns that scale from small to large apps |
| 👥 **Team Friendly** | Clear structure for team collaboration |

---

## 📁 Project Structure

```
lib/
├── 📂 core/                          # Core Infrastructure
│   ├── constants/                    # API endpoints, app constants
│   ├── di/                           # Dependency injection (GetIt + Injectable)
│   ├── error/                        # Failures & Exceptions
│   │   ├── failures.dart             # ← Sealed classes for all failures
│   │   └── exceptions.dart           # ← Data layer exceptions
│   ├── network/                      # HTTP client & interceptors
│   │   ├── network_client.dart       # ← Dio wrapper
│   │   └── interceptors/
│   │       ├── auth_interceptor.dart # ← Token injection & 401 handling
│   │       └── logging_interceptor.dart
│   ├── router/                       # Navigation (GoRouter)
│   │   ├── app_router.dart           # ← Auth-aware routing
│   │   └── route_names.dart          # ← Type-safe route constants
│   ├── storage/                      # Local & secure storage
│   ├── types/                        # Type definitions (Either, etc.)
│   └── utils/                        # Logger, extensions
│
├── 📂 features/                      # Feature Modules (Feature-First)
│   │
│   ├── 📂 auth/                      # ✅ COMPLETE Authentication Module
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── auth_remote_datasource.dart  # API calls
│   │   │   │   └── auth_local_datasource.dart   # Caching
│   │   │   ├── models/
│   │   │   │   └── user_model.dart              # JSON ↔ Domain
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart    # Implements domain interface
│   │   │
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── user.dart                    # Business entity
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart         # Abstract contract
│   │   │   └── usecases/
│   │   │       ├── login_usecase.dart
│   │   │       ├── logout_usecase.dart
│   │   │       └── get_current_user_usecase.dart
│   │   │
│   │   └── presentation/
│   │       ├── providers/
│   │       │   ├── auth_provider.dart           # State management
│   │       │   └── auth_state.dart              # Sealed state classes
│   │       └── screens/
│   │           ├── login_screen.dart
│   │           └── splash_screen.dart
│   │
│   └── 📂 home/                      # Example feature
│       └── presentation/screens/home_screen.dart
│
├── app.dart                          # Root widget
└── main.dart                         # App entry point
```

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK: `>=3.2.0`
- Dart SDK: `>=3.0.0`

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/yourusername/flutter-clean-mvvm-starter.git
cd flutter-clean-mvvm-starter

# 2. Install dependencies
flutter pub get

# 3. Run code generation (REQUIRED!)
flutter pub run build_runner build --delete-conflicting-outputs

# 4. Run the app
flutter run
```

### Quick Commands

```bash
# Watch mode (auto-regenerate on file changes)
flutter pub run build_runner watch

# Clean build
flutter clean && flutter pub get && flutter pub run build_runner build --delete-conflicting-outputs

# Run tests
flutter test

# Code analysis
flutter analyze
```

---

## 🎯 What's Included

### ✅ Complete Authentication Module

A **fully implemented** authentication system demonstrating the entire architecture:

**Features:**
- Login with email/password
- Auto-login on app start
- Secure token storage
- Automatic token refresh
- Logout functionality
- User caching for offline support

**Architecture Demonstration:**
- ✅ Domain entities (`User`)
- ✅ Repository pattern (interface + implementation)
- ✅ Use cases (business logic)
- ✅ Data models with JSON serialization
- ✅ Remote & local data sources
- ✅ State management with Riverpod
- ✅ Sealed classes for state
- ✅ Type-safe error handling

---

## 🔑 Core Concepts

### 1. Type-Safe Error Handling

**No more try-catch hell!** Using functional programming patterns:

```dart
// ❌ Old way - easy to forget error handling
try {
  final user = await repository.login(email, password);
  navigateToHome(user);
} catch (e) {
  // Oops, forgot to handle this!
}

// ✅ New way - compiler forces you to handle errors
final result = await loginUseCase(email: email, password: password);

result.fold(
  (failure) => failure.when(
    network: () => showError('No internet connection'),
    unauthorized: () => showError('Invalid credentials'),
    server: (message) => showError(message),
    // Compiler ensures ALL cases handled!
  ),
  (user) => navigateToHome(user),
);
```

### 2. Automatic Token Refresh

**Zero user friction** - tokens refresh automatically:

```dart
// 1. User makes authenticated request
// 2. Token expired → 401 error
// 3. AuthInterceptor detects 401
// 4. Automatically refreshes token
// 5. Retries original request
// 6. User never notices! ✨
```

**Features:**
- Request queuing during refresh
- Prevents concurrent refresh attempts
- Automatic logout on refresh failure
- Seamless user experience

### 3. Sealed Classes for States

**Exhaustive pattern matching** - never miss a state:

```dart
@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;
  const factory AuthState.loading() = _Loading;
  const factory AuthState.authenticated(User user) = _Authenticated;
  const factory AuthState.unauthenticated() = _Unauthenticated;
  const factory AuthState.error(Failure failure) = _Error;
}

// Compiler ensures you handle ALL states
authState.when(
  initial: () => SplashScreen(),
  loading: () => LoadingIndicator(),
  authenticated: (user) => HomeScreen(user),
  unauthenticated: () => LoginScreen(),
  error: (failure) => ErrorScreen(failure),
  // Missing a case? → Compile error! ✅
);
```

---

## 🛠️ Tech Stack

<div align="center">

| Category | Technology | Why? |
|----------|-----------|------|
| **State Management** | ![Riverpod](https://img.shields.io/badge/Riverpod-2.4%2B-00A9FF?logo=flutter) | Compile-time safety, less boilerplate |
| **Networking** | ![Dio](https://img.shields.io/badge/Dio-5.4%2B-00A9FF) | Interceptors, easy configuration |
| **DI** | ![GetIt](https://img.shields.io/badge/GetIt%20%2B%20Injectable-Latest-blue) | Service locator with code generation |
| **Error Handling** | ![FpDart](https://img.shields.io/badge/FpDart-Latest-orange) | Functional programming (Either) |
| **Data Classes** | ![Freezed](https://img.shields.io/badge/Freezed-2.4%2B-brightgreen) | Immutability, sealed classes |
| **Serialization** | ![JSON](https://img.shields.io/badge/json__serializable-6.7%2B-yellow) | Code generation |
| **Routing** | ![GoRouter](https://img.shields.io/badge/GoRouter-12%2B-blue) | Type-safe, auth-aware routing |
| **Storage** | ![Storage](https://img.shields.io/badge/Secure%20%2B%20SharedPrefs-Latest-red) | Encrypted + fast storage |

</div>

---

## 📚 Documentation

| Document | Description |
|----------|-------------|
| 📘 [**ARCHITECTURE.md**](ARCHITECTURE.md) | Deep dive into architectural decisions & interview prep |
| 📗 [**SETUP.md**](SETUP.md) | Step-by-step setup guide & troubleshooting |
| 📙 [**QUICKSTART.md**](QUICKSTART.md) | Quick start guide (Turkish) |

---

## 🎓 Learning Resources

### Code Comments

Every file includes extensive comments explaining:
- ✅ **WHY** this decision was made (not just WHAT)
- ✅ **Alternatives** considered
- ✅ **Trade-offs** involved
- ✅ **Interview defense** points

Perfect for:
- Learning Clean Architecture
- Interview preparation
- Team onboarding
- Code reviews

### Example: Why Riverpod over BLoC?

```dart
/// WHY RIVERPOD OVER BLOC:
/// 1. Less boilerplate (no events, just methods)
/// 2. Better compile-time safety with code generation
/// 3. Easier testing (providers are pure functions)
/// 4. Better DevTools integration
/// 5. Simpler mental model for most use cases
///
/// WHEN TO USE BLOC INSTEAD:
/// - Need explicit event tracking
/// - Team already experienced with BLoC
/// - Complex event transformation needed
```

---

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test
flutter test test/features/auth/domain/usecases/login_usecase_test.dart
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

---

## 🔧 Adding a New Feature

Follow the established pattern:

```bash
# 1. Create feature folder structure
lib/features/new_feature/
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

# 2. Implement from domain → data → presentation

# 3. Run code generation
flutter pub run build_runner build --delete-conflicting-outputs
```

See [ARCHITECTURE.md](ARCHITECTURE.md) for detailed guide.

---

## 🌟 Highlights

### Production-Ready Features

- ✅ **Environment Configuration** - Dev, Staging, Production
- ✅ **Secure Token Storage** - Encrypted on device
- ✅ **Offline Support** - Local caching strategy
- ✅ **Error Recovery** - Automatic retry logic
- ✅ **Logging** - Comprehensive request/response logs
- ✅ **Type Safety** - Compile-time error checking
- ✅ **Code Generation** - Automated boilerplate
- ✅ **Lint Rules** - Production-grade code quality

### Developer Experience

- ✅ **Hot Reload** - Fast development cycle
- ✅ **Code Organization** - Feature-first structure
- ✅ **Documentation** - Extensive inline comments
- ✅ **Examples** - Complete auth module
- ✅ **Tooling** - VS Code + Android Studio support
- ✅ **CI/CD Ready** - GitHub Actions template included

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 💬 FAQ

<details>
<summary><b>Q: Is this over-engineered for small apps?</b></summary>

Yes, for very simple apps this might be overkill. But it scales beautifully. Once you understand the pattern, adding features is actually faster than a "quick and dirty" approach that becomes unmaintainable.
</details>

<details>
<summary><b>Q: Why Clean Architecture instead of simpler patterns?</b></summary>

Clean Architecture provides:
- Clear separation of concerns
- Easy testing (mock any layer)
- Team scalability (multiple devs can work independently)
- Long-term maintainability
- Ability to swap implementations (REST → GraphQL, etc.)
</details>

<details>
<summary><b>Q: Can I use BLoC instead of Riverpod?</b></summary>

Absolutely! The architecture is framework-agnostic. Swap Riverpod providers with BLoC blocs, and the rest stays the same.
</details>

<details>
<summary><b>Q: How do I integrate my API?</b></summary>

1. Update `lib/core/constants/api_constants.dart` with your endpoints
2. Modify `user_model.dart` to match your API response
3. Update the auth data sources to call your endpoints
4. Done! The architecture handles the rest.
</details>

---

## 🙏 Acknowledgments

- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html) by Robert C. Martin
- [Riverpod Documentation](https://riverpod.dev)
- Flutter Community
- All contributors

---

<div align="center">

### ⭐ Star this repo if you find it useful!

**Built with ❤️ by the Flutter Community**

[Report Bug](https://github.com/yourusername/flutter-clean-mvvm-starter/issues) • [Request Feature](https://github.com/yourusername/flutter-clean-mvvm-starter/issues) • [Documentation](ARCHITECTURE.md)

</div>
