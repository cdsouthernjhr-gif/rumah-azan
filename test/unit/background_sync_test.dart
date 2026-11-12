import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rumah_azan/background_sync.dart';
import 'package:rumah_azan/core/utilities/myt_time.dart';
import 'package:rumah_azan/data/local/database.dart';
import 'package:rumah_azan/data/models/app_settings.dart';
import 'package:rumah_azan/data/models/prayer_audio_config.dart';
import 'package:rumah_azan/data/models/prayer_day.dart';
import 'package:rumah_azan/data/repositories/diagnostics_repository.dart';
import 'package:rumah_azan/data/repositories/prayer_repository.dart';
import 'package:rumah_azan/data/repositories/settings_repository.dart';

import '../helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppDatabase db;
  final now = myt('2026-11-12', '10:00');

  setUp(() async {
    Myt.clock = () => now;
    db = AppDatabase(DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true));
    final repo = PrayerRepository(db, DiagnosticsRepository(db));
    await repo.ensureZonesSeeded();
    // Fresh verified data for the whole refresh window → no network needed.
    await repo.upsert([for (var i = 0; i < 31; i++) day(Myt.addDays('2026-11-12', i), fetchedAt: now)]);
  });
  tearDown(() async {
    await db.close();
    Myt.clock = DateTime.now;
  });

  test('skips cleanly before onboarding is completed', () async {
    final r = await performBackgroundSync(db);
    expect(r.skipped, isTrue);
    expect(r.ok, isTrue);
  });

  test('re-plans the full 30-day horizon headlessly (no widgets)', () async {
    final s = SettingsRepository(db);
    await s.save(AppSettings.initial().copyWith({'zoneCode': 'JHR03', 'onboardingDone': true, 'eventReminder': false}));
    await s.saveAudioConfig(PrayerAudioConfig.defaultFor(Prayer.subuh).copyWithJson({'reminderMinutes': 10}));
    final r = await performBackgroundSync(db);
    expect(r.skipped, isFalse);
    expect(r.ok, isTrue);
    // From 10:00 today: 30 days × 5 azan notices − Subuh (passed) today
    // + 30 Subuh reminders − today's (passed).
    expect(r.planned, 30 * 5 - 1 + 30 - 1);
    final log = await DiagnosticsRepository(db).recent(5);
    expect(log.any((e) => e.tag == 'background'), isTrue);
  });
}
