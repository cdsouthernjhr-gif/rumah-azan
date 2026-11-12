import 'package:rumah_azan/core/utilities/myt_time.dart';
import 'package:rumah_azan/data/models/prayer_day.dart';

/// Builds a verified PrayerDay from MYT wall-clock "HH:mm" strings.
PrayerDay day(
  String date, {
  String subuh = '05:45',
  String syuruk = '07:00',
  String zohor = '13:05',
  String asar = '16:25',
  String maghrib = '19:05',
  String isyak = '20:15',
  String? imsak = '05:35',
  PrayerSource source = PrayerSource.jakim,
  String zone = 'JHR03',
  DateTime? fetchedAt,
}) {
  final d = Myt.parseDateKey(date);
  DateTime t(String hm) {
    final m = Myt.parseHm(hm)!;
    return Myt.instantFromWall(d.year, d.month, d.day, m ~/ 60, m % 60);
  }

  return PrayerDay(
    zone: zone,
    date: date,
    imsak: imsak == null ? null : t(imsak),
    subuh: t(subuh),
    syuruk: t(syuruk),
    zohor: t(zohor),
    asar: t(asar),
    maghrib: t(maghrib),
    isyak: t(isyak),
    source: source,
    fetchedAt: fetchedAt ?? DateTime.utc(2026, 1, 1),
  );
}

/// Instant for a MYT wall-clock date/time.
DateTime myt(String date, String hm, [int second = 0]) {
  final d = Myt.parseDateKey(date);
  final m = Myt.parseHm(hm)!;
  return Myt.instantFromWall(d.year, d.month, d.day, m ~/ 60, m % 60, second);
}
