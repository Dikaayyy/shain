import 'package:shain/features/course/data/course_detail.dart';
import 'package:shain/features/course/data/course_repository.dart';
import 'package:shain/features/course/data/course_summary.dart';
import 'package:shain/features/course/data/lesson.dart';

class FakeCourseRepository implements CourseRepository {
  FakeCourseRepository({
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

CourseDetail sampleCourseDetail({bool unsorted = false}) {
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
