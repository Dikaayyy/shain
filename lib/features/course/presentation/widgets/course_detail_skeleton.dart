import 'package:flutter/material.dart';
import 'package:shain/core/theme/app_radius.dart';
import 'package:shain/core/theme/app_spacing.dart';
import 'package:shain/shared/widgets/skeleton_box.dart';

/// Placeholder skeleton untuk halaman detail course saat data sedang dimuat.
class CourseDetailSkeleton extends StatelessWidget {
  const CourseDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: AppSpacing.thumbnailAspectRatio,
            child: SkeletonBox(
              width: double.infinity,
              height: double.infinity,
              borderRadius: 0,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.pageHorizontal,
              vertical: AppSpacing.s24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: double.infinity, height: AppSpacing.s32),
                SizedBox(height: AppSpacing.s8),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: SkeletonBox(height: AppSpacing.s24),
                    ),
                    Spacer(flex: 1),
                  ],
                ),
                SizedBox(height: AppSpacing.s16),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: SkeletonBox(
                        height: AppSpacing.s32,
                        borderRadius: AppRadius.full,
                      ),
                    ),
                    SizedBox(width: AppSpacing.s8),
                    Expanded(
                      flex: 2,
                      child: SkeletonBox(
                        height: AppSpacing.s32,
                        borderRadius: AppRadius.full,
                      ),
                    ),
                    Spacer(flex: 1),
                  ],
                ),
                SizedBox(height: AppSpacing.sectionGap),
                SkeletonBox(width: 160, height: AppSpacing.s24),
                SizedBox(height: AppSpacing.s12),
                SkeletonBox(width: double.infinity, height: AppSpacing.s16),
                SizedBox(height: AppSpacing.s8),
                SkeletonBox(width: double.infinity, height: AppSpacing.s16),
                SizedBox(height: AppSpacing.s8),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: SkeletonBox(height: AppSpacing.s16),
                    ),
                    Spacer(flex: 1),
                  ],
                ),
                SizedBox(height: AppSpacing.sectionGap),
                SkeletonBox(width: 140, height: AppSpacing.s24),
                SizedBox(height: AppSpacing.s16),
                SkeletonBox(
                  width: double.infinity,
                  height: AppSpacing.lessonTileMinHeight,
                  borderRadius: AppRadius.lg,
                ),
                SizedBox(height: AppSpacing.cardGap),
                SkeletonBox(
                  width: double.infinity,
                  height: AppSpacing.lessonTileMinHeight,
                  borderRadius: AppRadius.lg,
                ),
                SizedBox(height: AppSpacing.cardGap),
                SkeletonBox(
                  width: double.infinity,
                  height: AppSpacing.lessonTileMinHeight,
                  borderRadius: AppRadius.lg,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
