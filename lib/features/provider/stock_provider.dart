import 'package:flutter/material.dart';
import 'package:mobile_app/features/model/product_model.dart';
import 'package:mobile_app/features/model/product_summary_model.dart';
import '../service/stock_service.dart';

class StockProvider extends ChangeNotifier {
  List<ProductModel> _products = [];
  List<ProductSummaryModel> _summary = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ProductModel> get products => _products;
  List<ProductSummaryModel> get summary => _summary;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Fetches your Stock from Postgre SQL via Spring Boot
  Future<void> fetchAllProducts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // Tells UI to show progress loader

    try {
      _products = await StockService.fetchStockItems();
    } catch (e) {
      _errorMessage = e.toString().replaceAll("Exception: ", "");
    } finally {
      _isLoading = false;
      notifyListeners(); // Tells UI to turn off loader and render list
    }
  }

  Future<void> fetchAllProductsSummery() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // Tells UI to show progress loader

    try {
      _summary = await StockService.fetchStockSummery();
    } catch (e) {
      _errorMessage = e.toString().replaceAll("Exception: ", "");
    } finally {
      _isLoading = false;
      notifyListeners(); // Tells UI to turn off loader and render list
    }
  }

  void clear() {
    _isLoading = false;
    _errorMessage = null;
    _products = [];
    _summary = [];
    notifyListeners();
  }
}
