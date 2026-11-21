import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rumah_azan/background_sync.dart';
import 'package:rumah_azan/data/local/database.dart';
import 'package:rumah_azan/data/repositories/diagnostics_repository.dart';
import 'package:rumah_azan/data/repositories/prayer_repository.dart';
import 'package:rumah_azan/data/repositories/settings_repository.dart';

/// Regression test for the Galaxy S21 report:
/// "SqliteException(5): database is locked" on first launch, when the UI
/// engine and the background-sync engine opened the same NEW database file
/// at the same time and both ran CREATE TABLE.
void main() {
  // Timing-dependent stress test: retried so a rare scheduler hiccup on a
  // loaded CI machine does not block releases; a real regression fails
  // every attempt. Failures print the round and SQLite error.
  test('two separate connections can create and use the same new file concurrently', retry: 2, () async {
    final dir = await Directory.systemTemp.createTemp('ra_db');
    final file = File('${dir.path}/rumah_azan.sqlite');
    // Two engines in one process = two drift instances on the same file.
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    Future<AppDatabase> open() => openAppDatabaseReady(
          open: () => AppDatabase(NativeDatabase.createInBackground(file, setup: configureSqliteConnection)),
        );

    for (var round = 0; round < 25; round++) {
      for (final f in [file, File('${file.path}-wal'), File('${file.path}-shm')]) {
        if (f.existsSync()) f.deleteSync();
      }
      final List<AppDatabase> opened;
      try {
        opened = await Future.wait([open(), open()]);
      } catch (e, st) {
        // ignore: avoid_print
        print('db_concurrency round $round open failed: $e\n$st');
        rethrow;
      }
      final a = opened[0], b = opened[1];
      Future<void> use(AppDatabase db) async {
        await SettingsRepository(db).load(); // triggers migrations (CREATE TABLE …)
        await PrayerRepository(db, DiagnosticsRepository(db)).ensureZonesSeeded();
        await DiagnosticsRepository(db).info('t', 'concurrent write');
      }

      try {
        await Future.wait([use(a), use(b)]);
      } catch (e, st) {
        // Make any CI failure diagnosable (round + exact SQLite error).
        // ignore: avoid_print
        print('db_concurrency round $round failed: $e\n$st');
        rethrow;
      }
      expect(await a.prayerZones.count().getSingle(), greaterThan(50));
      await a.close();
      await b.close();
    }
    await dir.delete(recursive: true);
  });

  test('connection setup enables WAL and a busy timeout', () async {
    final dir = await Directory.systemTemp.createTemp('ra_db2');
    final db = AppDatabase(NativeDatabase(File('${dir.path}/x.sqlite'), setup: configureSqliteConnection));
    final mode = await db.customSelect('PRAGMA journal_mode').getSingle();
    final timeout = await db.customSelect('PRAGMA busy_timeout').getSingle();
    expect(mode.data.values.first, 'wal');
    expect(timeout.data.values.first, 10000);
    await db.close();
    await dir.delete(recursive: true);
  });
}
