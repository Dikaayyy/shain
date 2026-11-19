import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:shain/features/course/presentation/pages/course_detail_page.dart';
import 'package:shain/features/course/presentation/pages/course_list_page.dart';
import 'package:shain/features/course/presentation/pages/lesson_player_page.dart';

/// Konfigurasi rute navigasi aplikasi Shain menggunakan GoRouter.
class AppRouter {
  const AppRouter._();

  static const String homePath = '/';
  static const String courseDetailRoutePath = '/courses/:courseId';
  static const String lessonPlayerRoutePath =
      '/courses/:courseId/lessons/:lessonId';

  static String courseDetailPath(String courseId) => '/courses/$courseId';
  static String lessonPlayerPath(String courseId, String lessonId) =>
      '/courses/$courseId/lessons/$lessonId';

  static final GoRouter router = GoRouter(
    initialLocation: homePath,
    routes: [
      GoRoute(
        path: homePath,
        builder: (context, state) => const CourseListPage(),
      ),
      GoRoute(
        path: courseDetailRoutePath,
        builder: (context, state) => CourseDetailPage(
          courseId: state.pathParameters['courseId']!,
        ),
      ),
      GoRoute(
        path: lessonPlayerRoutePath,
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
}
