import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test Helpers - Reusable utilities for testing
///
/// WHY: DRY principle - don't repeat yourself in every test file
class TestHelpers {
  TestHelpers._(); // Private constructor

  /// Create a Material App with Riverpod for widget testing
  ///
  /// Usage:
  /// ```dart
  /// await tester.pumpWidget(
  ///   TestHelpers.makeTestableWidget(
  ///     child: LoginScreen(),
  ///     overrides: [authProvider.overrideWith(...)]
  ///   ),
  /// );
  /// ```
  static Widget makeTestableWidget({
    required Widget child,
    List<Override> overrides = const [],
    NavigatorObserver? navigatorObserver,
  }) {
    return ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        home: child,
        navigatorObservers:
            navigatorObserver != null ? [navigatorObserver] : [],
      ),
    );
  }

  /// Wait for all animations to complete
  static Future<void> pumpAndSettleWithDelay(
    WidgetTester tester, [
    Duration? duration,
  ]) async {
    await tester.pumpAndSettle(duration ?? const Duration(milliseconds: 500));
  }

  /// Enter text and trigger rebuild
  static Future<void> enterTextAndPump(
    WidgetTester tester,
    Finder finder,
    String text,
  ) async {
    await tester.enterText(finder, text);
    await tester.pump();
  }

  /// Tap widget and wait for animation
  static Future<void> tapAndSettle(
    WidgetTester tester,
    Finder finder,
  ) async {
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  /// Verify widget exists exactly once
  static void expectSingleWidget(Finder finder) {
    expect(finder, findsOneWidget);
  }

  /// Verify widget doesn't exist
  static void expectNoWidget(Finder finder) {
    expect(finder, findsNothing);
  }

  /// Verify text appears in widget
  static void expectTextInWidget(String text) {
    expect(find.text(text), findsOneWidget);
  }

  /// Find widget by key
  static Finder findByKey(String key) {
    return find.byKey(Key(key));
  }

  /// Find widget by type
  static Finder findByType<T extends Widget>() {
    return find.byType(T);
  }
}

/// Mock Navigator Observer for testing navigation
class MockNavigatorObserver extends NavigatorObserver {
  final List<Route<dynamic>> pushedRoutes = [];
  final List<Route<dynamic>> poppedRoutes = [];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushedRoutes.add(route);
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    poppedRoutes.add(route);
    super.didPop(route, previousRoute);
  }

  void reset() {
    pushedRoutes.clear();
    poppedRoutes.clear();
  }
}
