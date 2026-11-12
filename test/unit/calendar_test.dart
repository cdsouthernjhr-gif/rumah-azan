import 'package:flutter_test/flutter_test.dart';
import 'package:rumah_azan/features/islamic_calendar/domain/calendar_service.dart';
import 'package:rumah_azan/features/islamic_calendar/domain/hijri.dart';
import 'package:rumah_azan/features/islamic_calendar/domain/islamic_events.dart';

void main() {
  group('Tabular Hijri', () {
    test('round-trips Hijri → Gregorian → Hijri', () {
      for (final h in const [HijriDate(1446, 1, 1), HijriDate(1447, 9, 1), HijriDate(1448, 12, 10), HijriDate(1450, 2, 29)]) {
        final g = TabularHijri.toGregorian(h);
        expect(TabularHijri.fromGregorian(g), h, reason: '$h → $g');
      }
    });

    test('is within ±1 day of known Malaysian dates (calculated, not official)', () {
      // Awal Muharram 1446 = 7 Jul 2024; Awal Ramadan 1445 = 12 Mar 2024 (Malaysia).
      for (final (h, g) in [
        (const HijriDate(1446, 1, 1), DateTime.utc(2024, 7, 7)),
        (const HijriDate(1445, 9, 1), DateTime.utc(2024, 3, 12)),
      ]) {
        final calc = TabularHijri.toGregorian(h);
        expect(calc.difference(g).inDays.abs(), lessThanOrEqualTo(1), reason: '$h calc=$calc expected≈$g');
      }
    });

    test('user adjustment shifts the calculated date', () {
      final g = DateTime.utc(2026, 11, 12);
      final base = TabularHijri.fromGregorian(g);
      final plus = TabularHijri.fromGregorian(g, adjustDays: 1);
      // +1 → the displayed Hijri date is one day later.
      expect(TabularHijri.toGregorian(plus).difference(TabularHijri.toGregorian(base)).inDays, 1);
      // toGregorian/fromGregorian stay inverse under the same adjustment.
      const h = HijriDate(1448, 9, 1);
      expect(TabularHijri.fromGregorian(TabularHijri.toGregorian(h, adjustDays: 1), adjustDays: 1), h);
    });
  });

  group('CalendarService', () {
    test('prefers JAKIM Hijri over calculation and labels the source', () {
      const svc = CalendarService(jakimHijri: {'2026-11-12': '1448-05-22'});
      final a = svc.hijriFor('2026-11-12');
      expect(a.source, HijriSource.jakim);
      expect(a.date, const HijriDate(1448, 5, 22));
      expect(svc.hijriFor('2026-11-13').source, HijriSource.calculated);
    });

    test('finds calculated events and multi-day Tasyrik', () {
      const svc = CalendarService();
      final g = TabularHijri.toGregorian(const HijriDate(1448, 12, 9));
      final start = '${g.year}-${g.month.toString().padLeft(2, '0')}-${g.day.toString().padLeft(2, '0')}';
      final ev = svc.eventsBetween(start, 6).map((e) => e.def.key).toList();
      expect(ev, ['arafah', 'aidiladha', 'tasyrik', 'tasyrik', 'tasyrik']);
    });

    test('official override replaces the calculated date for that year', () {
      final calc = TabularHijri.toGregorian(const HijriDate(1448, 10, 1));
      String k(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      final official = calc.add(const Duration(days: 1));
      final svc = CalendarService(overrides: [
        OfficialEventDate(eventKey: 'aidilfitri', hijriYear: 1448, dateKey: k(official), source: 'official'),
      ]);
      final events = svc.eventsBetween(k(calc.subtract(const Duration(days: 3))), 10).where((e) => e.def.key == 'aidilfitri').toList();
      expect(events.length, 1);
      expect(events.single.dateKey, k(official));
      expect(events.single.source, HijriSource.official);
    });

    test('all required events are defined', () {
      final keys = islamicEventDefs.map((e) => e.key).toSet();
      expect(keys, containsAll(['awal_muharram', 'asyura', 'maulidur_rasul', 'israk_mikraj', 'nisfu_syaaban',
          'awal_ramadan', 'nuzul_quran', 'aidilfitri', 'arafah', 'aidiladha', 'tasyrik']));
    });
  });
}
