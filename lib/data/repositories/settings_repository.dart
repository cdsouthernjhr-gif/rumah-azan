import 'dart:convert';

import 'package:drift/drift.dart';

import '../local/database.dart';
import '../models/app_settings.dart';
import '../models/prayer_audio_config.dart';
import '../models/prayer_day.dart';

class SettingsRepository {
  SettingsRepository(this.db);
  final AppDatabase db;

  static const _key = 'app_settings';

  Future<AppSettings> load() async {
    final row = await (db.select(db.userSettings)..where((t) => t.key.equals(_key))).getSingleOrNull();
    if (row == null) return AppSettings.initial();
    try {
      final m = jsonDecode(row.value);
      if (m is Map<String, dynamic>) return AppSettings(m);
    } catch (_) {/* corrupted → defaults */}
    return AppSettings.initial();
  }

  Future<void> save(AppSettings s) => db.into(db.userSettings).insertOnConflictUpdate(
        UserSettingsCompanion.insert(
          key: _key,
          value: jsonEncode(s.toJson()),
          updatedAt: Value(DateTime.now().toUtc()),
        ),
      );

  Future<Map<Prayer, PrayerAudioConfig>> loadAudioConfigs() async {
    final rows = await db.select(db.audioSchedules).get();
    final notif = await db.select(db.notificationSettings).get();
    final out = <Prayer, PrayerAudioConfig>{};
    for (final p in Prayer.obligatory) {
      final a = rows.where((r) => r.prayer == p.name).firstOrNull;
      final n = notif.where((r) => r.prayer == p.name).firstOrNull;
      final merged = <String, Object?>{
        if (a != null) ...(_decode(a.configJson)),
        if (n != null) ...(_decode(n.configJson)),
      };
      out[p] = PrayerAudioConfig.fromJson(p, merged);
    }
    return out;
  }

  static const _notifKeys = {'notifyEnabled', 'reminderMinutes', 'vibrate'};

  Future<void> saveAudioConfig(PrayerAudioConfig c) async {
    final all = c.toJson();
    final audio = {for (final e in all.entries) if (!_notifKeys.contains(e.key)) e.key: e.value};
    final notif = {for (final e in all.entries) if (_notifKeys.contains(e.key)) e.key: e.value};
    final now = DateTime.now().toUtc();
    await db.transaction(() async {
      await db.into(db.audioSchedules).insertOnConflictUpdate(AudioSchedulesCompanion.insert(
          prayer: c.prayer.name, configJson: jsonEncode(audio), updatedAt: Value(now)));
      await db.into(db.notificationSettings).insertOnConflictUpdate(NotificationSettingsCompanion.insert(
          prayer: c.prayer.name, configJson: jsonEncode(notif), updatedAt: Value(now)));
    });
  }

  static Map<String, Object?> _decode(String s) {
    try {
      final m = jsonDecode(s);
      if (m is Map<String, dynamic>) return m;
    } catch (_) {}
    return const {};
  }
}
