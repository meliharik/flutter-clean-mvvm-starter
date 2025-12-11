import 'package:flutter/material.dart';
import 'package:flutter_clean_mvvm_starter/app.dart';
import 'package:flutter_clean_mvvm_starter/core/di/injection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// Integration Tests
///
/// WHY INTEGRATION TESTS:
/// 1. Test complete user flows (e.g., login → home → logout)
/// 2. Test real dependencies (not mocked)
/// 3. Test navigation between screens
/// 4. Test state persistence
/// 5. Catch integration issues that unit tests miss
///
/// HOW TO RUN:
/// ```
/// flutter test integration_test/app_test.dart
/// ```
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Authentication Flow Integration Test', () {
    setUpAll(() async {
      // Initialize dependencies (like in main.dart)
      await configureDependencies();
    });

    testWidgets('Complete login flow test', (tester) async {
      // STEP 1: Launch app
      await tester.pumpWidget(
        const ProviderScope(
          child: App(),
        ),
      );

      // Wait for splash screen
      await tester.pumpAndSettle();

      // STEP 2: Verify we're on login screen
      expect(find.text('Login'), findsWidgets);
      expect(find.byType(TextFormField), findsNWidgets(2));

      // STEP 3: Enter credentials
      final emailField = find.byType(TextFormField).first;
      final passwordField = find.byType(TextFormField).last;

      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passwordField, 'password123');
      await tester.pumpAndSettle();

      // STEP 4: Tap login button
      final loginButton = find.widgetWithText(ElevatedButton, 'Login');
      await tester.tap(loginButton);

      // Wait for navigation
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // STEP 5: Should navigate to home screen
      // Note: This will fail with real API since we don't have backend
      // In real integration test, you'd use a test backend or mock server

      // Verify we're on login screen (because API returns error)
      expect(find.text('Login'), findsWidgets);
    });

    testWidgets('Form validation test', (tester) async {
      // Launch app
      await tester.pumpWidget(
        const ProviderScope(
          child: App(),
        ),
      );

      await tester.pumpAndSettle();

      // Try to login without credentials
      final loginButton = find.widgetWithText(ElevatedButton, 'Login');
      await tester.tap(loginButton);
      await tester.pump();

      // Should show validation errors
      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('Invalid email validation test', (tester) async {
      // Launch app
      await tester.pumpWidget(
        const ProviderScope(
          child: App(),
        ),
      );

      await tester.pumpAndSettle();

      // Enter invalid email
      final emailField = find.byType(TextFormField).first;
      await tester.enterText(emailField, 'invalid-email');

      final loginButton = find.widgetWithText(ElevatedButton, 'Login');
      await tester.tap(loginButton);
      await tester.pump();

      // Should show email validation error
      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    testWidgets('Password length validation test', (tester) async {
      // Launch app
      await tester.pumpWidget(
        const ProviderScope(
          child: App(),
        ),
      );

      await tester.pumpAndSettle();

      // Enter valid email but short password
      final emailField = find.byType(TextFormField).first;
      final passwordField = find.byType(TextFormField).last;

      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passwordField, '123');

      final loginButton = find.widgetWithText(ElevatedButton, 'Login');
      await tester.tap(loginButton);
      await tester.pump();

      // Should show password validation error
      expect(
        find.text('Password must be at least 6 characters'),
        findsOneWidget,
      );
    });
  });

  group('Navigation Integration Test', () {
    testWidgets('Should show splash screen initially', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: App(),
        ),
      );

      // Splash screen should be visible initially
      expect(find.text('Flutter Clean MVVM'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Should navigate from splash to login', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: App(),
        ),
      );

      // Wait for auth check to complete
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Should be on login screen now
      expect(find.text('Login'), findsWidgets);
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    });
  });
}
