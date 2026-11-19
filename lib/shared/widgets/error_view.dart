import 'package:flutter/material.dart';
import 'package:shain/core/constants/app_strings.dart';
import 'package:shain/core/network/app_exception.dart';
import 'package:shain/core/theme/app_colors.dart';
import 'package:shain/core/theme/app_spacing.dart';
import 'package:shain/core/theme/app_text_styles.dart';
import 'package:shain/shared/widgets/primary_button.dart';

/// Tampilan state error dengan ikon coral, judul, pesan ramah, dan tombol coba lagi.
class ErrorView extends StatelessWidget {
  const ErrorView({
    super.key,
    required this.title,
    required this.message,
    required this.onRetry,
    this.icon = Icons.wifi_off_rounded,
    this.retryLabel = AppStrings.retryButton,
  });

  factory ErrorView.fromError({
    Key? key,
    required Object error,
    required VoidCallback onRetry,
  }) {
    final exception = error is AppException ? error : AppException.unknown();
    return ErrorView(
      key: key,
      icon: iconForType(exception.type),
      title: exception.title,
      message: exception.message,
      onRetry: onRetry,
    );
  }

  static IconData iconForType(AppExceptionType type) {
    switch (type) {
      case AppExceptionType.network:
        return Icons.wifi_off_rounded;
      case AppExceptionType.server:
        return Icons.cloud_off_rounded;
      case AppExceptionType.unknown:
        return Icons.error_outline_rounded;
    }
  }

  final String title;
  final String message;
  final VoidCallback onRetry;
  final IconData icon;
  final String retryLabel;

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
                color: AppColors.coralSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: AppSpacing.s48,
                color: AppColors.coral,
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
            const SizedBox(height: AppSpacing.s24),
            PrimaryButton(
              label: retryLabel,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
