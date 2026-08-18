import 'package:flutter/material.dart';
import 'package:mobile_app/features/model/site_model.dart';
import 'package:mobile_app/features/service/site_service.dart';


class SiteProvider extends ChangeNotifier {
  List<SiteModel> _sites = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<SiteModel> get sites => _sites;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Fetches your customers from PostgreSQL via Spring Boot
  Future<void> fetchAllSites() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // Tells UI to show progress loader

    try {
      _sites = await SiteService.fetchSites();
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
    _sites = [];
    notifyListeners();
  }
}
