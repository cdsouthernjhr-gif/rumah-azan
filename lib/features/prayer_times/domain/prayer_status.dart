import '../../../data/models/prayer_day.dart';

/// Snapshot of where "now" sits in the prayer timetable.
class PrayerStatus {
  const PrayerStatus({
    required this.current,
    required this.next,
    required this.nextTime,
    required this.previousTime,
    required this.now,
    required this.nextIsTomorrow,
  });

  /// Current period (the last time that has passed); null if unknown.
  final Prayer? current;
  final Prayer next;
  final DateTime nextTime;
  final DateTime? previousTime;
  final DateTime now;
  final bool nextIsTomorrow;

  /// Never negative.
  Duration get remaining {
    final d = nextTime.difference(now);
    return d.isNegative ? Duration.zero : d;
  }

  /// 0..1 progress from the previous time to the next time.
  double get progress {
    if (previousTime == null) return 0;
    final total = nextTime.difference(previousTime!).inMilliseconds;
    if (total <= 0) return 0;
    return (now.difference(previousTime!).inMilliseconds / total).clamp(0.0, 1.0);
  }
}

/// Computes the status. Works across midnight: before today's Subuh the
/// current period is yesterday's Isyak; after today's Isyak the next prayer is
/// tomorrow's Subuh. Returns null if there is not enough data to know the next
/// time (e.g. after Isyak with no timetable for tomorrow).
PrayerStatus? computePrayerStatus({
  required DateTime now,
  required PrayerDay? today,
  PrayerDay? yesterday,
  PrayerDay? tomorrow,
}) {
  if (today == null) {
    if (tomorrow != null && now.isBefore(tomorrow.subuh)) {
      return PrayerStatus(
        current: yesterday == null ? null : Prayer.isyak,
        next: Prayer.subuh,
        nextTime: tomorrow.subuh,
        previousTime: yesterday?.isyak,
        now: now,
        nextIsTomorrow: true,
      );
    }
    return null;
  }

  Prayer? current;
  DateTime? prev;
  for (final p in Prayer.values) {
    final t = today.timeOf(p);
    if (!t.isAfter(now)) {
      current = p;
      prev = t;
    } else {
      if (current == null && yesterday != null) {
        current = Prayer.isyak;
        prev = yesterday.isyak;
      }
      return PrayerStatus(
        current: current,
        next: p,
        nextTime: t,
        previousTime: prev,
        now: now,
        nextIsTomorrow: false,
      );
    }
  }
  // After Isyak.
  if (tomorrow == null) return null;
  return PrayerStatus(
    current: Prayer.isyak,
    next: Prayer.subuh,
    nextTime: tomorrow.subuh,
    previousTime: today.isyak,
    now: now,
    nextIsTomorrow: true,
  );
}
