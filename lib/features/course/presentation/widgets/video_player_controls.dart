import 'package:flutter/material.dart';
import 'package:shain/core/constants/app_strings.dart';
import 'package:shain/core/theme/app_colors.dart';
import 'package:shain/core/theme/app_spacing.dart';
import 'package:shain/core/theme/app_text_styles.dart';
import 'package:shain/core/utils/duration_format.dart';
import 'package:video_player/video_player.dart';

/// Overlay kontrol pemutar video berisi tombol play/pause, seek bar, durasi, dan full screen.
class VideoPlayerControls extends StatefulWidget {
  const VideoPlayerControls({
    super.key,
    required this.controller,
    this.hasInitError = false,
    this.isFullScreen = false,
    this.onToggleFullScreen,
  });

  final VideoPlayerController controller;
  final bool hasInitError;
  final bool isFullScreen;
  final VoidCallback? onToggleFullScreen;

  @override
  State<VideoPlayerControls> createState() => _VideoPlayerControlsState();
}

class _VideoPlayerControlsState extends State<VideoPlayerControls> {
  double? _dragSeconds;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: widget.controller,
      builder: (context, value, _) {
        if (!value.isInitialized || value.hasError || widget.hasInitError) {
          return const SizedBox.shrink();
        }

        final totalSeconds = value.duration.inSeconds;
        final maxSeconds = totalSeconds > 0 ? totalSeconds.toDouble() : 1.0;
        final rawPosition = _dragSeconds ?? value.position.inSeconds.toDouble();
        final sliderValue = rawPosition.clamp(0.0, maxSeconds);
        final currentSeconds = sliderValue.round();

        return Stack(
          children: [
            if (!value.isBuffering)
              Center(
                child: Semantics(
                  button: true,
                  label: AppStrings.playPauseTooltip,
                  child: Material(
                    color: AppColors.controlSurface,
                    shape: const CircleBorder(),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () {
                        if (value.isPlaying) {
                          widget.controller.pause();
                        } else {
                          widget.controller.play();
                        }
                      },
                      child: SizedBox(
                        width: AppSpacing.playOverlayButtonSize,
                        height: AppSpacing.playOverlayButtonSize,
                        child: Icon(
                          value.isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: AppColors.ink,
                          size: AppSpacing.s32,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.transparent,
                      AppColors.scrimDark,
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.s16,
                    AppSpacing.s4,
                    AppSpacing.s16,
                    AppSpacing.s8,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: AppSpacing.minTouchTarget,
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: AppSpacing.s4,
                              activeTrackColor: AppColors.sky,
                              inactiveTrackColor: AppColors.trackInactive,
                              thumbColor: AppColors.sky,
                              overlayColor: AppColors.seekOverlay,
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: AppSpacing.seekThumbSize / 2,
                              ),
                              overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: AppSpacing.seekThumbSize,
                              ),
                            ),
                            child: Slider(
                              value: sliderValue,
                              min: 0,
                              max: maxSeconds,
                              onChangeStart: totalSeconds > 0
                                  ? (newValue) {
                                      setState(() => _dragSeconds = newValue);
                                    }
                                  : null,
                              onChanged: totalSeconds > 0
                                  ? (newValue) {
                                      setState(() => _dragSeconds = newValue);
                                    }
                                  : null,
                              onChangeEnd: totalSeconds > 0
                                  ? (newValue) {
                                      setState(() => _dragSeconds = null);
                                      widget.controller.seekTo(
                                        Duration(seconds: newValue.round()),
                                      );
                                    }
                                  : null,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s12),
                      Text(
                        AppStrings.videoTimeProgress(
                          DurationFormat.formatSeconds(currentSeconds),
                          DurationFormat.formatSeconds(totalSeconds),
                        ),
                        style: AppTextStyles.timeMono.copyWith(
                          color: AppColors.background,
                        ),
                      ),
                      if (widget.onToggleFullScreen != null) ...[
                        const SizedBox(width: AppSpacing.s4),
                        IconButton(
                          onPressed: widget.onToggleFullScreen,
                          tooltip: widget.isFullScreen
                              ? AppStrings.exitFullScreenTooltip
                              : AppStrings.enterFullScreenTooltip,
                          icon: Icon(
                            widget.isFullScreen
                                ? Icons.fullscreen_exit_rounded
                                : Icons.fullscreen_rounded,
                            color: AppColors.background,
                            size: AppSpacing.s24,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
