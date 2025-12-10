import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'injection.config.dart';

/// GetIt instance - Service Locator
///
/// WHY SERVICE LOCATOR PATTERN:
/// 1. Centralized dependency management
/// 2. Easy to access dependencies from anywhere
/// 3. Simplifies testing (can register mocks)
/// 4. Lazy initialization (dependencies created only when needed)
///
/// ALTERNATIVE: Constructor injection everywhere (verbose, hard to maintain)
final getIt = GetIt.instance;

/// Initialize dependency injection
///
/// WHY @InjectableInit:
/// - Generates registration code automatically
/// - Type-safe (compile-time errors if registration fails)
/// - Reduces boilerplate (no manual registration for every class)
/// - Supports different environments (dev, prod, test)
///
/// REGISTRATION TYPES:
/// - @singleton: Created once, lives for app lifetime
/// - @lazySingleton: Created on first use, then cached
/// - @factory: New instance every time
///
/// HOW IT WORKS:
/// 1. Mark classes with @injectable/@singleton/@lazySingleton
/// 2. Run: flutter pub run build_runner build
/// 3. Generated code in injection.config.dart registers everything
/// 4. Call configureDependencies() in main()
@InjectableInit(
  initializerName: 'init', // Generated function name
  preferRelativeImports: true, // Cleaner imports
  asExtension: true, // Allows getIt.init() syntax
)
Future<void> configureDependencies() async {
  // Register third-party dependencies that don't have @injectable
  // WHY: These are from external packages, we can't annotate them
  await _registerExternalDependencies();

  // Initialize injectable (generated code)
  getIt.init();
}

/// Register dependencies from external packages
///
/// WHY ASYNC:
/// - SharedPreferences.getInstance() is async
/// - Must be initialized before app starts
Future<void> _registerExternalDependencies() async {
  // SharedPreferences - Must be initialized before use
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  // FlutterSecureStorage - No async initialization needed
  getIt.registerSingleton<FlutterSecureStorage>(
    const FlutterSecureStorage(
      aOptions: AndroidOptions(
        encryptedSharedPreferences: true, // More secure on Android
      ),
    ),
  );

  // Connectivity - Check internet connection
  getIt.registerSingleton<Connectivity>(Connectivity());

  // Dio - HTTP client (interceptors will be added by NetworkClient)
  getIt.registerSingleton<Dio>(Dio());
}

/// Reset dependencies (useful for testing)
///
/// WHY:
/// - Tests need fresh state between test cases
/// - Can register mocks after reset
Future<void> resetDependencies() async {
  await getIt.reset();
}
