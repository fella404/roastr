import 'package:flutter/material.dart';

import '../../../core/network/api_service.dart';
import '../models/auth_state.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final ApiService _api;

  AuthState _authState = AuthState.initial;
  User? _user;
  String? _errorMessage;
  String? _sessionExpiredMessage;

  AuthProvider(this._authService, this._api) {
    _api.onError = _handleApiError;
  }

  AuthState get authState => _authState;
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  String? get sessionExpiredMessage => _sessionExpiredMessage;
  bool get isLoading => _authState == AuthState.loading;
  bool get isAuthenticated => _authState == AuthState.authenticated;

  void _setState(AuthState state, {String? error}) {
    _authState = state;
    _errorMessage = error;
    notifyListeners();
  }

  void _handleApiError(ApiException error) {
    if (error.statusCode == 403) {
      handleAccountDeactivated();
    }
  }

  void clearSessionExpiredMessage() {
    _sessionExpiredMessage = null;
    notifyListeners();
  }

  Future<void> checkAuthStatus() async {
    try {
      final user = await _authService.getCurrentUser();
      _user = user;
      _setState(AuthState.authenticated);
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        await _authService.logout();
        _user = null;
        _sessionExpiredMessage =
            'Your session has expired. Please log in again.';
        _setState(AuthState.unauthenticated);
      } else {
        _setState(AuthState.unauthenticated);
      }
    } catch (_) {
      _user = null;
      _setState(AuthState.unauthenticated);
    }
  }

  Future<void> handleAccountDeactivated() async {
    await _authService.logout();
    _user = null;
    _errorMessage = 'Your account has been deactivated.';
    _setState(AuthState.unauthenticated);
  }

  Future<bool> login(String email, String password) async {
    _setState(AuthState.loading);

    try {
      final response = await _authService.login(email, password);
      _user = response.user;
      _setState(AuthState.authenticated);
      return true;
    } on ApiException catch (e) {
      _setState(AuthState.error, error: e.message);
      return false;
    } catch (_) {
      _setState(AuthState.error, error: 'An error occurred, please try again');
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    _setState(AuthState.unauthenticated);
  }
}
