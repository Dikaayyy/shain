import 'package:go_router/go_router.dart';
import 'package:shain/features/course/presentation/pages/course_list_page.dart';

/// Konfigurasi rute navigasi aplikasi Shain menggunakan GoRouter.
class AppRouter {
  const AppRouter._();

  static const String homePath = '/';

  static final GoRouter router = GoRouter(
    initialLocation: homePath,
    routes: [
      GoRoute(
        path: homePath,
        builder: (context, state) => const CourseListPage(),
      ),
    ],
  );
}
