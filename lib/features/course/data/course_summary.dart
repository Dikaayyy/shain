/// Model ringkasan course yang ditampilkan pada halaman daftar course.
class CourseSummary {
  const CourseSummary({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.instructor,
    required this.lessonCount,
    required this.totalDurationMinutes,
  });

  final String id;
  final String title;
  final String description;
  final String thumbnailUrl;
  final String instructor;
  final int lessonCount;
  final int totalDurationMinutes;

  factory CourseSummary.fromJson(Map<String, dynamic> json) {
    return CourseSummary(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String,
      instructor: json['instructor'] as String,
      lessonCount: (json['lessonCount'] as num).toInt(),
      totalDurationMinutes: (json['totalDurationMinutes'] as num).toInt(),
    );
  }
}
