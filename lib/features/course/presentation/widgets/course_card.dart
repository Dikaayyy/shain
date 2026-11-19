import 'package:flutter/material.dart';
import 'package:shain/core/constants/app_strings.dart';
import 'package:shain/core/theme/app_colors.dart';
import 'package:shain/core/theme/app_radius.dart';
import 'package:shain/core/theme/app_spacing.dart';
import 'package:shain/core/theme/app_text_styles.dart';
import 'package:shain/core/utils/duration_format.dart';
import 'package:shain/features/course/data/course_summary.dart';
import 'package:shain/features/course/presentation/widgets/tag_pill.dart';

/// Kartu ringkasan course yang menampilkan thumbnail 16:9, info, dan tag durasi.
class CourseCard extends StatelessWidget {
  const CourseCard({
    super.key,
    required this.course,
    this.onTap,
  });

  final CourseSummary course;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: const BorderSide(
          color: AppColors.outline,
          width: AppSpacing.borderThin,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: AppSpacing.thumbnailAspectRatio,
              child: Image.network(
                course.thumbnailUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const _ThumbnailPlaceholder(
                    icon: Icons.image_outlined,
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return const _ThumbnailPlaceholder(
                    icon: Icons.broken_image_outlined,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.s16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title,
                    style: AppTextStyles.displayH3,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.s4),
                  Text(
                    AppStrings.instructorLabel(course.instructor),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.inkMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.s8),
                  Text(
                    course.description,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.inkMuted,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.s16),
                  Wrap(
                    spacing: AppSpacing.s8,
                    runSpacing: AppSpacing.s8,
                    children: [
                      TagPill(
                        icon: Icons.play_circle_outline_rounded,
                        label: AppStrings.lessonCountTag(course.lessonCount),
                      ),
                      TagPill(
                        icon: Icons.schedule_rounded,
                        label: DurationFormat.minutesLabel(
                          course.totalDurationMinutes,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Placeholder surfaceSunken untuk thumbnail course saat memuat atau gagal muat.
class _ThumbnailPlaceholder extends StatelessWidget {
  const _ThumbnailPlaceholder({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.surfaceSunken,
      child: Center(
        child: Icon(
          icon,
          size: AppSpacing.s32,
          color: AppColors.inkSubtle,
        ),
      ),
    );
  }
}
