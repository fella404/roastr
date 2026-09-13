import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class PaginationWidget extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final bool hasPreviousPage;
  final bool hasNextPage;
  final bool isLoading;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  const PaginationWidget({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.hasPreviousPage,
    required this.hasNextPage,
    required this.isLoading,
    this.onPrevious,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        children: [
          Text(
            'Page $currentPage of $totalPages  ($totalItems items)',
            style: const TextStyle(fontSize: 13, color: AppColors.textBlackSoft),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildButton(
                label: 'Prev',
                onPressed: hasPreviousPage && !isLoading ? onPrevious : null,
              ),
              const SizedBox(width: 12),
              _buildButton(
                label: 'Next',
                onPressed: hasNextPage && !isLoading ? onNext : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildButton({required String label, required VoidCallback? onPressed}) {
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
