import 'package:flutter/material.dart';
import 'package:mobile_app/features/model/mrn_model.dart';
import 'package:mobile_app/features/service/mrn_service.dart';

class MrnProvider extends ChangeNotifier {
  bool _loaded = false;
  bool isLoading = false;
  String? errorMessage;
  Map<DateTime, List<MrnModel>> _orderByDate = {};

  Map<DateTime, List<MrnModel>> get ordersByDate => _orderByDate;

  // 1. Helper to get a flat list of all orders across all dates
  List<MrnModel> get allOrders {
    return _orderByDate.values.expand((list) => list).toList();
  }

  double get totalSales {
    return allOrders.fold(0.0, (sum, order) => sum + (order.totalAmt));
    // Note: Change 'grandTotal' or 'totalAmount' to match whatever property name is inside your OrderModel
  }

  double get outstandingBalance {
    return allOrders.fold(0.0, (sum, order) {
      if (order.status.toLowerCase() == 'pending') {
        return sum + (order.totalAmt);
      }
      return sum;
    });
  }

  List<MrnModel> get recentOrders {
    // 1. Shallow copy to prevent state mutation
    final list = List<MrnModel>.from(allOrders);

    // 2. Comprehensive dual-pass sorting
    list.sort((a, b) {
      // Primary Sort: Newest Date First
      int dateCompare = b.orderDate.compareTo(a.orderDate);
      if (dateCompare != 0) return dateCompare;

      // Secondary Sort Fallback: If dates match exactly, sort by Order Number descending
      // Extract numbers from strings like "# SO/0011/26-27" -> 11
      int numA = _extractOrderNumber(a.orderNumber);
      int numB = _extractOrderNumber(b.orderNumber);

      return numB.compareTo(numA);
    });

    // 3. Take the top 5 safely
    return list.take(5).toList();
  }

  // Helper method to extract sequence IDs safely
  int _extractOrderNumber(String? orderNo) {
    try {
      // Splitting "# SO/0011/26-27" by '/' gets ["# SO", "0011", "26-27"]
      final parts = orderNo?.split('/');
      if (parts!.length > 1) {
        return int.parse(parts[1]); // Parses "0011" to 11
      }
    } catch (e) {
      debugPrint('Error parsing order number: $e');
    }
    return 0; // Fallback if string layout changes
  }

  Future<void> fetchAllOrders({bool force = false}) async {
    if (_loaded && !force) return;
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final remoteOrders = await MrnService.fetchAllOrders();
      final map = <DateTime, List<MrnModel>>{};

      for (final order in remoteOrders) {
        final key = DateTime.utc(
          order.orderDate.year,
          order.orderDate.month,
          order.orderDate.day,
        );
        map.putIfAbsent(key, () => []);
        map[key]!.add(order);
      }
      _orderByDate = map;
    } catch (e) {
      errorMessage = e.toString().replaceAll('Exception', '');
    } finally {
      _loaded = true;
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveOrder(MrnModel order) async {
    final success = await MrnService.saveOrder(order);
    if (success) {
      await fetchAllOrders(force: true);
    }
    return success;
  }

  Future<bool> updateOrder(MrnModel items) async {
    final success = await MrnService.updateOrder(items);
    if(success) {
      await fetchAllOrders(force: true);
    }
    return success;
  }

  List<MrnModel> getOrdersForDay(DateTime day) {
    final key = DateTime.utc(day.year, day.month, day.day);
    return _orderByDate[key] ?? [];
  }

  void clear() {
    _loaded = false;
    isLoading = false;
    errorMessage = null;
    _orderByDate = {};
    notifyListeners();
  }
}
