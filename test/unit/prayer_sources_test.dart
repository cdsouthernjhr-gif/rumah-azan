import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:rumah_azan/core/utilities/myt_time.dart';
import 'package:rumah_azan/data/models/prayer_day.dart';
import 'package:rumah_azan/data/remote/estimate_calculator.dart';
import 'package:rumah_azan/data/remote/prayer_time_provider.dart';

/// NOTE: these fixtures exercise the parser against the documented response
/// SHAPE of each source. The times are synthetic test values, not real
/// timetable data, and are never shipped in the app.
Map<String, dynamic> esolatFixture({String zone = 'JHR03', String status = 'OK!'}) => {
      'prayerTime': [
        {
          'hijri': '1448-05-22',
          'date': '12-Nov-2026',
          'day': 'Thursday',
          'imsak': '05:31:00',
          'fajr': '05:41:00',
          'syuruk': '06:58:00',
          'dhuhr': '12:58:00',
          'asr': '16:19:00',
          'maghrib': '18:54:00',
          'isha': '20:07:00',
        },
        {
          // Malay month abbreviation is accepted.
          'hijri': '1448-05-23', 'date': '13-Ogo-2026', 'imsak': '05:31:00', 'fajr': '05:41:00',
          'syuruk': '06:58:00', 'dhuhr': '12:58:00', 'asr': '16:19:00', 'maghrib': '18:54:00', 'isha': '20:07:00',
        },
        {
          // Inconsistent (Asar before Zohor) → must be dropped.
          'date': '14-Nov-2026', 'fajr': '05:41:00', 'syuruk': '06:58:00', 'dhuhr': '12:58:00',
          'asr': '11:00:00', 'maghrib': '18:54:00', 'isha': '20:07:00',
        },
        {
          // Missing field → dropped.
          'date': '15-Nov-2026', 'fajr': '05:41:00',
        },
      ],
      'status': status,
      'zone': zone,
    };

void main() {
  group('JAKIM e-Solat parser', () {
    test('parses valid days in Malaysian time and drops invalid ones', () {
      final days = JakimESolatProvider.parse(esolatFixture(), 'JHR03', DateTime.utc(2026));
      expect(days.length, 2);
      final d = days.first;
      expect(d.date, '2026-11-12');
      expect(Myt.hhmm(d.subuh), '05:41');
      expect(Myt.hhmm(d.isyak), '20:07');
      expect(d.subuh, DateTime.utc(2026, 11, 11, 21, 41)); // 05:41 MYT == 21:41 UTC prev day
      expect(d.hijri, '1448-05-22');
      expect(d.source, PrayerSource.jakim);
      expect(days[1].date, '2026-08-13');
    });

    test('rejects mismatched zone', () {
      expect(() => JakimESolatProvider.parse(esolatFixture(zone: 'JHR02'), 'JHR03', DateTime.utc(2026)),
          throwsA(isA<PrayerDataException>()));
    });

    test('rejects error status', () {
      expect(() => JakimESolatProvider.parse(esolatFixture(status: 'NO_RECORD!'), 'JHR03', DateTime.utc(2026)),
          throwsA(isA<PrayerDataException>()));
    });

    test('builds the documented endpoint URL', () {
      final u = JakimESolatProvider.uriFor('JHR03', period: 'year');
      expect(u.scheme, 'https');
      expect(u.host, 'www.e-solat.gov.my');
      expect(u.queryParameters, {'r': 'esolatApi/TakwimSolat', 'period': 'year', 'zone': 'JHR03'});
    });

    test('falls back from year to month period, and surfaces network errors', () async {
      final requested = <String>[];
      final client = MockClient((req) async {
        requested.add(req.url.queryParameters['period']!);
        if (req.url.queryParameters['period'] == 'year') return http.Response('oops', 500);
        return http.Response(jsonEncode(esolatFixture()), 200);
      });
      final days = await JakimESolatProvider(client: client).fetchUpcoming('JHR03');
      expect(requested, ['year', 'month']);
      expect(days, isNotEmpty);

      final failing = MockClient((_) async => http.Response('down', 503));
      expect(JakimESolatProvider(client: failing).fetchUpcoming('JHR03'), throwsA(isA<PrayerDataException>()));
    });
  });

  group('Mirror parser', () {
    test('parses unix timestamps and derives the MYT date', () {
      int ts(String hm) {
        final p = hm.split(':').map(int.parse).toList();
        return Myt.instantFromWall(2026, 11, 12, p[0], p[1]).millisecondsSinceEpoch ~/ 1000;
      }

      final days = WaktuSolatMirrorProvider.parse({
        'zone': 'JHR03',
        'prayers': [
          {
            'day': 12, 'hijri': '1448-05-22', 'fajr': ts('05:41'), 'syuruk': ts('06:58'), 'dhuhr': ts('12:58'),
            'asr': ts('16:19'), 'maghrib': ts('18:54'), 'isha': ts('20:07'),
          },
        ],
      }, 'JHR03', DateTime.utc(2026));
      expect(days.single.date, '2026-11-12');
      expect(days.single.source, PrayerSource.mirror);
      expect(Myt.hhmm(days.single.maghrib), '18:54');
    });
  });

  group('Offline estimate', () {
    test('Kluang estimate is plausible, ordered and labelled as estimate', () {
      final d = const EstimateCalculator().compute(zone: 'JHR03', date: '2026-11-12', lat: 2.03, lng: 103.32);
      expect(d.source, PrayerSource.estimate);
      expect(d.source.isVerified, isFalse);
      expect(d.isConsistent, isTrue);
      int min(DateTime t) => Myt.toWall(t).hour * 60 + Myt.toWall(t).minute;
      // Near-equatorial location: broad sanity ranges only.
      expect(min(d.subuh), inInclusiveRange(5 * 60 + 20, 6 * 60 + 5));
      expect(min(d.zohor), inInclusiveRange(12 * 60 + 40, 13 * 60 + 15));
      expect(min(d.maghrib), inInclusiveRange(18 * 60 + 40, 19 * 60 + 25));
      expect(min(d.isyak), inInclusiveRange(19 * 60 + 50, 20 * 60 + 40));
      expect(d.imsak, d.subuh.subtract(const Duration(minutes: 10)));
    });
  });
}
