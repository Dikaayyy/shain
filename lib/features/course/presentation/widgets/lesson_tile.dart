import 'package:flutter/material.dart';
import 'package:shain/core/constants/app_strings.dart';
import 'package:shain/core/theme/app_colors.dart';
import 'package:shain/core/theme/app_radius.dart';
import 'package:shain/core/theme/app_spacing.dart';
import 'package:shain/core/theme/app_text_styles.dart';
import 'package:shain/core/utils/duration_format.dart';
import 'package:shain/features/course/data/lesson.dart';

/// Kartu item lesson interaktif dengan state normal dan state aktif (sedang diputar).
class LessonTile extends StatelessWidget {
  const LessonTile({
    super.key,
    required this.lesson,
    this.isActive = false,
    this.onTap,
  });

  final Lesson lesson;
  final bool isActive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final formattedDuration = DurationFormat.formatSeconds(
      lesson.durationSeconds,
    );
    final subtitle = isActive
        ? AppStrings.activeLessonDuration(formattedDuration)
        : formattedDuration;

    return Material(
      color: isActive ? AppColors.skySoft : AppColors.background,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(
          color: isActive ? AppColors.sky : AppColors.outline,
          width: isActive ? AppSpacing.borderActive : AppSpacing.borderThin,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: AppSpacing.lessonTileMinHeight,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s16,
              vertical: AppSpacing.s12,
            ),
            child: Row(
              children: [
                Container(
                  width: AppSpacing.lessonBadgeSize,
                  height: AppSpacing.lessonBadgeSize,
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.sky : AppColors.surfaceSunken,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: isActive
                      ? const Icon(
                          Icons.play_arrow_rounded,
                          color: AppColors.background,
                          size: AppSpacing.s24,
                        )
                      : Text(
                          '${lesson.order}',
                          style: AppTextStyles.titleMedium.copyWith(
                            color: AppColors.ink,
                          ),
                        ),
                ),
                const SizedBox(width: AppSpacing.s16),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lesson.title,
                        style: AppTextStyles.titleMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.s4),
                      Text(
                        subtitle,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.inkMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
