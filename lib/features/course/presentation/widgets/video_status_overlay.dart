import 'package:flutter/material.dart';
import 'package:shain/core/constants/app_strings.dart';
import 'package:shain/core/theme/app_colors.dart';
import 'package:shain/core/theme/app_spacing.dart';
import 'package:shain/core/theme/app_text_styles.dart';
import 'package:shain/shared/widgets/secondary_button.dart';
import 'package:video_player/video_player.dart';

/// Overlay status pemutar video untuk kondisi loading, buffering, dan error.
class VideoStatusOverlay extends StatelessWidget {
  const VideoStatusOverlay({
    super.key,
    required this.controller,
    required this.onRetry,
    this.hasInitError = false,
  });

  final VideoPlayerController controller;
  final VoidCallback onRetry;
  final bool hasInitError;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        if (value.hasError || hasInitError) {
          return ColoredBox(
            color: AppColors.ink.withValues(alpha: 0.85),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pageHorizontal,
                  vertical: AppSpacing.s12,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: AppColors.coral,
                      size: AppSpacing.s32,
                    ),
                    const SizedBox(height: AppSpacing.s8),
                    Text(
                      AppStrings.videoErrorText,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.background,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.s12),
                    SecondaryButton(
                      label: AppStrings.retryButton,
                      onPressed: onRetry,
                      isExpanded: false,
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (!value.isInitialized) {
          return _SpinnerScrim(label: AppStrings.videoLoadingText);
        }

        if (value.isBuffering) {
          return _SpinnerScrim(label: AppStrings.videoBufferingText);
        }

        return const SizedBox.shrink();
      },
    );
  }
}

/// Scrim gelap 40% dengan indikator muat sky dan teks status video.
class _SpinnerScrim extends StatelessWidget {
  const _SpinnerScrim({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black.withValues(alpha: 0.4),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppColors.sky),
            const SizedBox(height: AppSpacing.s12),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.background,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
