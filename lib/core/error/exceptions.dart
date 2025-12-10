/// Base exception class for all custom exceptions
///
/// WHY: Exceptions are thrown at the DATA layer (e.g., when API fails, storage fails)
/// They are then caught and converted to Failures in the repository implementation.
/// This separation keeps the domain layer clean of implementation details.
abstract class AppException implements Exception {
  final String message;
  final int? statusCode;

  const AppException({
    required this.message,
    this.statusCode,
  });

  @override
  String toString() => message;
}

/// Thrown when server returns an error response
class ServerException extends AppException {
  const ServerException({
    required super.message,
    super.statusCode,
  });
}

/// Thrown when there's no internet connection
class NetworkException extends AppException {
  const NetworkException({
    String message = 'No internet connection. Please check your network.',
  }) : super(message: message);
}

/// Thrown when cached data is not found
class CacheException extends AppException {
  const CacheException({
    String message = 'Cached data not found',
  }) : super(message: message);
}

/// Thrown when authentication fails (401)
class UnauthorizedException extends AppException {
  const UnauthorizedException({
    String message = 'Unauthorized. Please login again.',
  }) : super(message: message, statusCode: 401);
}

/// Thrown when access is forbidden (403)
class ForbiddenException extends AppException {
  const ForbiddenException({
    String message = 'Access forbidden',
  }) : super(message: message, statusCode: 403);
}

/// Thrown when resource is not found (404)
class NotFoundException extends AppException {
  const NotFoundException({
    String message = 'Resource not found',
  }) : super(message: message, statusCode: 404);
}

/// Thrown when request timeout occurs
class TimeoutException extends AppException {
  const TimeoutException({
    String message = 'Request timeout. Please try again.',
  }) : super(message: message);
}

/// Thrown for validation errors (400)
class ValidationException extends AppException {
  final Map<String, dynamic>? errors;

  const ValidationException({
    String message = 'Validation failed',
    this.errors,
  }) : super(message: message, statusCode: 400);
}
