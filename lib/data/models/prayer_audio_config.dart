import 'prayer_day.dart';

/// What happens exactly at prayer time.
enum AtPrayerMode { fullAzan, shortAzan, notificationOnly, silent }

/// Per-prayer configuration for the automatic audio & notification engine.
class PrayerAudioConfig {
  const PrayerAudioConfig({
    required this.prayer,
    this.beforeEnabled = false,
    this.beforeMinutes = 10,
    this.beforePlaylistId,
    this.beforeVolume = 0.7,
    this.atMode = AtPrayerMode.notificationOnly,
    this.fullAzanAudioId,
    this.shortAzanAudioId,
    this.atVolume = 1.0,
    this.afterEnabled = false,
    this.afterDelayMinutes = 15,
    this.afterPlaylistId,
    this.afterRepeat = 1,
    this.afterMaxMinutes = 15,
    this.afterVolume = 0.7,
    this.notifyEnabled = true,
    this.reminderMinutes = 0,
    this.vibrate = true,
  });

  final Prayer prayer;

  // A. Before prayer
  final bool beforeEnabled;
  final int beforeMinutes;
  final int? beforePlaylistId;
  final double beforeVolume;

  // B. At prayer time
  final AtPrayerMode atMode;
  final int? fullAzanAudioId;
  final int? shortAzanAudioId;
  final double atVolume;

  // C. After prayer
  final bool afterEnabled;
  final int afterDelayMinutes;
  final int? afterPlaylistId;
  final int afterRepeat;
  final int afterMaxMinutes;
  final double afterVolume;

  // Notifications
  final bool notifyEnabled;

  /// Advance reminder notification (minutes before); 0 = off.
  final int reminderMinutes;
  final bool vibrate;

  /// Defaults from the brief: Subuh/Maghrib/Isyak 15 min, Zohor/Asar 10 min.
  factory PrayerAudioConfig.defaultFor(Prayer p) => PrayerAudioConfig(
        prayer: p,
        beforeMinutes: switch (p) {
          Prayer.zohor || Prayer.asar => 10,
          _ => 15,
        },
      );

  PrayerAudioConfig copyWithJson(Map<String, Object?> patch) =>
      PrayerAudioConfig.fromJson(prayer, {...toJson(), ...patch});

  Map<String, Object?> toJson() => {
        'beforeEnabled': beforeEnabled,
        'beforeMinutes': beforeMinutes,
        'beforePlaylistId': beforePlaylistId,
        'beforeVolume': beforeVolume,
        'atMode': atMode.name,
        'fullAzanAudioId': fullAzanAudioId,
        'shortAzanAudioId': shortAzanAudioId,
        'atVolume': atVolume,
        'afterEnabled': afterEnabled,
        'afterDelayMinutes': afterDelayMinutes,
        'afterPlaylistId': afterPlaylistId,
        'afterRepeat': afterRepeat,
        'afterMaxMinutes': afterMaxMinutes,
        'afterVolume': afterVolume,
        'notifyEnabled': notifyEnabled,
        'reminderMinutes': reminderMinutes,
        'vibrate': vibrate,
      };

  factory PrayerAudioConfig.fromJson(Prayer p, Map<String, Object?> j) {
    final d = PrayerAudioConfig.defaultFor(p);
    int i(String k, int def, int min, int max) =>
        ((j[k] is num) ? (j[k] as num).toInt() : def).clamp(min, max);
    double v(String k, double def) =>
        ((j[k] is num) ? (j[k] as num).toDouble() : def).clamp(0.0, 1.0);
    bool b(String k, bool def) => j[k] is bool ? j[k] as bool : def;
    int? id(String k) => j[k] is num ? (j[k] as num).toInt() : null;
    return PrayerAudioConfig(
      prayer: p,
      beforeEnabled: b('beforeEnabled', d.beforeEnabled),
      beforeMinutes: i('beforeMinutes', d.beforeMinutes, 1, 60),
      beforePlaylistId: id('beforePlaylistId'),
      beforeVolume: v('beforeVolume', d.beforeVolume),
      atMode: AtPrayerMode.values.firstWhere((m) => m.name == j['atMode'], orElse: () => d.atMode),
      fullAzanAudioId: id('fullAzanAudioId'),
      shortAzanAudioId: id('shortAzanAudioId'),
      atVolume: v('atVolume', d.atVolume),
      afterEnabled: b('afterEnabled', d.afterEnabled),
      afterDelayMinutes: i('afterDelayMinutes', d.afterDelayMinutes, 0, 60),
      afterPlaylistId: id('afterPlaylistId'),
      afterRepeat: i('afterRepeat', d.afterRepeat, 1, 10),
      afterMaxMinutes: i('afterMaxMinutes', d.afterMaxMinutes, 1, 120),
      afterVolume: v('afterVolume', d.afterVolume),
      notifyEnabled: b('notifyEnabled', d.notifyEnabled),
      reminderMinutes: i('reminderMinutes', d.reminderMinutes, 0, 60),
      vibrate: b('vibrate', d.vibrate),
    );
  }
}
