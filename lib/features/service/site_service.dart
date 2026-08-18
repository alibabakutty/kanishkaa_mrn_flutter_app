
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile_app/features/model/site_model.dart';
import 'package:mobile_app/features/service/api_service.dart';

class SiteService {
  static final String baseUrl =
      dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8080';

  static Future<List<SiteModel>> fetchSites() async {
    try {


      final response = await ApiService.authorizedGet(
        '/api/v1/site-name-masters',
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = response.data as List<dynamic>;

        return jsonData
            .map((e) => SiteModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to load customers: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('Fetch customer network error: ${e.message}');
      if (e.response?.data != null) {
        debugPrint('Server response message: ${e.response?.data}');
      }
      rethrow;
    } catch (e) {
      debugPrint('Fetch customer error: $e');
      rethrow;
    }
  }
}
