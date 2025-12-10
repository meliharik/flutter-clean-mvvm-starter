import 'package:flutter_clean_mvvm_starter/core/error/exceptions.dart';
import 'package:flutter_clean_mvvm_starter/core/error/failures.dart';
import 'package:flutter_clean_mvvm_starter/core/types/typedefs.dart';
import 'package:flutter_clean_mvvm_starter/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:flutter_clean_mvvm_starter/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:flutter_clean_mvvm_starter/features/auth/domain/entities/user.dart';
import 'package:flutter_clean_mvvm_starter/features/auth/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

/// Repository implementation - Data layer
///
/// CRITICAL ROLE IN CLEAN ARCHITECTURE:
/// This is where the magic happens - converting exceptions to failures!
///
/// FLOW:
/// 1. Presentation calls UseCase
/// 2. UseCase calls Repository (interface)
/// 3. Repository calls DataSource (implementation)
/// 4. DataSource throws Exception (network error, 401, etc.)
/// 5. Repository CATCHES exception and converts to Failure
/// 6. Repository returns Either<Failure, Data>
/// 7. Presentation handles success/failure with pattern matching
///
/// WHY THIS PATTERN:
/// - Domain layer stays pure (no HTTP, no exceptions)
/// - Presentation gets type-safe errors
/// - Easy to test (mock datasources)
/// - Single place for error mapping
@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  AuthRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
  );

  @override
  FutureEither<User> login({
    required String email,
    required String password,
  }) async {
    try {
      // Call remote datasource
      final userModel = await _remoteDataSource.login(
        email: email,
        password: password,
      );

      // Cache user locally for offline access
      await _localDataSource.cacheUser(userModel);

      // Convert model to entity and return success
      return Right(userModel.toEntity());
    } on AppException catch (e) {
      // Convert exception to failure
      return Left(_mapExceptionToFailure(e));
    } catch (e) {
      // Unexpected error
      return Left(Failure.unexpected(message: e.toString()));
    }
  }

  @override
  FutureEither<User> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final userModel = await _remoteDataSource.register(
        email: email,
        password: password,
        name: name,
      );

      await _localDataSource.cacheUser(userModel);

      return Right(userModel.toEntity());
    } on AppException catch (e) {
      return Left(_mapExceptionToFailure(e));
    } catch (e) {
      return Left(Failure.unexpected(message: e.toString()));
    }
  }

  @override
  FutureEither<void> logout() async {
    try {
      // Call remote logout (might fail, that's ok)
      await _remoteDataSource.logout();

      // Always clear local data
      await _localDataSource.clearCachedUser();

      return const Right(null);
    } on AppException catch (e) {
      return Left(_mapExceptionToFailure(e));
    } catch (e) {
      return Left(Failure.unexpected(message: e.toString()));
    }
  }

  @override
  FutureEither<User> getCurrentUser() async {
    try {
      // Try cache first for better performance
      final cachedUser = await _localDataSource.getCachedUser();

      if (cachedUser != null) {
        return Right(cachedUser.toEntity());
      }

      // No cache, fetch from API
      final userModel = await _remoteDataSource.getCurrentUser();

      // Cache for next time
      await _localDataSource.cacheUser(userModel);

      return Right(userModel.toEntity());
    } on AppException catch (e) {
      return Left(_mapExceptionToFailure(e));
    } catch (e) {
      return Left(Failure.unexpected(message: e.toString()));
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    return _localDataSource.hasValidToken();
  }

  /// Map AppException to Failure
  ///
  /// WHY: This is the boundary between data and domain layers
  /// Exceptions (implementation detail) -> Failures (business concept)
  ///
  /// PATTERN MATCHING: Dart 3 sealed classes force exhaustive handling
  Failure _mapExceptionToFailure(AppException exception) {
    return switch (exception) {
      ServerException() => Failure.server(
          message: exception.message,
          statusCode: exception.statusCode,
        ),
      NetworkException() => Failure.network(message: exception.message),
      UnauthorizedException() => Failure.unauthorized(message: exception.message),
      ForbiddenException() => Failure.forbidden(message: exception.message),
      NotFoundException() => Failure.notFound(message: exception.message),
      TimeoutException() => Failure.timeout(message: exception.message),
      ValidationException() => Failure.validation(
          message: exception.message,
          errors: exception.errors,
        ),
      CacheException() => Failure.cache(message: exception.message),
      _ => Failure.unexpected(message: exception.message),
    };
  }
}
