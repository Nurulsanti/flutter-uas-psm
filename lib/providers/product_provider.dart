import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class ProductProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  int _totalPages = 1;
  int _total = 0;
  
  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get total => _total;
  
  Future<void> fetchProducts({
    int page = 1,
    int perPage = 10,
    String? search,
    String? category,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _apiService.getProducts(
        page: page,
        perPage: perPage,
        search: search,
        category: category,
      );
      
      _products = result['products'] as List<Product>;
      _total = result['total'];
      _currentPage = result['currentPage'];
      _totalPages = result['lastPage'];
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Product?> fetchProductDetail(int id) async {
    try {
      return await _apiService.getProduct(id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
