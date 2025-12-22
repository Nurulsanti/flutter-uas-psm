import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class DashboardProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _summary;
  List<Map<String, dynamic>> _categoryData = [];
  List<Map<String, dynamic>> _trendData = [];
  List<Map<String, dynamic>> _topProducts = [];
  List<Map<String, dynamic>> _regionData = [];
  List<Map<String, dynamic>> _salesTrend = [];
  List<Map<String, dynamic>> _segmentData = [];
  List<Map<String, dynamic>> _cityData = [];
  List<Map<String, dynamic>> _stateData = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get summary => _summary;
  List<Map<String, dynamic>> get categoryData => _categoryData;
  List<Map<String, dynamic>> get trendData => _trendData;
  List<Map<String, dynamic>> get topProducts => _topProducts;
  List<Map<String, dynamic>> get regionData => _regionData;
  List<Map<String, dynamic>> get salesTrend => _salesTrend;
  List<Map<String, dynamic>> get segmentData => _segmentData;
  List<Map<String, dynamic>> get cityData => _cityData;
  List<Map<String, dynamic>> get stateData => _stateData;

  Future<void> fetchDashboardData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Call existing methods separately
      final dashboardData = await _apiService.getDashboardSummary();
      final categories = await _apiService.getSalesByCategory();
      final topProductsList = await _apiService.getTopProducts();
      final regions = await _apiService.getSalesByRegion();
      final monthlySales = await _apiService.getMonthlyTrend();
      final segments = await _apiService.getSalesBySegment();

      // Get total products count from products API
      final productsData = await _apiService.getProducts(page: 1, perPage: 1);
      final totalProducts = productsData['total'] ?? 0;

      _summary = {
        'total_sales': dashboardData.totalSales,
        'total_categories': categories.length,
        'total_transactions': dashboardData.totalOrders,
        'total_products': totalProducts,
        'total_states': 0,
        'total_regions': regions.length,
        'avg_transaction_value': dashboardData.avgOrderValue,
      };

      _categoryData = categories
          .map((e) => {'category': e.category, 'total_sales': e.sales})
          .toList();

      _salesTrend = monthlySales
          .map((e) => {'period': e.period, 'sales': e.sales})
          .toList();

      _topProducts = topProductsList
          .map((e) => {'product_name': e.name, 'total_quantity': e.sales})
          .toList();

      _regionData = regions
          .map((e) => {'region': e.region, 'total_sales': e.sales})
          .toList();

      _segmentData = segments
          .map((e) => {'segment': e.segment, 'total_sales': e.sales})
          .toList();

      _cityData = [];
      _stateData = [];

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}
