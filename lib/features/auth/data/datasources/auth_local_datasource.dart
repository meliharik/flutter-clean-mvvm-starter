import 'dart:convert';

import 'package:flutter_clean_mvvm_starter/core/constants/app_constants.dart';
import 'package:flutter_clean_mvvm_starter/core/storage/local_storage.dart';
import 'package:flutter_clean_mvvm_starter/core/storage/secure_storage.dart';
import 'package:flutter_clean_mvvm_starter/features/auth/data/models/user_model.dart';
import 'package:injectable/injectable.dart';

/// Local data source for authentication
///
/// WHY LOCAL DATASOURCE:
/// 1. Cache user data (avoid unnecessary API calls)
/// 2. Check auth state offline
/// 3. Faster app startup (don't wait for API)
///
/// CACHING STRATEGY:
/// - Store user data in SharedPreferences
/// - Check token in SecureStorage
/// - Repository decides when to use cache vs API
abstract class AuthLocalDataSource {
  Future<UserModel?> getCachedUser();
  Future<void> cacheUser(UserModel user);
  Future<void> clearCachedUser();
  Future<bool> hasValidToken();
}

@LazySingleton(as: AuthLocalDataSource)
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final LocalStorage _localStorage;
  final SecureStorage _secureStorage;

  AuthLocalDataSourceImpl(this._localStorage, this._secureStorage);

  @override
  Future<UserModel?> getCachedUser() async {
    final userJson = _localStorage.getString(AppConstants.userDataKey);

    if (userJson == null) return null;

    try {
      final userMap = json.decode(userJson) as Map<String, dynamic>;
      return UserModel.fromJson(userMap);
    } catch (_) {
      // Invalid cached data, return null
      return null;
    }
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    final userJson = json.encode(user.toJson());
    await _localStorage.setString(AppConstants.userDataKey, userJson);
  }

  @override
  Future<void> clearCachedUser() async {
    await _localStorage.remove(AppConstants.userDataKey);
  }

  @override
  Future<bool> hasValidToken() async {
    final token = await _secureStorage.read(AppConstants.accessTokenKey);
    return token != null && token.isNotEmpty;
  }
}
