import 'package:drift/drift.dart';

import '../../core/utilities/myt_time.dart';
import '../local/database.dart';
import '../models/prayer_day.dart';
import '../remote/estimate_calculator.dart';
import '../remote/prayer_time_provider.dart';
import '../static/jakim_zones.dart';
import 'diagnostics_repository.dart';

/// Outcome of a refresh attempt.
class RefreshResult {
  const RefreshResult({required this.ok, required this.days, this.error, this.providerName});
  final bool ok;
  final int days;
  final String? error;
  final String? providerName;
}

/// Offline-first prayer time repository.
///
/// Resolution order for a day: cached verified data (JAKIM / mirror) →
/// labelled astronomical estimate (only if allowed) → null (UI shows a clear
/// "no verified timetable" warning). Invented or stale data is never
/// presented as current verified data.
class PrayerRepository {
  PrayerRepository(this.db, this.diag, {this.estimator = const EstimateCalculator()});

  final AppDatabase db;
  final DiagnosticsRepository diag;
  final EstimateCalculator estimator;

  Future<void> ensureZonesSeeded() async {
    final count = await db.prayerZones.count().getSingle();
    if (count >= jakimZones.length) return;
    await db.batch((b) {
      b.insertAllOnConflictUpdate(
        db.prayerZones,
        [
          for (final z in jakimZones)
            PrayerZonesCompanion.insert(
              code: z.code,
              state: z.state,
              areas: z.areas,
              lat: Value(z.lat),
              lng: Value(z.lng),
            ),
        ],
      );
    });
  }

  Future<RefreshResult> refresh(String zone, PrayerTimeProvider provider) async {
    try {
      await ensureZonesSeeded();
      final days = await provider.fetchUpcoming(zone);
      await upsert(days);
      await diag.info('prayer_sync', '${provider.displayName}: ${days.length} hari untuk $zone');
      return RefreshResult(ok: true, days: days.length, providerName: provider.displayName);
    } catch (e) {
      await diag.error('prayer_sync', '${provider.displayName}: $e');
      return RefreshResult(ok: false, days: 0, error: e.toString(), providerName: provider.displayName);
    }
  }

  Future<void> upsert(List<PrayerDay> days) async {
    await db.batch((b) {
      for (final d in days) {
        if (!d.source.isVerified) continue; // never persist estimates as data
        b.insert(
          db.prayerTimes,
          PrayerTimesCompanion.insert(
            zone: d.zone,
            date: d.date,
            imsak: Value(d.imsak?.millisecondsSinceEpoch),
            subuh: d.subuh.millisecondsSinceEpoch,
            syuruk: d.syuruk.millisecondsSinceEpoch,
            zohor: d.zohor.millisecondsSinceEpoch,
            asar: d.asar.millisecondsSinceEpoch,
            maghrib: d.maghrib.millisecondsSinceEpoch,
            isyak: d.isyak.millisecondsSinceEpoch,
            hijri: Value(d.hijri),
            source: d.source.name,
            fetchedAt: d.fetchedAt,
          ),
          onConflict: DoUpdate(
            (old) => PrayerTimesCompanion.custom(
              imsak: Variable(d.imsak?.millisecondsSinceEpoch),
              subuh: Variable(d.subuh.millisecondsSinceEpoch),
              syuruk: Variable(d.syuruk.millisecondsSinceEpoch),
              zohor: Variable(d.zohor.millisecondsSinceEpoch),
              asar: Variable(d.asar.millisecondsSinceEpoch),
              maghrib: Variable(d.maghrib.millisecondsSinceEpoch),
              isyak: Variable(d.isyak.millisecondsSinceEpoch),
              hijri: Variable(d.hijri),
              source: Variable(d.source.name),
              fetchedAt: Variable(d.fetchedAt),
            ),
            target: [db.prayerTimes.zone, db.prayerTimes.date],
          ),
        );
      }
    });
  }

  static PrayerDay _fromRow(PrayerTimeRow r) {
    DateTime t(int ms) => DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true);
    return PrayerDay(
      zone: r.zone,
      date: r.date,
      imsak: r.imsak == null ? null : t(r.imsak!),
      subuh: t(r.subuh),
      syuruk: t(r.syuruk),
      zohor: t(r.zohor),
      asar: t(r.asar),
      maghrib: t(r.maghrib),
      isyak: t(r.isyak),
      source: PrayerSource.values.firstWhere((s) => s.name == r.source, orElse: () => PrayerSource.jakim),
      fetchedAt: r.fetchedAt,
      hijri: r.hijri,
    );
  }

  Future<PrayerDay?> cachedDay(String zone, String date) async {
    final row = await (db.select(db.prayerTimes)
          ..where((t) => t.zone.equals(zone) & t.date.equals(date)))
        .getSingleOrNull();
    return row == null ? null : _fromRow(row);
  }

  Future<List<PrayerDay>> cachedRange(String zone, String from, String to) async {
    final rows = await (db.select(db.prayerTimes)
          ..where((t) =>
              t.zone.equals(zone) & t.date.isBiggerOrEqualValue(from) & t.date.isSmallerOrEqualValue(to))
          ..orderBy([(t) => OrderingTerm.asc(t.date)]))
        .get();
    return rows.map(_fromRow).toList();
  }

  /// Latest date for which verified data is cached, or null.
  Future<String?> lastCachedDate(String zone) async {
    final row = await (db.select(db.prayerTimes)
          ..where((t) => t.zone.equals(zone))
          ..orderBy([(t) => OrderingTerm.desc(t.date)])
          ..limit(1))
        .getSingleOrNull();
    return row?.date;
  }

  Future<DateTime?> lastFetchedAt(String zone) async {
    final q = db.selectOnly(db.prayerTimes)
      ..addColumns([db.prayerTimes.fetchedAt.max()])
      ..where(db.prayerTimes.zone.equals(zone));
    return q.map((r) => r.read(db.prayerTimes.fetchedAt.max())).getSingleOrNull();
  }

  /// Verified day if cached, else an estimate (if [allowEstimate] and the zone
  /// has a reference point), else null.
  Future<PrayerDay?> resolveDay(String zone, String date, {required bool allowEstimate}) async {
    final cached = await cachedDay(zone, date);
    if (cached != null) return cached;
    if (!allowEstimate) return null;
    final z = zoneByCode(zone);
    if (z?.lat == null || z?.lng == null) return null;
    return estimator.compute(zone: zone, date: date, lat: z!.lat!, lng: z.lng!);
  }

  /// Resolved days from [fromDate] for [count] days (missing days skipped).
  Future<List<PrayerDay>> resolveRange(String zone, String fromDate, int count,
      {required bool allowEstimate}) async {
    final out = <PrayerDay>[];
    for (var i = 0; i < count; i++) {
      final d = await resolveDay(zone, Myt.addDays(fromDate, i), allowEstimate: allowEstimate);
      if (d != null) out.add(d);
    }
    return out;
  }

  Future<int> clearCache() => db.delete(db.prayerTimes).go();
}
