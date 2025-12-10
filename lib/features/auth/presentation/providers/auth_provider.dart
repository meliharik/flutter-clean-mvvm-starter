import 'package:flutter_clean_mvvm_starter/core/di/injection.dart';
import 'package:flutter_clean_mvvm_starter/core/utils/logger.dart';
import 'package:flutter_clean_mvvm_starter/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_clean_mvvm_starter/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:flutter_clean_mvvm_starter/features/auth/domain/usecases/login_usecase.dart';
import 'package:flutter_clean_mvvm_starter/features/auth/domain/usecases/logout_usecase.dart';
import 'package:flutter_clean_mvvm_starter/features/auth/presentation/providers/auth_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_provider.g.dart';

/// Authentication provider using Riverpod
///
/// WHY RIVERPOD OVER BLOC:
/// 1. Less boilerplate (no events, just methods)
/// 2. Better compile-time safety with code generation
/// 3. Easier testing (providers are pure functions)
/// 4. Better DevTools integration
/// 5. Simpler mental model for most use cases
///
/// MVVM PATTERN:
/// - State: AuthState (sealed class with all possible states)
/// - View: Listens to this provider
/// - ViewModel: This class (manages state, calls use cases)
///
/// ARCHITECTURE FLOW:
/// UI action -> ViewModel method -> UseCase -> Repository -> DataSource
/// DataSource -> Repository (Either) -> UseCase -> ViewModel (update state) -> UI rebuild
///
/// DEPENDENCY INJECTION:
/// - Riverpod handles DI automatically
/// - Use cases injected via constructor
/// - Providers can depend on other providers
@riverpod
class AuthNotifier extends _$AuthNotifier {
  late final LoginUseCase _loginUseCase;
  late final LogoutUseCase _logoutUseCase;
  late final GetCurrentUserUseCase _getCurrentUserUseCase;
  late final AuthRepository _authRepository;

  @override
  AuthState build() {
    // Inject dependencies from get_it
    // WHY: Riverpod doesn't know about get_it, so we bridge manually
    // ALTERNATIVE: Use Riverpod providers for dependency injection
    _loginUseCase = ref.read(loginUseCaseProvider);
    _logoutUseCase = ref.read(logoutUseCaseProvider);
    _getCurrentUserUseCase = ref.read(getCurrentUserUseCaseProvider);
    _authRepository = ref.read(authRepositoryProvider);

    // Initialize auth state on app start
    _checkAuthStatus();

    return const AuthState.initial();
  }

  /// Check authentication status on app start
  ///
  /// WHY: Need to know if user is already logged in
  /// - If yes: auto-login and navigate to home
  /// - If no: show login screen
  Future<void> _checkAuthStatus() async {
    state = const AuthState.loading();

    final isLoggedIn = await _authRepository.isLoggedIn();

    if (isLoggedIn) {
      // Has token, try to fetch user
      final result = await _getCurrentUserUseCase();

      result.fold(
        (failure) {
          // Token invalid or expired, logout
          AppLogger.warning('Auto-login failed', failure);
          state = const AuthState.unauthenticated();
        },
        (user) {
          // Successfully authenticated
          AppLogger.info('Auto-login successful: ${user.email}');
          state = AuthState.authenticated(user);
        },
      );
    } else {
      // No token, user needs to login
      state = const AuthState.unauthenticated();
    }
  }

  /// Login with email and password
  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const AuthState.loading();

    final result = await _loginUseCase(email: email, password: password);

    result.fold(
      (failure) {
        AppLogger.error('Login failed', failure);
        state = AuthState.error(failure);
        // Auto-transition to unauthenticated after showing error
        Future.delayed(const Duration(seconds: 2), () {
          state.whenOrNull(
            error: (_) => state = const AuthState.unauthenticated(),
          );
        });
      },
      (user) {
        AppLogger.info('Login successful: ${user.email}');
        state = AuthState.authenticated(user);
      },
    );
  }

  /// Logout current user
  Future<void> logout() async {
    state = const AuthState.loading();

    final result = await _logoutUseCase();

    result.fold(
      (failure) {
        AppLogger.error('Logout failed', failure);
        // Even if logout fails, clear local state
        state = const AuthState.unauthenticated();
      },
      (_) {
        AppLogger.info('Logout successful');
        state = const AuthState.unauthenticated();
      },
    );
  }

  /// Refresh user data
  Future<void> refreshUser() async {
    final result = await _getCurrentUserUseCase();

    result.fold(
      (failure) {
        AppLogger.error('Refresh user failed', failure);
        // Don't change state, keep current user
      },
      (user) {
        AppLogger.info('User refreshed: ${user.email}');
        state = AuthState.authenticated(user);
      },
    );
  }
}

/// Providers for use cases (bridge between get_it and Riverpod)
///
/// WHY: Riverpod providers can be injected into other providers
/// These fetch instances from get_it service locator
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
