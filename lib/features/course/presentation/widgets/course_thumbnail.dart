import 'package:flutter/material.dart';
import 'package:shain/core/theme/app_colors.dart';
import 'package:shain/core/theme/app_spacing.dart';

/// Menampilkan gambar thumbnail course 16:9 beserta placeholder muat dan gagal muat.
class CourseThumbnail extends StatelessWidget {
  const CourseThumbnail({
    super.key,
    required this.imageUrl,
  });

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: AppSpacing.thumbnailAspectRatio,
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const _ThumbnailPlaceholder(icon: Icons.image_outlined);
        },
        errorBuilder: (context, error, stackTrace) {
          return const _ThumbnailPlaceholder(
            icon: Icons.broken_image_outlined,
          );
        },
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
