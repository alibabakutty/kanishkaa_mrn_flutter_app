import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthStorageService {
  AuthStorageService._();

  static final _storage = const FlutterSecureStorage();

  static const String _tokenKey = 'auth_token';
  static const String _userEmployeeIdKey = 'auth_userEmployeeId';
  static const String _usernameKey = 'auth_username';
  static const String _emailKey = 'auth_email';
  static const String _mobileKey = 'auth_mobile';
  static const String _roleKey = 'auth_role';
  static const String _companyKey = 'auth_company';

  // Save token + user details
  static Future<void> saveAuth({
    required String token,
    String? userEmployeeId,
    String? username,
    String? email,
    String? mobileNumber,
    String? role,
    String? company,
  }) async {
    await _storage.write(key: _tokenKey, value: token);
    if (userEmployeeId != null) await _storage.write(key: _userEmployeeIdKey, value: userEmployeeId);
    if (username != null) await _storage.write(key: _usernameKey, value: username);
    if (email != null) await _storage.write(key: _emailKey, value: email);
    if (mobileNumber != null) await _storage.write(key: _mobileKey, value: mobileNumber);
    if (role != null) await _storage.write(key: _roleKey, value: role);
    if (company != null) await _storage.write(key: _companyKey, value: company);
  }

  static Future<String?> getToken() async =>
      await _storage.read(key: _tokenKey);

  static Future<String?> getUserEmployeeId() async =>
      await _storage.read(key: _userEmployeeIdKey);

  static Future<String?> getUsername() async =>
      await _storage.read(key: _usernameKey);

  static Future<String?> getEmail() async =>
      await _storage.read(key: _emailKey);

  static Future<String?> getMobileNumber() async =>
      await _storage.read(key: _mobileKey);

  static Future<String?> getRole() async =>
      await _storage.read(key: _roleKey);

  static Future<String?> getCompany() async =>
      await _storage.read(key: _companyKey);

  // Clear everything on logout
  static Future<void> clearAll() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userEmployeeIdKey);
    await _storage.delete(key: _usernameKey);
    await _storage.delete(key: _emailKey);
    await _storage.delete(key: _mobileKey);
    await _storage.delete(key: _roleKey);
    await _storage.delete(key: _companyKey);
  }

  // Keep old helpers if you still use them elsewhere
  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  static Future<void> logout() async {
    await clearAll();
  }
}