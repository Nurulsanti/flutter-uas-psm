class ApiConfig {
  static const String baseUrl = 'https://backend-psm-uas-production.up.railway.app/api';
  static const Duration timeout = Duration(seconds: 30);

  // Endpoint constants
  static const String products = '/products';
  static const String transactions = '/transactions';
  static const String dashboardSummary = '/dashboard/summary';
  static const String salesByCategory = '/dashboard/sales-by-category';
  static const String salesByRegion = '/dashboard/sales-by-region';
  static const String salesByState = '/dashboard/sales-by-state';
  static const String salesByCity = '/dashboard/sales-by-city';
  static const String topProducts = '/dashboard/top-products';
  static const String monthlyTrend = '/dashboard/monthly-trend';
  static const String dailyTrend = '/dashboard/daily-trend';
  static const String salesBySegment = '/dashboard/sales-by-segment';
}
