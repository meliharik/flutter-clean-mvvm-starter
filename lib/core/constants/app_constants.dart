/// Application-wide constants
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Flutter Clean MVVM';
  static const String appVersion = '1.0.0';

  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  static const String isFirstLaunchKey = 'is_first_launch';
  static const String themeKey = 'theme_mode';

  // Validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;

  // Pagination
  static const int defaultPageSize = 20;

  // Cache Duration
  static const Duration cacheValidDuration = Duration(minutes: 5);
}
