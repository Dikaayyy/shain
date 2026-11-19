import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shain/core/theme/app_theme.dart';
import 'package:shain/features/course/presentation/widgets/video_player_controls.dart';
import 'package:shain/features/course/presentation/widgets/video_status_overlay.dart';
import 'package:video_player/video_player.dart';

class _FakeVideoPlayerController extends VideoPlayerController {
  _FakeVideoPlayerController()
      : super.networkUrl(Uri.parse('https://example.com/video.mp4'));

  int playCalls = 0;
  int pauseCalls = 0;
  final List<Duration> seekTargets = [];

  @override
  Future<void> initialize() async {}

  @override
  Future<void> play() async {
    playCalls++;
    value = value.copyWith(isPlaying: true);
  }

  @override
  Future<void> pause() async {
    pauseCalls++;
    value = value.copyWith(isPlaying: false);
  }

  @override
  Future<void> seekTo(Duration position) async {
    seekTargets.add(position);
    value = value.copyWith(position: position);
  }
}

void main() {
  group('VideoStatusOverlay', () {
    testWidgets('renders loading, buffering, and error states with retry',
        (tester) async {
      final controller = _FakeVideoPlayerController();
      addTearDown(controller.dispose);
      var retried = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: SizedBox(
              width: 360,
              height: 202.5,
              child: VideoStatusOverlay(
                controller: controller,
                onRetry: () => retried = true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Memuat video...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      controller.value = VideoPlayerValue(
        duration: const Duration(seconds: 90),
        size: const Size(1280, 720),
        isInitialized: true,
        isBuffering: true,
      );
      await tester.pump();

      expect(find.text('Menyangga video...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      controller.value = VideoPlayerValue.erroneous('Stream error');
      await tester.pump();

      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
      expect(find.text('Video tidak dapat diputar'), findsOneWidget);
      await tester.tap(find.text('Coba Lagi'));
      expect(retried, isTrue);
    });
  });

  group('VideoPlayerControls', () {
    testWidgets('toggles play/pause and seeks after drag', (tester) async {
      final controller = _FakeVideoPlayerController();
      addTearDown(controller.dispose);
      controller.value = VideoPlayerValue(
        duration: const Duration(seconds: 90),
        position: const Duration(seconds: 10),
        size: const Size(1280, 720),
        isInitialized: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: SizedBox(
              width: 360,
              height: 202.5,
              child: VideoPlayerControls(controller: controller),
            ),
          ),
        ),
      );

      expect(find.text('00:10 / 01:30'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.play_arrow_rounded));
      await tester.pump();
      expect(controller.playCalls, 1);
      expect(find.byIcon(Icons.pause_rounded), findsOneWidget);

      await tester.tap(find.byIcon(Icons.pause_rounded));
      await tester.pump();
      expect(controller.pauseCalls, 1);

      final sliderRect = tester.getRect(find.byType(Slider));
      final gesture = await tester.startGesture(sliderRect.center);
      await gesture.moveTo(
        Offset(sliderRect.left + sliderRect.width * 0.75, sliderRect.center.dy),
      );
      await tester.pump();
      expect(controller.seekTargets, isEmpty);

      await gesture.up();
      await tester.pump();
      expect(controller.seekTargets, hasLength(1));
      expect(controller.seekTargets.first.inSeconds, greaterThan(45));
    });
  });
}
