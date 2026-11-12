/// Global constants for Rumah Azan.
class AppConstants {
  AppConstants._();

  static const appName = 'Rumah Azan';
  static const appTagline = 'Islamic Prayer & Lifestyle';
  static const packageId = 'com.rumahazan.app';
  static const appVersion = '0.1.0';

  /// Malaysia uses a single fixed offset (UTC+8, no daylight saving).
  /// All JAKIM prayer times are expressed in Malaysian time, independent of
  /// the device's configured timezone.
  static const mytOffset = Duration(hours: 8);

  static const defaultZoneCode = 'JHR03'; // Kluang, Pontian (Johor)

  static const nativeChannel = 'com.rumahazan.app/native';
  static const playerEventsChannel = 'com.rumahazan.app/player_events';

  /// Number of days ahead the audio scheduler plans (alarms keep working
  /// this long even if the app is never opened).
  static const schedulerHorizonDays = 30;

  /// Refresh the timetable when fewer than this many future days are cached.
  static const refreshCoverageDays = 7;

  /// Kaabah coordinates (Masjidil Haram, Makkah).
  static const kaabahLat = 21.4225;
  static const kaabahLng = 39.8262;
}
