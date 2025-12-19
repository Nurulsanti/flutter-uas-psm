import 'package:flutter/material.dart';
import '../models/dashboard_metrics.dart';
import '../services/api_service.dart';

class DashboardProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  DashboardMetrics? _metrics;
  List<CategorySales> _categorySales = [];
  List<TopProduct> _topProducts = [];
  List<MonthlySales> _monthlySales = [];
  bool _isLoading = false;
  String? _error;
  
  DashboardMetrics? get metrics => _metrics;
  List<CategorySales> get categorySales => _categorySales;
  List<TopProduct> get topProducts => _topProducts;
  List<MonthlySales> get monthlySales => _monthlySales;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  Future<void> fetchDashboardData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Fetch all dashboard data in parallel
      final results = await Future.wait([
        _apiService.getDashboardSummary(),
        _apiService.getSalesByCategory(),
        _apiService.getTopProducts(),
        _apiService.getMonthlyTrend(),
      ]);
      
      _metrics = results[0] as DashboardMetrics;
      _categorySales = results[1] as List<CategorySales>;
      _topProducts = results[2] as List<TopProduct>;
      _monthlySales = results[3] as List<MonthlySales>;
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
