import 'dart:math' as math;

import 'package:drift_flutter/drift_flutter.dart';
import 'package:sqlite3/common.dart' show CommonDatabase;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_constants.dart';
import 'core/services/app_controller.dart';
import 'data/local/database.dart';
import 'data/models/app_settings.dart';
import 'data/providers/providers.dart';
import 'data/repositories/settings_repository.dart';

/// Opens the app database.
///
/// The UI engine and the headless background engine (BackgroundSyncJob) are
/// separate Flutter engines, so they use separate SQLite connections to the
/// same file. `setup` runs right after the connection opens — BEFORE drift
/// creates/migrates tables — so a connection that finds the file busy waits
/// (busy_timeout) instead of failing with "database is locked".
///
/// `shareAcrossIsolates` is deliberately NOT used: it does not work across
/// engines, and when opening fails it retries forever (frozen splash screen).
AppDatabase openAppDatabase() => AppDatabase(driftDatabase(
      name: 'rumah_azan',
      native: DriftNativeOptions(setup: configureSqliteConnection),
    ));

/// True for SQLite "busy"/"locked" errors (another connection holds a lock).
bool isSqliteBusy(Object e) {
  final s = e.toString();
  return s.contains('database is locked') || s.contains('SQLITE_BUSY') || s.contains('(code 5)') || s.contains('(code 6)');
}

/// Opens the database AND runs its migrations, retrying if another
/// connection (UI vs background engine) is creating the same new file at
/// that moment. In some first-open cases SQLite answers "locked" at once
/// without honouring busy_timeout, so a bounded retry with random jitter is
/// what makes concurrent first opens reliable.
Future<AppDatabase> openAppDatabaseReady({AppDatabase Function()? open, int attempts = 8}) async {
  final opener = open ?? openAppDatabase;
  final rnd = math.Random();
  for (var i = 1;; i++) {
    final db = opener();
    try {
      await db.customSelect('SELECT 1').get(); // forces open + migrations
      return db;
    } catch (e) {
      await db.close();
      if (!isSqliteBusy(e) || i >= attempts) rethrow;
      await Future<void>.delayed(Duration(milliseconds: 150 * i + rnd.nextInt(250)));
    }
  }
}

/// Per-connection SQLite settings (also used by tests).
void configureSqliteConnection(CommonDatabase db) {
  db.execute('PRAGMA busy_timeout = 10000');
  // WAL: a reader and a writer can work concurrently. Switching needs
  // exclusive access, and SQLite answers "locked" immediately (no waiting)
  // when another connection is active. WAL is persistent in the file, so it
  // is enough that one connection succeeds; ignore failure here.
  try {
    // Only switch when needed: after the first open the file stays WAL, so
    // later opens never race on the mode change.
    final mode = db.select('PRAGMA journal_mode').first.values.first;
    if ('$mode'.toLowerCase() != 'wal') db.select('PRAGMA journal_mode = WAL');
  } on Object {
    // Another connection is using the file; it will (or did) enable WAL.
  }
}

/// Result of one background run (exposed for tests).
class BackgroundSyncResult {
  const BackgroundSyncResult({required this.ok, required this.planned, required this.skipped});
  final bool ok;
  final int planned;

  /// True when there was nothing to do (first-run setup not completed).
  final bool skipped;
}

/// Refresh-if-needed and re-plan, using the same AppController as the UI.
/// Pure orchestration: no widgets, so it runs in a headless engine.
Future<BackgroundSyncResult> performBackgroundSync(AppDatabase db) async {
  final settings = await SettingsRepository(db).load();
  if (!settings.onboardingDone || settings.zoneCode == null) {
    return const BackgroundSyncResult(ok: true, planned: 0, skipped: true);
  }
  final container = ProviderContainer(overrides: [
    databaseProvider.overrideWithValue(db),
    initialSettingsProvider.overrideWithValue(AppSettings(settings.raw)),
  ]);
  try {
    final ctl = container.read(appControllerProvider);
    await ctl.importNativeHistory();
    await ctl.refreshPrayerData();
    final planned = await ctl.resyncSchedule();
    final sync = container.read(syncStatusProvider);
    await container.read(diagnosticsRepoProvider).info(
          'background',
          'Segerak latar belakang: ${sync.lastOk == null ? 'tiada muat turun diperlukan' : (sync.lastOk! ? 'berjaya' : 'gagal')}, $planned acara',
        );
    return BackgroundSyncResult(ok: sync.lastOk != false, planned: planned, skipped: false);
  } finally {
    container.dispose();
  }
}

/// Entry point run by BackgroundSyncJob.kt in a headless Flutter engine.
Future<void> runBackgroundSync() async {
  WidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel(AppConstants.nativeChannel);
  var ok = false;
  AppDatabase? db;
  try {
    db = await openAppDatabaseReady();
    ok = (await performBackgroundSync(db)).ok;
  } catch (e) {
    debugPrint('background sync failed: $e');
  } finally {
    await db?.close();
    try {
      await channel.invokeMethod('backgroundDone', {'ok': ok});
    } on MissingPluginException {
      // Not running under BackgroundSyncJob (e.g. tests).
    }
  }
}
