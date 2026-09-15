import 'category_model.dart';

class UserManage {
  final String id;
  final String name;
  final String email;
  final String role;
  final bool isActive;
  final String? profileImage;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserManage({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.isActive = true,
    this.profileImage,
    this.createdAt,
    this.updatedAt,
  });

  factory UserManage.fromJson(Map<String, dynamic> json) {
    return UserManage(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'CASHIER',
      isActive: json['isActive'] ?? true,
      profileImage: json['profileImage'],
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null,
    );
  }

  String getInitials() {
    if (name.isEmpty) return '?';
    final words = name.trim().split(RegExp(r'\s+'));
    if (words.length == 1) {
      return words[0][0].toUpperCase();
    } else if (words.length == 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    } else {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
  }

  String getRoleDisplayName() {
    if (role == 'ADMIN') return 'Admin';
    return 'Cashier';
  }
}

class UserManageListResponse {
  final List<UserManage> data;
  final PaginationMeta pagination;

  const UserManageListResponse({
    required this.data,
    required this.pagination,
  });

  factory UserManageListResponse.fromJson(Map<String, dynamic> json) {
    return UserManageListResponse(
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => UserManage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      pagination: PaginationMeta.fromJson(
          json['pagination'] as Map<String, dynamic>? ?? {}),
    );
  }
}
