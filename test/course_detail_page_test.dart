import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shain/core/constants/app_strings.dart';
import 'package:shain/core/network/app_exception.dart';
import 'package:shain/core/theme/app_colors.dart';
import 'package:shain/core/theme/app_spacing.dart';
import 'package:shain/core/theme/app_theme.dart';
import 'package:shain/features/course/data/course_detail.dart';
import 'package:shain/features/course/data/lesson.dart';
import 'package:shain/features/course/presentation/pages/course_detail_page.dart';
import 'package:shain/features/course/presentation/widgets/course_detail_skeleton.dart';
import 'package:shain/features/course/presentation/widgets/lesson_tile.dart';
import 'package:shain/features/course/providers/course_providers.dart';
import 'package:shain/shared/widgets/app_top_bar.dart';

import 'helpers/fake_course_repository.dart';

void main() {
  group('CourseDetailPage', () {
    testWidgets('keeps AppTopBar visible during loading skeleton',
        (tester) async {
      final completer = Completer<CourseDetail>();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            courseRepositoryProvider.overrideWithValue(
              FakeCourseRepository(
                onGetCourseDetail: (_) => completer.future,
              ),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const CourseDetailPage(courseId: 'flutter-basic'),
          ),
        ),
      );

      expect(find.byType(AppTopBar), findsOneWidget);
      expect(find.text(AppStrings.courseDetailTitle), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
      expect(find.byType(CourseDetailSkeleton), findsOneWidget);
    });

    testWidgets('shows server error with AppTopBar and retries cleanly',
        (tester) async {
      var shouldFail = true;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            courseRepositoryProvider.overrideWithValue(
              FakeCourseRepository(
                onGetCourseDetail: (_) async {
                  if (shouldFail) {
                    throw AppException.server(500);
                  }
                  return sampleCourseDetail(unsorted: true);
                },
              ),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const CourseDetailPage(courseId: 'flutter-basic'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(AppTopBar), findsOneWidget);
      expect(find.text('Gagal memuat course'), findsOneWidget);
      expect(
        find.text('Server sedang sibuk. Silakan coba lagi beberapa saat.'),
        findsOneWidget,
      );

      shouldFail = false;
      await tester.tap(find.text('Coba Lagi'));
      await tester.pumpAndSettle();

      expect(find.text('Flutter Dasar'), findsOneWidget);
      expect(find.text('Oleh Budi'), findsOneWidget);
      expect(find.text('2 lesson'), findsOneWidget);
      expect(find.text('4 menit'), findsOneWidget);
      expect(find.text('Tentang course'), findsOneWidget);
      expect(find.text('Daftar Lesson'), findsOneWidget);
      expect(find.text('Mulai dari Lesson 1'), findsOneWidget);

      final firstTileY =
          tester.getTopLeft(find.text('Pengenalan Flutter')).dy;
      final secondTileY = tester.getTopLeft(find.text('Widget Dasar')).dy;
      expect(firstTileY, lessThan(secondTileY));
    });
  });

  group('LessonTile', () {
    const lesson = Lesson(
      id: 'l1',
      order: 1,
      title: 'Pengenalan Flutter',
      durationSeconds: 90,
      videoUrl: 'https://example.com/1.mp4',
    );

    testWidgets('renders inactive and active states according to tokens',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: Column(
              children: const [
                LessonTile(lesson: lesson),
                LessonTile(lesson: lesson, isActive: true),
              ],
            ),
          ),
        ),
      );

      final tiles = tester.widgetList<Material>(
        find.descendant(
          of: find.byType(LessonTile),
          matching: find.byType(Material),
        ),
      ).toList();

      expect(tiles[0].color, AppColors.background);
      final inactiveShape = tiles[0].shape! as RoundedRectangleBorder;
      expect(inactiveShape.side.width, AppSpacing.borderThin);
      expect(inactiveShape.side.color, AppColors.outline);

      expect(tiles[1].color, AppColors.skySoft);
      final activeShape = tiles[1].shape! as RoundedRectangleBorder;
      expect(activeShape.side.width, AppSpacing.borderActive);
      expect(activeShape.side.color, AppColors.sky);

      expect(find.text('1'), findsOneWidget);
      expect(find.text('01:30'), findsOneWidget);
      expect(find.text('01:30 · Sedang diputar'), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);

      final tileSize = tester.getSize(find.byType(LessonTile).first);
      expect(tileSize.height, greaterThanOrEqualTo(72));
    });
  });
}
