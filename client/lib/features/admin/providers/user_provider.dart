import 'package:flutter/foundation.dart';

import '../models/category_model.dart';
import '../models/user_manage_model.dart';
import '../services/user_service.dart';

class UserProvider extends ChangeNotifier {
  final UserService _service;

  List<UserManage> _users = [];
  PaginationMeta? _pagination;
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  int _currentPage = 1;

  UserProvider(this._service);

  List<UserManage> get users => _users;
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

  Future<void> fetchUsers({int? page}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final targetPage = page ?? _currentPage;
      final response = await _service.getUsers(
        page: targetPage,
        search: _searchQuery.isEmpty ? null : _searchQuery,
      );
      _users = response.data;
      _pagination = response.pagination;
      _currentPage = response.pagination.page;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void searchUsers(String query) {
    _searchQuery = query;
    fetchUsers(page: 1);
  }

  void nextPage() {
    if (hasNextPage) {
      fetchUsers(page: _currentPage + 1);
    }
  }

  void previousPage() {
    if (hasPreviousPage) {
      fetchUsers(page: _currentPage - 1);
    }
  }

  Future<void> refreshUsers() async {
    await fetchUsers(page: 1);
  }

  Future<void> createUser(String name, String email, String role) async {
    _isCreating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.createUser(name: name, email: email, role: role);
      await fetchUsers(page: 1);
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isCreating = false;
      notifyListeners();
    }
  }

  Future<void> updateUser(String id, String name, String email, String role, bool isActive) async {
    _isUpdating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.updateUser(id: id, name: name, email: email, role: role, isActive: isActive);
      await fetchUsers(page: _currentPage);
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  Future<void> deleteUser(String id) async {
    _isDeleting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.deleteUser(id);
      await fetchUsers(page: _currentPage);
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isDeleting = false;
      notifyListeners();
    }
  }
}
