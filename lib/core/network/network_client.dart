import 'package:dio/dio.dart';
import 'package:flutter_clean_mvvm_starter/core/constants/api_constants.dart';
import 'package:flutter_clean_mvvm_starter/core/error/exceptions.dart';
import 'package:flutter_clean_mvvm_starter/core/network/interceptors/auth_interceptor.dart';
import 'package:flutter_clean_mvvm_starter/core/network/interceptors/logging_interceptor.dart';
import 'package:injectable/injectable.dart';

/// Generic network client wrapping Dio
///
/// WHY WRAP DIO:
/// 1. Centralized configuration (base URL, timeouts, headers)
/// 2. Centralized error handling (convert DioException to AppException)
/// 3. Easy to mock in tests (mock this class instead of Dio directly)
/// 4. Can swap HTTP client library if needed (just change this file)
/// 5. Interceptors are managed in one place
///
/// ARCHITECTURE NOTE:
/// This class is part of the DATA layer infrastructure.
/// Remote data sources will depend on this client to make API calls.
///
/// ERROR HANDLING STRATEGY:
/// - Dio throws DioException for network errors
/// - We catch these and convert to domain-agnostic AppException
/// - Repository catches AppException and converts to Failure
/// - Presentation layer receives Either<Failure, Data>
@lazySingleton
class NetworkClient {
  late final Dio _dio;

  NetworkClient({
    required AuthInterceptor authInterceptor,
    required LoggingInterceptor loggingInterceptor,
  }) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // WHY THIS ORDER:
    // 1. Logging first - see the request before auth modifies it
    // 2. Auth second - adds token to headers
    _dio.interceptors.addAll([
      loggingInterceptor,
      authInterceptor,
    ]);
  }

  /// GET request
  ///
  /// Example:
  /// ```dart
  /// final response = await networkClient.get<Map<String, dynamic>>(
  ///   '/users/123',
  ///   queryParameters: {'include': 'profile'},
  /// );
  /// ```
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response.data as T;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// POST request
  ///
  /// Example:
  /// ```dart
  /// final response = await networkClient.post<Map<String, dynamic>>(
  ///   '/auth/login',
  ///   data: {'email': 'user@example.com', 'password': 'secret'},
  /// );
  /// ```
  Future<T> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response.data as T;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT request
  Future<T> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response.data as T;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// PATCH request
  Future<T> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response.data as T;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE request
  Future<T> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response.data as T;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Convert DioException to domain-specific AppException
  ///
  /// WHY: This mapping is crucial for Clean Architecture:
  /// 1. Domain layer doesn't know about Dio (dependency inversion)
  /// 2. Exceptions are semantically meaningful (NetworkException vs "no internet")
  /// 3. Easy to add custom handling for specific status codes
  /// 4. UI can show appropriate error messages based on exception type
  AppException _handleError(DioException error) {
    switch (error.type) {
      // No internet connection
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutException();

      // No internet or connection refused
      case DioExceptionType.connectionError:
        return const NetworkException();

      // Server responded with error
      case DioExceptionType.badResponse:
        return _handleResponseError(error.response);

      // Request cancelled
      case DioExceptionType.cancel:
        return const ServerException(
          message: 'Request cancelled',
        );

      // Unknown error
      case DioExceptionType.unknown:
        if (error.message?.contains('SocketException') ?? false) {
          return const NetworkException();
        }
        return ServerException(
          message: error.message ?? 'Unknown error occurred',
        );

      default:
        return ServerException(
          message: error.message ?? 'Unexpected error occurred',
        );
    }
  }

  /// Handle HTTP response errors based on status code
  ///
  /// WHY STATUS CODE MAPPING:
  /// - 400: Validation errors (form fields, invalid input)
  /// - 401: Unauthorized (token expired, not logged in)
  /// - 403: Forbidden (logged in but no permission)
  /// - 404: Resource not found
  /// - 5xx: Server errors (backend issues)
  AppException _handleResponseError(Response? response) {
    final statusCode = response?.statusCode;
    final data = response?.data;

    // Try to extract error message from response
    String message = 'An error occurred';
    if (data is Map<String, dynamic>) {
      message = data['message'] as String? ??
          data['error'] as String? ??
          message;
    }

    switch (statusCode) {
      case 400:
        return ValidationException(
          message: message,
          errors: data is Map<String, dynamic> ? data['errors'] : null,
        );

      case 401:
        return const UnauthorizedException();

      case 403:
        return ForbiddenException(message: message);

      case 404:
        return NotFoundException(message: message);

      case 500:
      case 502:
      case 503:
        return ServerException(
          message: message,
          statusCode: statusCode,
        );

      default:
        return ServerException(
          message: message,
          statusCode: statusCode,
        );
    }
  }
}
