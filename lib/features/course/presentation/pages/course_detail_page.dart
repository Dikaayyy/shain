import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shain/core/constants/app_strings.dart';
import 'package:shain/core/network/app_exception.dart';
import 'package:shain/core/router/app_router.dart';
import 'package:shain/core/theme/app_colors.dart';
import 'package:shain/core/theme/app_spacing.dart';
import 'package:shain/core/theme/app_text_styles.dart';
import 'package:shain/core/utils/duration_format.dart';
import 'package:shain/features/course/data/course_detail.dart';
import 'package:shain/features/course/data/lesson.dart';
import 'package:shain/features/course/presentation/widgets/course_detail_skeleton.dart';
import 'package:shain/features/course/presentation/widgets/lesson_tile.dart';
import 'package:shain/features/course/presentation/widgets/tag_pill.dart';
import 'package:shain/features/course/providers/course_providers.dart';
import 'package:shain/shared/widgets/app_top_bar.dart';
import 'package:shain/shared/widgets/error_view.dart';
import 'package:shain/shared/widgets/primary_button.dart';

/// Halaman detail course yang menampilkan info materi, daftar lesson, dan tombol mulai.
class CourseDetailPage extends ConsumerWidget {
  const CourseDetailPage({
    super.key,
    required this.courseId,
  });

  final String courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(courseDetailProvider(courseId));

    return Scaffold(
      appBar: AppTopBar(
        title: AppStrings.courseDetailTitle,
        onBack: () => _handleBack(context),
      ),
      body: detailAsync.when(
        loading: () => const CourseDetailSkeleton(),
        error: (error, _) {
          final exception =
              error is AppException ? error : AppException.unknown();
          return ErrorView(
            icon: _iconForError(exception.type),
            title: exception.title,
            message: exception.message,
            onRetry: () => ref.invalidate(courseDetailProvider(courseId)),
          );
        },
        data: (course) => _CourseDetailContent(course: course),
      ),
    );
  }

  void _handleBack(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      GoRouter.maybeOf(context)?.go(AppRouter.homePath);
    }
  }

  IconData _iconForError(AppExceptionType type) {
    switch (type) {
      case AppExceptionType.network:
        return Icons.wifi_off_rounded;
      case AppExceptionType.server:
        return Icons.cloud_off_rounded;
      case AppExceptionType.unknown:
        return Icons.error_outline_rounded;
    }
  }
}

/// Konten utama detail course beserta tombol sticky untuk memulai lesson pertama.
class _CourseDetailContent extends StatelessWidget {
  const _CourseDetailContent({required this.course});

  final CourseDetail course;

  @override
  Widget build(BuildContext context) {
    final sortedLessons = List<Lesson>.of(course.lessons)
      ..sort((a, b) => a.order.compareTo(b.order));

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.pageHorizontal,
                    vertical: AppSpacing.s24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.title,
                        style: AppTextStyles.displayH2,
                      ),
                      const SizedBox(height: AppSpacing.s8),
                      Text(
                        AppStrings.instructorLabel(course.instructor),
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.inkMuted,
                        ),
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
                      const SizedBox(height: AppSpacing.sectionGap),
                      const Text(
                        AppStrings.aboutCourseSectionTitle,
                        style: AppTextStyles.displayH3,
                      ),
                      const SizedBox(height: AppSpacing.s12),
                      Text(
                        course.description,
                        style: AppTextStyles.bodyMedium,
                      ),
                      const SizedBox(height: AppSpacing.sectionGap),
                      const Text(
                        AppStrings.lessonListSectionTitle,
                        style: AppTextStyles.displayH3,
                      ),
                      const SizedBox(height: AppSpacing.s16),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: sortedLessons.length,
                        separatorBuilder: (_, _) => const SizedBox(
                          height: AppSpacing.cardGap,
                        ),
                        itemBuilder: (context, index) {
                          final lesson = sortedLessons[index];
                          return LessonTile(
                            lesson: lesson,
                            onTap: () => context.push(
                              AppRouter.lessonPlayerPath(course.id, lesson.id),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pageHorizontal,
            vertical: AppSpacing.s16,
          ),
          decoration: const BoxDecoration(
            color: AppColors.background,
            border: Border(
              top: BorderSide(
                color: AppColors.outline,
                width: AppSpacing.borderThin,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: PrimaryButton(
              label: AppStrings.startFirstLessonButton,
              onPressed: sortedLessons.isEmpty
                  ? null
                  : () => context.push(
                        AppRouter.lessonPlayerPath(
                          course.id,
                          sortedLessons.first.id,
                        ),
                      ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Placeholder surfaceSunken untuk thumbnail detail course saat memuat atau gagal muat.
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
