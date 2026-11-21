import 'package:flutter_test/flutter_test.dart';
import 'package:rumah_azan/core/l10n/l10n.dart';
import 'package:rumah_azan/data/static/jakim_zones.dart';
import 'package:rumah_azan/features/countdown/day_countdown.dart';
import 'package:rumah_azan/features/home_widget/widget_payload.dart';
import 'package:rumah_azan/features/islamic_calendar/domain/calendar_service.dart';
import 'package:rumah_azan/features/islamic_calendar/domain/hijri.dart';

import '../helpers.dart';

String key(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

void main() {
  group('Day countdown', () {
    test('fixed date: days until, today, past', () {
      const cal = CalendarService();
      const c = DayCountdown(id: '1', title: 'Trip', dateKey: '2026-12-25');
      expect(resolveCountdown(c, '2026-11-21', cal).days, 34);
      expect(resolveCountdown(c, '2026-12-25', cal).days, 0);
      expect(resolveCountdown(c, '2026-12-27', cal).days, -2);
    });

    test('yearly: next anniversary, including 29 Feb in non-leap years', () {
      expect(nextAnniversary('1990-05-10', '2026-11-21'), '2027-05-10');
      expect(nextAnniversary('1990-12-01', '2026-11-21'), '2026-12-01');
      expect(nextAnniversary('1990-11-21', '2026-11-21'), '2026-11-21', reason: 'today counts');
      expect(nextAnniversary('2000-02-29', '2026-11-21'), '2027-02-28');
      expect(nextAnniversary('2000-02-29', '2027-03-01'), '2028-02-29');
      const c = DayCountdown(id: '2', title: 'Hari jadi', dateKey: '1990-12-01', yearly: true);
      expect(resolveCountdown(c, '2026-11-21', const CalendarService()).days, 10);
    });

    test('Islamic event: next occurrence from the calendar; official date wins', () {
      final ramadan = TabularHijri.toGregorian(const HijriDate(1448, 9, 1));
      const c = DayCountdown(id: '3', title: 'Ramadan', eventKey: 'awal_ramadan');
      final calc = resolveCountdown(c, '2026-11-21', const CalendarService());
      expect(calc.dateKey, key(ramadan));
      expect(calc.isCalculated, isTrue);
      final official = ramadan.add(const Duration(days: 1));
      final cal = CalendarService(overrides: [
        OfficialEventDate(eventKey: 'awal_ramadan', hijriYear: 1448, dateKey: key(official), source: 'official'),
      ]);
      final t = resolveCountdown(c, '2026-11-21', cal);
      expect(t.dateKey, key(official));
      expect(t.source, HijriSource.official);
      expect(t.isCalculated, isFalse);
    });

    test('sorting: today/soonest first, then past, unknown last', () {
      CountdownTarget t(String id, int? days) =>
          CountdownTarget(countdown: DayCountdown(id: id, title: id, dateKey: '2026-01-01'), dateKey: null, days: days);
      final sorted = sortTargets([t('past1', -1), t('far', 50), t('unknown', null), t('today', 0), t('past9', -9), t('soon', 3)]);
      expect(sorted.map((e) => e.countdown.id).toList(), ['today', 'soon', 'far', 'past1', 'past9', 'unknown']);
    });

    test('labels and JSON validation', () {
      expect(daysLabel(0).$1, 'cd_today');
      expect(daysLabel(1).$1, 'cd_tomorrow');
      expect(daysLabel(12).$1, 'cd_days_left');
      expect(daysLabel(12).$2['n'], 12);
      expect(daysLabel(-3).$1, 'cd_days_ago');
      expect(daysLabel(-3).$2['n'], 3);
      expect(daysLabel(null).$1, 'cd_unknown');
      const c = DayCountdown(id: 'x', title: 'T', dateKey: '2027-01-01', yearly: true, pinned: false);
      final back = DayCountdown.fromJson(c.toJson())!;
      expect(back.yearly, isTrue);
      expect(back.pinned, isFalse);
      expect(DayCountdown.fromJson({'id': 'x', 'title': 'T'}), isNull, reason: 'needs a date or an event');
      expect(DayCountdown.fromJson({'id': 'x', 'title': 'T', 'dateKey': '21/11/2026'}), isNull);
      expect(DayCountdown.fromJson('junk'), isNull);
    });
  });

  group('Home-screen widget payload', () {
    test('contains localised labels, 6 times per day and the first upcoming pinned countdown', () {
      const cal = CalendarService(jakimHijri: {'2026-11-21': '1448-06-11'});
      final past = CountdownTarget(
        countdown: const DayCountdown(id: 'p', title: 'Lepas', dateKey: '2026-11-01'),
        dateKey: '2026-11-01',
        days: -20,
      );
      final next = CountdownTarget(
        countdown: const DayCountdown(id: 'n', title: 'Hari Raya', eventKey: 'aidilfitri'),
        dateKey: '2027-03-10',
        days: 109,
        source: HijriSource.calculated,
      );
      final p = buildWidgetPayload(
        l10n: const L10n('ms'),
        zone: zoneByCode('JHR03'),
        days: [day('2026-11-21'), day('2026-11-22')],
        calendar: cal,
        pinnedCountdowns: [past, next],
      );
      expect(p['zone'], 'JHR03 · Kluang, Pontian');
      final labels = p['labels'] as Map;
      expect(labels['prayers'], ['Subuh', 'Syuruk', 'Zohor', 'Asar', 'Maghrib', 'Isyak']);
      expect(labels['cdDaysLeft'], '{n} hari lagi');
      final days = p['days'] as List;
      expect(days.length, 2);
      final d0 = days.first as Map;
      expect(d0['date'], '2026-11-21');
      expect(d0['gregorian'], 'Sabtu, 21 November 2026');
      expect(d0['hijri'], '11 Jamadilakhir 1448 H');
      expect((d0['times'] as List).length, 6);
      expect((d0['times'] as List).first, myt('2026-11-21', '05:45').millisecondsSinceEpoch);
      expect(d0['estimated'], isFalse);
      final cd = p['countdown'] as Map;
      expect(cd['title'], 'Hari Raya', reason: 'past countdown skipped');
      expect(cd['dateKey'], '2027-03-10');
      expect(cd['calculated'], isTrue);
    });

    test('no countdown and English labels', () {
      final p = buildWidgetPayload(
        l10n: const L10n('en'),
        zone: null,
        days: const [],
        calendar: const CalendarService(),
        pinnedCountdowns: const [],
      );
      expect(p['countdown'], isNull);
      expect((p['labels'] as Map)['next'], 'Next prayer');
      expect(p['zone'], '');
    });
  });
}
