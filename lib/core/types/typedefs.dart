import 'package:fpdart/fpdart.dart';
import 'package:flutter_clean_mvvm_starter/core/error/failures.dart';

/// Type alias for asynchronous operations that can fail.
///
/// WHY: Using Either<Failure, T> instead of throwing exceptions provides:
/// 1. Explicit error handling at compile time (forces you to handle both cases)
/// 2. Better testability (no need to catch exceptions)
/// 3. Functional programming pattern that composes well
/// 4. Makes it clear in the signature that this operation can fail
///
/// Usage:
/// ```dart
/// FutureEither<User> login(String email, String password) async {
///   try {
///     final user = await api.login(email, password);
///     return Right(user);  // Success
///   } catch (e) {
///     return Left(ServerFailure(message: e.toString()));  // Failure
///   }
/// }
/// ```
typedef FutureEither<T> = Future<Either<Failure, T>>;

/// Type alias for synchronous operations that can fail.
///
/// WHY: Same benefits as FutureEither but for synchronous operations.
/// Useful for validation, parsing, or any operation that doesn't involve async.
typedef SyncEither<T> = Either<Failure, T>;

/// Type alias for JSON maps (commonly used in serialization).
///
/// WHY: Provides semantic meaning and easier refactoring.
/// Instead of Map<String, dynamic> everywhere, DataMap makes intent clear.
typedef DataMap = Map<String, dynamic>;
