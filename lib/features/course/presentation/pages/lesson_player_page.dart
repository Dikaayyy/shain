import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shain/core/constants/app_strings.dart';
import 'package:shain/core/network/app_exception.dart';
import 'package:shain/core/router/app_router.dart';
import 'package:shain/core/theme/app_colors.dart';
import 'package:shain/core/theme/app_spacing.dart';
import 'package:shain/core/theme/app_text_styles.dart';
import 'package:shain/features/course/data/course_detail.dart';
import 'package:shain/features/course/data/lesson.dart';
import 'package:shain/features/course/presentation/widgets/lesson_tile.dart';
import 'package:shain/features/course/presentation/widgets/lesson_video_viewport.dart';
import 'package:shain/features/course/providers/course_providers.dart';
import 'package:shain/shared/widgets/app_top_bar.dart';
import 'package:shain/shared/widgets/error_view.dart';
import 'package:video_player/video_player.dart';

/// Halaman pemutar video lesson dengan kontrol playback streaming dan daftar lesson lain.
class LessonPlayerPage extends ConsumerStatefulWidget {
  const LessonPlayerPage({super.key, required this.courseId, required this.lessonId});

  final String courseId;
  final String lessonId;

  @override
  ConsumerState<LessonPlayerPage> createState() => _LessonPlayerPageState();
}

class _LessonPlayerPageState extends ConsumerState<LessonPlayerPage>
    with WidgetsBindingObserver {
  ProviderSubscription<AsyncValue<CourseDetail>>? _detailSubscription;
  VideoPlayerController? _controller;
  String? _activeVideoUrl;
  bool _hasInitError = false;
  bool _didFinishInitState = false;
  bool _isFullScreen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _detailSubscription = ref.listenManual<AsyncValue<CourseDetail>>(
      courseDetailProvider(widget.courseId),
      (_, next) {
        if (next case AsyncData<CourseDetail>(:final value)) {
          if (_activeVideoUrl != null) return;
          final lesson = _findLesson(value);
          if (lesson != null) _initController(lesson.videoUrl);
        }
      },
      fireImmediately: true,
    );
    _didFinishInitState = true;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      final controller = _controller;
      if (controller != null && controller.value.isPlaying) controller.pause();
    }
  }

  @override
  void dispose() {
    if (_isFullScreen) _applySystemUiForFullScreen(false);
    WidgetsBinding.instance.removeObserver(this);
    _detailSubscription?.close();
    _controller?.dispose();
    super.dispose();
  }

  void _setFullScreen(bool value) {
    if (_isFullScreen == value) return;
    _applySystemUiForFullScreen(value);
    setState(() => _isFullScreen = value);
  }

  void _applySystemUiForFullScreen(bool isFullScreen) {
    if (isFullScreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      SystemChrome.setPreferredOrientations(const [
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setPreferredOrientations(const [
        DeviceOrientation.portraitUp,
      ]);
    }
  }

  Future<void> _initController(String videoUrl) async {
    _activeVideoUrl = videoUrl;
    final previousController = _controller;
    final controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
    _controller = controller;
    _hasInitError = false;

    if (previousController != null) {
      if (mounted) setState(() {});
      // Dispose controller lama setelah frame rebuild selesai agar aman dari listener aktif.
      WidgetsBinding.instance.addPostFrameCallback((_) => previousController.dispose());
    } else if (_didFinishInitState && mounted) {
      setState(() {});
    }

    try {
      await controller.initialize();
      if (!mounted || _controller != controller) return;
      setState(() {});
    } catch (_) {
      if (!mounted || _controller != controller) return;
      setState(() => _hasInitError = true);
    }
  }

  Lesson? _findLesson(CourseDetail course) {
    for (final lesson in course.lessons) {
      if (lesson.id == widget.lessonId) return lesson;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(courseDetailProvider(widget.courseId));

    return PopScope(
      canPop: !_isFullScreen,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _isFullScreen) _setFullScreen(false);
      },
      child: Scaffold(
        backgroundColor: _isFullScreen ? AppColors.ink : null,
        appBar: _isFullScreen
            ? null
            : AppTopBar(
                title: AppStrings.lessonPlayerTitle,
                onBack: () => _handleBack(context),
              ),
        body: detailAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.sky)),
          error: (error, _) => ErrorView.fromError(
            error: error,
            onRetry: () => ref.invalidate(courseDetailProvider(widget.courseId)),
          ),
          data: (course) {
            final currentLesson = _findLesson(course);
            if (currentLesson == null) {
              return ErrorView.fromError(
                error: AppException.unknown(),
                onRetry: () => ref.invalidate(courseDetailProvider(widget.courseId)),
              );
            }

            final viewport = LessonVideoViewport(
              controller: _controller,
              hasInitError: _hasInitError,
              isFullScreen: _isFullScreen,
              onToggleFullScreen: () => _setFullScreen(!_isFullScreen),
              onRetry: () => _initController(currentLesson.videoUrl),
            );

            if (_isFullScreen) return viewport;

            final sortedLessons = List<Lesson>.of(course.lessons)
              ..sort((a, b) => a.order.compareTo(b.order));

            return ListView(
              children: [
                viewport,
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.pageHorizontal,
                    vertical: AppSpacing.s24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(currentLesson.title, style: AppTextStyles.displayH3),
                      const SizedBox(height: AppSpacing.s8),
                      Text(
                        AppStrings.lessonPositionMeta(
                          order: currentLesson.order,
                          total: sortedLessons.length,
                          courseTitle: course.title,
                        ),
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.inkMuted),
                      ),
                      const SizedBox(height: AppSpacing.sectionGap),
                      const Text(AppStrings.otherLessonsSectionTitle, style: AppTextStyles.displayH3),
                      const SizedBox(height: AppSpacing.s16),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: sortedLessons.length,
                        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.cardGap),
                        itemBuilder: (context, index) {
                          final lesson = sortedLessons[index];
                          final isActive = lesson.id == currentLesson.id;
                          return LessonTile(
                            lesson: lesson,
                            isActive: isActive,
                            onTap: isActive
                                ? null
                                : () => context.pushReplacement(
                                      AppRouter.lessonPlayerPath(course.id, lesson.id),
                                    ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _handleBack(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      GoRouter.maybeOf(context)?.go(AppRouter.courseDetailPath(widget.courseId));
    }
  }
}
