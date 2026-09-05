import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final textTheme = GoogleFonts.poppinsTextTheme().apply(
      bodyColor: AppColors.textBlack,
      displayColor: AppColors.textBlack,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.neutralWarm,
      colorScheme: const ColorScheme.light(
        primary: AppColors.starbucksGreen,
        onPrimary: AppColors.textWhite,
        secondary: AppColors.greenAccent,
        onSecondary: AppColors.textWhite,
        surface: AppColors.white,
        onSurface: AppColors.textBlack,
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.neutralWarm,
        foregroundColor: AppColors.textBlack,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textBlack,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.white,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.greenAccent,
        foregroundColor: AppColors.textWhite,
        elevation: 6,
        shape: CircleBorder(),
      ),
    );
  }
}
