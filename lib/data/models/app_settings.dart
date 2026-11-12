import '../../core/theme/app_theme.dart';

/// Immutable application settings backed by a JSON map.
///
/// Unknown keys are preserved so newer backups restore cleanly on older
/// builds, and missing keys fall back to defaults.
class AppSettings {
  const AppSettings(this.raw);
  final Map<String, Object?> raw;

  static const defaults = <String, Object?>{
    'language': 'ms',
    'zoneCode': null, // null → onboarding (Kluang/JHR03 pre-selected)
    'prayerProvider': 'jakim', // jakim | mirror
    'allowEstimateDisplay': true,
    'allowEstimateForAlarms': false,
    'showImsak': true,
    'theme': 'emeraldGold',
    'fontScale': 1.0,
    'autoAudioEnabled': true,
    'respectSilentMode': true,
    'hijriAdjust': 0, // −2..+2 days applied to the calculated Hijri date
    // Wallpaper
    'wallpaperAuto': true,
    'wallpaperFixed': 'builtin:night_crescent',
    'wallpaperMorning': 'builtin:morning_sunrise',
    'wallpaperAfternoon': 'builtin:afternoon_cream',
    'wallpaperEvening': 'builtin:evening_sunset',
    'wallpaperNight': 'builtin:night_crescent',
    'slotMorning': '05:00',
    'slotAfternoon': '11:00',
    'slotEvening': '17:00',
    'slotNight': '19:30',
    'autoThemeFromSlot': false,
    'wpBrightness': 1.0, // 0.3..1.0
    'wpOverlay': 0.35, // dark overlay 0..0.8
    'wpBlur': 0.0, // 0..12
    'wpFit': 'cover', // cover | contain
    // Display mode
    'keepScreenOn': false,
    'orientation': 'auto', // auto | portrait | landscape
    'startInDisplayMode': false,
    'displayAutoReturnMin': 0, // 0 = off
    'screensaverMin': 0, // 0 = off
    'slideshow': false,
    'slideshowSec': 60,
    // Sleep mode
    'sleepScheduled': false,
    'sleepStart': '22:30',
    'sleepEnd': '05:00',
    'sleepDim': 0.6, // overlay dimming 0..0.9 (app-level only)
    'sleepMuteNonEssential': true,
    // Extra notifications
    'zikrMorningReminder': false,
    'zikrMorningTime': '07:00',
    'zikrEveningReminder': false,
    'zikrEveningTime': '17:30',
    'eventReminder': true,
    'eventReminderTime': '08:00',
    'notifyBeforeRecitation': false,
    // Wallpaper framing ("crop"): zoom ≥ 1 and focal point −1..1
    'wpZoom': 1.0,
    'wpAlignX': 0.0,
    'wpAlignY': 0.0,
    // Housekeeping
    'lastSyncAt': null,
    'onboardingDone': false,
  };

  factory AppSettings.initial() => AppSettings(Map.of(defaults));

  T _get<T>(String k) {
    final v = raw.containsKey(k) ? raw[k] : defaults[k];
    if (v is T) return v;
    final d = defaults[k];
    if (T == double && d is num) return d.toDouble() as T;
    return d as T;
  }

  double _num(String k) {
    final v = raw[k] ?? defaults[k];
    return v is num ? v.toDouble() : (defaults[k] as num).toDouble();
  }

  int _int(String k) {
    final v = raw[k] ?? defaults[k];
    return v is num ? v.toInt() : (defaults[k] as num).toInt();
  }

  AppSettings copyWith(Map<String, Object?> patch) => AppSettings({...raw, ...patch});

  Map<String, Object?> toJson() => {...defaults, ...raw};

  String get language => _get<String>('language');
  String? get zoneCode => raw['zoneCode'] as String?;
  String get prayerProvider => _get<String>('prayerProvider');
  bool get allowEstimateDisplay => _get<bool>('allowEstimateDisplay');
  bool get allowEstimateForAlarms => _get<bool>('allowEstimateForAlarms');
  bool get showImsak => _get<bool>('showImsak');
  AppThemeId get theme => AppThemeId.values.firstWhere(
        (t) => t.name == raw['theme'],
        orElse: () => AppThemeId.emeraldGold,
      );
  double get fontScale => _num('fontScale').clamp(0.8, 1.6);
  bool get autoAudioEnabled => _get<bool>('autoAudioEnabled');
  bool get respectSilentMode => _get<bool>('respectSilentMode');
  int get hijriAdjust => _int('hijriAdjust').clamp(-2, 2);

  bool get wallpaperAuto => _get<bool>('wallpaperAuto');
  String get wallpaperFixed => _get<String>('wallpaperFixed');
  String wallpaperForSlot(String slot) => _get<String>('wallpaper${_cap(slot)}');
  String slotStart(String slot) => _get<String>('slot${_cap(slot)}');
  bool get autoThemeFromSlot => _get<bool>('autoThemeFromSlot');
  double get wpBrightness => _num('wpBrightness').clamp(0.3, 1.0);
  double get wpOverlay => _num('wpOverlay').clamp(0.0, 0.8);
  double get wpBlur => _num('wpBlur').clamp(0.0, 12.0);
  String get wpFit => _get<String>('wpFit');

  bool get keepScreenOn => _get<bool>('keepScreenOn');
  String get orientation => _get<String>('orientation');
  bool get startInDisplayMode => _get<bool>('startInDisplayMode');
  int get displayAutoReturnMin => _int('displayAutoReturnMin');
  int get screensaverMin => _int('screensaverMin');
  bool get slideshow => _get<bool>('slideshow');
  int get slideshowSec => _int('slideshowSec').clamp(10, 3600);

  bool get sleepScheduled => _get<bool>('sleepScheduled');
  String get sleepStart => _get<String>('sleepStart');
  String get sleepEnd => _get<String>('sleepEnd');
  double get sleepDim => _num('sleepDim').clamp(0.0, 0.9);
  bool get sleepMuteNonEssential => _get<bool>('sleepMuteNonEssential');

  bool get zikrMorningReminder => _get<bool>('zikrMorningReminder');
  String get zikrMorningTime => _get<String>('zikrMorningTime');
  bool get zikrEveningReminder => _get<bool>('zikrEveningReminder');
  String get zikrEveningTime => _get<String>('zikrEveningTime');
  bool get eventReminder => _get<bool>('eventReminder');
  String get eventReminderTime => _get<String>('eventReminderTime');
  bool get notifyBeforeRecitation => _get<bool>('notifyBeforeRecitation');

  double get wpZoom => _num('wpZoom').clamp(1.0, 3.0);
  double get wpAlignX => _num('wpAlignX').clamp(-1.0, 1.0);
  double get wpAlignY => _num('wpAlignY').clamp(-1.0, 1.0);

  DateTime? get lastSyncAt {
    final v = raw['lastSyncAt'];
    return v is String ? DateTime.tryParse(v) : null;
  }

  bool get onboardingDone => _get<bool>('onboardingDone');

  static String _cap(String s) => s[0].toUpperCase() + s.substring(1);
}
