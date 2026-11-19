import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shain/core/constants/app_strings.dart';
import 'package:shain/core/network/app_exception.dart';
import 'package:shain/core/theme/app_theme.dart';
import 'package:shain/features/course/data/course_summary.dart';
import 'package:shain/features/course/presentation/pages/course_list_page.dart';
import 'package:shain/features/course/presentation/widgets/course_card_skeleton.dart';
import 'package:shain/features/course/providers/course_providers.dart';

import 'helpers/fake_course_repository.dart';

void main() {
  group('CourseListPage', () {
    testWidgets('shows 3 skeletons when loading', (tester) async {
      tester.view.physicalSize = const Size(412, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final completer = Completer<List<CourseSummary>>();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            courseRepositoryProvider.overrideWithValue(
              FakeCourseRepository(onGetCourses: () => completer.future),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const CourseListPage(),
          ),
        ),
      );

      expect(find.text(AppStrings.courseListTitle), findsOneWidget);
      expect(find.byType(CourseCardSkeleton), findsNWidgets(3));
    });

    testWidgets('shows empty view and reloads on tap', (tester) async {
      var calls = 0;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            courseRepositoryProvider.overrideWithValue(
              FakeCourseRepository(
                onGetCourses: () async {
                  calls++;
                  return const <CourseSummary>[];
                },
              ),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const CourseListPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text(AppStrings.emptyCoursesTitle), findsOneWidget);
      expect(find.text(AppStrings.emptyCoursesMessage), findsOneWidget);

      await tester.tap(find.text(AppStrings.reloadButton));
      await tester.pumpAndSettle();

      expect(calls, 2);
    });

    testWidgets('shows network error view and retries on tap', (tester) async {
      var shouldFail = true;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            courseRepositoryProvider.overrideWithValue(
              FakeCourseRepository(
                onGetCourses: () async {
                  if (shouldFail) {
                    throw AppException.network();
                  }
                  return const [
                    CourseSummary(
                      id: 'c1',
                      title: 'UI Flutter Rapi',
                      description: 'Belajar layout responsif.',
                      thumbnailUrl: 'https://example.com/c1.png',
                      instructor: 'Andi',
                      lessonCount: 5,
                      totalDurationMinutes: 30,
                    ),
                  ];
                },
              ),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const CourseListPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text(AppStrings.networkErrorTitle), findsOneWidget);
      expect(find.text(AppStrings.networkErrorMessage), findsOneWidget);

      shouldFail = false;
      await tester.tap(find.text(AppStrings.retryButton));
      await tester.pumpAndSettle();

      expect(find.text('UI Flutter Rapi'), findsOneWidget);
      expect(find.text('5 lesson'), findsOneWidget);
      expect(find.text('30 menit'), findsOneWidget);
    });
  });
}
