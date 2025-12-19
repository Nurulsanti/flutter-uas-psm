import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/product.dart';
import '../models/transaction.dart';
import '../models/dashboard_metrics.dart';

class ApiService {
  // Get Products with pagination and search
  Future<Map<String, dynamic>> getProducts({
    int page = 1,
    int perPage = 10,
    String? search,
    String? category,
  }) async {
    try {
      var uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.products}');
      var queryParams = {
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      }

      uri = uri.replace(queryParameters: queryParams);

      final response = await http.get(uri).timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'products': (data['data'] as List)
              .map((item) => Product.fromJson(item))
              .toList(),
          'total': data['total'] ?? 0,
          'currentPage': data['current_page'] ?? 1,
          'lastPage': data['last_page'] ?? 1,
        };
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading products: $e');
    }
  }

  // Get Product Detail
  Future<Product> getProduct(int id) async {
    try {
      final response = await http
          .get(Uri.parse('${ApiConfig.baseUrl}${ApiConfig.products}/$id'))
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Product.fromJson(data['data']);
      } else {
        throw Exception('Failed to load product: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading product: $e');
    }
  }

  // Create Transaction
  Future<Transaction> createTransaction(Transaction transaction) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}${ApiConfig.transactions}'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(transaction.toJson()),
          )
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        return Transaction.fromJson(data['data']);
      } else {
        throw Exception('Failed to create transaction: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating transaction: $e');
    }
  }

  // Get Transactions
  Future<List<Transaction>> getTransactions() async {
    try {
      final response = await http
          .get(Uri.parse('${ApiConfig.baseUrl}${ApiConfig.transactions}'))
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['data'] as List)
            .map((item) => Transaction.fromJson(item))
            .toList();
      } else {
        throw Exception('Failed to load transactions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading transactions: $e');
    }
  }

  // Get Dashboard Summary - FIXED: parse flat response
  Future<DashboardMetrics> getDashboardSummary() async {
    try {
      final response = await http
          .get(Uri.parse('${ApiConfig.baseUrl}${ApiConfig.dashboardSummary}'))
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return DashboardMetrics.fromJson(data);
      } else {
        throw Exception('Failed to load dashboard: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading dashboard: $e');
    }
  }

  // Get Sales by Category - FIXED: parse array response
  Future<List<CategorySales>> getSalesByCategory() async {
    try {
      final response = await http
          .get(Uri.parse('${ApiConfig.baseUrl}${ApiConfig.salesByCategory}'))
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data as List)
            .map((item) => CategorySales(
                  category: item['category'] ?? 'Unknown',
                  sales: (item['sales'] ?? 0).toDouble(),
                ))
            .toList();
      } else {
        throw Exception('Failed to load category sales: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading category sales: $e');
    }
  }

  // Get Top Products - FIXED: parse array response
  Future<List<TopProduct>> getTopProducts() async {
    try {
      final response = await http
          .get(Uri.parse('${ApiConfig.baseUrl}${ApiConfig.topProducts}'))
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data as List)
            .map((item) => TopProduct(
                  name: item['name'] ?? 'Unknown',
                  sales: (item['sales'] ?? 0).toDouble(),
                ))
            .toList();
      } else {
        throw Exception('Failed to load top products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading top products: $e');
    }
  }

  // Get Monthly Trend - FIXED: parse array response
  Future<List<MonthlySales>> getMonthlyTrend() async {
    try {
      final response = await http
          .get(Uri.parse('${ApiConfig.baseUrl}${ApiConfig.monthlyTrend}'))
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data as List)
            .map((item) => MonthlySales(
                  period: item['period'] ?? '',
                  sales: (item['sales'] ?? 0).toDouble(),
                ))
            .toList();
      } else {
        throw Exception('Failed to load monthly trend: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading monthly trend: $e');
    }
  }
}
