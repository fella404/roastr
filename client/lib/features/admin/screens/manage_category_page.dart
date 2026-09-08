import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/manage_item_card.dart';
import '../../../shared/widgets/search_bar_with_add_button.dart';

class ManageCategoryPage extends StatelessWidget {
  const ManageCategoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
        titleSpacing: 12,
        title: const Text(
          'Manage Category',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textBlack,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            SearchBarWithAddButton(
              hintText: 'Search category...',
              onAddPressed: () {
                // TODO: Implement add category
              },
            ),
            const SizedBox(height: 24),
            _buildCategoryList(),
            _buildPagination(),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryList() {
    // TODO: Replace with actual data from provider
    final categories = [
      {'name': 'Coffee', 'totalProducts': 12},
      {'name': 'Non-Coffee', 'totalProducts': 8},
      {'name': 'Snacks', 'totalProducts': 5},
      {'name': 'Merchandise', 'totalProducts': 3},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: categories.map((category) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildCategoryItem(
              name: category['name'] as String,
              totalProducts: category['totalProducts'] as int,
              onEdit: () {
                // TODO: Implement edit category
              },
              onDelete: () {
                // TODO: Implement delete category
              },
            ),
          );
        }).toList(),
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
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textBlack,
            ),
          ),
          Text(
            'Total: $totalProducts Product',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textBlackSoft,
            ),
          ),
        ],
      ),
      onEdit: onEdit,
      onDelete: onDelete,
    );
  }

  Widget _buildPagination() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildPaginationButton(
            label: 'Prev',
            onPressed: () {
              // TODO: Implement previous page
            },
          ),
          const SizedBox(width: 12),
          _buildPaginationButton(
            label: 'Next',
            onPressed: () {
              // TODO: Implement next page
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 100,
      height: 40,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.greenAccent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
