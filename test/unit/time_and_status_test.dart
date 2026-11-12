import 'package:flutter_test/flutter_test.dart';
import 'package:rumah_azan/core/utilities/myt_time.dart';
import 'package:rumah_azan/data/models/prayer_day.dart';
import 'package:rumah_azan/features/prayer_times/domain/prayer_status.dart';

import '../helpers.dart';

void main() {
  group('Myt time helpers', () {
    test('Malaysian civil date is independent of device timezone (UTC+8)', () {
      // 2026-11-12 16:30 UTC == 2026-11-13 00:30 MYT
      expect(Myt.dateKey(DateTime.utc(2026, 11, 12, 16, 30)), '2026-11-13');
      expect(Myt.dateKey(DateTime.utc(2026, 11, 12, 15, 59)), '2026-11-12');
    });

    test('addDays handles month and year rollover', () {
      expect(Myt.addDays('2026-12-31', 1), '2027-01-01');
      expect(Myt.addDays('2028-03-01', -1), '2028-02-29'); // leap year
    });

    test('countdown never goes negative', () {
      expect(Myt.countdown(const Duration(seconds: -5)), '00:00:00');
      expect(Myt.countdown(const Duration(hours: 1, minutes: 2, seconds: 3)), '01:02:03');
    });

    test('inWindow handles windows across midnight', () {
      final start = Myt.parseHm('22:30')!, end = Myt.parseHm('05:00')!;
      expect(Myt.inWindow(Myt.parseHm('23:00')!, start, end), isTrue);
      expect(Myt.inWindow(Myt.parseHm('04:59')!, start, end), isTrue);
      expect(Myt.inWindow(Myt.parseHm('05:00')!, start, end), isFalse);
      expect(Myt.inWindow(Myt.parseHm('12:00')!, start, end), isFalse);
      expect(Myt.parseHm('25:00'), isNull);
    });
  });

  group('Prayer status / countdown engine', () {
    final yesterday = day('2026-11-11');
    final today = day('2026-11-12');
    final tomorrow = day('2026-11-13', subuh: '05:46');

    test('mid-day: next is Asar, current Zohor, countdown correct', () {
      final s = computePrayerStatus(now: myt('2026-11-12', '15:25'), today: today, yesterday: yesterday, tomorrow: tomorrow)!;
      expect(s.next, Prayer.asar);
      expect(s.current, Prayer.zohor);
      expect(s.remaining, const Duration(hours: 1));
      expect(s.progress, closeTo(140 / 200, 0.001)); // 13:05→16:25 is 200 min
      expect(s.nextIsTomorrow, isFalse);
    });

    test('before Subuh: current is yesterday Isyak', () {
      final s = computePrayerStatus(now: myt('2026-11-12', '03:00'), today: today, yesterday: yesterday, tomorrow: tomorrow)!;
      expect(s.next, Prayer.subuh);
      expect(s.current, Prayer.isyak);
      expect(s.previousTime, yesterday.isyak);
    });

    test('after Isyak: rolls over to tomorrow Subuh', () {
      final s = computePrayerStatus(now: myt('2026-11-12', '22:00'), today: today, yesterday: yesterday, tomorrow: tomorrow)!;
      expect(s.next, Prayer.subuh);
      expect(s.nextIsTomorrow, isTrue);
      expect(s.nextTime, tomorrow.subuh);
      expect(s.remaining, const Duration(hours: 7, minutes: 46));
    });

    test('after Isyak without tomorrow data: unknown (no invented time)', () {
      expect(computePrayerStatus(now: myt('2026-11-12', '22:00'), today: today), isNull);
    });

    test('exactly at prayer time switches to the following prayer', () {
      final s = computePrayerStatus(now: today.maghrib, today: today, tomorrow: tomorrow)!;
      expect(s.current, Prayer.maghrib);
      expect(s.next, Prayer.isyak);
    });

    test('Syuruk is a reference time, not obligatory', () {
      expect(Prayer.syuruk.isObligatory, isFalse);
      expect(Prayer.obligatory, isNot(contains(Prayer.syuruk)));
      expect(Prayer.obligatory.length, 5);
    });

    test('consistency check rejects out-of-order times', () {
      expect(today.isConsistent, isTrue);
      expect(day('2026-11-12', asar: '12:00').isConsistent, isFalse);
    });
  });
}
