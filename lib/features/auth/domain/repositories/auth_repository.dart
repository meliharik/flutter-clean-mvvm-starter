import 'package:flutter_clean_mvvm_starter/core/types/typedefs.dart';
import 'package:flutter_clean_mvvm_starter/features/auth/domain/entities/user.dart';

/// Authentication repository interface - Domain layer
///
/// WHY ABSTRACT CLASS (Interface):
/// 1. DEPENDENCY INVERSION: High-level modules (usecases) don't depend on low-level (API)
/// 2. TESTABILITY: Can mock this interface in tests
/// 3. FLEXIBILITY: Can swap implementations (REST API, GraphQL, Firebase, Mock)
/// 4. DOMAIN PURITY: Domain doesn't know about Dio, HTTP, JSON, etc.
///
/// CLEAN ARCHITECTURE FLOW:
/// Presentation -> UseCase -> Repository Interface (Domain)
///                                       ↑
///                                  Implementation (Data)
///                                       ↑
///                                  DataSource (API)
///
/// WHY EITHER<FAILURE, DATA>:
/// - Forces error handling (can't ignore failures)
/// - Type-safe error handling
/// - No try-catch hell in presentation layer
abstract class AuthRepository {
  /// Login with email and password
  ///
  /// Returns:
  /// - Right(User): Login successful
  /// - Left(Failure): Login failed (network, validation, unauthorized, etc.)
  FutureEither<User> login({
    required String email,
    required String password,
  });

  /// Register new user
  FutureEither<User> register({
    required String email,
    required String password,
    required String name,
  });

  /// Logout current user
  ///
  /// Returns:
  /// - Right(void): Logout successful
  /// - Left(Failure): Logout failed
  FutureEither<void> logout();

  /// Get currently logged-in user
  ///
  /// Returns:
  /// - Right(User): User is logged in
  /// - Left(Failure): No user logged in or token expired
  FutureEither<User> getCurrentUser();

  /// Check if user is logged in (has valid token)
  ///
  /// WHY SYNC: Just checking local storage, no API call
  /// Returns true if access token exists, false otherwise
  Future<bool> isLoggedIn();
}
