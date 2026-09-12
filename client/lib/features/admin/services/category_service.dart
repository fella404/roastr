import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_service.dart';
import '../models/category_model.dart';

class CategoryService {
  final ApiService _api;

  CategoryService(this._api);

  Future<CategoryListResponse> getCategories({
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
        ? '${ApiConstants.categories}/search'
        : ApiConstants.categories;

    final response = await _api.get(endpoint, queryParams: queryParams);
    return CategoryListResponse.fromJson(response);
  }

  Future<Category> getCategory(String id) async {
    final response = await _api.get('${ApiConstants.categories}/$id');
    return Category.fromJson(response);
  }

  Future<void> createCategory({
    required String name,
    required String icon,
  }) async {
    await _api.post(
      ApiConstants.categories,
      body: {'name': name, 'icon': icon},
    );
  }

  Future<void> updateCategory({
    required String id,
    required String name,
    required String icon,
  }) async {
    await _api.put(
      '${ApiConstants.categories}/$id',
      body: {'name': name, 'icon': icon},
    );
  }

  Future<void> deleteCategory(String id) async {
    await _api.delete('${ApiConstants.categories}/$id');
  }
}
