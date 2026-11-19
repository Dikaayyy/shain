import 'package:flutter/material.dart';
import 'package:shain/core/theme/app_colors.dart';
import 'package:shain/core/theme/app_spacing.dart';
import 'package:shain/features/course/presentation/widgets/video_player_controls.dart';
import 'package:shain/features/course/presentation/widgets/video_status_overlay.dart';
import 'package:video_player/video_player.dart';

/// Viewport video 16:9 yang menggabungkan layer VideoPlayer, kontrol, dan overlay status.
class LessonVideoViewport extends StatelessWidget {
  const LessonVideoViewport({
    super.key,
    required this.controller,
    required this.hasInitError,
    required this.onRetry,
  });

  final VideoPlayerController? controller;
  final bool hasInitError;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final activeController = controller;

    return AspectRatio(
      aspectRatio: AppSpacing.thumbnailAspectRatio,
      child: ColoredBox(
        color: AppColors.ink,
        child: activeController == null
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.sky),
              )
            : Stack(
                fit: StackFit.expand,
                children: [
                  if (activeController.value.isInitialized &&
                      !activeController.value.hasError &&
                      !hasInitError)
                    Center(
                      child: AspectRatio(
                        aspectRatio: activeController.value.aspectRatio > 0
                            ? activeController.value.aspectRatio
                            : AppSpacing.thumbnailAspectRatio,
                        child: VideoPlayer(activeController),
                      ),
                    ),
                  VideoPlayerControls(
                    controller: activeController,
                    hasInitError: hasInitError,
                  ),
                  VideoStatusOverlay(
                    controller: activeController,
                    hasInitError: hasInitError,
                    onRetry: onRetry,
                  ),
                ],
              ),
      ),
    );
  }
}
