import 'package:dio/dio.dart';
import 'package:flutter_clean_mvvm_starter/core/utils/logger.dart';
import 'package:injectable/injectable.dart';

/// Interceptor for logging HTTP requests and responses
///
/// WHY: Essential for debugging and monitoring:
/// 1. See exactly what data is being sent/received
/// 2. Track API performance (response times)
/// 3. Debug authentication issues
/// 4. Monitor error responses
///
/// PRODUCTION NOTE: Consider disabling or reducing verbosity in production
/// or sending logs to a crash reporting service (Firebase Crashlytics, Sentry)
@injectable
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    AppLogger.debug(
      '┌─────────────────────────────────────────────────────────────',
    );
    AppLogger.debug('│ 🚀 REQUEST: ${options.method} ${options.uri}');
    AppLogger.debug('│ Headers: ${options.headers}');
    if (options.data != null) {
      AppLogger.debug('│ Body: ${options.data}');
    }
    AppLogger.debug(
      '└─────────────────────────────────────────────────────────────',
    );
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    AppLogger.info(
      '┌─────────────────────────────────────────────────────────────',
    );
    AppLogger.info(
      '│ ✅ RESPONSE: ${response.statusCode} ${response.requestOptions.uri}',
    );
    AppLogger.info('│ Data: ${response.data}');
    AppLogger.info(
      '└─────────────────────────────────────────────────────────────',
    );
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppLogger.error(
      '┌─────────────────────────────────────────────────────────────',
    );
    AppLogger.error(
      '│ ❌ ERROR: ${err.response?.statusCode} ${err.requestOptions.uri}',
    );
    AppLogger.error('│ Message: ${err.message}');
    if (err.response?.data != null) {
      AppLogger.error('│ Response: ${err.response?.data}');
    }
    AppLogger.error(
      '└─────────────────────────────────────────────────────────────',
    );
    super.onError(err, handler);
  }
}
