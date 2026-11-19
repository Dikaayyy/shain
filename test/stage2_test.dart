import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shain/core/constants/app_strings.dart';
import 'package:shain/core/network/app_exception.dart';
import 'package:shain/core/router/app_router.dart';
import 'package:shain/core/theme/app_colors.dart';
import 'package:shain/core/theme/app_spacing.dart';
import 'package:shain/core/theme/app_theme.dart';
import 'package:shain/features/course/data/api_course_repository.dart';
import 'package:shain/features/course/data/course_detail.dart';
import 'package:shain/features/course/data/course_repository.dart';
import 'package:shain/features/course/data/course_summary.dart';
import 'package:shain/features/course/data/lesson.dart';
import 'package:shain/features/course/presentation/pages/course_detail_page.dart';
import 'package:shain/features/course/presentation/pages/course_list_page.dart';
import 'package:shain/features/course/presentation/pages/lesson_player_page.dart';
import 'package:shain/features/course/presentation/widgets/course_detail_skeleton.dart';
import 'package:shain/features/course/presentation/widgets/lesson_tile.dart';
import 'package:shain/features/course/presentation/widgets/video_player_controls.dart';
import 'package:shain/features/course/presentation/widgets/video_status_overlay.dart';
import 'package:shain/features/course/providers/course_providers.dart';
import 'package:shain/shared/widgets/app_top_bar.dart';
import 'package:video_player/video_player.dart';

class _FakeCourseRepository implements CourseRepository {
  _FakeCourseRepository({
    this.onGetCourses,
    this.onGetCourseDetail,
  });

  final Future<List<CourseSummary>> Function()? onGetCourses;
  final Future<CourseDetail> Function(String id)? onGetCourseDetail;

  @override
  Future<List<CourseSummary>> getCourses() {
    final handler = onGetCourses;
    if (handler == null) return Future.value(const <CourseSummary>[]);
    return handler();
  }

  @override
  Future<CourseDetail> getCourseDetail(String id) {
    final handler = onGetCourseDetail;
    if (handler == null) {
      throw UnimplementedError();
    }
    return handler(id);
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

class _FakeVideoPlayerController extends VideoPlayerController {
  _FakeVideoPlayerController()
      : super.networkUrl(Uri.parse('https://example.com/video.mp4'));

  int playCalls = 0;
  int pauseCalls = 0;
  final List<Duration> seekTargets = [];

  @override
  Future<void> initialize() async {}

  @override
  Future<void> play() async {
    playCalls++;
    value = value.copyWith(isPlaying: true);
  }

  @override
  Future<void> pause() async {
    pauseCalls++;
    value = value.copyWith(isPlaying: false);
  }

  @override
  Future<void> seekTo(Duration position) async {
    seekTargets.add(position);
    value = value.copyWith(position: position);
  }
}

CourseDetail _sampleCourseDetail({bool unsorted = false}) {
  const lesson1 = Lesson(
    id: 'l1',
    order: 1,
    title: 'Pengenalan Flutter',
    durationSeconds: 90,
    videoUrl: 'https://example.com/l1.mp4',
  );
  const lesson2 = Lesson(
    id: 'l2',
    order: 2,
    title: 'Widget Dasar',
    durationSeconds: 150,
    videoUrl: 'https://example.com/l2.mp4',
  );

  return CourseDetail(
    id: 'flutter-basic',
    title: 'Flutter Dasar',
    description: 'Membangun antarmuka aplikasi mobile dengan rapi.',
    thumbnailUrl: 'https://example.com/thumb.png',
    instructor: 'Budi',
    lessons: unsorted ? const [lesson2, lesson1] : const [lesson1, lesson2],
  );
}

void main() {
  group('CourseDetail repository & provider', () {
    test('ApiCourseRepository.getCourseDetail parses detail JSON', () async {
      final dio = Dio()
        ..httpClientAdapter = _FakeAdapter((options) async {
          expect(options.path, '/courses/flutter-basic.json');
          return ResponseBody.fromString(
            jsonEncode({
              'id': 'flutter-basic',
              'title': 'Flutter Dasar',
              'description': 'Deskripsi course',
              'thumbnailUrl': 'https://example.com/thumb.png',
              'instructor': 'Budi',
              'lessons': [
                {
                  'id': 'l1',
                  'order': 1,
                  'title': 'Lesson Satu',
                  'durationSeconds': 90,
                  'videoUrl': 'https://example.com/1.mp4',
                },
              ],
            }),
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        });

      final repo = ApiCourseRepository(dio);
      final detail = await repo.getCourseDetail('flutter-basic');

      expect(detail.id, 'flutter-basic');
      expect(detail.lessonCount, 1);
      expect(detail.totalDurationMinutes, 2);
    });

    test('maps HTTP 500 on getCourseDetail to expected server error copy',
        () async {
      final dio = Dio()
        ..httpClientAdapter = _FakeAdapter((options) async {
          return ResponseBody.fromString('Server Error', 500);
        });

      final repo = ApiCourseRepository(dio);

      expect(
        repo.getCourseDetail('flutter-basic'),
        throwsA(
          isA<AppException>()
              .having((e) => e.type, 'type', AppExceptionType.server)
              .having((e) => e.title, 'title', 'Gagal memuat course')
              .having(
                (e) => e.message,
                'message',
                'Server sedang sibuk. Silakan coba lagi beberapa saat.',
              ),
        ),
      );
    });

    test('courseDetailProvider loads detail via repository', () async {
      final container = ProviderContainer(
        overrides: [
          courseRepositoryProvider.overrideWithValue(
            _FakeCourseRepository(
              onGetCourseDetail: (id) async => _sampleCourseDetail(),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final detail = await container.read(
        courseDetailProvider('flutter-basic').future,
      );

      expect(detail.title, 'Flutter Dasar');
      expect(detail.lessons, hasLength(2));
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

  group('CourseDetailPage states', () {
    testWidgets('keeps AppTopBar visible during loading skeleton',
        (tester) async {
      final completer = Completer<CourseDetail>();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            courseRepositoryProvider.overrideWithValue(
              _FakeCourseRepository(
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
              _FakeCourseRepository(
                onGetCourseDetail: (_) async {
                  if (shouldFail) {
                    throw AppException.server(500);
                  }
                  return _sampleCourseDetail(unsorted: true);
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

  group('Video widgets', () {
    testWidgets('VideoStatusOverlay renders loading, buffering, and error',
        (tester) async {
      final controller = _FakeVideoPlayerController();
      addTearDown(controller.dispose);
      var retried = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: SizedBox(
              width: 360,
              height: 202.5,
              child: VideoStatusOverlay(
                controller: controller,
                onRetry: () => retried = true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Memuat video...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      controller.value = VideoPlayerValue(
        duration: const Duration(seconds: 90),
        size: const Size(1280, 720),
        isInitialized: true,
        isBuffering: true,
      );
      await tester.pump();

      expect(find.text('Menyangga video...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      controller.value = VideoPlayerValue.erroneous('Stream error');
      await tester.pump();

      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
      expect(find.text('Video tidak dapat diputar'), findsOneWidget);
      await tester.tap(find.text('Coba Lagi'));
      expect(retried, isTrue);
    });

    testWidgets('VideoPlayerControls toggles play/pause and seeks after drag',
        (tester) async {
      final controller = _FakeVideoPlayerController();
      addTearDown(controller.dispose);
      controller.value = VideoPlayerValue(
        duration: const Duration(seconds: 90),
        position: const Duration(seconds: 10),
        size: const Size(1280, 720),
        isInitialized: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: SizedBox(
              width: 360,
              height: 202.5,
              child: VideoPlayerControls(controller: controller),
            ),
          ),
        ),
      );

      expect(find.text('00:10 / 01:30'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.play_arrow_rounded));
      await tester.pump();
      expect(controller.playCalls, 1);
      expect(find.byIcon(Icons.pause_rounded), findsOneWidget);

      await tester.tap(find.byIcon(Icons.pause_rounded));
      await tester.pump();
      expect(controller.pauseCalls, 1);

      final sliderRect = tester.getRect(find.byType(Slider));
      final gesture = await tester.startGesture(sliderRect.center);
      await gesture.moveTo(
        Offset(sliderRect.left + sliderRect.width * 0.75, sliderRect.center.dy),
      );
      await tester.pump();
      expect(controller.seekTargets, isEmpty);

      await gesture.up();
      await tester.pump();
      expect(controller.seekTargets, hasLength(1));
      expect(controller.seekTargets.first.inSeconds, greaterThan(45));
    });
  });

  group('Navigation & LessonPlayerPage', () {
    testWidgets(
        'navigates List -> Detail -> Player, replaces lesson without stacking, and keeps lesson list usable on error',
        (tester) async {
      tester.view.physicalSize = const Size(412, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final router = GoRouter(
        initialLocation: AppRouter.homePath,
        routes: [
          GoRoute(
            path: AppRouter.homePath,
            builder: (context, state) => const CourseListPage(),
          ),
          GoRoute(
            path: AppRouter.courseDetailRoutePath,
            builder: (context, state) => CourseDetailPage(
              courseId: state.pathParameters['courseId']!,
            ),
          ),
          GoRoute(
            path: AppRouter.lessonPlayerRoutePath,
            pageBuilder: (context, state) {
              final courseId = state.pathParameters['courseId']!;
              final lessonId = state.pathParameters['lessonId']!;
              return NoTransitionPage<void>(
                key: ValueKey('lesson-$courseId-$lessonId'),
                child: LessonPlayerPage(
                  courseId: courseId,
                  lessonId: lessonId,
                ),
              );
            },
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            courseRepositoryProvider.overrideWithValue(
              _FakeCourseRepository(
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
                onGetCourseDetail: (_) async => _sampleCourseDetail(),
              ),
            ),
          ],
          child: MaterialApp.router(
            theme: AppTheme.light,
            routerConfig: router,
          ),
        ),
      );

      await tester.pumpAndSettle();

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
    });
  });
}
