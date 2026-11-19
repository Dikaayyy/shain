# Shain

Aplikasi mobile e-learning berbasis Flutter untuk melihat daftar course, membaca detail materi, dan memutar video lesson secara streaming dengan antarmuka yang bersih, kontras tinggi, dan target sentuh ramah pengguna (`>= 56x56`).

## Requirement

- **Flutter**: `3.47.2` (channel stable)
- **Dart SDK**: `^3.13.2`
- Perangkat/emulator Android (dengan izin `INTERNET` aktif di `android/app/src/main/AndroidManifest.xml`)

## Instalasi

```bash
flutter pub get
```

## Konfigurasi Base URL

Seluruh konfigurasi jaringan berada di [`lib/core/network/api_config.dart`](lib/core/network/api_config.dart):

```dart
static const String baseUrl = 'https://dikaayyy.github.io/elearning-mock-api';
static const String coursesPath = '/courses.json';
static String courseDetailPath(String id) => '/courses/$id.json';
```

Batas waktu koneksi (`connectTimeout`) dan penerimaan data (`receiveTimeout`) masing-masing disetel ke `10 detik`.

## Cara Menjalankan

```bash
# Menjalankan aplikasi pada device/emulator aktif
flutter run

# Analisis statis kode
flutter analyze

# Menjalankan seluruh unit dan widget test
flutter test
```

## Struktur Folder

```text
lib/
├── app.dart                               # Root MaterialApp.router & tema global
├── main.dart                              # Entry point dengan ProviderScope
├── core/
│   ├── constants/app_strings.dart         # Seluruh string UI bahasa Indonesia
│   ├── network/                           # ApiConfig & AppException
│   ├── router/app_router.dart             # Provider & konfigurasi GoRouter + errorBuilder
│   ├── theme/                             # Token warna, radius, spacing, tipografi, ThemeData
│   └── utils/duration_format.dart         # Formatter menit & mm:ss
├── features/
│   └── course/
│       ├── data/                          # Model (CourseSummary, CourseDetail, Lesson) & repository
│       ├── providers/course_providers.dart# Dio, repository, list & detail providers
│       └── presentation/
│           ├── pages/                     # CourseListPage, CourseDetailPage, LessonPlayerPage
│           └── widgets/                   # Kartu, thumbnail, skeleton, tile, kontrol video
└── shared/
    └── widgets/                           # AppTopBar, PrimaryButton, SecondaryButton, Empty/ErrorView, SkeletonBox
docs/
├── design.md                              # Diagram arsitektur, sequence video, & kontrak API
└── design/                                # Folder untuk screenshot desain Figma
test/
├── stage1_test.dart                       # Test model, mapping DioException, & CourseListPage
└── stage2_test.dart                       # Test detail, widget video, & alur penuh GoRouter
```

## Pemilihan Package

- **`flutter_riverpod`**: Manajemen state dan dependency injection yang terstruktur, mudah di-override pada pengujian, serta mendukung `autoDispose.family` untuk detail course.
- **`go_router`**: Navigasi deklaratif berbasis URL path (`/`, `/courses/:courseId`, `/courses/:courseId/lessons/:lessonId`), mendukung `pushReplacement` saat berpindah lesson dan `errorBuilder` untuk route tidak dikenal.
- **`dio`**: HTTP client dengan konfigurasi `BaseOptions` (`baseUrl`, timeout) dan `DioException` terstruktur yang dipetakan ke `AppException`.
- **`video_player`**: Pemutar video resmi Flutter untuk memutar video MP4/HLS secara streaming dari URL.
- **Alasan tanpa `chewie`**: Kontrol pemutar video dibuat custom (`VideoPlayerControls` dan `VideoStatusOverlay`) agar ukuran tombol sentuh (`64x64`), tinggi seek bar (`56`), warna token Figma, dan teks status berbahasa Indonesia seragam dengan desain aplikasi tanpa terikat tema bawaan `chewie`.

## Alasan Streaming vs Download

Video diputar secara **streaming langsung** melalui `VideoPlayerController.networkUrl(...)` (bukan mengunduh file terlebih dahulu sebelum diputar) karena:
1. Pemutaran dapat dimulai lebih cepat tanpa menunggu seluruh berkas video selesai diunduh.
2. Tidak membebani ruang penyimpanan (storage) perangkat pengguna dan tidak memerlukan manajemen file lokal maupun pembersihan cache.

## Alur Data Satu Fitur (Course List)

1. **UI (`CourseListPage`)**: Melakukan `ref.watch(courseListProvider)` dan merender 3 `CourseCardSkeleton` saat loading, `EmptyView` saat list kosong, `ErrorView` saat error, atau daftar `CourseCard` saat data tersedia.
2. **Provider (`courseListProvider`)**: Memanggil `ref.watch(courseRepositoryProvider).getCourses()`.
3. **Repository (`ApiCourseRepository`)**: Memanggil `_dio.get<List<dynamic>>(ApiConfig.coursesPath)`.
4. **Network (`Dio` -> API)**: Mengambil JSON dari `GET https://dikaayyy.github.io/elearning-mock-api/courses.json`.
5. **Mapping**: JSON dikonversi menjadi `List<CourseSummary>`. Jika terjadi `DioException`, repository memetakannya menjadi `AppException.network()`, `AppException.server(statusCode)`, atau `AppException.unknown()`.
6. **UI Update**: Riverpod memperbarui `AsyncValue<List<CourseSummary>>`, lalu `CourseListPage` menampilkan kartu course atau pesan error ramah pengguna beserta tombol coba lagi.

## Mengganti Mock API dengan API Asli

Saat beralih dari mock API statis ke backend REST API produksi:
1. Buka [`lib/core/network/api_config.dart`](lib/core/network/api_config.dart).
2. Ganti nilai `baseUrl` ke URL server backend Anda.
3. Ubah path endpoint dengan menghapus akhiran `.json`:
   - `coursesPath = '/courses'`
   - `courseDetailPath(String id) => '/courses/$id'`
4. Pastikan struktur JSON respons backend tetap mengikuti kontrak pada [`docs/design.md`](docs/design.md).

## Catatan Desain & Akses

- **Tipografi**: Menggunakan font bawaan platform (tanpa `fontFamily` kustom pada `AppTextStyles`) agar ringan dan konsisten di Android/iOS.
- **Akun Demo**: Tidak ada akun demo maupun layar login karena aplikasi langsung menampilkan katalog course publik.

## Asumsi dan Keterbatasan

- **Konten Placeholder**: Thumbnail dan URL video pada mock API menggunakan media placeholder publik untuk kebutuhan demonstrasi.
- **Tanpa Autentikasi**: Belum tersedia login, token sesi, atau otorisasi pengguna.
- **Tanpa Cache Offline**: Seluruh data course dan video membutuhkan koneksi internet aktif; tidak ada penyimpanan offline maupun fitur unduh materi.
- **Belum Ada Persistensi Progres**: Status lesson yang sedang diputar hanya berlaku di sesi layar aktif dan belum menyimpan riwayat atau posisi terakhir menonton.
- **Orientasi Portrait**: Tata letak difokuskan pada tampilan portrait dengan rasio viewport video `16:9` (belum ada mode fullscreen landscape).
