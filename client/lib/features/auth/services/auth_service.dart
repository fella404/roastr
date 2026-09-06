import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_service.dart';
import '../../../core/network/storage_service.dart';
import '../models/user_model.dart';

class AuthService {
  final ApiService _api;
  final StorageService _storage;

  AuthService(this._api, this._storage);

  Future<LoginResponse> login(String email, String password) async {
    final response = await _api.post(
      ApiConstants.login,
      body: {'email': email, 'password': password},
    );

    final loginResponse = LoginResponse.fromJson(response);
    await _storage.saveToken(loginResponse.token);
    return loginResponse;
  }

  Future<User> getCurrentUser() async {
    final response = await _api.get(ApiConstants.me);
    return User.fromJson(response);
  }

  Future<void> logout() async {
    await _storage.removeToken();
  }
}
