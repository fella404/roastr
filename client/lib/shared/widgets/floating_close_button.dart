import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class FloatingCloseButton extends StatelessWidget {
  final VoidCallback onTap;

  const FloatingCloseButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 296, // 280px (drawer width) + 16px
      top: 16, // Aligned with AppBar height
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.close,
            color: AppColors.textBlack,
            size: 24,
          ),
        ),
      ),
    );
  }
}