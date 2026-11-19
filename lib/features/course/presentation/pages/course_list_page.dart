import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shain/core/constants/app_strings.dart';
import 'package:shain/core/network/app_exception.dart';
import 'package:shain/core/router/app_router.dart';
import 'package:shain/core/theme/app_colors.dart';
import 'package:shain/core/theme/app_spacing.dart';
import 'package:shain/core/theme/app_text_styles.dart';
import 'package:shain/features/course/data/course_summary.dart';
import 'package:shain/features/course/presentation/widgets/course_card.dart';
import 'package:shain/features/course/presentation/widgets/course_card_skeleton.dart';
import 'package:shain/features/course/providers/course_providers.dart';
import 'package:shain/shared/widgets/app_top_bar.dart';
import 'package:shain/shared/widgets/empty_view.dart';
import 'package:shain/shared/widgets/error_view.dart';

/// Halaman utama daftar course yang menampilkan state loading, data, kosong, dan error.
class CourseListPage extends ConsumerWidget {
  const CourseListPage({super.key});

  static const int _skeletonCount = 3;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coursesAsync = ref.watch(courseListProvider);

    return Scaffold(
      appBar: const AppTopBar(title: AppStrings.courseListTitle),
      body: coursesAsync.when(
        loading: () => _CourseListBody(
          itemCount: _skeletonCount,
          itemBuilder: (context, index) => const CourseCardSkeleton(),
        ),
        data: (courses) {
          if (courses.isEmpty) {
            return EmptyView(
              title: AppStrings.emptyCoursesTitle,
              message: AppStrings.emptyCoursesMessage,
              actionLabel: AppStrings.reloadButton,
              onAction: () => ref.invalidate(courseListProvider),
            );
          }
          return _CourseDataList(courses: courses);
        },
        error: (error, _) {
          final exception =
              error is AppException ? error : AppException.unknown();
          return ErrorView(
            icon: _iconForError(exception.type),
            title: exception.title,
            message: exception.message,
            onRetry: () => ref.invalidate(courseListProvider),
          );
        },
      ),
    );
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

/// Menampilkan subjudul halaman diikuti daftar kartu course atau skeleton.
class _CourseListBody extends StatelessWidget {
  const _CourseListBody({
    required this.itemCount,
    required this.itemBuilder,
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pageHorizontal,
        vertical: AppSpacing.s24,
      ),
      itemCount: itemCount + 1,
      separatorBuilder: (context, index) => const SizedBox(
        height: AppSpacing.cardGap,
      ),
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.s8),
            child: Text(
              AppStrings.courseListSubtitle,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.inkMuted,
              ),
            ),
          );
        }
        return itemBuilder(context, index - 1);
      },
    );
  }
}

/// Wrapper daftar CourseCard saat data berhasil dimuat.
class _CourseDataList extends StatelessWidget {
  const _CourseDataList({required this.courses});

  final List<CourseSummary> courses;

  @override
  Widget build(BuildContext context) {
    return _CourseListBody(
      itemCount: courses.length,
      itemBuilder: (context, index) {
        final course = courses[index];
        return CourseCard(
          course: course,
          onTap: () => context.push(AppRouter.courseDetailPath(course.id)),
        );
      },
    );
  }
}
