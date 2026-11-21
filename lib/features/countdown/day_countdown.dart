import '../../core/utilities/myt_time.dart';
import '../islamic_calendar/domain/calendar_service.dart';

/// A user-defined "how many days until …" countdown.
///
/// Either a fixed Gregorian [dateKey] (optionally repeating every year, e.g.
/// birthdays/anniversaries) or an Islamic event ([eventKey]) whose next
/// date comes from the Hijri calendar (official / JAKIM / calculated).
class DayCountdown {
  const DayCountdown({
    required this.id,
    required this.title,
    this.dateKey,
    this.eventKey,
    this.yearly = false,
    this.pinned = true,
  });

  final String id;
  final String title;
  final String? dateKey; // yyyy-MM-dd
  final String? eventKey; // e.g. awal_ramadan
  final bool yearly;

  /// Shown on the dashboard, in Display Mode and on the home-screen widget.
  final bool pinned;

  bool get isEvent => eventKey != null;

  Map<String, Object?> toJson() => {
        'id': id,
        'title': title,
        'dateKey': dateKey,
        'eventKey': eventKey,
        'yearly': yearly,
        'pinned': pinned,
      };

  static DayCountdown? fromJson(Object? j) {
    if (j is! Map) return null;
    final id = j['id'], title = j['title'];
    final date = j['dateKey'], event = j['eventKey'];
    if (id is! String || title is! String) return null;
    if (date is! String && event is! String) return null;
    if (date is String && !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(date)) return null;
    return DayCountdown(
      id: id,
      title: title,
      dateKey: date is String ? date : null,
      eventKey: event is String ? event : null,
      yearly: j['yearly'] == true,
      pinned: j['pinned'] != false,
    );
  }

  DayCountdown copyWith({String? title, bool? pinned}) => DayCountdown(
        id: id,
        title: title ?? this.title,
        dateKey: dateKey,
        eventKey: eventKey,
        yearly: yearly,
        pinned: pinned ?? this.pinned,
      );
}

/// Resolved target of a countdown for a given "today".
class CountdownTarget {
  const CountdownTarget({required this.countdown, required this.dateKey, required this.days, this.source});
  final DayCountdown countdown;

  /// Null when an event has no occurrence in the search window.
  final String? dateKey;

  /// Days from today (0 = today, negative = past). Null if unknown.
  final int? days;

  /// For events: how the date was determined.
  final HijriSource? source;

  bool get isCalculated => source == HijriSource.calculated;
}

int daysBetween(String fromKey, String toKey) =>
    Myt.parseDateKey(toKey).difference(Myt.parseDateKey(fromKey)).inDays;

/// Next yearly anniversary of [dateKey] on or after [todayKey]. 29 Feb falls
/// on 28 Feb in non-leap years.
String nextAnniversary(String dateKey, String todayKey) {
  final d = Myt.parseDateKey(dateKey);
  final t = Myt.parseDateKey(todayKey);
  String inYear(int y) {
    var day = d.day;
    final lastDay = DateTime.utc(y, d.month + 1, 0).day;
    if (day > lastDay) day = lastDay;
    return Myt.dateKeyFromWall(DateTime.utc(y, d.month, day));
  }

  final thisYear = inYear(t.year);
  return thisYear.compareTo(todayKey) >= 0 ? thisYear : inYear(t.year + 1);
}

/// Resolves [c] relative to [todayKey]. Events are looked up within the next
/// ~13 months in [calendar].
CountdownTarget resolveCountdown(DayCountdown c, String todayKey, CalendarService calendar) {
  if (c.eventKey != null) {
    final occ = calendar.eventsBetween(todayKey, 400).where((e) => e.def.key == c.eventKey).firstOrNull;
    if (occ == null) return CountdownTarget(countdown: c, dateKey: null, days: null);
    return CountdownTarget(
      countdown: c,
      dateKey: occ.dateKey,
      days: daysBetween(todayKey, occ.dateKey),
      source: occ.source,
    );
  }
  final target = c.yearly ? nextAnniversary(c.dateKey!, todayKey) : c.dateKey!;
  return CountdownTarget(countdown: c, dateKey: target, days: daysBetween(todayKey, target));
}

/// Upcoming first (today, then soonest), past ones last, unknown at the end.
List<CountdownTarget> sortTargets(List<CountdownTarget> list) {
  int rank(CountdownTarget t) => t.days == null ? 2 : (t.days! < 0 ? 1 : 0);
  return [...list]..sort((a, b) {
      final r = rank(a).compareTo(rank(b));
      if (r != 0) return r;
      if (a.days == null || b.days == null) return 0;
      return rank(a) == 1 ? b.days!.compareTo(a.days!) : a.days!.compareTo(b.days!);
    });
}

/// l10n key + args for "n days left" style labels.
(String, Map<String, Object?>) daysLabel(int? days) {
  if (days == null) return ('cd_unknown', const {});
  if (days == 0) return ('cd_today', const {});
  if (days == 1) return ('cd_tomorrow', const {});
  if (days > 1) return ('cd_days_left', {'n': days});
  if (days == -1) return ('cd_yesterday', const {});
  return ('cd_days_ago', {'n': -days});
}
