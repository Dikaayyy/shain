import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shain/core/constants/app_strings.dart';
import 'package:shain/features/course/presentation/pages/course_detail_page.dart';
import 'package:shain/features/course/presentation/pages/course_list_page.dart';
import 'package:shain/features/course/presentation/pages/lesson_player_page.dart';
import 'package:shain/shared/widgets/app_top_bar.dart';
import 'package:shain/shared/widgets/error_view.dart';

/// Menyediakan instance GoRouter terpusat yang mengikuti siklus hidup ProviderScope.
final appRouterProvider = Provider<GoRouter>((ref) {
  final router = AppRouter.createRouter();
  ref.onDispose(router.dispose);
  return router;
});

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

  static GoRouter createRouter({String initialLocation = homePath}) {
    return GoRouter(
      initialLocation: initialLocation,
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
      errorBuilder: (context, state) => Scaffold(
        appBar: AppTopBar(
          title: AppStrings.appName,
          onBack: () => context.go(homePath),
        ),
        body: ErrorView(
          icon: Icons.error_outline_rounded,
          title: AppStrings.unknownErrorTitle,
          message: AppStrings.unknownErrorMessage,
          onRetry: () => context.go(homePath),
        ),
      ),
    );
  }
}
