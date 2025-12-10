import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

/// Wrapper around FlutterSecureStorage
///
/// WHY: Abstraction provides:
/// 1. Easy to mock in tests
/// 2. Single place to configure storage options
/// 3. Can switch underlying storage implementation if needed
/// 4. Type-safe key-value access
///
/// WHY SECURE STORAGE for tokens:
/// 1. Encrypted storage on both iOS (Keychain) and Android (KeyStore)
/// 2. Not accessible by other apps
/// 3. Survives app reinstalls (configurable)
@lazySingleton
class SecureStorage {
  final FlutterSecureStorage _storage;

  SecureStorage(this._storage);

  /// Read value from secure storage
  Future<String?> read(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      return null;
    }
  }

  /// Write value to secure storage
  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  /// Delete value from secure storage
  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  /// Delete all values from secure storage
  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }

  /// Check if key exists
  Future<bool> containsKey(String key) async {
    return await _storage.containsKey(key: key);
  }
}
