import 'dart:async';
import 'package:flutter/foundation.dart';

import '../models/category_model.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';

class ProductProvider extends ChangeNotifier {
  final ProductService _service;

  List<Product> _products = [];
  PaginationMeta? _pagination;
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  String? _selectedCategoryId;
  int _currentPage = 1;
  Timer? _debounce;

  ProductProvider(this._service);

  List<Product> get products => _products;
  PaginationMeta? get pagination => _pagination;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String? get selectedCategoryId => _selectedCategoryId;
  int get currentPage => _currentPage;
  bool get hasNextPage => _pagination?.hasNextPage ?? false;
  bool get hasPreviousPage => _pagination?.hasPreviousPage ?? false;
  int get totalPages => _pagination?.totalPages ?? 0;
  int get totalItems => _pagination?.total ?? 0;

  Future<void> fetchProducts({int? page}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final targetPage = page ?? _currentPage;
      final response = await _service.getProducts(
        page: targetPage,
        search: _searchQuery.isEmpty ? null : _searchQuery,
        categoryId: _selectedCategoryId,
      );
      _products = response.data;
      _pagination = response.pagination;
      _currentPage = response.pagination.page;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void searchProducts(String query) {
    _searchQuery = query;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      fetchProducts(page: 1);
    });
  }

  void filterByCategory(String? categoryId) {
    _selectedCategoryId = categoryId;
    fetchProducts(page: 1);
  }

  void nextPage() {
    if (hasNextPage) {
      fetchProducts(page: _currentPage + 1);
    }
  }

  void previousPage() {
    if (hasPreviousPage) {
      fetchProducts(page: _currentPage - 1);
    }
  }

  Future<void> refreshProducts() async {
    await fetchProducts(page: 1);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
