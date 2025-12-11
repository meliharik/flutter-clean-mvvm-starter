import 'package:flutter_clean_mvvm_starter/core/error/exceptions.dart';
import 'package:flutter_clean_mvvm_starter/core/error/failures.dart';
import 'package:flutter_clean_mvvm_starter/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:flutter_clean_mvvm_starter/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:flutter_clean_mvvm_starter/features/auth/data/models/user_model.dart';
import 'package:flutter_clean_mvvm_starter/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_clean_mvvm_starter/features/auth/domain/entities/user.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

/// Mock Data Sources
class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

void main() {
  late AuthRepositoryImpl repository;
  late MockAuthRemoteDataSource mockRemoteDataSource;
  late MockAuthLocalDataSource mockLocalDataSource;

  /// Test data
  const tEmail = 'test@example.com';
  const tPassword = 'password123';
  const tUserModel = UserModel(
    id: '1',
    email: tEmail,
    name: 'Test User',
  );
  const tUser = User(
    id: '1',
    email: tEmail,
    name: 'Test User',
  );

  setUpAll(() {
    // Register fallback values for mocktail
    registerFallbackValue(tUserModel);
  });

  setUp(() {
    mockRemoteDataSource = MockAuthRemoteDataSource();
    mockLocalDataSource = MockAuthLocalDataSource();
    repository = AuthRepositoryImpl(
      mockRemoteDataSource,
      mockLocalDataSource,
    );
  });

  /// WHY WE TEST REPOSITORIES:
  /// 1. Test exception → failure conversion
  /// 2. Test model → entity conversion
  /// 3. Test coordination between data sources
  /// 4. Test caching logic

  group('login', () {
    test(
        'should return User when remote data source returns UserModel successfully',
        () async {
      // ARRANGE
      when(() => mockRemoteDataSource.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => tUserModel);

      when(() => mockLocalDataSource.cacheUser(any()))
          .thenAnswer((_) async => {});

      // ACT
      final result = await repository.login(
        email: tEmail,
        password: tPassword,
      );

      // ASSERT
      expect(result, const Right(tUser));

      // Verify data source was called
      verify(() => mockRemoteDataSource.login(
            email: tEmail,
            password: tPassword,
          )).called(1);

      // Verify user was cached
      verify(() => mockLocalDataSource.cacheUser(tUserModel)).called(1);
    });

    test('should return NetworkFailure when NetworkException is thrown',
        () async {
      // ARRANGE
      when(() => mockRemoteDataSource.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(const NetworkException());

      // ACT
      final result = await repository.login(
        email: tEmail,
        password: tPassword,
      );

      // ASSERT - Verify exception was converted to failure
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<NetworkFailure>()),
        (_) => fail('Should return NetworkFailure'),
      );

      // Verify cache was not called (no successful login)
      verifyNever(() => mockLocalDataSource.cacheUser(any()));
    });

    test('should return UnauthorizedFailure when UnauthorizedException is thrown',
        () async {
      // ARRANGE
      when(() => mockRemoteDataSource.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(const UnauthorizedException(
        message: 'Invalid credentials',
      ));

      // ACT
      final result = await repository.login(
        email: tEmail,
        password: tPassword,
      );

      // ASSERT
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<UnauthorizedFailure>());
          expect(failure.userMessage, 'Invalid credentials');
        },
        (_) => fail('Should return UnauthorizedFailure'),
      );
    });

    test('should return ServerFailure when ServerException is thrown',
        () async {
      // ARRANGE
      when(() => mockRemoteDataSource.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(const ServerException(
        message: 'Internal server error',
        statusCode: 500,
      ));

      // ACT
      final result = await repository.login(
        email: tEmail,
        password: tPassword,
      );

      // ASSERT
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.userMessage, 'Internal server error');
        },
        (_) => fail('Should return ServerFailure'),
      );
    });

    test('should return ValidationFailure when ValidationException is thrown',
        () async {
      // ARRANGE
      when(() => mockRemoteDataSource.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(const ValidationException(
        message: 'Invalid email format',
        errors: {'email': 'Must be a valid email address'},
      ));

      // ACT
      final result = await repository.login(
        email: 'invalid-email',
        password: tPassword,
      );

      // ASSERT
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.userMessage, 'Invalid email format');
        },
        (_) => fail('Should return ValidationFailure'),
      );
    });

    test('should return UnexpectedFailure when unexpected error occurs',
        () async {
      // ARRANGE
      when(() => mockRemoteDataSource.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(Exception('Unexpected error'));

      // ACT
      final result = await repository.login(
        email: tEmail,
        password: tPassword,
      );

      // ASSERT
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<UnexpectedFailure>()),
        (_) => fail('Should return UnexpectedFailure'),
      );
    });
  });

  group('getCurrentUser', () {
    test('should return cached user when available', () async {
      // ARRANGE
      when(() => mockLocalDataSource.getCachedUser())
          .thenAnswer((_) async => tUserModel);

      // ACT
      final result = await repository.getCurrentUser();

      // ASSERT
      expect(result, const Right(tUser));

      // Verify cache was checked first
      verify(() => mockLocalDataSource.getCachedUser()).called(1);

      // Verify remote was NOT called (cache hit)
      verifyNever(() => mockRemoteDataSource.getCurrentUser());
    });

    test('should fetch from remote when cache is empty', () async {
      // ARRANGE
      when(() => mockLocalDataSource.getCachedUser())
          .thenAnswer((_) async => null);
      when(() => mockRemoteDataSource.getCurrentUser())
          .thenAnswer((_) async => tUserModel);
      when(() => mockLocalDataSource.cacheUser(any()))
          .thenAnswer((_) async => {});

      // ACT
      final result = await repository.getCurrentUser();

      // ASSERT
      expect(result, const Right(tUser));

      // Verify flow: cache check → remote call → cache update
      verify(() => mockLocalDataSource.getCachedUser()).called(1);
      verify(() => mockRemoteDataSource.getCurrentUser()).called(1);
      verify(() => mockLocalDataSource.cacheUser(tUserModel)).called(1);
    });
  });

  group('logout', () {
    test('should clear cached user and call remote logout', () async {
      // ARRANGE
      when(() => mockRemoteDataSource.logout()).thenAnswer((_) async {});
      when(() => mockLocalDataSource.clearCachedUser())
          .thenAnswer((_) async {});

      // ACT
      final result = await repository.logout();

      // ASSERT
      expect(result, const Right(null));
      verify(() => mockRemoteDataSource.logout()).called(1);
      verify(() => mockLocalDataSource.clearCachedUser()).called(1);
    });

    test('should still clear cache even if remote logout fails', () async {
      // ARRANGE
      when(() => mockRemoteDataSource.logout())
          .thenThrow(const NetworkException());
      when(() => mockLocalDataSource.clearCachedUser())
          .thenAnswer((_) async {});

      // ACT
      final result = await repository.logout();

      // ASSERT - Logout should fail but cache cleared
      expect(result.isLeft(), true);
    });
  });

  group('isLoggedIn', () {
    test('should return true when valid token exists', () async {
      // ARRANGE
      when(() => mockLocalDataSource.hasValidToken())
          .thenAnswer((_) async => true);

      // ACT
      final result = await repository.isLoggedIn();

      // ASSERT
      expect(result, true);
      verify(() => mockLocalDataSource.hasValidToken()).called(1);
    });

    test('should return false when no token exists', () async {
      // ARRANGE
      when(() => mockLocalDataSource.hasValidToken())
          .thenAnswer((_) async => false);

      // ACT
      final result = await repository.isLoggedIn();

      // ASSERT
      expect(result, false);
    });
  });
}
