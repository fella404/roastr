import 'package:flutter/foundation.dart' hide Category;

import '../models/category_model.dart';
import '../services/category_service.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryService _service;

  List<Category> _categories = [];
  PaginationMeta? _pagination;
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  int _currentPage = 1;

  CategoryProvider(this._service);

  List<Category> get categories => _categories;
  PaginationMeta? get pagination => _pagination;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  int get currentPage => _currentPage;

  bool _isCreating = false;
  bool _isUpdating = false;
  bool _isDeleting = false;

  bool get isCreating => _isCreating;
  bool get isUpdating => _isUpdating;
  bool get isDeleting => _isDeleting;
  bool get hasNextPage => _pagination?.hasNextPage ?? false;
  bool get hasPreviousPage => _pagination?.hasPreviousPage ?? false;
  int get totalPages => _pagination?.totalPages ?? 0;
  int get totalItems => _pagination?.total ?? 0;

  Future<void> fetchCategories({int? page}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final targetPage = page ?? _currentPage;
      final response = await _service.getCategories(
        page: targetPage,
        search: _searchQuery.isEmpty ? null : _searchQuery,
      );
      _categories = response.data;
      _pagination = response.pagination;
      _currentPage = response.pagination.page;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void searchCategories(String query) {
    _searchQuery = query;
    fetchCategories(page: 1);
  }

  void nextPage() {
    if (hasNextPage) {
      fetchCategories(page: _currentPage + 1);
    }
  }

  void previousPage() {
    if (hasPreviousPage) {
      fetchCategories(page: _currentPage - 1);
    }
  }

  Future<void> refreshCategories() async {
    await fetchCategories(page: 1);
  }

  Future<void> createCategory(String name, String icon) async {
    _isCreating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.createCategory(name: name, icon: icon);
      await fetchCategories(page: 1);
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isCreating = false;
      notifyListeners();
    }
  }

  Future<void> updateCategory(String id, String name, String icon) async {
    _isUpdating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.updateCategory(id: id, name: name, icon: icon);
      await fetchCategories(page: _currentPage);
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  Future<void> deleteCategory(String id) async {
    _isDeleting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.deleteCategory(id);
      await fetchCategories(page: _currentPage);
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isDeleting = false;
      notifyListeners();
    }
  }
}
