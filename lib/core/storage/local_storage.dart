import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Wrapper around SharedPreferences
///
/// WHY: For non-sensitive data (theme preferences, onboarding status, etc.)
/// SharedPreferences is faster than SecureStorage and suitable for non-sensitive data.
@lazySingleton
class LocalStorage {
  final SharedPreferences _prefs;

  LocalStorage(this._prefs);

  // String operations
  String? getString(String key) => _prefs.getString(key);
  Future<bool> setString(String key, String value) => _prefs.setString(key, value);

  // Bool operations
  bool? getBool(String key) => _prefs.getBool(key);
  Future<bool> setBool(String key, bool value) => _prefs.setBool(key, value);

  // Int operations
  int? getInt(String key) => _prefs.getInt(key);
  Future<bool> setInt(String key, int value) => _prefs.setInt(key, value);

  // Double operations
  double? getDouble(String key) => _prefs.getDouble(key);
  Future<bool> setDouble(String key, double value) => _prefs.setDouble(key, value);

  // List operations
  List<String>? getStringList(String key) => _prefs.getStringList(key);
  Future<bool> setStringList(String key, List<String> value) => _prefs.setStringList(key, value);

  // Remove operations
  Future<bool> remove(String key) => _prefs.remove(key);
  Future<bool> clear() => _prefs.clear();

  // Check if key exists
  bool containsKey(String key) => _prefs.containsKey(key);
}
