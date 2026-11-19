import 'package:flutter/material.dart';
import 'package:shain/core/constants/app_strings.dart';
import 'package:shain/core/theme/app_colors.dart';
import 'package:shain/core/theme/app_spacing.dart';
import 'package:shain/core/theme/app_text_styles.dart';

/// Bilah atas halaman dengan tinggi 64, judul satu baris, dan tombol kembali opsional.
class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopBar({
    super.key,
    required this.title,
    this.onBack,
  });

  final String title;
  final VoidCallback? onBack;

  @override
  Size get preferredSize => const Size.fromHeight(AppSpacing.topBarHeight);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      child: SafeArea(
        bottom: false,
        child: Container(
          height: AppSpacing.topBarHeight,
          padding: EdgeInsets.only(
            left: onBack != null ? AppSpacing.s8 : AppSpacing.pageHorizontal,
            right: AppSpacing.pageHorizontal,
          ),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: AppColors.outline,
                width: AppSpacing.borderThin,
              ),
            ),
          ),
          child: Row(
            children: [
              if (onBack != null) ...[
                SizedBox(
                  width: AppSpacing.minTouchTarget,
                  height: AppSpacing.minTouchTarget,
                  child: IconButton(
                    onPressed: onBack,
                    tooltip: AppStrings.backButtonTooltip,
                    constraints: const BoxConstraints(
                      minWidth: AppSpacing.minTouchTarget,
                      minHeight: AppSpacing.minTouchTarget,
                    ),
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: AppColors.ink,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.s4),
              ],
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.displayH3,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
