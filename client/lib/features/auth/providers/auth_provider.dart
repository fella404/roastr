import 'package:flutter/material.dart';

import '../../../core/network/api_service.dart';
import '../models/auth_state.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  AuthState _authState = AuthState.initial;
  User? _user;
  String? _errorMessage;

  AuthProvider(this._authService);

  AuthState get authState => _authState;
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _authState == AuthState.loading;
  bool get isAuthenticated => _authState == AuthState.authenticated;

  void _setState(AuthState state, {String? error}) {
    _authState = state;
    _errorMessage = error;
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
        _setState(AuthState.unauthenticated);
      } else {
        _setState(AuthState.unauthenticated);
      }
    } catch (_) {
      _user = null;
      _setState(AuthState.unauthenticated);
    }
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
      _setState(AuthState.error, error: 'Terjadi kesalahan, silakan coba lagi');
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    _setState(AuthState.unauthenticated);
  }
}
