import 'package:shain/features/course/data/course_detail.dart';
import 'package:shain/features/course/data/course_summary.dart';

/// Kontrak abstrak pengambilan data daftar course dan detail course.
abstract class CourseRepository {
  Future<List<CourseSummary>> getCourses();

  Future<CourseDetail> getCourseDetail(String id);
}
