import 'category_model.dart';

class Product {
  final String id;
  final String name;
  final String image;
  final double price;
  final String categoryId;
  final String categoryName;
  final String categoryIcon;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Product({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    required this.categoryId,
    required this.categoryName,
    required this.categoryIcon,
    this.createdAt,
    this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final category = json['categoryId'];
    final catId = category is String ? category : (category['_id'] ?? '');
    final catName = category is Map ? (category['name'] ?? '') : '';
    final catIcon = category is Map ? (category['icon'] ?? '') : '';

    return Product(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      categoryId: catId,
      categoryName: catName,
      categoryIcon: catIcon,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null,
    );
  }
}

class ProductListResponse {
  final List<Product> data;
  final PaginationMeta pagination;

  const ProductListResponse({
    required this.data,
    required this.pagination,
  });

  factory ProductListResponse.fromJson(Map<String, dynamic> json) {
    return ProductListResponse(
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => Product.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      pagination: PaginationMeta.fromJson(
          json['pagination'] as Map<String, dynamic>? ?? {}),
    );
  }
}
