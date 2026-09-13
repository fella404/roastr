import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_service.dart';
import '../models/product_model.dart';

class ProductService {
  final ApiService _api;

  ProductService(this._api);

  Future<ProductListResponse> getProducts({
    int page = 1,
    int limit = 10,
    String? search,
    String? categoryId,
  }) async {
    final queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
      if (categoryId != null && categoryId.isNotEmpty) 'categoryId': categoryId,
      if (search != null && search.isNotEmpty) 'search': search,
    };

    final endpoint = search != null && search.isNotEmpty
        ? '${ApiConstants.products}/search'
        : ApiConstants.products;

    final response = await _api.get(endpoint, queryParams: queryParams);
    return ProductListResponse.fromJson(response);
  }

  Future<Product> getProduct(String id) async {
    final response = await _api.get('${ApiConstants.products}/$id');
    return Product.fromJson(response);
  }
}
