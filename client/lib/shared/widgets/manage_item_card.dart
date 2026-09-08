import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class ManageItemCard extends StatelessWidget {
  final Widget content;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ManageItemCard({
    super.key,
    required this.content,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          content,
          const SizedBox(height: 16),
          const Divider(height: 1, thickness: 1, color: AppColors.border),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildActionButton(
                label: 'Edit',
                color: AppColors.greenAccent,
                onTap: onEdit,
              ),
              const SizedBox(width: 8),
              _buildActionButton(
                label: 'Delete',
                color: Colors.red,
                onTap: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
