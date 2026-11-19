import 'package:flutter/material.dart';
import 'package:shain/core/theme/app_colors.dart';
import 'package:shain/core/theme/app_radius.dart';
import 'package:shain/core/theme/app_spacing.dart';
import 'package:shain/shared/widgets/skeleton_box.dart';

/// Placeholder kartu course berbentuk skeleton saat daftar course sedang dimuat.
class CourseCardSkeleton extends StatelessWidget {
  const CourseCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: AppColors.outline,
          width: AppSpacing.borderThin,
        ),
      ),
      child: const Column(
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
            padding: EdgeInsets.all(AppSpacing.s16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(
                  width: double.infinity,
                  height: AppSpacing.s24,
                ),
                SizedBox(height: AppSpacing.s8),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: SkeletonBox(height: AppSpacing.s16),
                    ),
                    Spacer(flex: 1),
                  ],
                ),
                SizedBox(height: AppSpacing.s12),
                SkeletonBox(
                  width: double.infinity,
                  height: AppSpacing.s16,
                ),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
