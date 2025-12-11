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
    super.message = 'No internet connection. Please check your network.',
  });
}

/// Thrown when cached data is not found
class CacheException extends AppException {
  const CacheException({
    super.message = 'Cached data not found',
  });
}

/// Thrown when authentication fails (401)
class UnauthorizedException extends AppException {
  const UnauthorizedException({
    super.message = 'Unauthorized. Please login again.',
  }) : super(statusCode: 401);
}

/// Thrown when access is forbidden (403)
class ForbiddenException extends AppException {
  const ForbiddenException({
    super.message = 'Access forbidden',
  }) : super(statusCode: 403);
}

/// Thrown when resource is not found (404)
class NotFoundException extends AppException {
  const NotFoundException({
    super.message = 'Resource not found',
  }) : super(statusCode: 404);
}

/// Thrown when request timeout occurs
class TimeoutException extends AppException {
  const TimeoutException({
    super.message = 'Request timeout. Please try again.',
  });
}

/// Thrown for validation errors (400)
class ValidationException extends AppException {
  final Map<String, dynamic>? errors;

  const ValidationException({
    super.message = 'Validation failed',
    this.errors,
  }) : super(statusCode: 400);
}
