import 'package:flutter/material.dart';
import 'package:shain/core/theme/app_colors.dart';
import 'package:shain/core/theme/app_spacing.dart';
import 'package:shain/core/theme/app_text_styles.dart';
import 'package:shain/shared/widgets/secondary_button.dart';

/// Tampilan state kosong dengan ikon, judul, deskripsi, dan tombol aksi opsional.
class EmptyView extends StatelessWidget {
  const EmptyView({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.menu_book_rounded,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.pageHorizontal,
          vertical: AppSpacing.s32,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.s24),
              decoration: const BoxDecoration(
                color: AppColors.surfaceSunken,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: AppSpacing.s48,
                color: AppColors.inkSubtle,
              ),
            ),
            const SizedBox(height: AppSpacing.s24),
            Text(
              title,
              style: AppTextStyles.displayH3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.s8),
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.inkMuted,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.s24),
              SecondaryButton(
                label: actionLabel!,
                onPressed: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
