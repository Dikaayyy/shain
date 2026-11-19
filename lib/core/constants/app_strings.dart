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
  static const String serverErrorTitle = 'Gagal memuat data';
  static const String serverErrorMessage =
      'Terjadi gangguan pada server. Silakan coba beberapa saat lagi.';
  static const String unknownErrorTitle = 'Terjadi kesalahan';
  static const String unknownErrorMessage =
      'Terjadi kesalahan yang tidak diketahui. Silakan coba lagi.';

  static const String backButtonTooltip = 'Kembali';

  static String lessonCountTag(int count) => '$count lesson';
  static String durationMinutesTag(int minutes) => '$minutes menit';
  static String instructorLabel(String name) => 'Oleh $name';
}
