import 'package:dio/dio.dart';
import 'package:shain/core/network/api_config.dart';
import 'package:shain/core/network/app_exception.dart';
import 'package:shain/features/course/data/course_detail.dart';
import 'package:shain/features/course/data/course_repository.dart';
import 'package:shain/features/course/data/course_summary.dart';

/// Implementasi CourseRepository yang memanggil API menggunakan Dio secara langsung.
class ApiCourseRepository implements CourseRepository {
  const ApiCourseRepository(this._dio);

  final Dio _dio;

  @override
  Future<List<CourseSummary>> getCourses() {
    return _runRequest(() async {
      final response = await _dio.get<List<dynamic>>(ApiConfig.coursesPath);
      final items = response.data ?? const <dynamic>[];
      return items
          .map((item) => CourseSummary.fromJson(item as Map<String, dynamic>))
          .toList();
    });
  }

  @override
  Future<CourseDetail> getCourseDetail(String id) {
    return _runRequest(() async {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConfig.courseDetailPath(id),
      );
      final data = response.data;
      if (data == null) {
        throw AppException.unknown();
      }
      return CourseDetail.fromJson(data);
    });
  }

  Future<T> _runRequest<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on AppException {
      rethrow;
    } on DioException catch (error) {
      throw _mapDioException(error);
    } catch (_) {
      throw AppException.unknown();
    }
  }

  AppException _mapDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return AppException.network();
      case DioExceptionType.badResponse:
        return AppException.server(error.response?.statusCode);
      default:
        return AppException.unknown();
    }
  }
}
