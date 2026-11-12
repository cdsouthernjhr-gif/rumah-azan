import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;

import '../../core/utilities/myt_time.dart';
import '../../features/islamic_calendar/domain/calendar_service.dart';
import '../local/database.dart';

// ---------------------------------------------------------------------------
// Tasbih
// ---------------------------------------------------------------------------
class TasbihRepository {
  TasbihRepository(this.db);
  final AppDatabase db;

  Future<void> save({required String zikr, required int count, required int target}) async {
    if (count <= 0) return;
    await db.into(db.tasbihRecords).insert(TasbihRecordsCompanion.insert(
          zikr: zikr,
          count: count,
          target: target,
          date: Myt.todayKey(),
          createdAt: Value(DateTime.now().toUtc()),
        ));
  }

  Stream<List<TasbihRow>> watchHistory([int limit = 100]) => (db.select(db.tasbihRecords)
        ..orderBy([(t) => OrderingTerm.desc(t.id)])
        ..limit(limit))
      .watch();

  /// Total count per day for the last [days] days (MYT), oldest first.
  Future<List<(String, int)>> dailyTotals(int days) async {
    final from = Myt.addDays(Myt.todayKey(), -(days - 1));
    final sum = db.tasbihRecords.count.sum();
    final rows = await (db.selectOnly(db.tasbihRecords)
          ..addColumns([db.tasbihRecords.date, sum])
          ..where(db.tasbihRecords.date.isBiggerOrEqualValue(from))
          ..groupBy([db.tasbihRecords.date]))
        .get();
    final map = {for (final r in rows) r.read(db.tasbihRecords.date)!: r.read(sum) ?? 0};
    return [
      for (var i = 0; i < days; i++)
        (Myt.addDays(from, i), map[Myt.addDays(from, i)] ?? 0),
    ];
  }

  Future<void> clear() => db.delete(db.tasbihRecords).go();
}

// ---------------------------------------------------------------------------
// Calendar: official overrides + JAKIM Hijri dates from cached timetables
// ---------------------------------------------------------------------------
class CalendarRepository {
  CalendarRepository(this.db);
  final AppDatabase db;

  Future<Map<String, String>> jakimHijriMap() async {
    final rows = await (db.selectOnly(db.prayerTimes, distinct: true)
          ..addColumns([db.prayerTimes.date, db.prayerTimes.hijri])
          ..where(db.prayerTimes.hijri.isNotNull()))
        .get();
    return {
      for (final r in rows) r.read(db.prayerTimes.date)!: r.read(db.prayerTimes.hijri)!,
    };
  }

  Future<List<OfficialEventDate>> overrides() async {
    final rows = await db.select(db.islamicEvents).get();
    return [
      for (final r in rows)
        OfficialEventDate(
          eventKey: r.eventKey,
          hijriYear: r.hijriYear,
          dateKey: r.gregorianDate,
          source: r.source,
          note: r.note,
        ),
    ];
  }

  Future<void> setOverride({
    required String eventKey,
    required int hijriYear,
    required String dateKey,
    String source = 'official',
    String? note,
  }) =>
      db.into(db.islamicEvents).insert(
            IslamicEventsCompanion.insert(
              eventKey: eventKey,
              hijriYear: hijriYear,
              gregorianDate: dateKey,
              source: source,
              note: Value(note),
            ),
            onConflict: DoUpdate(
              (old) => IslamicEventsCompanion(
                gregorianDate: Value(dateKey),
                source: Value(source),
                note: Value(note),
              ),
              target: [db.islamicEvents.eventKey, db.islamicEvents.hijriYear],
            ),
          );

  Future<void> removeOverride(String eventKey, int hijriYear) =>
      (db.delete(db.islamicEvents)..where((t) => t.eventKey.equals(eventKey) & t.hijriYear.equals(hijriYear))).go();
}

// ---------------------------------------------------------------------------
// Custom wallpapers (built-in ones are procedural; see wallpaper feature)
// ---------------------------------------------------------------------------
class WallpaperRepository {
  WallpaperRepository(this.db, this.dir);
  final AppDatabase db;
  final Future<Directory> Function() dir;

  static const allowedExt = {'.jpg', '.jpeg', '.png', '.webp'};

  Stream<List<WallpaperRow>> watchAll() => db.select(db.wallpapers).watch();

  Future<int> import(Stream<List<int>> data, String fileName, String name) async {
    final ext = p.extension(fileName).toLowerCase();
    if (!allowedExt.contains(ext)) throw ArgumentError('Format imej tidak disokong: $ext');
    final d = await dir();
    if (!await d.exists()) await d.create(recursive: true);
    final target = p.join(d.path, 'wp_${DateTime.now().millisecondsSinceEpoch}$ext');
    final sink = File(target).openWrite();
    try {
      await sink.addStream(data);
    } finally {
      await sink.close();
    }
    return db.into(db.wallpapers).insert(WallpapersCompanion.insert(name: name, filePath: target));
  }

  Future<WallpaperRow?> byId(int id) =>
      (db.select(db.wallpapers)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<void> delete(int id) async {
    final row = await byId(id);
    if (row == null) return;
    await (db.delete(db.wallpapers)..where((t) => t.id.equals(id))).go();
    final f = File(row.filePath);
    if (await f.exists()) await f.delete();
  }
}

// ---------------------------------------------------------------------------
// Backup / restore (settings, schedules, playlists metadata, favorites,
// events, tasbih). Audio and image files are not embedded; their library
// rows are kept only if the file still exists on restore.
// ---------------------------------------------------------------------------
class BackupRepository {
  BackupRepository(this.db);
  final AppDatabase db;

  static const formatVersion = 1;

  Future<String> exportJson() async {
    final settings = await db.select(db.userSettings).get();
    final schedules = await db.select(db.audioSchedules).get();
    final notifs = await db.select(db.notificationSettings).get();
    final favs = await db.select(db.favorites).get();
    final events = await db.select(db.islamicEvents).get();
    final tasbih = await db.select(db.tasbihRecords).get();
    final playlists = await db.select(db.audioPlaylists).get();
    final items = await db.select(db.audioPlaylistItems).get();
    final audio = await db.select(db.audioLibrary).get();
    return const JsonEncoder.withIndent(' ').convert({
      'app': 'rumah_azan',
      'format': formatVersion,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'settings': [for (final s in settings) {'key': s.key, 'value': s.value}],
      'audioSchedules': [for (final s in schedules) {'prayer': s.prayer, 'config': s.configJson}],
      'notificationSettings': [for (final s in notifs) {'prayer': s.prayer, 'config': s.configJson}],
      'favorites': [for (final f in favs) f.contentId],
      'islamicEvents': [
        for (final e in events)
          {'key': e.eventKey, 'hijriYear': e.hijriYear, 'date': e.gregorianDate, 'source': e.source, 'note': e.note},
      ],
      'tasbih': [
        for (final t in tasbih) {'zikr': t.zikr, 'count': t.count, 'target': t.target, 'date': t.date},
      ],
      'audioLibrary': [
        for (final a in audio)
          {'id': a.id, 'title': a.title, 'category': a.category, 'filePath': a.filePath, 'sourceUrl': a.sourceUrl},
      ],
      'playlists': [for (final pl in playlists) {'id': pl.id, 'name': pl.name}],
      'playlistItems': [
        for (final i in items) {'playlistId': i.playlistId, 'audioId': i.audioId, 'position': i.position},
      ],
    });
  }

  /// Restores a backup. Validates structure before touching the database and
  /// runs in a single transaction (all-or-nothing).
  Future<void> importJson(String raw) async {
    final Object? decoded = jsonDecode(raw);
    if (decoded is! Map || decoded['app'] != 'rumah_azan') {
      throw const FormatException('Bukan fail sandaran Rumah Azan');
    }
    final fmt = decoded['format'];
    if (fmt is! int || fmt > formatVersion) {
      throw const FormatException('Versi sandaran tidak disokong');
    }
    List<Map<String, dynamic>> list(String k) =>
        [for (final e in (decoded[k] as List?) ?? const []) if (e is Map) e.cast<String, dynamic>()];

    await db.transaction(() async {
      for (final s in list('settings')) {
        await db.into(db.userSettings).insertOnConflictUpdate(
            UserSettingsCompanion.insert(key: '${s['key']}', value: '${s['value']}'));
      }
      for (final s in list('notificationSettings')) {
        await db.into(db.notificationSettings).insertOnConflictUpdate(
            NotificationSettingsCompanion.insert(prayer: '${s['prayer']}', configJson: '${s['config']}'));
      }
      for (final f in (decoded['favorites'] as List?) ?? const []) {
        await db.into(db.favorites).insertOnConflictUpdate(FavoritesCompanion.insert(contentId: '$f'));
      }
      for (final e in list('islamicEvents')) {
        await db.into(db.islamicEvents).insert(
              IslamicEventsCompanion.insert(
                eventKey: '${e['key']}',
                hijriYear: (e['hijriYear'] as num).toInt(),
                gregorianDate: '${e['date']}',
                source: '${e['source']}',
                note: Value(e['note'] as String?),
              ),
              mode: InsertMode.insertOrReplace,
            );
      }
      for (final t in list('tasbih')) {
        await db.into(db.tasbihRecords).insert(TasbihRecordsCompanion.insert(
              zikr: '${t['zikr']}',
              count: (t['count'] as num).toInt(),
              target: (t['target'] as num).toInt(),
              date: '${t['date']}',
            ));
      }
      // Audio rows: only restore entries whose file still exists.
      final idMap = <int, int>{};
      for (final a in list('audioLibrary')) {
        final path = '${a['filePath']}';
        if (!File(path).existsSync()) continue;
        final existing =
            await (db.select(db.audioLibrary)..where((t) => t.filePath.equals(path))).getSingleOrNull();
        idMap[(a['id'] as num).toInt()] = existing?.id ??
            await db.into(db.audioLibrary).insert(AudioLibraryCompanion.insert(
                  title: '${a['title']}',
                  category: '${a['category']}',
                  filePath: path,
                  sourceUrl: Value(a['sourceUrl'] as String?),
                ));
      }
      final plMap = <int, int>{};
      for (final pl in list('playlists')) {
        plMap[(pl['id'] as num).toInt()] =
            await db.into(db.audioPlaylists).insert(AudioPlaylistsCompanion.insert(name: '${pl['name']}'));
      }
      for (final i in list('playlistItems')) {
        final pid = plMap[(i['playlistId'] as num).toInt()];
        final aid = idMap[(i['audioId'] as num).toInt()];
        if (pid == null || aid == null) continue;
        await db.into(db.audioPlaylistItems).insert(AudioPlaylistItemsCompanion.insert(
              playlistId: pid,
              audioId: aid,
              position: (i['position'] as num).toInt(),
            ));
      }
      // Per-prayer configs reference playlist/audio ids: remap to new ids.
      for (final s in list('audioSchedules')) {
        final cfg = Map<String, dynamic>.from(jsonDecode('${s['config']}') as Map);
        int? remap(Object? v, Map<int, int> m) => v is num ? m[v.toInt()] : null;
        cfg['beforePlaylistId'] = remap(cfg['beforePlaylistId'], plMap);
        cfg['afterPlaylistId'] = remap(cfg['afterPlaylistId'], plMap);
        cfg['fullAzanAudioId'] = remap(cfg['fullAzanAudioId'], idMap);
        cfg['shortAzanAudioId'] = remap(cfg['shortAzanAudioId'], idMap);
        await db.into(db.audioSchedules).insertOnConflictUpdate(
            AudioSchedulesCompanion.insert(prayer: '${s['prayer']}', configJson: jsonEncode(cfg)));
      }
    });
  }
}
