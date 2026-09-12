import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/category_icons.dart';

class CategoryChipData {
  final String id;
  final String name;
  final String iconKey;

  const CategoryChipData({required this.id, required this.name, required this.iconKey});
}

class CategoryFilterChips extends StatelessWidget {
  final List<CategoryChipData> categories;
  final String? selectedCategoryId;
  final ValueChanged<String?> onCategorySelected;

  const CategoryFilterChips({super.key, required this.categories, required this.selectedCategoryId, required this.onCategorySelected});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 88,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildChip(icon: Icons.apps, label: 'All', isSelected: selectedCategoryId == null, onTap: () => onCategorySelected(null)),
          ...categories.map((category) {
            return _buildChip(
              icon: CategoryIcons.getIcon(category.iconKey) ?? Icons.fastfood,
              label: category.name,
              isSelected: selectedCategoryId == category.id,
              onTap: () => onCategorySelected(category.id),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildChip({required IconData icon, required String label, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.white,
                border: Border.all(color: isSelected ? AppColors.greenAccent : Colors.transparent, width: 2),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), spreadRadius: 0, blurRadius: 12, offset: Offset(2, 4))],
              ),
              child: Icon(icon, size: 24, color: isSelected ? AppColors.greenAccent : AppColors.textBlackSoft),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? AppColors.textBlack : AppColors.textBlackSoft,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
