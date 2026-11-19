import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shain/core/network/api_config.dart';
import 'package:shain/features/course/data/api_course_repository.dart';
import 'package:shain/features/course/data/course_detail.dart';
import 'package:shain/features/course/data/course_repository.dart';
import 'package:shain/features/course/data/course_summary.dart';

/// Menyediakan instance Dio dengan base URL dan batas waktu dari ApiConfig.
final dioProvider = Provider<Dio>((ref) {
  return Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
    ),
  );
});

/// Menyediakan implementasi CourseRepository untuk lapisan presentation.
final courseRepositoryProvider = Provider<CourseRepository>((ref) {
  return ApiCourseRepository(ref.watch(dioProvider));
});

/// Mengambil daftar ringkasan course secara asinkron untuk CourseListPage.
final courseListProvider = FutureProvider<List<CourseSummary>>(
  (ref) {
    return ref.watch(courseRepositoryProvider).getCourses();
  },
  retry: (_, _) => null,
);

/// Mengambil detail course berdasarkan courseId secara asinkron dengan autoDispose.
final courseDetailProvider = FutureProvider.autoDispose
    .family<CourseDetail, String>(
      (ref, courseId) {
        return ref.watch(courseRepositoryProvider).getCourseDetail(courseId);
      },
      retry: (_, _) => null,
    );
