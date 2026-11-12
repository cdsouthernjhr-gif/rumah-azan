import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/utilities/myt_time.dart';
import '../models/prayer_day.dart';

/// Replaceable prayer-time data source.
abstract class PrayerTimeProvider {
  String get id;
  String get displayName;
  PrayerSource get sourceKind;

  /// Returns validated days for the current month (and possibly beyond).
  /// Throws [PrayerDataException] on network/format errors. Never returns
  /// invented data.
  Future<List<PrayerDay>> fetchUpcoming(String zone);
}

class PrayerDataException implements Exception {
  PrayerDataException(this.message, {this.cause});
  final String message;
  final Object? cause;
  @override
  String toString() => 'PrayerDataException: $message${cause != null ? ' ($cause)' : ''}';
}

const _userAgent = 'RumahAzan/0.1 (Android; offline-first prayer app)';
const _timeout = Duration(seconds: 20);

Future<Map<String, dynamic>> _getJson(http.Client client, Uri uri) async {
  final http.Response res;
  try {
    res = await client
        .get(uri, headers: {'User-Agent': _userAgent, 'Accept': 'application/json'})
        .timeout(_timeout);
  } catch (e) {
    throw PrayerDataException('Gagal menghubungi ${uri.host}', cause: e);
  }
  if (res.statusCode != 200) {
    throw PrayerDataException('HTTP ${res.statusCode} daripada ${uri.host}');
  }
  final Object? decoded;
  try {
    decoded = jsonDecode(utf8.decode(res.bodyBytes));
  } catch (e) {
    throw PrayerDataException('Respons bukan JSON yang sah', cause: e);
  }
  if (decoded is! Map<String, dynamic>) {
    throw PrayerDataException('Format respons tidak dijangka');
  }
  return decoded;
}

/// Official JAKIM e-Solat JSON endpoint.
///
/// Endpoint: https://www.e-solat.gov.my/index.php?r=esolatApi/TakwimSolat
///   `&period=month&zone=<ZONE>`
/// This is the publicly accessible JSON endpoint used by the e-Solat portal.
/// JAKIM does not publish formal API documentation or terms for it; see
/// docs/PRAYER_DATA_SOURCE.md for the verification status and caveats.
class JakimESolatProvider implements PrayerTimeProvider {
  JakimESolatProvider({http.Client? client}) : _client = client ?? http.Client();
  final http.Client _client;

  @override
  String get id => 'jakim';
  @override
  String get displayName => 'JAKIM e-Solat';
  @override
  PrayerSource get sourceKind => PrayerSource.jakim;

  static Uri uriFor(String zone, {String period = 'month'}) => Uri.https(
        'www.e-solat.gov.my',
        '/index.php',
        {'r': 'esolatApi/TakwimSolat', 'period': period, 'zone': zone},
      );

  @override
  Future<List<PrayerDay>> fetchUpcoming(String zone) async {
    // Whole year first (best offline coverage); fall back to current month.
    try {
      final json = await _getJson(_client, uriFor(zone, period: 'year'));
      return parse(json, zone, Myt.nowInstant());
    } on PrayerDataException {
      final json = await _getJson(_client, uriFor(zone, period: 'month'));
      return parse(json, zone, Myt.nowInstant());
    }
  }

  static const _months = {
    'jan': 1, 'feb': 2, 'mar': 3, 'apr': 4, 'may': 5, 'jun': 6,
    'jul': 7, 'aug': 8, 'sep': 9, 'oct': 10, 'nov': 11, 'dec': 12,
    // Malay abbreviations, in case the portal localises month names.
    'mac': 3, 'mei': 5, 'ogo': 8, 'ogs': 8, 'okt': 10, 'dis': 12,
  };

  /// Parses an e-Solat response. Days failing validation are dropped; if no
  /// valid day remains a [PrayerDataException] is thrown.
  static List<PrayerDay> parse(Map<String, dynamic> json, String zone, DateTime fetchedAt) {
    final status = json['status']?.toString() ?? '';
    final list = json['prayerTime'];
    if (list is! List || !status.toUpperCase().startsWith('OK')) {
      throw PrayerDataException('Respons e-Solat tidak sah (status: "$status")');
    }
    final respZone = json['zone']?.toString();
    if (respZone != null && respZone.isNotEmpty && respZone.toUpperCase() != zone.toUpperCase()) {
      throw PrayerDataException('Zon dalam respons ($respZone) tidak sepadan dengan $zone');
    }
    final out = <PrayerDay>[];
    for (final raw in list) {
      if (raw is! Map) continue;
      final dm = RegExp(r'^(\d{1,2})-([A-Za-z]{3})-(\d{4})$').firstMatch('${raw['date']}'.trim());
      if (dm == null) continue;
      final day = int.parse(dm.group(1)!);
      final month = _months[dm.group(2)!.toLowerCase()];
      final year = int.parse(dm.group(3)!);
      if (month == null) continue;

      DateTime? t(String key) {
        final m = RegExp(r'^(\d{1,2}):(\d{2})(?::(\d{2}))?$').firstMatch('${raw[key] ?? ''}'.trim());
        if (m == null) return null;
        return Myt.instantFromWall(year, month, day, int.parse(m.group(1)!),
            int.parse(m.group(2)!), int.parse(m.group(3) ?? '0'));
      }

      final subuh = t('fajr'), syuruk = t('syuruk'), zohor = t('dhuhr');
      final asar = t('asr'), maghrib = t('maghrib'), isyak = t('isha');
      if ([subuh, syuruk, zohor, asar, maghrib, isyak].contains(null)) continue;
      final hijri = '${raw['hijri'] ?? ''}'.trim();
      final pd = PrayerDay(
        zone: zone,
        date: Myt.dateKeyFromWall(DateTime.utc(year, month, day)),
        imsak: t('imsak'),
        subuh: subuh!,
        syuruk: syuruk!,
        zohor: zohor!,
        asar: asar!,
        maghrib: maghrib!,
        isyak: isyak!,
        source: PrayerSource.jakim,
        fetchedAt: fetchedAt,
        hijri: RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(hijri) ? hijri : null,
      );
      if (pd.isConsistent) out.add(pd);
    }
    if (out.isEmpty) throw PrayerDataException('Tiada data waktu solat yang sah dalam respons e-Solat');
    return out;
  }
}

/// Secondary source: the open-source "Waktu Solat" community API
/// (api.waktusolat.app), which republishes JAKIM e-Solat timetables.
/// Not an official JAKIM service — shown as "cermin komuniti" in the UI and
/// disabled unless the user selects it.
class WaktuSolatMirrorProvider implements PrayerTimeProvider {
  WaktuSolatMirrorProvider({http.Client? client}) : _client = client ?? http.Client();
  final http.Client _client;

  @override
  String get id => 'mirror';
  @override
  String get displayName => 'Waktu Solat API (cermin data JAKIM)';
  @override
  PrayerSource get sourceKind => PrayerSource.mirror;

  static Uri uriFor(String zone) => Uri.https('api.waktusolat.app', '/v2/solat/$zone');

  @override
  Future<List<PrayerDay>> fetchUpcoming(String zone) async {
    final json = await _getJson(_client, uriFor(zone));
    return parse(json, zone, Myt.nowInstant());
  }

  static List<PrayerDay> parse(Map<String, dynamic> json, String zone, DateTime fetchedAt) {
    final list = json['prayers'];
    if (list is! List) throw PrayerDataException('Respons cermin tidak mengandungi "prayers"');
    final respZone = json['zone']?.toString();
    if (respZone != null && respZone.toUpperCase() != zone.toUpperCase()) {
      throw PrayerDataException('Zon dalam respons ($respZone) tidak sepadan dengan $zone');
    }
    final out = <PrayerDay>[];
    for (final raw in list) {
      if (raw is! Map) continue;
      DateTime? t(String k) {
        final v = raw[k];
        if (v is! num) return null;
        return DateTime.fromMillisecondsSinceEpoch(v.toInt() * 1000, isUtc: true);
      }

      final subuh = t('fajr'), syuruk = t('syuruk'), zohor = t('dhuhr');
      final asar = t('asr'), maghrib = t('maghrib'), isyak = t('isha');
      if ([subuh, syuruk, zohor, asar, maghrib, isyak].contains(null)) continue;
      final hijri = '${raw['hijri'] ?? ''}'.trim();
      final pd = PrayerDay(
        zone: zone,
        date: Myt.dateKey(subuh!),
        imsak: t('imsak'),
        subuh: subuh,
        syuruk: syuruk!,
        zohor: zohor!,
        asar: asar!,
        maghrib: maghrib!,
        isyak: isyak!,
        source: PrayerSource.mirror,
        fetchedAt: fetchedAt,
        hijri: RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(hijri) ? hijri : null,
      );
      if (pd.isConsistent) out.add(pd);
    }
    if (out.isEmpty) throw PrayerDataException('Tiada data waktu solat yang sah dalam respons cermin');
    return out;
  }
}
