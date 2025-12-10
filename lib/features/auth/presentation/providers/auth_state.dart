import 'package:flutter_clean_mvvm_starter/core/error/failures.dart';
import 'package:flutter_clean_mvvm_starter/features/auth/domain/entities/user.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_state.freezed.dart';

/// Authentication state
///
/// WHY SEALED STATES:
/// 1. Exhaustive pattern matching (compiler ensures all states handled)
/// 2. Type-safe state management
/// 3. Clear state transitions
/// 4. Easy to debug (know exactly which state you're in)
///
/// STATE MACHINE:
/// Initial -> Loading -> Authenticated | Unauthenticated | Error
///
/// UI reacts to these states:
/// - Initial: Show splash screen
/// - Loading: Show progress indicator
/// - Authenticated: Navigate to home
/// - Unauthenticated: Show login screen
/// - Error: Show error message
@freezed
class AuthState with _$AuthState {
  /// Initial state - app just started
  const factory AuthState.initial() = _Initial;

  /// Loading state - checking auth or performing auth action
  const factory AuthState.loading() = _Loading;

  /// Authenticated state - user is logged in
  const factory AuthState.authenticated(User user) = _Authenticated;

  /// Unauthenticated state - user is not logged in
  const factory AuthState.unauthenticated() = _Unauthenticated;

  /// Error state - authentication failed
  const factory AuthState.error(Failure failure) = _Error;
}
