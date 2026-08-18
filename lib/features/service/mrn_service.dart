import 'package:flutter/cupertino.dart';
import 'package:mobile_app/features/model/all_mrn_model.dart';
import 'package:mobile_app/features/model/mrn_model.dart';
import 'package:mobile_app/features/service/api_service.dart';

class MrnService {
  static Future<bool> saveOrder(MrnModel order) async {
    try {
      final requestBody = order.toJson();

      final response = await ApiService.authorizedPost(
        '/api/v1/orders/save/order',
        body: requestBody,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        debugPrint('Backend Error: ${response.statusCode} - ${response.data}');
        return false;
      }
    } catch (e) {
      debugPrint('Network Catch Block Exception: $e');
      return false;
    }
  }

  static Future<List<Object>> getAllOrders() async {
    try {
      final response = await ApiService.authorizedGet(
        '/api/v1/orders/all-orders',
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonMap =
            response.data as Map<String, dynamic>;

        final List<dynamic> dataList = jsonMap['data'] as List<dynamic>;
        return dataList
            .map((item) => AllMrnModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load orders: $e');
    }
  }

  static Future<List<MrnModel>> fetchAllOrders() async {
    try {
      final response = await ApiService.authorizedGet(
        '/api/v1/orders/fetch-orders',
      );

      // debugPrint('Status code: ${response.statusCode}');
      // debugPrint('Body Length: ${response.body.length}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody =
            response.data as Map<String, dynamic>;
        final List<dynamic> jsonList = responseBody['data'] ?? [];
        return jsonList
            .map((json) => MrnModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to backend: $e');
    }
  }

  static Future<bool> updateOrder(MrnModel items) async {
    final requestBody = items.toJson();
    try {
      final response = await ApiService.authorizedPut(
        '/api/v1/orders/update-order',
        requestBody,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        debugPrint('Backend Error: ${response.statusCode} - ${response.data}');
        return false;
      }
    } catch (e) {
      debugPrint('Network Catch Block Exception: $e');
      return false;
    }
  }
}
