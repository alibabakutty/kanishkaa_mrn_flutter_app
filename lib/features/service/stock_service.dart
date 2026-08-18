

import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile_app/features/model/product_summary_model.dart';
import 'package:mobile_app/features/model/product_model.dart';
import 'package:mobile_app/features/service/api_service.dart';

class StockService {

  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8080';
  
  static Future<List<ProductModel>> fetchStockItems() async {
    try {
      final response = await ApiService.authorizedGet("/api/v1/inventory-masters");


      if(response.statusCode == 200){
        final List<dynamic> jsonData = response.data as List<dynamic>;
        return jsonData
            .map((e) => ProductModel.fromJson(e as Map<String, dynamic>),
        ).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching Stocks: $e');
      return [];
    }
  }

  static Future<List<ProductSummaryModel>> fetchStockSummery() async {
    try {
      final response = await ApiService.authorizedGet("/api/v1/inventory-masters");


      if(response.statusCode == 200){
        final List<dynamic> jsonData = response.data as List<dynamic>;
        return jsonData
            .map((e) => ProductSummaryModel.fromJson(e as Map<String, dynamic>),
        ).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching Stocks: $e');
      return [];
    }
  }
}