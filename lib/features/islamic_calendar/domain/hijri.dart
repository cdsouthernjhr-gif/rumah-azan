/// Hijri date utilities.
///
/// The arithmetic (tabular) Islamic calendar is used as an offline
/// *calculation* only. Malaysia determines months by rukyah/imkanur rukyah,
/// so official dates may differ by ±1 (occasionally 2) days. The app therefore
/// prefers, in order: (1) dates confirmed by the user/authority, (2) the Hijri
/// date published by JAKIM alongside the prayer timetable, (3) this
/// calculation plus the user's manual adjustment — and labels which one is
/// shown.
class HijriDate {
  const HijriDate(this.year, this.month, this.day);
  final int year;
  final int month;
  final int day;

  static const monthsMs = [
    'Muharram', 'Safar', 'Rabiulawal', 'Rabiulakhir', 'Jamadilawal', 'Jamadilakhir',
    'Rejab', 'Syaaban', 'Ramadan', 'Syawal', 'Zulkaedah', 'Zulhijjah',
  ];
  static const monthsEn = [
    'Muharram', 'Safar', "Rabi' al-Awwal", "Rabi' al-Thani", 'Jumada al-Ula', 'Jumada al-Akhirah',
    'Rajab', "Sha'ban", 'Ramadan', 'Shawwal', "Dhu al-Qa'dah", 'Dhu al-Hijjah',
  ];

  String monthName(String lang) => (lang == 'en' ? monthsEn : monthsMs)[month - 1];
  String format(String lang) => '$day ${monthName(lang)} $year H';

  static HijriDate? tryParse(String? s) {
    if (s == null) return null;
    final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(s);
    if (m == null) return null;
    final y = int.parse(m.group(1)!), mo = int.parse(m.group(2)!), d = int.parse(m.group(3)!);
    if (mo < 1 || mo > 12 || d < 1 || d > 30) return null;
    return HijriDate(y, mo, d);
  }

  @override
  bool operator ==(Object other) =>
      other is HijriDate && other.year == year && other.month == month && other.day == day;
  @override
  int get hashCode => Object.hash(year, month, day);
  @override
  String toString() => '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
}

class TabularHijri {
  TabularHijri._();
  static const double _epoch = 1948439.5;

  static double gregorianToJd(int y, int m, int d) {
    final a = ((14 - m) / 12).floor();
    final yy = y + 4800 - a;
    final mm = m + 12 * a - 3;
    return d + ((153 * mm + 2) / 5).floor() + 365 * yy + (yy / 4).floor() -
        (yy / 100).floor() + (yy / 400).floor() - 32045 - 0.5;
  }

  static DateTime jdToGregorian(double jd) {
    final z = (jd + 0.5).floor();
    final a = z + 32044;
    final b = ((4 * a + 3) / 146097).floor();
    final c = a - (146097 * b / 4).floor();
    final d = ((4 * c + 3) / 1461).floor();
    final e = c - (1461 * d / 4).floor();
    final m = ((5 * e + 2) / 153).floor();
    final day = e - ((153 * m + 2) / 5).floor() + 1;
    final month = m + 3 - 12 * (m / 10).floor();
    final year = 100 * b + d - 4800 + (m / 10).floor();
    return DateTime.utc(year, month, day);
  }

  static double islamicToJd(int y, int m, int d) =>
      d + (29.5 * (m - 1)).ceil() + (y - 1) * 354 + ((3 + 11 * y) / 30).floor() + _epoch - 1;

  static HijriDate fromGregorian(DateTime g, {int adjustDays = 0}) {
    final jd = gregorianToJd(g.year, g.month, g.day).floor() + 0.5 + adjustDays;
    final year = ((30 * (jd - _epoch) + 10646) / 10631).floor();
    var month = (((jd - (29 + islamicToJd(year, 1, 1))) / 29.5).ceil() + 1).clamp(1, 12);
    final day = (jd - islamicToJd(year, month, 1) + 1).toInt();
    return HijriDate(year, month, day);
  }

  static DateTime toGregorian(HijriDate h, {int adjustDays = 0}) =>
      jdToGregorian(islamicToJd(h.year, h.month, h.day) - adjustDays);
}
