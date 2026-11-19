import 'package:flutter/material.dart';
import 'package:shain/core/theme/app_colors.dart';
import 'package:shain/core/theme/app_radius.dart';
import 'package:shain/core/theme/app_spacing.dart';
import 'package:shain/core/theme/app_text_styles.dart';

/// Label pill ringkas berlatar skySoft dengan ikon kecil dan teks metadata.
class TagPill extends StatelessWidget {
  const TagPill({
    super.key,
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s12,
        vertical: AppSpacing.s4,
      ),
      decoration: BoxDecoration(
        color: AppColors.skySoft,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: AppSpacing.s16,
            color: AppColors.sky,
          ),
          const SizedBox(width: AppSpacing.s8),
          Text(
            label,
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }
}
