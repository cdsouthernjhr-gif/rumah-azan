import 'package:drift_flutter/drift_flutter.dart';
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
/// NOTE: `shareAcrossIsolates` is deliberately NOT used: if opening SQLite
/// fails, drift_flutter's shared mode retries forever, which froze the app on
/// its splash screen. Concurrent access from the UI and the background engine
/// is instead handled by SQLite itself (WAL + busy_timeout, see
/// AppDatabase.migration.beforeOpen).
AppDatabase openAppDatabase() => AppDatabase(driftDatabase(name: 'rumah_azan'));

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
    db = openAppDatabase();
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
