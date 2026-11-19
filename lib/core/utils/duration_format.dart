import 'package:shain/core/constants/app_strings.dart';

/// Utilitas pemformatan durasi dalam menit dan detik untuk tampilan UI.
class DurationFormat {
  const DurationFormat._();

  static String minutesLabel(int minutes) =>
      AppStrings.durationMinutesTag(minutes);

  static String formatSeconds(int totalSeconds) {
    final clamped = totalSeconds < 0 ? 0 : totalSeconds;
    final minutes = (clamped ~/ 60).toString().padLeft(2, '0');
    final seconds = (clamped % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
