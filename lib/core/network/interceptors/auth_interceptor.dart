import 'package:dio/dio.dart';
import 'package:flutter_clean_mvvm_starter/core/constants/api_constants.dart';
import 'package:flutter_clean_mvvm_starter/core/constants/app_constants.dart';
import 'package:flutter_clean_mvvm_starter/core/storage/secure_storage.dart';
import 'package:flutter_clean_mvvm_starter/core/utils/logger.dart';
import 'package:injectable/injectable.dart';

/// Interceptor for handling authentication
///
/// CRITICAL RESPONSIBILITIES:
/// 1. Append Bearer token to all authenticated requests
/// 2. Handle 401 Unauthorized responses (token expired)
/// 3. Attempt to refresh the token
/// 4. Retry the original request with new token
/// 5. Logout user if refresh fails
///
/// WHY THIS IS CRUCIAL:
/// - Without this, every API call would need manual token handling
/// - Token refresh logic is centralized (DRY principle)
/// - Seamless user experience (auto-refresh happens behind the scenes)
/// - Security: tokens are stored in SecureStorage, not in memory
///
/// TOKEN REFRESH FLOW:
/// 1. Request fails with 401
/// 2. Queue is locked (prevents multiple refresh attempts)
/// 3. Refresh token is used to get new access token
/// 4. New tokens are stored
/// 5. Original request is retried with new token
/// 6. Queue is unlocked for other pending requests
@injectable
class AuthInterceptor extends Interceptor {
  final SecureStorage _secureStorage;
  final Dio _dio;

  // Flag to prevent infinite refresh loops
  bool _isRefreshing = false;

  // Queue to hold requests while token is being refreshed
  final List<({RequestOptions options, ErrorInterceptorHandler handler})>
      _requestQueue = [];

  AuthInterceptor({
    required SecureStorage secureStorage,
    required Dio dio,
  })  : _secureStorage = secureStorage,
        _dio = dio;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // WHY: Only add token to requests that require authentication
    // Some endpoints (login, register) don't need tokens
    final requiresAuth = !_isPublicEndpoint(options.path);

    if (requiresAuth) {
      final accessToken = await _secureStorage.read(AppConstants.accessTokenKey);

      if (accessToken != null) {
        options.headers['Authorization'] = 'Bearer $accessToken';
      }
    }

    super.onRequest(options, handler);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // WHY 401 specifically: Indicates token is invalid/expired
    if (err.response?.statusCode == 401) {
      // WHY: Check if we're already refreshing to prevent concurrent refreshes
      if (!_isRefreshing) {
        _isRefreshing = true;

        try {
          // Attempt to refresh the token
          final success = await _refreshToken();

          if (success) {
            // Token refreshed successfully, retry all queued requests
            _isRefreshing = false;
            await _retryQueuedRequests();

            // Retry the original request
            final response = await _retry(err.requestOptions);
            return handler.resolve(response);
          } else {
            // Refresh failed, clear tokens and propagate error
            _isRefreshing = false;
            await _clearTokens();
            _rejectQueuedRequests(handler);
            return handler.reject(err);
          }
        } catch (e) {
          _isRefreshing = false;
          await _clearTokens();
          _rejectQueuedRequests(handler);
          return handler.reject(err);
        }
      } else {
        // Already refreshing, add to queue
        _requestQueue.add((options: err.requestOptions, handler: handler));
        return;
      }
    }

    super.onError(err, handler);
  }

  /// Attempt to refresh the access token using refresh token
  Future<bool> _refreshToken() async {
    try {
      AppLogger.info('🔄 Attempting to refresh token...');

      final refreshToken =
          await _secureStorage.read(AppConstants.refreshTokenKey);

      if (refreshToken == null) {
        AppLogger.warning('No refresh token found');
        return false;
      }

      // WHY: Create a new Dio instance to avoid infinite loop
      // (this request shouldn't trigger the interceptor)
      final refreshDio = Dio(BaseOptions(
        baseUrl: ApiConstants.baseUrl,
      ));

      final response = await refreshDio.post(
        ApiConstants.refreshToken,
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200) {
        final newAccessToken = response.data['access_token'] as String?;
        final newRefreshToken = response.data['refresh_token'] as String?;

        if (newAccessToken != null) {
          await _secureStorage.write(
            AppConstants.accessTokenKey,
            newAccessToken,
          );

          if (newRefreshToken != null) {
            await _secureStorage.write(
              AppConstants.refreshTokenKey,
              newRefreshToken,
            );
          }

          AppLogger.info('✅ Token refreshed successfully');
          return true;
        }
      }

      return false;
    } catch (e) {
      AppLogger.error('❌ Token refresh failed', e);
      return false;
    }
  }

  /// Retry a failed request with the new token
  Future<Response> _retry(RequestOptions requestOptions) async {
    final accessToken = await _secureStorage.read(AppConstants.accessTokenKey);

    final options = Options(
      method: requestOptions.method,
      headers: {
        ...requestOptions.headers,
        'Authorization': 'Bearer $accessToken',
      },
    );

    return _dio.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  /// Retry all requests that were queued during token refresh
  Future<void> _retryQueuedRequests() async {
    for (final request in _requestQueue) {
      try {
        final response = await _retry(request.options);
        request.handler.resolve(response);
      } catch (e) {
        request.handler.reject(
          DioException(
            requestOptions: request.options,
            error: e,
          ),
        );
      }
    }
    _requestQueue.clear();
  }

  /// Reject all queued requests (when refresh fails)
  void _rejectQueuedRequests(ErrorInterceptorHandler handler) {
    for (final request in _requestQueue) {
      request.handler.reject(
        DioException(
          requestOptions: request.options,
          error: 'Token refresh failed',
        ),
      );
    }
    _requestQueue.clear();
  }

  /// Clear stored tokens (on logout or refresh failure)
  Future<void> _clearTokens() async {
    await _secureStorage.delete(AppConstants.accessTokenKey);
    await _secureStorage.delete(AppConstants.refreshTokenKey);
    AppLogger.info('🔒 Tokens cleared');
  }

  /// Check if endpoint is public (doesn't require authentication)
  bool _isPublicEndpoint(String path) {
    const publicEndpoints = [
      ApiConstants.login,
      ApiConstants.register,
      ApiConstants.refreshToken,
    ];

    return publicEndpoints.any((endpoint) => path.contains(endpoint));
  }
}
