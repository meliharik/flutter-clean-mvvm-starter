import 'package:flutter_clean_mvvm_starter/core/constants/api_constants.dart';
import 'package:flutter_clean_mvvm_starter/core/constants/app_constants.dart';
import 'package:flutter_clean_mvvm_starter/core/network/network_client.dart';
import 'package:flutter_clean_mvvm_starter/core/storage/secure_storage.dart';
import 'package:flutter_clean_mvvm_starter/core/types/typedefs.dart';
import 'package:flutter_clean_mvvm_starter/features/auth/data/models/user_model.dart';
import 'package:injectable/injectable.dart';

/// Remote data source for authentication
///
/// WHY DATASOURCE ABSTRACTION:
/// 1. Repository doesn't know about HTTP, Dio, etc.
/// 2. Can have multiple datasources (Remote, Local, Mock)
/// 3. Easy to test (mock the datasource)
/// 4. Can swap API (REST -> GraphQL) without touching repository
///
/// RESPONSIBILITIES:
/// - Make HTTP requests
/// - Parse JSON responses
/// - Throw exceptions on errors
/// - NO business logic (that's in use cases)
/// - NO error conversion (that's in repository)
abstract class AuthRemoteDataSource {
  Future<UserModel> login({
    required String email,
    required String password,
  });

  Future<UserModel> register({
    required String email,
    required String password,
    required String name,
  });

  Future<void> logout();

  Future<UserModel> getCurrentUser();
}

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final NetworkClient _client;
  final SecureStorage _secureStorage;

  AuthRemoteDataSourceImpl(this._client, this._secureStorage);

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    // Make API call
    final response = await _client.post<DataMap>(
      ApiConstants.login,
      data: {
        'email': email,
        'password': password,
      },
    );

    // Extract tokens and save to secure storage
    // WHY: Tokens are needed for subsequent authenticated requests
    final accessToken = response['access_token'] as String;
    final refreshToken = response['refresh_token'] as String;

    await _secureStorage.write(AppConstants.accessTokenKey, accessToken);
    await _secureStorage.write(AppConstants.refreshTokenKey, refreshToken);

    // Parse user data from response
    final userData = response['user'] as DataMap;
    return UserModel.fromJson(userData);
  }

  @override
  Future<UserModel> register({
    required String email,
    required String password,
    required String name,
  }) async {
    final response = await _client.post<DataMap>(
      ApiConstants.register,
      data: {
        'email': email,
        'password': password,
        'name': name,
      },
    );

    // Save tokens (same as login)
    final accessToken = response['access_token'] as String;
    final refreshToken = response['refresh_token'] as String;

    await _secureStorage.write(AppConstants.accessTokenKey, accessToken);
    await _secureStorage.write(AppConstants.refreshTokenKey, refreshToken);

    final userData = response['user'] as DataMap;
    return UserModel.fromJson(userData);
  }

  @override
  Future<void> logout() async {
    // Call logout endpoint (optional - some APIs don't need this)
    try {
      await _client.post(ApiConstants.logout);
    } catch (_) {
      // Ignore errors - we'll clear tokens anyway
    }

    // Clear stored tokens
    // WHY: Even if API call fails, we want to logout locally
    await _secureStorage.delete(AppConstants.accessTokenKey);
    await _secureStorage.delete(AppConstants.refreshTokenKey);
  }

  @override
  Future<UserModel> getCurrentUser() async {
    // Fetch current user from API
    final response = await _client.get<DataMap>(ApiConstants.me);
    return UserModel.fromJson(response);
  }
}
