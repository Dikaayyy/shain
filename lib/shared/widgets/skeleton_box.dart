import 'package:flutter/material.dart';
import 'package:shain/core/theme/app_colors.dart';
import 'package:shain/core/theme/app_radius.dart';

/// Kotak placeholder generik berwarna surfaceSunken untuk state loading.
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius = AppRadius.sm,
  });

  final double? width;
  final double? height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surfaceSunken,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}
