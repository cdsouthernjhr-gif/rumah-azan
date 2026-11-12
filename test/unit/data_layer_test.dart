import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rumah_azan/data/local/database.dart';
import 'package:rumah_azan/data/models/app_settings.dart';
import 'package:rumah_azan/data/models/prayer_audio_config.dart';
import 'package:rumah_azan/data/models/prayer_day.dart';
import 'package:rumah_azan/data/repositories/diagnostics_repository.dart';
import 'package:rumah_azan/data/repositories/misc_repositories.dart';
import 'package:rumah_azan/data/repositories/prayer_repository.dart';
import 'package:rumah_azan/data/repositories/settings_repository.dart';
import 'package:rumah_azan/data/static/jakim_zones.dart';

import '../helpers.dart';

AppDatabase memoryDb() => AppDatabase(DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true));

void main() {
  late AppDatabase db;
  late PrayerRepository repo;

  setUp(() async {
    db = memoryDb();
    repo = PrayerRepository(db, DiagnosticsRepository(db));
    await repo.ensureZonesSeeded();
  });
  tearDown(() => db.close());

  test('schema v1 creates all tables', () async {
    final rows = await db.customSelect("SELECT name FROM sqlite_master WHERE type='table'").get();
    final names = rows.map((r) => r.read<String>('name')).toSet();
    expect(names, containsAll([
      'prayer_zones', 'prayer_times', 'islamic_events', 'islamic_calendar', 'audio_library', 'audio_playlists',
      'audio_playlist_items', 'audio_schedules', 'audio_playback_history', 'wallpapers', 'user_settings',
      'favorites', 'tasbih_records', 'notification_settings', 'app_diagnostics',
    ]));
    expect(db.schemaVersion, 1);
  });

  test('zones seeded once; Kluang is JHR03', () async {
    await repo.ensureZonesSeeded();
    expect(await db.prayerZones.count().getSingle(), jakimZones.length);
    expect(zoneByCode('JHR03')!.areas, contains('Kluang'));
    expect(jakimZones.map((z) => z.code).toSet().length, jakimZones.length, reason: 'unique codes');
  });

  test('upsert is idempotent (no duplicate days) and updates values', () async {
    await repo.upsert([day('2026-11-12'), day('2026-11-13')]);
    await repo.upsert([day('2026-11-12', maghrib: '19:06')]);
    expect(await db.prayerTimes.count().getSingle(), 2);
    final d = await repo.cachedDay('JHR03', '2026-11-12');
    expect(d!.maghrib, myt('2026-11-12', '19:06'));
    expect(await repo.lastCachedDate('JHR03'), '2026-11-13');
  });

  test('estimates are never persisted as data', () async {
    await repo.upsert([day('2026-11-12', source: PrayerSource.estimate)]);
    expect(await db.prayerTimes.count().getSingle(), 0);
  });

  test('resolveDay: verified → estimate (if allowed) → null', () async {
    await repo.upsert([day('2026-11-12')]);
    expect((await repo.resolveDay('JHR03', '2026-11-12', allowEstimate: false))!.source, PrayerSource.jakim);
    expect(await repo.resolveDay('JHR03', '2026-11-20', allowEstimate: false), isNull);
    expect((await repo.resolveDay('JHR03', '2026-11-20', allowEstimate: true))!.source, PrayerSource.estimate);
    // Special zone without reference point → no estimate.
    expect(await repo.resolveDay('SWK09', '2026-11-20', allowEstimate: true), isNull);
  });

  test('settings and audio configs persist', () async {
    final s = SettingsRepository(db);
    await s.save(AppSettings.initial().copyWith({'zoneCode': 'JHR03', 'language': 'en'}));
    final loaded = await s.load();
    expect(loaded.zoneCode, 'JHR03');
    expect(loaded.language, 'en');
    await s.saveAudioConfig(PrayerAudioConfig.defaultFor(Prayer.asar).copyWithJson({'reminderMinutes': 7, 'beforeEnabled': true}));
    final cfgs = await s.loadAudioConfigs();
    expect(cfgs[Prayer.asar]!.reminderMinutes, 7);
    expect(cfgs[Prayer.asar]!.beforeEnabled, isTrue);
    expect(cfgs.length, 5);
  });

  test('backup round-trip remaps playlist and audio ids', () async {
    final tmp = await Directory.systemTemp.createTemp('ra');
    final f = File('${tmp.path}/a.mp3')..writeAsBytesSync([0, 1, 2]);
    final audioId = await db.into(db.audioLibrary).insert(AudioLibraryCompanion.insert(title: 'Azan', category: 'azan', filePath: f.path));
    final plId = await db.into(db.audioPlaylists).insert(AudioPlaylistsCompanion.insert(name: 'Subuh'));
    await db.into(db.audioPlaylistItems).insert(AudioPlaylistItemsCompanion.insert(playlistId: plId, audioId: audioId, position: 0));
    await SettingsRepository(db).saveAudioConfig(PrayerAudioConfig.defaultFor(Prayer.subuh)
        .copyWithJson({'beforePlaylistId': plId, 'fullAzanAudioId': audioId, 'atMode': 'fullAzan'}));
    await db.into(db.favorites).insert(FavoritesCompanion.insert(contentId: 'surah_112'));
    final json = await BackupRepository(db).exportJson();
    expect(jsonDecode(json)['app'], 'rumah_azan');

    final db2 = memoryDb();
    addTearDown(db2.close);
    // Occupy ids so restored rows get different ids.
    await db2.into(db2.audioPlaylists).insert(AudioPlaylistsCompanion.insert(name: 'existing'));
    await BackupRepository(db2).importJson(json);
    final pls = await db2.select(db2.audioPlaylists).get();
    final restoredPl = pls.firstWhere((p) => p.name == 'Subuh');
    final cfg = (await SettingsRepository(db2).loadAudioConfigs())[Prayer.subuh]!;
    expect(cfg.beforePlaylistId, restoredPl.id);
    expect(cfg.fullAzanAudioId, isNotNull);
    expect(cfg.atMode, AtPrayerMode.fullAzan);
    expect((await db2.select(db2.favorites).get()).single.contentId, 'surah_112');
    await tmp.delete(recursive: true);
  });

  test('restore rejects foreign files', () async {
    expect(BackupRepository(db).importJson('{"app":"other"}'), throwsA(isA<FormatException>()));
  });

  test('tasbih daily totals aggregate by MYT date', () async {
    final t = TasbihRepository(db);
    await t.save(zikr: 'Subhanallah', count: 33, target: 33);
    await t.save(zikr: 'Alhamdulillah', count: 10, target: 33);
    await t.save(zikr: 'x', count: 0, target: 33); // ignored
    final totals = await t.dailyTotals(7);
    expect(totals.length, 7);
    expect(totals.last.$2, 43);
  });

  test('diagnostics log is bounded', () async {
    final d = DiagnosticsRepository(db);
    for (var i = 0; i < DiagnosticsRepository.maxRows + 20; i++) {
      await d.info('t', 'm$i');
    }
    expect(await db.appDiagnostics.count().getSingle(), DiagnosticsRepository.maxRows);
  });
}
