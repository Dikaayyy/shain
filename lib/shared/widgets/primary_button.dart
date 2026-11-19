import 'package:flutter/material.dart';
import 'package:shain/core/theme/app_colors.dart';
import 'package:shain/core/theme/app_radius.dart';
import 'package:shain/core/theme/app_spacing.dart';
import 'package:shain/core/theme/app_text_styles.dart';

/// Tombol aksi utama aplikasi dengan state default, pressed, disabled, dan loading.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isExpanded = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    final isDisabled = !isLoading && onPressed == null;

    return SizedBox(
      width: isExpanded ? double.infinity : null,
      height: AppSpacing.primaryButtonHeight,
      child: FilledButton(
        onPressed: isLoading ? null : onPressed,
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(
            Size(AppSpacing.minTouchTarget, AppSpacing.primaryButtonHeight),
          ),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: AppSpacing.s24),
          ),
          elevation: const WidgetStatePropertyAll(0),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (isLoading) return AppColors.skyDeep;
            if (states.contains(WidgetState.disabled)) {
              return AppColors.surfaceSunken;
            }
            if (states.contains(WidgetState.pressed)) return AppColors.sky;
            return AppColors.skyDeep;
          }),
          foregroundColor: WidgetStatePropertyAll(
            isDisabled ? AppColors.inkSubtle : AppColors.background,
          ),
          overlayColor: const WidgetStatePropertyAll(AppColors.sky),
        ),
        child: isLoading
            ? const SizedBox(
                width: AppSpacing.s24,
                height: AppSpacing.s24,
                child: CircularProgressIndicator(
                  strokeWidth: AppSpacing.borderThick,
                  color: AppColors.background,
                ),
              )
            : Text(
                label,
                style: AppTextStyles.labelButton.copyWith(
                  color: isDisabled ? AppColors.inkSubtle : AppColors.background,
                ),
              ),
      ),
    );
  }
}
