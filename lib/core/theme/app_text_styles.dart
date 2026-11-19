import 'package:flutter/material.dart';
import 'package:shain/core/theme/app_colors.dart';

/// Token tipografi aplikasi Shain menggunakan font bawaan platform tanpa fontFamily.
class AppTextStyles {
  const AppTextStyles._();

  static const TextStyle displayH1 = TextStyle(
    fontSize: 32,
    height: 40 / 32,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
  );

  static const TextStyle displayH2 = TextStyle(
    fontSize: 28,
    height: 36 / 28,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
  );

  static const TextStyle displayH3 = TextStyle(
    fontSize: 24,
    height: 32 / 24,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 19,
    height: 28 / 19,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.19,
    color: AppColors.ink,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 20,
    height: 32 / 20,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.2,
    color: AppColors.ink,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 18,
    height: 28 / 18,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.18,
    color: AppColors.ink,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.16,
    color: AppColors.ink,
  );

  static const TextStyle labelButton = TextStyle(
    fontSize: 20,
    height: 24 / 20,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.2,
    color: AppColors.ink,
  );

  static const TextStyle timeMono = TextStyle(
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w500,
    fontFeatures: [FontFeature.tabularFigures()],
    color: AppColors.ink,
  );
}
