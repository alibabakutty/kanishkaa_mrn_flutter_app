import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthStorageService {
  AuthStorageService._();

  static final _storage = const FlutterSecureStorage();

  static const String _tokenKey = 'auth_token';
  static const String _usernameKey = 'auth_username';
  static const String _emailKey = 'auth_email';
  static const String _mobileKey = 'auth_mobile';
  static const String _roleKey = 'auth_role';

  // Save token + user details
  static Future<void> saveAuth({
    required String token,
    String? username,
    String? email,
    String? mobileNumber,
    String? role,
  }) async {
    await _storage.write(key: _tokenKey, value: token);
    if (username != null) await _storage.write(key: _usernameKey, value: username);
    if (email != null) await _storage.write(key: _emailKey, value: email);
    if (mobileNumber != null) await _storage.write(key: _mobileKey, value: mobileNumber);
    if (role != null) await _storage.write(key: _roleKey, value: role);
  }

  static Future<String?> getToken() async =>
      await _storage.read(key: _tokenKey);

  static Future<String?> getUsername() async =>
      await _storage.read(key: _usernameKey);

  static Future<String?> getEmail() async =>
      await _storage.read(key: _emailKey);

  static Future<String?> getMobileNumber() async =>
      await _storage.read(key: _mobileKey);

  static Future<String?> getRole() async =>
      await _storage.read(key: _roleKey);

  // Clear everything on logout
  static Future<void> clearAll() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _usernameKey);
    await _storage.delete(key: _emailKey);
    await _storage.delete(key: _mobileKey);
    await _storage.delete(key: _roleKey);
  }

  // Keep old helpers if you still use them elsewhere
  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  static Future<void> logout() async {
    await clearAll();
  }
}