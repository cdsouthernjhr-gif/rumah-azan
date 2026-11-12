import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'background_sync.dart';
import 'core/startup_error_app.dart';
import 'data/local/database.dart';
import 'data/models/app_settings.dart';
import 'data/providers/providers.dart';
import 'data/repositories/diagnostics_repository.dart';
import 'data/repositories/prayer_repository.dart';
import 'data/repositories/settings_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final AppDatabase db;
  final AppSettings settings;
  try {
    // Never hang on the splash screen: if storage cannot be opened, show the
    // reason on screen so the user can report it.
    (db, settings) = await _openStorage().timeout(const Duration(seconds: 20));
  } catch (e, st) {
    debugPrint('Rumah Azan startup error: $e\n$st'); // visible in logcat
    runApp(StartupErrorApp(error: e, stack: st));
    return;
  }

  runApp(ProviderScope(
    overrides: [
      databaseProvider.overrideWithValue(db),
      initialSettingsProvider.overrideWithValue(settings),
    ],
    child: const RumahAzanApp(),
  ));
}

Future<(AppDatabase, AppSettings)> _openStorage() async {
  final db = openAppDatabase();
  final settings = await SettingsRepository(db).load();
  await PrayerRepository(db, DiagnosticsRepository(db)).ensureZonesSeeded();
  return (db, settings);
}

/// Headless entry point for the daily background refresh
/// (android/.../BackgroundSyncJob.kt). Kept in the root library and marked
/// as an entry point so it is not tree-shaken from release builds.
@pragma('vm:entry-point')
Future<void> backgroundSyncMain() => runBackgroundSync();
