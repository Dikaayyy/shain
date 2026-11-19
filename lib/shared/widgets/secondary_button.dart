import 'package:flutter/material.dart';
import 'package:shain/core/theme/app_colors.dart';
import 'package:shain/core/theme/app_radius.dart';
import 'package:shain/core/theme/app_spacing.dart';
import 'package:shain/core/theme/app_text_styles.dart';

/// Tombol aksi sekunder dengan border 2px skyDeep dan tinggi minimum 56.
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isExpanded = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null;
    final foreground = isDisabled ? AppColors.inkSubtle : AppColors.skyDeep;

    return SizedBox(
      width: isExpanded ? double.infinity : null,
      height: AppSpacing.secondaryButtonHeight,
      child: OutlinedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(
            Size(AppSpacing.minTouchTarget, AppSpacing.secondaryButtonHeight),
          ),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: AppSpacing.s24),
          ),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) return AppColors.skySoft;
            return AppColors.background;
          }),
          overlayColor: const WidgetStatePropertyAll(AppColors.skySoft),
          side: WidgetStatePropertyAll(
            BorderSide(
              color: isDisabled ? AppColors.outline : AppColors.skyDeep,
              width: AppSpacing.borderThick,
            ),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelButton.copyWith(color: foreground),
        ),
      ),
    );
  }
}
