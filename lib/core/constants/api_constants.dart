/// API-related constants
///
/// WHY: Centralized configuration makes it easy to:
/// 1. Switch between environments (dev, staging, prod)
/// 2. Update endpoints without searching through codebase
/// 3. Maintain consistent API versioning
class ApiConstants {
  ApiConstants._(); // Private constructor to prevent instantiation

  // Base URLs for different environments
  static const String baseUrlDev = 'https://api-dev.yourapp.com';
  static const String baseUrlStaging = 'https://api-staging.yourapp.com';
  static const String baseUrlProd = 'https://api.yourapp.com';

  // Current environment (change based on build configuration)
  static const String baseUrl = baseUrlDev;

  // API Versioning
  static const String apiVersion = '/api/v1';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Auth Endpoints
  static const String login = '$apiVersion/auth/login';
  static const String register = '$apiVersion/auth/register';
  static const String logout = '$apiVersion/auth/logout';
  static const String refreshToken = '$apiVersion/auth/refresh';
  static const String me = '$apiVersion/auth/me';

  // Example: Other feature endpoints
  static const String users = '$apiVersion/users';
  static const String profile = '$apiVersion/profile';
}
