import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/features/service/api_service.dart';
import 'package:mobile_app/features/service/auth_storage_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isInitializing = true;
  bool _isAuthenticated = false;
  bool _isLoading = false;

  String? _token;
  String? _username;
  String? _role;
  String? _userEmployeeId;
  String? _mobileNumber;
  String? _email;
  String? _company;

  bool get isInitializing => _isInitializing;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;

  // In AuthProvider.dart
  String get token => _token ?? '';
  String get username => _username ?? '';
  String get role => _role ?? '';
  String get userEmployeeId => _userEmployeeId ?? '';
  String get mobileNumber => _mobileNumber ?? '';
  String get email => _email ?? '';
  String get company => _company ?? '';

  Future<void> initialize() async {
    _isInitializing = true;
    notifyListeners();

    try {
      final savedToken = await AuthStorageService.getToken();

      if (savedToken == null || savedToken.isEmpty) {
        _clearUserState(notify: false);
        _isAuthenticated = false;
        return;
      }

      final savedUserEmployeeId = await AuthStorageService.getUserEmployeeId();
      final savedUsername = await AuthStorageService.getUsername();
      final savedEmail = await AuthStorageService.getEmail();
      final savedMobile = await AuthStorageService.getMobileNumber();
      final savedRole = await AuthStorageService.getRole();
      final savedCompany = await AuthStorageService.getCompany();

      _token = savedToken;
      _userEmployeeId = savedUserEmployeeId;
      _username = savedUsername;
      _email = savedEmail;
      _mobileNumber = savedMobile;
      _role = savedRole;
      _company = savedCompany;
      _isAuthenticated = true;
    } catch (e) {
      debugPrint('Initialize auth error: $e');
      _clearUserState(notify: false);
      _isAuthenticated = false;
    } finally {
      _isInitializing = false;
      notifyListeners();
    }
  }

  Future<bool> login(String username, String password) async {
  _isLoading = true;
  notifyListeners();

  try {
    final response = await ApiService.post(
      '/api/auth/login',
      data: {
        'username': username,
        'password': password,
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = Map<String, dynamic>.from(response.data);
      final token = data['token']?.toString();

      if (token != null && token.isNotEmpty) {
        final userEmployeeId = data['userEmployeeId']?.toString();
        final userUsername = data['username']?.toString();
        final email = data['email']?.toString();
        final mobileNumber = data['mobileNumber']?.toString();
        final role = data['role']?.toString();
        final company = data['company']?.toString();

        // Save token + user details
        await AuthStorageService.saveAuth(
          token: token,
          userEmployeeId: userEmployeeId,
          username: userUsername,
          email: email,
          mobileNumber: mobileNumber,
          role: role,
          company: company,
        );

        _token = token;
        _userEmployeeId = userEmployeeId;
        _username = userUsername;
        _email = email;
        _mobileNumber = mobileNumber;
        _role = role;
        _company = company;
        _isAuthenticated = true;

        notifyListeners();
        return true;
      }
    }

    return false;
  } on DioException catch (e) {
    debugPrint('Login Dio Error [${e.response?.statusCode}]: ${e.response?.data ?? e.message}');
    return false;
  } catch (e, stackTrace) {
    debugPrint('Login Error: $e');
    debugPrint('$stackTrace');
    return false;
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}

  Future<void> logout() async {
    try {
      await ApiService.authorizedPost('/api/auth/logout');
    } catch (e) {
      debugPrint('Logout error: $e');
    } finally {
      await AuthStorageService.logout();
      _clearUserState(notify: false);
      _isAuthenticated = false;
      notifyListeners();
    }
  }

  void _clearUserState({bool notify = true}) {
    _token = null;
    _username = null;
    _role = null;
    _userEmployeeId = null;
    _mobileNumber = null;
    _email = null;
    _company = null;

    if (notify) {
      notifyListeners();
    }
  }
}