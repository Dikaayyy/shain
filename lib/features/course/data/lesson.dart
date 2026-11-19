/// Model satu materi video (lesson) di dalam suatu course.
class Lesson {
  const Lesson({
    required this.id,
    required this.order,
    required this.title,
    required this.durationSeconds,
    required this.videoUrl,
  });

  final String id;
  final int order;
  final String title;
  final int durationSeconds;
  final String videoUrl;

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] as String,
      order: (json['order'] as num).toInt(),
      title: json['title'] as String,
      durationSeconds: (json['durationSeconds'] as num).toInt(),
      videoUrl: json['videoUrl'] as String,
    );
  }
}
