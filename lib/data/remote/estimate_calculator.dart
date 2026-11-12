import 'dart:math' as math;

import '../../core/utilities/myt_time.dart';
import '../models/prayer_day.dart';

/// Offline astronomical ESTIMATE of prayer times using parameters commonly
/// associated with JAKIM (Subuh 20°, Isyak 18°, Asar Syafie shadow ratio 1,
/// +2 minute ihtiyati, sunrise −2 minutes).
///
/// This is NOT official data. Results can differ from JAKIM's published
/// timetable by a few minutes, especially because the zone reference point is
/// approximate. The UI always labels it "Anggaran" with a warning, and the
/// audio scheduler only uses it if the user explicitly allows it.
class EstimateCalculator {
  const EstimateCalculator({
    this.fajrAngle = 20,
    this.ishaAngle = 18,
    this.ihtiyatiMinutes = 2,
  });

  final double fajrAngle;
  final double ishaAngle;
  final int ihtiyatiMinutes;

  static double _rad(double d) => d * math.pi / 180;
  static double _deg(double r) => r * 180 / math.pi;
  static double _fix(double a, double b) {
    a = a - b * (a / b).floorToDouble();
    return a < 0 ? a + b : a;
  }

  static double _julian(int y, int m, int d) {
    if (m <= 2) {
      y -= 1;
      m += 12;
    }
    final a = (y / 100).floor();
    final b = 2 - a + (a / 4).floor();
    return (365.25 * (y + 4716)).floorToDouble() +
        (30.6001 * (m + 1)).floorToDouble() +
        d + b - 1524.5;
  }

  /// Returns (declination°, equationOfTime hours) for Julian day [jd].
  static (double, double) _sun(double jd) {
    final d = jd - 2451545.0;
    final g = _fix(357.529 + 0.98560028 * d, 360);
    final q = _fix(280.459 + 0.98564736 * d, 360);
    final l = _fix(q + 1.915 * math.sin(_rad(g)) + 0.020 * math.sin(_rad(2 * g)), 360);
    final e = 23.439 - 0.00000036 * d;
    final ra = _fix(_deg(math.atan2(math.cos(_rad(e)) * math.sin(_rad(l)), math.cos(_rad(l)))) / 15, 24);
    final decl = _deg(math.asin(math.sin(_rad(e)) * math.sin(_rad(l))));
    var eqt = q / 15 - ra;
    if (eqt > 12) eqt -= 24;
    if (eqt < -12) eqt += 24;
    return (decl, eqt);
  }

  /// Hours from solar noon until the sun reaches altitude [alt] degrees.
  static double _hourAngle(double alt, double lat, double decl) {
    final v = (math.sin(_rad(alt)) - math.sin(_rad(lat)) * math.sin(_rad(decl))) /
        (math.cos(_rad(lat)) * math.cos(_rad(decl)));
    return _deg(math.acos(v.clamp(-1.0, 1.0))) / 15;
  }

  PrayerDay compute({
    required String zone,
    required String date,
    required double lat,
    required double lng,
  }) {
    final dt = Myt.parseDateKey(date);
    final jd = _julian(dt.year, dt.month, dt.day) - lng / 360 + 0.5;
    final (decl, eqt) = _sun(jd);
    final noonUtcHours = 12 - lng / 15 - eqt;

    final asrAlt = _deg(math.atan(1 / (1 + math.tan(_rad((lat - decl).abs())))));
    final fajr = noonUtcHours - _hourAngle(-fajrAngle, lat, decl);
    final sunrise = noonUtcHours - _hourAngle(-0.833, lat, decl);
    final asr = noonUtcHours + _hourAngle(asrAlt, lat, decl);
    final maghrib = noonUtcHours + _hourAngle(-0.833, lat, decl);
    final isha = noonUtcHours + _hourAngle(-ishaAngle, lat, decl);

    DateTime at(double utcHours, int adjustMinutes, {bool roundUp = true}) {
      final base = DateTime.utc(dt.year, dt.month, dt.day);
      final secs = (utcHours * 3600).round() + adjustMinutes * 60;
      var t = base.add(Duration(seconds: secs));
      // Round to whole minute: up for prayers (safer), down for syuruk.
      final rem = t.second;
      if (rem != 0) {
        t = t.subtract(Duration(seconds: rem));
        if (roundUp) t = t.add(const Duration(minutes: 1));
      }
      return t;
    }

    final subuhT = at(fajr, ihtiyatiMinutes);
    return PrayerDay(
      zone: zone,
      date: date,
      imsak: subuhT.subtract(const Duration(minutes: 10)),
      subuh: subuhT,
      syuruk: at(sunrise, -ihtiyatiMinutes, roundUp: false),
      zohor: at(noonUtcHours, ihtiyatiMinutes),
      asar: at(asr, ihtiyatiMinutes),
      maghrib: at(maghrib, ihtiyatiMinutes),
      isyak: at(isha, ihtiyatiMinutes),
      source: PrayerSource.estimate,
      fetchedAt: Myt.nowInstant(),
    );
  }
}
