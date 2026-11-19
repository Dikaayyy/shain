import 'package:flutter/material.dart';
import 'package:shain/core/theme/app_colors.dart';
import 'package:shain/core/theme/app_radius.dart';
import 'package:shain/core/theme/app_spacing.dart';
import 'package:shain/core/theme/app_text_styles.dart';

/// Konfigurasi ThemeData global aplikasi Shain berdasarkan design tokens.
class AppTheme {
  const AppTheme._();

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.skyDeep,
        onPrimary: AppColors.background,
        secondary: AppColors.sky,
        onSecondary: AppColors.background,
        surface: AppColors.surface,
        onSurface: AppColors.ink,
        error: AppColors.coral,
        onError: AppColors.background,
        outline: AppColors.outline,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: AppTextStyles.displayH3,
      ),
      cardTheme: CardThemeData(
        color: AppColors.background,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: const BorderSide(
            color: AppColors.outline,
            width: AppSpacing.borderThin,
          ),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: AppTextStyles.displayH1,
        displayMedium: AppTextStyles.displayH2,
        displaySmall: AppTextStyles.displayH3,
        titleMedium: AppTextStyles.titleMedium,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,
        labelLarge: AppTextStyles.labelButton,
      ),
    );
  }
}
