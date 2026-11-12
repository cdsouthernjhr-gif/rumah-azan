import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'data/local/database.dart';
import 'data/providers/providers.dart';
import 'data/repositories/prayer_repository.dart';
import 'data/repositories/diagnostics_repository.dart';
import 'data/repositories/settings_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = AppDatabase(driftDatabase(name: 'rumah_azan'));
  final settings = await SettingsRepository(db).load();
  await PrayerRepository(db, DiagnosticsRepository(db)).ensureZonesSeeded();

  runApp(ProviderScope(
    overrides: [
      databaseProvider.overrideWithValue(db),
      initialSettingsProvider.overrideWithValue(settings),
    ],
    child: const RumahAzanApp(),
  ));
}
