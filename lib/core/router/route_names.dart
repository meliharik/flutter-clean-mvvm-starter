/// Type-safe route names
///
/// WHY: Prevents typos and makes refactoring easier
/// Instead of '/login', use RouteNames.login
class RouteNames {
  RouteNames._();

  // Auth routes
  static const String splash = '/';
  static const String login = '/login';

  // Main routes
  static const String home = '/home';
  static const String profile = '/profile';
}
