class ApiConfig {
  static const String baseUrl = 'http://127.0.0.1:8002/api';
  static const Duration timeout = Duration(seconds: 30);

  // Endpoint constants
  static const String products = '/products';
  static const String transactions = '/transactions';
  static const String dashboardSummary = '/dashboard/summary';
  static const String salesByCategory = '/dashboard/sales-by-category';
  static const String salesByRegion = '/dashboard/sales-by-region';
  static const String topProducts = '/dashboard/top-products';
  static const String monthlyTrend = '/dashboard/monthly-trend';
}

