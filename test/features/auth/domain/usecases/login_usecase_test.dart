import 'package:flutter_clean_mvvm_starter/core/error/failures.dart';
import 'package:flutter_clean_mvvm_starter/features/auth/domain/entities/user.dart';
import 'package:flutter_clean_mvvm_starter/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_clean_mvvm_starter/features/auth/domain/usecases/login_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

/// Mock repository for testing
/// WHY MOCKTAIL: Better than mockito, no code generation needed
class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  /// System Under Test (SUT)
  late LoginUseCase loginUseCase;

  /// Dependencies (Mocked)
  late MockAuthRepository mockRepository;

  /// Test data
  const tEmail = 'test@example.com';
  const tPassword = 'password123';
  const tUser = User(
    id: '1',
    email: tEmail,
    name: 'Test User',
  );

  /// Setup - runs before each test
  setUp(() {
    mockRepository = MockAuthRepository();
    loginUseCase = LoginUseCase(mockRepository);
  });

  /// Test Group: Success Cases
  group('LoginUseCase - Success Cases', () {
    test('should return User when login is successful', () async {
      // ARRANGE - Setup mock behavior
      when(() => mockRepository.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => Right(tUser));

      // ACT - Execute the use case
      final result = await loginUseCase(
        email: tEmail,
        password: tPassword,
      );

      // ASSERT - Verify results
      expect(result, const Right(tUser));

      // Verify repository was called with correct params
      verify(() => mockRepository.login(
            email: tEmail,
            password: tPassword,
          )).called(1);

      // Verify no other calls were made
      verifyNoMoreInteractions(mockRepository);
    });

    test('should pass credentials to repository unchanged', () async {
      // ARRANGE
      const customEmail = 'custom@test.com';
      const customPassword = 'custom123';

      when(() => mockRepository.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => Right(tUser));

      // ACT
      await loginUseCase(
        email: customEmail,
        password: customPassword,
      );

      // ASSERT - Verify exact parameters passed
      verify(() => mockRepository.login(
            email: customEmail,
            password: customPassword,
          )).called(1);
    });
  });

  /// Test Group: Failure Cases
  group('LoginUseCase - Failure Cases', () {
    test('should return NetworkFailure when there is no internet', () async {
      // ARRANGE
      const tFailure = Failure.network();
      when(() => mockRepository.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => const Left(tFailure));

      // ACT
      final result = await loginUseCase(
        email: tEmail,
        password: tPassword,
      );

      // ASSERT
      expect(result, const Left(tFailure));
      verify(() => mockRepository.login(
            email: tEmail,
            password: tPassword,
          )).called(1);
    });

    test('should return UnauthorizedFailure when credentials are invalid',
        () async {
      // ARRANGE
      const tFailure = Failure.unauthorized(
        message: 'Invalid email or password',
      );
      when(() => mockRepository.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => const Left(tFailure));

      // ACT
      final result = await loginUseCase(
        email: tEmail,
        password: tPassword,
      );

      // ASSERT
      expect(result, const Left(tFailure));
    });

    test('should return ServerFailure when server error occurs', () async {
      // ARRANGE
      const tFailure = Failure.server(
        message: 'Internal server error',
        statusCode: 500,
      );
      when(() => mockRepository.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => const Left(tFailure));

      // ACT
      final result = await loginUseCase(
        email: tEmail,
        password: tPassword,
      );

      // ASSERT
      expect(result, const Left(tFailure));
    });
  });

  /// Test Group: Edge Cases
  group('LoginUseCase - Edge Cases', () {
    test('should handle empty email', () async {
      // ARRANGE
      when(() => mockRepository.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => const Left(
            Failure.validation(message: 'Email cannot be empty'),
          ));

      // ACT
      final result = await loginUseCase(
        email: '',
        password: tPassword,
      );

      // ASSERT
      expect(result.isLeft(), true);
    });

    test('should handle empty password', () async {
      // ARRANGE
      when(() => mockRepository.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => const Left(
            Failure.validation(message: 'Password cannot be empty'),
          ));

      // ACT
      final result = await loginUseCase(
        email: tEmail,
        password: '',
      );

      // ASSERT
      expect(result.isLeft(), true);
    });
  });
}
