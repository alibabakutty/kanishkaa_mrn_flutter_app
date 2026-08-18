
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile_app/features/service/auth_storage_service.dart';

class ApiService {
  static final String _baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:9090';

  static VoidCallback? onSessionInvalidated;

  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    )
  );

  static bool _initialized = false;
  static bool _handling401 = false;

  static void init(){
    if (_initialized) return;
    _initialized = true;

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await AuthStorageService.getToken();

          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          handler.next(options);
        },
        onError:(error, handler) async {
          final statusCode = error.response?.statusCode;
          final path = error.requestOptions.path;

          final isAuthCall = path.contains('/api/auth/login') || path.contains('/api/auth/logout');

          if (statusCode == 401 && !isAuthCall && !_handling401) {
            _handling401 = true;
            await AuthStorageService.logout();
            onSessionInvalidated?.call();
            _handling401 = false;
          }
          handler.next(error);
        },
      )
    );
    _dio.interceptors.add(
      LogInterceptor(requestBody: true, responseBody: true)
    );
  }

  static Future<Response> authorizedGet(String path) async {
    return await _dio.get(path);
  }

  static Future<Response> authorizedPost(String path, {dynamic body, Map<String, dynamic>? queryParameters}) async {
    return await _dio.post(path, data: body, queryParameters: queryParameters);
  }

  static Future<Response> authorizedPut(String path, dynamic body) async {
    return await _dio.put(path, data: body);
  }

  static Future<Response> post(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    return await _dio.post(path, data: data, queryParameters: queryParameters);
  }

  // GET sites
  Future<List<Map<String, dynamic>>> fetchSites() async {
    try{
      final response = await _dio.get('/api/v1/site-name-masters');

      // Dio automatically decodes JSON responses
      final List<dynamic> data = response.data;
      return data.cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  // GET Inventory Items
  Future<List<Map<String, dynamic>>> fetchInventory() async {
    try {
      final response = await _dio.get('/api/v1/inventory-masters');
      
      final List<dynamic> data = response.data;
      return data.cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  // Helper method for readable error messages
  String _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return "Connection timed out. Check server connection.";
      case DioExceptionType.badResponse:
        return "Server error: ${error.response?.statusCode}";
      case DioExceptionType.connectionError:
        return "Cannot connect to server at ${_dio.options.baseUrl}";
      default:
        return "An unexpected network error occurred.";
    }
  }
}