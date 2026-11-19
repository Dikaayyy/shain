import 'package:flutter_test/flutter_test.dart';
import 'package:shain/core/utils/duration_format.dart';
import 'package:shain/features/course/data/course_detail.dart';
import 'package:shain/features/course/data/course_summary.dart';
import 'package:shain/features/course/data/lesson.dart';

void main() {
  group('Models & DurationFormat', () {
    test('CourseSummary, CourseDetail, and Lesson parse JSON and derive totals',
        () {
      final summary = CourseSummary.fromJson({
        'id': 'flutter-basic',
        'title': 'Flutter Dasar',
        'description': 'Belajar widget dasar Flutter.',
        'thumbnailUrl': 'https://example.com/thumb.png',
        'instructor': 'Budi',
        'lessonCount': 4,
        'totalDurationMinutes': 25,
      });

      expect(summary.id, 'flutter-basic');
      expect(summary.lessonCount, 4);
      expect(summary.totalDurationMinutes, 25);

      final detail = CourseDetail.fromJson({
        'id': 'flutter-basic',
        'title': 'Flutter Dasar',
        'description': 'Belajar widget dasar Flutter.',
        'thumbnailUrl': 'https://example.com/thumb.png',
        'instructor': 'Budi',
        'lessons': [
          {
            'id': 'flutter-basic-1',
            'order': 1,
            'title': 'Pengenalan',
            'durationSeconds': 90,
            'videoUrl': 'https://example.com/1.mp4',
          },
          {
            'id': 'flutter-basic-2',
            'order': 2,
            'title': 'StatelessWidget',
            'durationSeconds': 100,
            'videoUrl': 'https://example.com/2.mp4',
          },
        ],
      });

      expect(detail.lessonCount, 2);
      expect(detail.totalDurationMinutes, 3);
      expect(DurationFormat.formatSeconds(90), '01:30');

      final lesson = Lesson.fromJson({
        'id': 'flutter-basic-3',
        'order': 3,
        'title': 'StatefulWidget',
        'durationSeconds': 140,
        'videoUrl': 'https://example.com/3.mp4',
      });
      expect(lesson.id, 'flutter-basic-3');
      expect(lesson.order, 3);
      expect(lesson.title, 'StatefulWidget');
      expect(lesson.durationSeconds, 140);
      expect(lesson.videoUrl, 'https://example.com/3.mp4');
    });
  });
}
