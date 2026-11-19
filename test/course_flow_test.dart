import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shain/app.dart';
import 'package:shain/core/constants/app_strings.dart';
import 'package:shain/core/router/app_router.dart';
import 'package:shain/features/course/data/course_summary.dart';
import 'package:shain/features/course/presentation/pages/course_detail_page.dart';
import 'package:shain/features/course/presentation/pages/course_list_page.dart';
import 'package:shain/features/course/presentation/pages/lesson_player_page.dart';
import 'package:shain/features/course/providers/course_providers.dart';
import 'package:shain/shared/widgets/error_view.dart';

import 'helpers/fake_course_repository.dart';

void main() {
  group('Course navigation flow', () {
    testWidgets(
        'navigates List -> Detail -> Player -> switch lesson -> Back to Detail -> Back to List via appRouterProvider',
        (tester) async {
      tester.view.physicalSize = const Size(412, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            courseRepositoryProvider.overrideWithValue(
              FakeCourseRepository(
                onGetCourses: () async => const [
                  CourseSummary(
                    id: 'flutter-basic',
                    title: 'Flutter Dasar',
                    description: 'Membangun aplikasi mobile.',
                    thumbnailUrl: 'https://example.com/thumb.png',
                    instructor: 'Budi',
                    lessonCount: 2,
                    totalDurationMinutes: 4,
                  ),
                ],
                onGetCourseDetail: (_) async => sampleCourseDetail(),
              ),
            ),
          ],
          child: const ShainApp(),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(CourseListPage), findsOneWidget);

      await tester.tap(find.text('Flutter Dasar'));
      await tester.pumpAndSettle();
      expect(find.byType(CourseDetailPage), findsOneWidget);

      await tester.tap(find.text('Mulai dari Lesson 1'));
      await tester.pumpAndSettle();

      expect(find.byType(LessonPlayerPage), findsOneWidget);
      expect(
        find.text('Lesson 1 dari 2 · Flutter Dasar'),
        findsOneWidget,
      );
      expect(find.text('01:30 · Sedang diputar'), findsOneWidget);

      // Video init catches MissingPluginException in test environment;
      // verify error overlay + retry button appear and lesson list remains usable.
      expect(find.text('Video tidak dapat diputar'), findsOneWidget);
      await tester.tap(find.text('Coba Lagi'));
      await tester.pumpAndSettle();
      expect(find.text('Video tidak dapat diputar'), findsOneWidget);

      // Switch to Lesson 2 via pushReplacement
      await tester.tap(find.text('Widget Dasar'));
      await tester.pumpAndSettle();

      expect(find.byType(LessonPlayerPage), findsOneWidget);
      expect(
        find.text('Lesson 2 dari 2 · Flutter Dasar'),
        findsOneWidget,
      );
      expect(find.text('02:30 · Sedang diputar'), findsOneWidget);

      // Back returns directly to CourseDetailPage (not Lesson 1)
      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pumpAndSettle();

      expect(find.byType(CourseDetailPage), findsOneWidget);
      expect(find.byType(LessonPlayerPage), findsNothing);

      // Back from CourseDetailPage returns to CourseListPage
      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pumpAndSettle();

      expect(find.byType(CourseListPage), findsOneWidget);
      expect(find.byType(CourseDetailPage), findsNothing);
    });

    testWidgets(
        'unknown route shows generic ErrorView and retry returns to CourseListPage',
        (tester) async {
      final router = AppRouter.createRouter(
        initialLocation: '/rute-tidak-dikenal',
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appRouterProvider.overrideWithValue(router),
            courseRepositoryProvider.overrideWithValue(
              FakeCourseRepository(
                onGetCourses: () async => const <CourseSummary>[],
              ),
            ),
          ],
          child: const ShainApp(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(ErrorView), findsOneWidget);
      expect(find.text(AppStrings.unknownErrorTitle), findsOneWidget);
      expect(find.text(AppStrings.unknownErrorMessage), findsOneWidget);

      await tester.tap(find.text(AppStrings.retryButton));
      await tester.pumpAndSettle();

      expect(find.byType(CourseListPage), findsOneWidget);
    });
  });
}
