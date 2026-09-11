import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/manage_item_card.dart';
import '../../../shared/widgets/search_bar_with_add_button.dart';
import '../providers/category_provider.dart';

class ManageCategoryPage extends StatefulWidget {
  const ManageCategoryPage({super.key});

  @override
  State<ManageCategoryPage> createState() => _ManageCategoryPageState();
}

class _ManageCategoryPageState extends State<ManageCategoryPage> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().fetchCategories();
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
      context.read<CategoryProvider>().searchCategories(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.menu), onPressed: () => Scaffold.of(context).openDrawer()),
        titleSpacing: 12,
        title: const Text(
          'Manage Category',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textBlack),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: SearchBarWithAddButton(
              hintText: 'Search category...',
              controller: _searchController,
              onChanged: _onSearchChanged,
              onAddPressed: () {
                // TODO: Implement add category
              },
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Consumer<CategoryProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.categories.isEmpty) {
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
                          onPressed: () => provider.fetchCategories(),
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

                if (provider.categories.isEmpty) {
                  return const Center(
                    child: Text('No categories found', style: TextStyle(fontSize: 14, color: AppColors.textBlackSoft)),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => provider.refreshCategories(),
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      ...provider.categories.map((category) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildCategoryItem(
                            name: category.name,
                            totalProducts: category.totalProducts,
                            onEdit: () {
                              // TODO: Implement edit category
                            },
                            onDelete: () {
                              // TODO: Implement delete category
                            },
                          ),
                        );
                      }),
                      _buildPagination(provider),
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

  Widget _buildCategoryItem({
    required String name,
    required int totalProducts,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    return ManageItemCard(
      content: Column(
        spacing: 4,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textBlack),
          ),
          Text(
            'Total: $totalProducts Product${totalProducts == 1 ? '' : 's'}',
            style: const TextStyle(fontSize: 14, color: AppColors.textBlackSoft),
          ),
        ],
      ),
      onEdit: onEdit,
      onDelete: onDelete,
    );
  }

  Widget _buildPagination(CategoryProvider provider) {
    if (provider.totalPages <= 1) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        children: [
          Text(
            'Page ${provider.currentPage} of ${provider.totalPages}  (${provider.totalItems} items)',
            style: const TextStyle(fontSize: 13, color: AppColors.textBlackSoft),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildPaginationButton(
                label: 'Prev',
                onPressed: provider.hasPreviousPage && !provider.isLoading ? () => provider.previousPage() : null,
              ),
              const SizedBox(width: 12),
              _buildPaginationButton(
                label: 'Next',
                onPressed: provider.hasNextPage && !provider.isLoading ? () => provider.nextPage() : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationButton({required String label, required VoidCallback? onPressed}) {
    return SizedBox(
      width: 100,
      height: 40,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.greenAccent,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.greenAccent.withValues(alpha: 0.4),
          disabledForegroundColor: Colors.white70,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
        child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      ),
    );
  }
}
