import 'package:flutter/material.dart';
import 'package:flutter_clean_mvvm_starter/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_clean_mvvm_starter/features/auth/presentation/providers/auth_state.dart';
import 'package:flutter_clean_mvvm_starter/features/auth/presentation/screens/login_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Fake AuthNotifier that returns a fixed state for testing
class FakeAuthNotifier extends AuthNotifier {
  final AuthState fixedState;

  FakeAuthNotifier({this.fixedState = const AuthState.unauthenticated()});

  @override
  AuthState build() => fixedState;
}

/// WHY WIDGET TESTS:
/// 1. Test UI renders correctly
/// 2. Test user interactions (tap, input)
/// 3. Test state-driven UI changes
/// 4. Test navigation
void main() {
  /// Helper to create testable widget with Riverpod
  Widget createWidgetUnderTest({AuthState? initialState}) {
    return ProviderScope(
      overrides: [
        authNotifierProvider.overrideWith(
          () => FakeAuthNotifier(
            fixedState: initialState ?? const AuthState.unauthenticated(),
          ),
        ),
      ],
      child: const MaterialApp(
        home: LoginScreen(),
      ),
    );
  }

  group('LoginScreen Widget Tests', () {
    testWidgets('should display all UI elements', (tester) async {
      // ACT
      await tester.pumpWidget(createWidgetUnderTest());

      // ASSERT - Check all elements are present
      expect(find.text('Login'), findsWidgets); // Title & button
      expect(find.byType(TextFormField), findsNWidgets(2)); // Email & password
      expect(find.byType(ElevatedButton), findsOneWidget); // Login button
      expect(find.byIcon(Icons.email), findsOneWidget);
      expect(find.byIcon(Icons.lock), findsOneWidget);
    });

    testWidgets('should show error when email is empty', (tester) async {
      // ARRANGE
      await tester.pumpWidget(createWidgetUnderTest());

      // ACT - Try to login without entering email
      final loginButton = find.byType(ElevatedButton);
      await tester.tap(loginButton);
      await tester.pump();

      // ASSERT - Validation error should appear
      expect(find.text('Please enter your email'), findsOneWidget);
    });

    testWidgets('should show error when password is empty', (tester) async {
      // ARRANGE
      await tester.pumpWidget(createWidgetUnderTest());

      // ACT - Enter email but not password
      final emailField = find.byType(TextFormField).first;
      await tester.enterText(emailField, 'test@example.com');

      final loginButton = find.byType(ElevatedButton);
      await tester.tap(loginButton);
      await tester.pump();

      // ASSERT
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('should show error when email is invalid', (tester) async {
      // ARRANGE
      await tester.pumpWidget(createWidgetUnderTest());

      // ACT - Enter invalid email
      final emailField = find.byType(TextFormField).first;
      await tester.enterText(emailField, 'invalid-email');

      final loginButton = find.byType(ElevatedButton);
      await tester.tap(loginButton);
      await tester.pump();

      // ASSERT
      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    testWidgets('should show error when password is too short', (tester) async {
      // ARRANGE
      await tester.pumpWidget(createWidgetUnderTest());

      // ACT - Enter short password
      final emailField = find.byType(TextFormField).first;
      final passwordField = find.byType(TextFormField).last;

      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passwordField, '123');

      final loginButton = find.byType(ElevatedButton);
      await tester.tap(loginButton);
      await tester.pump();

      // ASSERT
      expect(
        find.text('Password must be at least 6 characters'),
        findsOneWidget,
      );
    });

    testWidgets('should show loading indicator when state is loading',
        (tester) async {
      // ARRANGE - Create widget with loading state
      await tester.pumpWidget(
        createWidgetUnderTest(initialState: const AuthState.loading()),
      );

      // ASSERT - Loading indicator should be visible
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    // Note: SnackBar test removed because ref.listen only triggers on state CHANGES
    // In unit tests with fixed state, the listener doesn't fire
    // This is tested in integration tests where actual state changes occur

    testWidgets('should show demo credentials hint', (tester) async {
      // ARRANGE
      await tester.pumpWidget(createWidgetUnderTest());

      // ASSERT - Demo message should be visible
      expect(
        find.text('Demo: Use any email/password (API not connected)'),
        findsOneWidget,
      );
    });
  });
}
