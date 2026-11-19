/// Kumpulan teks antarmuka aplikasi Shain berbahasa Indonesia.
class AppStrings {
  const AppStrings._();

  static const String appName = 'Shain';
  static const String courseListTitle = 'Daftar Course';
  static const String courseListSubtitle =
      'Pilih course untuk mulai menonton video materi.';

  static const String emptyCoursesTitle = 'Belum ada course';
  static const String emptyCoursesMessage =
      'Course akan muncul di sini begitu tersedia.';
  static const String reloadButton = 'Muat Ulang';
  static const String retryButton = 'Coba Lagi';

  static const String networkErrorTitle = 'Koneksi bermasalah';
  static const String networkErrorMessage =
      'Periksa internetmu lalu coba lagi.';
  static const String serverErrorTitle = 'Gagal memuat course';
  static const String serverErrorMessage =
      'Server sedang sibuk. Silakan coba lagi beberapa saat.';
  static const String unknownErrorTitle = 'Terjadi kesalahan';
  static const String unknownErrorMessage =
      'Terjadi kesalahan yang tidak diketahui. Silakan coba lagi.';

  static const String backButtonTooltip = 'Kembali';

  static const String courseDetailTitle = 'Detail Course';
  static const String aboutCourseSectionTitle = 'Tentang course';
  static const String lessonListSectionTitle = 'Daftar Lesson';
  static const String startFirstLessonButton = 'Mulai dari Lesson 1';

  static const String lessonPlayerTitle = 'Pemutar Video';
  static const String otherLessonsSectionTitle = 'Lesson lainnya';
  static const String videoLoadingText = 'Memuat video...';
  static const String videoBufferingText = 'Menyangga video...';
  static const String videoErrorText = 'Video tidak dapat diputar';
  static const String playPauseTooltip = 'Putar atau jeda video';

  static String lessonCountTag(int count) => '$count lesson';
  static String durationMinutesTag(int minutes) => '$minutes menit';
  static String instructorLabel(String name) => 'Oleh $name';
  static String activeLessonDuration(String mmss) => '$mmss · Sedang diputar';
  static String lessonPositionMeta({
    required int order,
    required int total,
    required String courseTitle,
  }) =>
      'Lesson $order dari $total · $courseTitle';
}
