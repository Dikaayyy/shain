import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shain/core/network/app_exception.dart';
import 'package:shain/features/course/data/api_course_repository.dart';
import 'package:shain/features/course/providers/course_providers.dart';

import 'helpers/fake_course_repository.dart';

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this._handler);

  final Future<ResponseBody> Function(RequestOptions options) _handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    return _handler(options);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  group('ApiCourseRepository parsing', () {
    test('parses course list from Dio response', () async {
      final dio = Dio()
        ..httpClientAdapter = _FakeAdapter((options) async {
          return ResponseBody.fromString(
            jsonEncode([
              {
                'id': 'c1',
                'title': 'Dart Pemula',
                'description': 'Sintaks dasar Dart.',
                'thumbnailUrl': 'https://example.com/c1.png',
                'instructor': 'Sari',
                'lessonCount': 3,
                'totalDurationMinutes': 15,
              },
            ]),
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        });

      final repo = ApiCourseRepository(dio);
      final courses = await repo.getCourses();

      expect(courses, hasLength(1));
      expect(courses.first.title, 'Dart Pemula');
    });

    test('getCourseDetail parses detail JSON', () async {
      final dio = Dio()
        ..httpClientAdapter = _FakeAdapter((options) async {
          expect(options.path, '/courses/flutter-basic.json');
          return ResponseBody.fromString(
            jsonEncode({
              'id': 'flutter-basic',
              'title': 'Flutter Dasar',
              'description': 'Deskripsi course',
              'thumbnailUrl': 'https://example.com/thumb.png',
              'instructor': 'Budi',
              'lessons': [
                {
                  'id': 'l1',
                  'order': 1,
                  'title': 'Lesson Satu',
                  'durationSeconds': 90,
                  'videoUrl': 'https://example.com/1.mp4',
                },
              ],
            }),
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        });

      final repo = ApiCourseRepository(dio);
      final detail = await repo.getCourseDetail('flutter-basic');

      expect(detail.id, 'flutter-basic');
      expect(detail.lessonCount, 1);
      expect(detail.totalDurationMinutes, 2);
    });
  });

  group('ApiCourseRepository error mapping', () {
    test('maps connection timeout to AppException.network', () async {
      final dio = Dio()
        ..httpClientAdapter = _FakeAdapter((options) async {
          throw DioException(
            requestOptions: options,
            type: DioExceptionType.connectionTimeout,
          );
        });

      final repo = ApiCourseRepository(dio);

      expect(
        repo.getCourses(),
        throwsA(
          isA<AppException>().having(
            (e) => e.type,
            'type',
            AppExceptionType.network,
          ),
        ),
      );
    });

    test('maps HTTP 500 badResponse on getCourses to AppException.server',
        () async {
      final dio = Dio()
        ..httpClientAdapter = _FakeAdapter((options) async {
          return ResponseBody.fromString('Server Error', 500);
        });

      final repo = ApiCourseRepository(dio);

      expect(
        repo.getCourses(),
        throwsA(
          isA<AppException>()
              .having((e) => e.type, 'type', AppExceptionType.server)
              .having((e) => e.statusCode, 'statusCode', 500),
        ),
      );
    });

    test('maps HTTP 500 on getCourseDetail to expected server error copy',
        () async {
      final dio = Dio()
        ..httpClientAdapter = _FakeAdapter((options) async {
          return ResponseBody.fromString('Server Error', 500);
        });

      final repo = ApiCourseRepository(dio);

      expect(
        repo.getCourseDetail('flutter-basic'),
        throwsA(
          isA<AppException>()
              .having((e) => e.type, 'type', AppExceptionType.server)
              .having((e) => e.title, 'title', 'Gagal memuat course')
              .having(
                (e) => e.message,
                'message',
                'Server sedang sibuk. Silakan coba lagi beberapa saat.',
              ),
        ),
      );
    });

    test('maps DioExceptionType.unknown to AppException.unknown', () async {
      final dio = Dio()
        ..httpClientAdapter = _FakeAdapter((options) async {
          throw DioException(
            requestOptions: options,
            type: DioExceptionType.unknown,
          );
        });

      final repo = ApiCourseRepository(dio);

      expect(
        repo.getCourses(),
        throwsA(
          isA<AppException>().having(
            (e) => e.type,
            'type',
            AppExceptionType.unknown,
          ),
        ),
      );
    });
  });

  group('Course providers', () {
    test('courseDetailProvider loads detail via repository', () async {
      final container = ProviderContainer(
        overrides: [
          courseRepositoryProvider.overrideWithValue(
            FakeCourseRepository(
              onGetCourseDetail: (id) async => sampleCourseDetail(),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final detail = await container.read(
        courseDetailProvider('flutter-basic').future,
      );

      expect(detail.title, 'Flutter Dasar');
      expect(detail.lessons, hasLength(2));
    });
  });
}
