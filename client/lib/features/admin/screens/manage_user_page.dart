import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/delete_confirmation_dialog.dart';
import '../../../shared/widgets/manage_item_card.dart';
import '../../../shared/widgets/pagination_widget.dart';
import '../../../shared/widgets/search_bar_with_add_button.dart';
import '../models/user_manage_model.dart';
import '../providers/user_provider.dart';

class ManageUserPage extends StatefulWidget {
  const ManageUserPage({super.key});

  @override
  State<ManageUserPage> createState() => _ManageUserPageState();
}

class _ManageUserPageState extends State<ManageUserPage> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().fetchUsers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<UserProvider>().searchUsers(query);
    });
  }

  void _handleEdit(UserManage user) async {
    await context.push('/admin/users/edit/${user.id}');
    if (mounted) {
      context.read<UserProvider>().refreshUsers();
    }
  }

  void _handleDelete(UserManage user) async {
    showDialog(
      context: context,
      builder: (context) => DeleteConfirmationDialog(
        title: 'Deactivate User',
        message: 'Are you sure you want to deactivate this user?',
        warningMessage: "This user will not be able to login again",
        onConfirm: () async {
          try {
            await context.read<UserProvider>().deleteUser(user.id);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('User deactivated successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to deactivate user: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.menu), onPressed: () => Scaffold.of(context).openDrawer()),
        titleSpacing: 12,
        title: const Text(
          'Manage User',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textBlack),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: SearchBarWithAddButton(
              hintText: 'Search user...',
              controller: _searchController,
              onChanged: _onSearchChanged,
              onAddPressed: () async {
                await context.push('/admin/users/add');
                if (mounted) {
                  context.read<UserProvider>().refreshUsers();
                }
              },
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Consumer<UserProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.users.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.errorMessage != null) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          provider.errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 14, color: AppColors.textBlackSoft),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () => provider.fetchUsers(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.greenAccent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (provider.users.isEmpty) {
                  return const Center(
                    child: Text('No user found', style: TextStyle(fontSize: 14, color: AppColors.textBlackSoft)),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => provider.refreshUsers(),
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      ...provider.users.map((user) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildUserItem(
                            user: user,
                            onEdit: () => _handleEdit(user),
                            onDelete: () => _handleDelete(user),
                          ),
                        );
                      }),
                      PaginationWidget(
                        currentPage: provider.currentPage,
                        totalPages: provider.totalPages,
                        totalItems: provider.totalItems,
                        hasPreviousPage: provider.hasPreviousPage,
                        hasNextPage: provider.hasNextPage,
                        isLoading: provider.isLoading,
                        onPrevious: provider.previousPage,
                        onNext: provider.nextPage,
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserItem({
    required UserManage user,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    return ManageItemCard(
      content: Row(
        children: [
          _buildAvatar(user),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textBlack,
                        ),
                      ),
                      Text(
                        user.getRoleDisplayName(),
                        style: const TextStyle(fontSize: 14, color: AppColors.textBlackSoft),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(user.isActive),
              ],
            ),
          ),
        ],
      ),
      onEdit: onEdit,
      onDelete: onDelete,
    );
  }

  Widget _buildAvatar(UserManage user) {
    if (user.profileImage != null && user.profileImage!.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          '${ApiConstants.uploadsUrl}${user.profileImage}',
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildInitialAvatar(user);
          },
        ),
      );
    }
    return _buildInitialAvatar(user);
  }

  Widget _buildInitialAvatar(UserManage user) {
    return Container(
      width: 48,
      height: 48,
      decoration: const BoxDecoration(
        color: AppColors.greenAccent,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          user.getInitials(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: isActive ? Colors.green.shade700 : Colors.red.shade700,
        ),
      ),
    );
  }
}
