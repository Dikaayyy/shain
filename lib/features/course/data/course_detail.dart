import 'package:shain/features/course/data/lesson.dart';

/// Model detail course beserta daftar lesson dan turunan jumlah/durasi.
class CourseDetail {
  const CourseDetail({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.instructor,
    required this.lessons,
  });

  final String id;
  final String title;
  final String description;
  final String thumbnailUrl;
  final String instructor;
  final List<Lesson> lessons;

  int get lessonCount => lessons.length;

  int get totalDurationMinutes {
    final totalSeconds = lessons.fold<int>(
      0,
      (sum, lesson) => sum + lesson.durationSeconds,
    );
    return (totalSeconds / 60).round();
  }

  factory CourseDetail.fromJson(Map<String, dynamic> json) {
    final rawLessons = json['lessons'] as List<dynamic>;
    return CourseDetail(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String,
      instructor: json['instructor'] as String,
      lessons: rawLessons
          .map((item) => Lesson.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
