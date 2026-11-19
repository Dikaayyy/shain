# Dokumentasi Desain Teknis Shain

> Catatan: Folder [`docs/design/`](design/) disiapkan untuk menyimpan tangkapan layar (screenshot) desain Figma.

## (a) Komponen dan Alur Data

```mermaid
flowchart LR
    UI["UI Layer - CourseListPage, CourseDetailPage, LessonPlayerPage"]
    Provider["Riverpod Providers - courseListProvider, courseDetailProvider, courseRepositoryProvider"]
    Repo["Repository - CourseRepository / ApiCourseRepository"]
    Dio["HTTP Client - Dio + ApiConfig"]
    API["Mock / REST API - /courses.json & /courses/{id}.json"]

    UI -->|"ref.watch / ref.invalidate"| Provider
    Provider -->|"getCourses() / getCourseDetail(id)"| Repo
    Repo -->|"GET request"| Dio
    Dio -->|"HTTPS JSON"| API
    API -->|"Response JSON / Error"| Dio
    Dio -->|"List / Map / DioException"| Repo
    Repo -->|"CourseSummary / CourseDetail / AppException"| Provider
    Provider -->|"AsyncValue (loading, data, error)"| UI
```

## (b) Sequence Diagram Pemutaran Video

```mermaid
sequenceDiagram
    actor User as Pengguna
    participant Detail as CourseDetailPage
    participant Router as GoRouter
    participant Player as LessonPlayerPage
    participant VP as VideoPlayerController

    User->>Detail: Pilih lesson
    Detail->>Router: context.push(/courses/:courseId/lessons/:lessonId)
    Router->>Player: Bangun LessonPlayerPage (lessonId A)
    Player->>VP: VideoPlayerController.networkUrl(urlA)
    Player->>VP: initialize()
    VP-->>Player: Siap (isInitialized = true)
    User->>Player: Ketuk tombol Play
    Player->>VP: play()

    User->>Player: Pilih lesson lain (lessonId B)
    Player->>Router: context.pushReplacement(/courses/:courseId/lessons/:lessonIdB)
    Router-->>Player: Mount LessonPlayerPage baru (ValueKey baru)
    Player->>VP: dispose() controller lama (saat page lama unmount)
    Player->>VP: Buat VideoPlayerController baru (urlB) & initialize()

    User->>Player: Ketuk tombol Kembali / Retry
    alt Ketuk tombol Kembali
        Player->>Router: pop() langsung ke CourseDetailPage
        Router-->>Player: Unmount LessonPlayerPage
        Player->>VP: dispose()
    else Ketuk Retry setelah error init
        Player->>VP: Buat controller baru & schedule dispose controller lama pasca-frame
    end
```

## (c) Model Data dan Kontrak API

### 1. Model Data

- **`CourseSummary`** ([`lib/features/course/data/course_summary.dart`](../lib/features/course/data/course_summary.dart))
  - `id` (`String`)
  - `title` (`String`)
  - `description` (`String`)
  - `thumbnailUrl` (`String`)
  - `instructor` (`String`)
  - `lessonCount` (`int`)
  - `totalDurationMinutes` (`int`)
- **`CourseDetail`** ([`lib/features/course/data/course_detail.dart`](../lib/features/course/data/course_detail.dart))
  - `id` (`String`), `title` (`String`), `description` (`String`), `thumbnailUrl` (`String`), `instructor` (`String`)
  - `lessons` (`List<Lesson>`)
  - Getter turunan: `lessonCount` (`lessons.length`) dan `totalDurationMinutes` (`(totalSeconds / 60).round()`)
- **`Lesson`** ([`lib/features/course/data/lesson.dart`](../lib/features/course/data/lesson.dart))
  - `id` (`String`)
  - `order` (`int`)
  - `title` (`String`)
  - `durationSeconds` (`int`)
  - `videoUrl` (`String`)
- **`AppException`** ([`lib/core/network/app_exception.dart`](../lib/core/network/app_exception.dart))
  - Kategori: `AppExceptionType.network` (timeout / `connectionError`), `AppExceptionType.server` (`badResponse` + `statusCode`), `AppExceptionType.unknown` (error lainnya / payload null).

### 2. Kontrak Endpoint & Contoh JSON

#### `GET /courses.json` (API asli: `GET /courses`)

```json
[
  {
    "id": "flutter-basic",
    "title": "Flutter Dasar",
    "description": "Belajar membangun antarmuka mobile yang rapi dan mudah digunakan.",
    "thumbnailUrl": "https://example.com/flutter-basic.jpg",
    "instructor": "Budi Santoso",
    "lessonCount": 4,
    "totalDurationMinutes": 25
  }
]
```

#### `GET /courses/{id}.json` (API asli: `GET /courses/{id}`)

```json
{
  "id": "flutter-basic",
  "title": "Flutter Dasar",
  "description": "Belajar membangun antarmuka mobile yang rapi dan mudah digunakan.",
  "thumbnailUrl": "https://example.com/flutter-basic.jpg",
  "instructor": "Budi Santoso",
  "lessons": [
    {
      "id": "flutter-basic-1",
      "order": 1,
      "title": "Pengenalan Widget Dasar",
      "durationSeconds": 180,
      "videoUrl": "https://example.com/videos/flutter-basic-1.mp4"
    },
    {
      "id": "flutter-basic-2",
      "order": 2,
      "title": "Membuat Layout Responsif",
      "durationSeconds": 240,
      "videoUrl": "https://example.com/videos/flutter-basic-2.mp4"
    }
  ]
}
```
