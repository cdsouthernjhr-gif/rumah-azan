import '../constants/app_constants.dart';

/// Helpers for Malaysian time (MYT, UTC+8).
///
/// Prayer times are stored as absolute instants (UTC [DateTime]). For display
/// and for "which civil day is it in Malaysia", we convert to a *wall clock*
/// representation: a UTC DateTime whose fields equal the Malaysian clock.
/// This keeps behaviour correct even if the device timezone is set wrongly.
class Myt {
  Myt._();

  /// Overridable clock for tests.
  static DateTime Function() clock = DateTime.now;

  static DateTime nowInstant() => clock().toUtc();

  /// Wall-clock representation (fields = Malaysian local time).
  static DateTime toWall(DateTime instant) =>
      instant.toUtc().add(AppConstants.mytOffset);

  static DateTime nowWall() => toWall(nowInstant());

  /// Converts Malaysian wall-clock fields to an absolute instant.
  static DateTime instantFromWall(
    int year,
    int month,
    int day, [
    int hour = 0,
    int minute = 0,
    int second = 0,
  ]) =>
      DateTime.utc(year, month, day, hour, minute, second)
          .subtract(AppConstants.mytOffset);

  /// yyyy-MM-dd key of the Malaysian civil date for [instant].
  static String dateKey(DateTime instant) => dateKeyFromWall(toWall(instant));

  static String dateKeyFromWall(DateTime wall) =>
      '${wall.year.toString().padLeft(4, '0')}-'
      '${wall.month.toString().padLeft(2, '0')}-'
      '${wall.day.toString().padLeft(2, '0')}';

  static String todayKey() => dateKey(nowInstant());

  /// Parses yyyy-MM-dd into a wall-clock midnight DateTime (UTC fields).
  static DateTime parseDateKey(String key) {
    final p = key.split('-').map(int.parse).toList();
    return DateTime.utc(p[0], p[1], p[2]);
  }

  static String addDays(String key, int days) =>
      dateKeyFromWall(parseDateKey(key).add(Duration(days: days)));

  static String hhmm(DateTime instant) {
    final w = toWall(instant);
    return '${w.hour.toString().padLeft(2, '0')}:${w.minute.toString().padLeft(2, '0')}';
  }

  static String hhmmss(DateTime instant) {
    final w = toWall(instant);
    return '${hhmm(instant)}:${w.second.toString().padLeft(2, '0')}';
  }

  /// Formats a non-negative duration as HH:MM:SS (negative clamps to zero).
  static String countdown(Duration d) {
    if (d.isNegative) d = Duration.zero;
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    return '${h.toString().padLeft(2, '0')}:'
        '${m.toString().padLeft(2, '0')}:'
        '${s.toString().padLeft(2, '0')}';
  }

  /// Parses "HH:mm" into minutes from midnight; returns null if invalid.
  static int? parseHm(String s) {
    final m = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(s.trim());
    if (m == null) return null;
    final h = int.parse(m.group(1)!);
    final mi = int.parse(m.group(2)!);
    if (h > 23 || mi > 59) return null;
    return h * 60 + mi;
  }

  static String formatHm(int minutes) =>
      '${(minutes ~/ 60).toString().padLeft(2, '0')}:${(minutes % 60).toString().padLeft(2, '0')}';

  /// True if wall-clock minute-of-day [now] lies in [start,end), handling
  /// windows that cross midnight (e.g. 22:30 → 05:00).
  static bool inWindow(int now, int start, int end) {
    if (start == end) return false;
    if (start < end) return now >= start && now < end;
    return now >= start || now < end;
  }
}
