import '../../core/l10n/l10n.dart';
import '../../core/utilities/myt_time.dart';
import '../../data/models/prayer_day.dart';
import '../../data/models/prayer_zone.dart';
import '../countdown/day_countdown.dart';
import '../islamic_calendar/domain/calendar_service.dart';

/// Builds the data the Android home-screen widget renders. The widget
/// itself (Kotlin) only picks the right day/next prayer for "now", so it
/// stays correct between app runs; everything language- or calendar-related
/// is prepared here.
Map<String, Object?> buildWidgetPayload({
  required L10n l10n,
  required PrayerZone? zone,
  required List<PrayerDay> days,
  required CalendarService calendar,
  required List<CountdownTarget> pinnedCountdowns,
}) {
  String gregorian(String key) {
    final d = Myt.parseDateKey(key);
    return '${l10n.t('day_${d.weekday}')}, ${d.day} ${l10n.t('month_${d.month}')} ${d.year}';
  }

  final upcoming = pinnedCountdowns.where((t) => t.days != null && t.days! >= 0 && t.dateKey != null).firstOrNull;
  return {
    'version': 1,
    'zone': zone == null ? '' : '${zone.code} · ${zone.areas}',
    'labels': {
      'next': l10n.t('next_prayer'),
      'noData': l10n.t('widget_no_data'),
      'estimate': l10n.t('estimate_short'),
      'cdToday': l10n.t('cd_today'),
      'cdTomorrow': l10n.t('cd_tomorrow'),
      'cdDaysLeft': l10n.t('cd_days_left'), // contains {n}
      'prayers': [for (final p in Prayer.values) l10n.t('prayer_${p.name}')],
    },
    'days': [
      for (final d in days)
        {
          'date': d.date,
          'gregorian': gregorian(d.date),
          'hijri': calendar.hijriFor(d.date).date.format(l10n.lang),
          'estimated': !d.source.isVerified,
          'times': [for (final p in Prayer.values) d.timeOf(p).millisecondsSinceEpoch],
        },
    ],
    'countdown': upcoming == null
        ? null
        : {
            'title': upcoming.countdown.title,
            'dateKey': upcoming.dateKey,
            'calculated': upcoming.isCalculated,
          },
  };
}
