import 'package:flutter/material.dart';
import 'package:flutter_clean_mvvm_starter/core/router/app_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Root widget of the application
///
/// WHY SEPARATE FROM main.dart:
/// 1. Cleaner separation of concerns
/// 2. Easier to test
/// 3. Can have multiple app configurations (dev, prod)
class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'Flutter Clean MVVM',
      debugShowCheckedModeBanner: false,

      // Theme configuration
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          filled: true,
        ),
      ),

      // Dark theme (optional)
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),

      // Router configuration
      routerConfig: router,
    );
  }
}
