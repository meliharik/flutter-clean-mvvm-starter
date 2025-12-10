import 'package:flutter/material.dart';
import 'package:flutter_clean_mvvm_starter/app.dart';
import 'package:flutter_clean_mvvm_starter/core/di/injection.dart';
import 'package:flutter_clean_mvvm_starter/core/utils/logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Application entry point
///
/// INITIALIZATION FLOW:
/// 1. Ensure Flutter bindings initialized
/// 2. Configure dependency injection (get_it)
/// 3. Wrap app with ProviderScope (Riverpod)
/// 4. Run app
///
/// WHY ASYNC MAIN:
/// - Need to await DI setup (SharedPreferences, etc.)
/// - Can handle initialization errors
void main() async {
  // Ensure Flutter is initialized before any async operations
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependency injection
  // WHY: Must happen before app starts to inject dependencies
  try {
    await configureDependencies();
    AppLogger.info('✅ Dependency injection configured successfully');
  } catch (e, stackTrace) {
    AppLogger.fatal('❌ Failed to configure dependencies', e, stackTrace);
    // In production, you might want to show an error screen instead of crashing
  }

  // Run app with Riverpod
  // WHY ProviderScope: Required at root for Riverpod to work
  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}
