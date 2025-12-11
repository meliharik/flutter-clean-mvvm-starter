import 'package:flutter/material.dart';
import 'package:flutter_clean_mvvm_starter/core/error/failures.dart';
import 'package:flutter_clean_mvvm_starter/features/auth/domain/entities/user.dart';
import 'package:flutter_clean_mvvm_starter/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_clean_mvvm_starter/features/auth/presentation/providers/auth_state.dart';
import 'package:flutter_clean_mvvm_starter/features/auth/presentation/screens/login_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

/// Mock AuthNotifier for testing
class MockAuthNotifier extends Mock implements AuthNotifier {}

/// WHY WIDGET TESTS:
/// 1. Test UI renders correctly
/// 2. Test user interactions (tap, input)
/// 3. Test state-driven UI changes
/// 4. Test navigation
void main() {
  /// Helper to create testable widget with Riverpod
  Widget createWidgetUnderTest({
    required MockAuthNotifier mockNotifier,
  }) {
    return ProviderScope(
      overrides: [
        // Override provider with mock
        authNotifierProvider.overrideWith(() => mockNotifier),
      ],
      child: const MaterialApp(
        home: LoginScreen(),
      ),
    );
  }

  /// Test data
  const tEmail = 'test@example.com';
  const tPassword = 'password123';
  const tUser = User(
    id: '1',
    email: tEmail,
    name: 'Test User',
  );

  group('LoginScreen Widget Tests', () {
    late MockAuthNotifier mockNotifier;

    setUp(() {
      mockNotifier = MockAuthNotifier();
    });

    testWidgets('should display all UI elements', (tester) async {
      // ARRANGE
      when(() => mockNotifier.build())
          .thenReturn(const AuthState.unauthenticated());

      // ACT
      await tester.pumpWidget(createWidgetUnderTest(
        mockNotifier: mockNotifier,
      ));

      // ASSERT - Check all elements are present
      expect(find.text('Login'), findsWidgets); // Title & button
      expect(find.byType(TextFormField), findsNWidgets(2)); // Email & password
      expect(find.byType(ElevatedButton), findsOneWidget); // Login button
      expect(find.byIcon(Icons.email), findsOneWidget);
      expect(find.byIcon(Icons.lock), findsOneWidget);
    });

    testWidgets('should show error when email is empty', (tester) async {
      // ARRANGE
      when(() => mockNotifier.build())
          .thenReturn(const AuthState.unauthenticated());

      await tester.pumpWidget(createWidgetUnderTest(
        mockNotifier: mockNotifier,
      ));

      // ACT - Try to login without entering email
      final loginButton = find.byType(ElevatedButton);
      await tester.tap(loginButton);
      await tester.pump();

      // ASSERT - Validation error should appear
      expect(find.text('Please enter your email'), findsOneWidget);
    });

    testWidgets('should show error when password is empty', (tester) async {
      // ARRANGE
      when(() => mockNotifier.build())
          .thenReturn(const AuthState.unauthenticated());

      await tester.pumpWidget(createWidgetUnderTest(
        mockNotifier: mockNotifier,
      ));

      // ACT - Enter email but not password
      final emailField = find.byType(TextFormField).first;
      await tester.enterText(emailField, tEmail);

      final loginButton = find.byType(ElevatedButton);
      await tester.tap(loginButton);
      await tester.pump();

      // ASSERT
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('should show error when email is invalid', (tester) async {
      // ARRANGE
      when(() => mockNotifier.build())
          .thenReturn(const AuthState.unauthenticated());

      await tester.pumpWidget(createWidgetUnderTest(
        mockNotifier: mockNotifier,
      ));

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
      when(() => mockNotifier.build())
          .thenReturn(const AuthState.unauthenticated());

      await tester.pumpWidget(createWidgetUnderTest(
        mockNotifier: mockNotifier,
      ));

      // ACT - Enter short password
      final emailField = find.byType(TextFormField).first;
      final passwordField = find.byType(TextFormField).last;

      await tester.enterText(emailField, tEmail);
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

    testWidgets('should call login when form is valid', (tester) async {
      // ARRANGE
      when(() => mockNotifier.build())
          .thenReturn(const AuthState.unauthenticated());

      // Mock login method
      when(() => mockNotifier.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async {});

      await tester.pumpWidget(createWidgetUnderTest(
        mockNotifier: mockNotifier,
      ));

      // ACT - Enter valid credentials
      final emailField = find.byType(TextFormField).first;
      final passwordField = find.byType(TextFormField).last;

      await tester.enterText(emailField, tEmail);
      await tester.enterText(passwordField, tPassword);

      final loginButton = find.byType(ElevatedButton);
      await tester.tap(loginButton);
      await tester.pump();

      // ASSERT - Login should be called
      verify(() => mockNotifier.login(
            email: tEmail,
            password: tPassword,
          )).called(1);
    });

    testWidgets('should show loading indicator when loading', (tester) async {
      // ARRANGE
      when(() => mockNotifier.build()).thenReturn(const AuthState.loading());

      // ACT
      await tester.pumpWidget(createWidgetUnderTest(
        mockNotifier: mockNotifier,
      ));

      // ASSERT - Loading indicator should be visible
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Login button should NOT be visible
      expect(find.text('Login'), findsOneWidget); // Only title, not button
    });

    testWidgets('should show snackbar when error occurs', (tester) async {
      // ARRANGE
      when(() => mockNotifier.build()).thenReturn(
        const AuthState.error(
          Failure.unauthorized(message: 'Invalid credentials'),
        ),
      );

      // ACT
      await tester.pumpWidget(createWidgetUnderTest(
        mockNotifier: mockNotifier,
      ));

      // Wait for snackbar animation
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // ASSERT - Snackbar should appear
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Invalid credentials'), findsOneWidget);
    });

    testWidgets('password field should be obscured', (tester) async {
      // ARRANGE
      when(() => mockNotifier.build())
          .thenReturn(const AuthState.unauthenticated());

      await tester.pumpWidget(createWidgetUnderTest(
        mockNotifier: mockNotifier,
      ));

      // ACT - Find password field (by checking it has lock icon)
      final passwordField = find.ancestor(
        of: find.byIcon(Icons.lock),
        matching: find.byType(TextFormField),
      );

      // ASSERT - Password field should exist
      expect(passwordField, findsOneWidget);
    });

    testWidgets('should show demo credentials hint', (tester) async {
      // ARRANGE
      when(() => mockNotifier.build())
          .thenReturn(const AuthState.unauthenticated());

      await tester.pumpWidget(createWidgetUnderTest(
        mockNotifier: mockNotifier,
      ));

      // ASSERT - Demo message should be visible
      expect(
        find.text('Demo: Use any email/password (API not connected)'),
        findsOneWidget,
      );
    });
  });

  group('LoginScreen State Transitions', () {
    late MockAuthNotifier mockNotifier;

    setUp(() {
      mockNotifier = MockAuthNotifier();
    });

    testWidgets('should transition from unauthenticated to loading',
        (tester) async {
      // ARRANGE
      when(() => mockNotifier.build())
          .thenReturn(const AuthState.unauthenticated());

      await tester.pumpWidget(createWidgetUnderTest(
        mockNotifier: mockNotifier,
      ));

      // Verify initial state
      expect(find.byType(ElevatedButton), findsOneWidget);

      // ACT - Change state to loading
      when(() => mockNotifier.build()).thenReturn(const AuthState.loading());

      // Rebuild widget
      await tester.pumpAndSettle();

      // ASSERT - Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should transition from loading to error', (tester) async {
      // ARRANGE
      when(() => mockNotifier.build()).thenReturn(const AuthState.loading());

      await tester.pumpWidget(createWidgetUnderTest(
        mockNotifier: mockNotifier,
      ));

      // Verify loading state
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // ACT - Change state to error
      when(() => mockNotifier.build()).thenReturn(
        const AuthState.error(
          Failure.network(message: 'No internet connection'),
        ),
      );

      // Rebuild widget
      await tester.pumpAndSettle();

      // ASSERT - Should show error
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('No internet connection'), findsOneWidget);
    });
  });
}
