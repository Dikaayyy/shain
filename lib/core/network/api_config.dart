/// Menyimpan konfigurasi dasar API, endpoint, dan batas waktu jaringan.
class ApiConfig {
  const ApiConfig._();

  static const String baseUrl = 'https://dikaayyy.github.io/elearning-mock-api';
  static const String coursesPath = '/courses.json';
  static String courseDetailPath(String id) => '/courses/$id.json';

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);
}
