import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shain/core/constants/app_strings.dart';
import 'package:shain/core/network/app_exception.dart';
import 'package:shain/core/theme/app_theme.dart';
import 'package:shain/core/utils/duration_format.dart';
import 'package:shain/features/course/data/api_course_repository.dart';
import 'package:shain/features/course/data/course_detail.dart';
import 'package:shain/features/course/data/course_repository.dart';
import 'package:shain/features/course/data/course_summary.dart';
import 'package:shain/features/course/data/lesson.dart';
import 'package:shain/features/course/presentation/pages/course_list_page.dart';
import 'package:shain/features/course/presentation/widgets/course_card_skeleton.dart';
import 'package:shain/features/course/providers/course_providers.dart';

class _FakeCourseRepository implements CourseRepository {
  _FakeCourseRepository(this._onGetCourses);

  final Future<List<CourseSummary>> Function() _onGetCourses;

  @override
  Future<List<CourseSummary>> getCourses() => _onGetCourses();

  @override
  Future<CourseDetail> getCourseDetail(String id) {
    throw UnimplementedError();
  }
}

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this._handler);

  final Future<ResponseBody> Function(RequestOptions options) _handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    return _handler(options);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  group('Models & DurationFormat', () {
    test('CourseSummary and CourseDetail parse JSON and derive totals', () {
      final summary = CourseSummary.fromJson({
        'id': 'flutter-basic',
        'title': 'Flutter Dasar',
        'description': 'Belajar widget dasar Flutter.',
        'thumbnailUrl': 'https://example.com/thumb.png',
        'instructor': 'Budi',
        'lessonCount': 4,
        'totalDurationMinutes': 25,
      });

      expect(summary.id, 'flutter-basic');
      expect(summary.lessonCount, 4);
      expect(summary.totalDurationMinutes, 25);

      final detail = CourseDetail.fromJson({
        'id': 'flutter-basic',
        'title': 'Flutter Dasar',
        'description': 'Belajar widget dasar Flutter.',
        'thumbnailUrl': 'https://example.com/thumb.png',
        'instructor': 'Budi',
        'lessons': [
          {
            'id': 'flutter-basic-1',
            'order': 1,
            'title': 'Pengenalan',
            'durationSeconds': 90,
            'videoUrl': 'https://example.com/1.mp4',
          },
          {
            'id': 'flutter-basic-2',
            'order': 2,
            'title': 'StatelessWidget',
            'durationSeconds': 100,
            'videoUrl': 'https://example.com/2.mp4',
          },
        ],
      });

      expect(detail.lessonCount, 2);
      expect(detail.totalDurationMinutes, 3);
      expect(DurationFormat.formatSeconds(90), '01:30');

      final lesson = Lesson.fromJson({
        'id': 'flutter-basic-3',
        'order': 3,
        'title': 'StatefulWidget',
        'durationSeconds': 140,
        'videoUrl': 'https://example.com/3.mp4',
      });
      expect(lesson.id, 'flutter-basic-3');
      expect(lesson.order, 3);
      expect(lesson.title, 'StatefulWidget');
      expect(lesson.durationSeconds, 140);
      expect(lesson.videoUrl, 'https://example.com/3.mp4');
    });
  });

  group('ApiCourseRepository', () {
    test('parses course list from Dio response', () async {
      final dio = Dio()
        ..httpClientAdapter = _FakeAdapter((options) async {
          return ResponseBody.fromString(
            jsonEncode([
              {
                'id': 'c1',
                'title': 'Dart Pemula',
                'description': 'Sintaks dasar Dart.',
                'thumbnailUrl': 'https://example.com/c1.png',
                'instructor': 'Sari',
                'lessonCount': 3,
                'totalDurationMinutes': 15,
              },
            ]),
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        });

      final repo = ApiCourseRepository(dio);
      final courses = await repo.getCourses();

      expect(courses, hasLength(1));
      expect(courses.first.title, 'Dart Pemula');
    });

    test('maps connection timeout to AppException.network', () async {
      final dio = Dio()
        ..httpClientAdapter = _FakeAdapter((options) async {
          throw DioException(
            requestOptions: options,
            type: DioExceptionType.connectionTimeout,
          );
        });

      final repo = ApiCourseRepository(dio);

      expect(
        repo.getCourses(),
        throwsA(
          isA<AppException>().having(
            (e) => e.type,
            'type',
            AppExceptionType.network,
          ),
        ),
      );
    });

    test('maps HTTP 500 badResponse to AppException.server', () async {
      final dio = Dio()
        ..httpClientAdapter = _FakeAdapter((options) async {
          return ResponseBody.fromString('Server Error', 500);
        });

      final repo = ApiCourseRepository(dio);

      expect(
        repo.getCourses(),
        throwsA(
          isA<AppException>()
              .having((e) => e.type, 'type', AppExceptionType.server)
              .having((e) => e.statusCode, 'statusCode', 500),
        ),
      );
    });

    test('maps DioExceptionType.unknown to AppException.unknown', () async {
      final dio = Dio()
        ..httpClientAdapter = _FakeAdapter((options) async {
          throw DioException(
            requestOptions: options,
            type: DioExceptionType.unknown,
          );
        });

      final repo = ApiCourseRepository(dio);

      expect(
        repo.getCourses(),
        throwsA(
          isA<AppException>().having(
            (e) => e.type,
            'type',
            AppExceptionType.unknown,
          ),
        ),
      );
    });
  });

  group('CourseListPage states', () {
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
              _FakeCourseRepository(() => completer.future),
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
              _FakeCourseRepository(() async {
                calls++;
                return const <CourseSummary>[];
              }),
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
              _FakeCourseRepository(() async {
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
              }),
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
