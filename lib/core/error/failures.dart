import 'package:freezed_annotation/freezed_annotation.dart';

part 'failures.freezed.dart';

/// Sealed class representing all possible failure states
///
/// WHY SEALED CLASSES (Dart 3):
/// 1. Exhaustive pattern matching - compiler ensures you handle all cases
/// 2. No unknown subtypes - all failure types are defined here
/// 3. Better than enums - can carry different data per type
/// 4. Type-safe error handling without runtime surprises
///
/// WHY FREEZED:
/// 1. Immutability by default (failures shouldn't be mutated)
/// 2. Automatic copyWith, toString, equality
/// 3. Union types for sealed classes
/// 4. Pattern matching support
///
/// ARCHITECTURE NOTE:
/// Failures live in the DOMAIN layer. They represent business logic errors.
/// Exceptions (from data layer) are caught and converted to Failures in repositories.
/// This keeps the domain layer independent of implementation details (network, storage, etc.)
///
/// Usage in presentation layer:
/// ```dart
/// result.fold(
///   (failure) => failure.when(
///     server: (message) => showError('Server error: $message'),
///     network: () => showError('No internet connection'),
///     unauthorized: () => navigateToLogin(),
///     // Compiler forces you to handle all cases!
///   ),
///   (data) => showSuccess(data),
/// );
/// ```
@freezed
class Failure with _$Failure {
  const Failure._(); // Required for custom methods/getters

  /// Server-side error (500, 503, etc.)
  const factory Failure.server({
    required String message,
    int? statusCode,
  }) = ServerFailure;

  /// Network connectivity error
  const factory Failure.network({
    @Default('No internet connection') String message,
  }) = NetworkFailure;

  /// Authentication error (401)
  const factory Failure.unauthorized({
    @Default('Unauthorized. Please login again.') String message,
  }) = UnauthorizedFailure;

  /// Permission error (403)
  const factory Failure.forbidden({
    @Default('Access forbidden') String message,
  }) = ForbiddenFailure;

  /// Resource not found (404)
  const factory Failure.notFound({
    @Default('Resource not found') String message,
  }) = NotFoundFailure;

  /// Validation error (400)
  const factory Failure.validation({
    required String message,
    Map<String, dynamic>? errors,
  }) = ValidationFailure;

  /// Cached data not available
  const factory Failure.cache({
    @Default('Data not found in cache') String message,
  }) = CacheFailure;

  /// Request timeout
  const factory Failure.timeout({
    @Default('Request timeout') String message,
  }) = TimeoutFailure;

  /// Unexpected error
  const factory Failure.unexpected({
    required String message,
  }) = UnexpectedFailure;

  // Helper method to get user-friendly message
  // This can be called from UI to display appropriate error messages
  String get userMessage => when(
        server: (message, _) => message,
        network: (message) => message,
        unauthorized: (message) => message,
        forbidden: (message) => message,
        notFound: (message) => message,
        validation: (message, _) => message,
        cache: (message) => message,
        timeout: (message) => message,
        unexpected: (message) => message,
      );
}
