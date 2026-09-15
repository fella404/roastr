import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_service.dart';
import '../models/user_manage_model.dart';

class UserService {
  final ApiService _api;

  UserService(this._api);

  Future<UserManageListResponse> getUsers({
    int page = 1,
    int limit = 10,
    String? search,
  }) async {
    final queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
      if (search != null && search.isNotEmpty) 'search': search,
    };

    final endpoint = search != null && search.isNotEmpty
        ? '${ApiConstants.users}/search'
        : ApiConstants.users;

    final response = await _api.get(endpoint, queryParams: queryParams);
    return UserManageListResponse.fromJson(response);
  }

  Future<UserManage> getUser(String id) async {
    final response = await _api.get('${ApiConstants.users}/$id');
    return UserManage.fromJson(response);
  }

  Future<void> createUser({
    required String name,
    required String email,
    required String role,
  }) async {
    await _api.post(
      ApiConstants.users,
      body: {'name': name, 'email': email, 'role': role},
    );
  }

  Future<void> updateUser({
    required String id,
    required String name,
    required String email,
    required String role,
    required bool isActive,
  }) async {
    await _api.put(
      '${ApiConstants.users}/$id',
      body: {'name': name, 'email': email, 'role': role, 'isActive': isActive},
    );
  }

  Future<void> deleteUser(String id) async {
    await _api.delete('${ApiConstants.users}/$id');
  }
}
