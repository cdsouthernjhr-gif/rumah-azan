import 'package:drift/drift.dart';

part 'database.g.dart';

/// SCHEMA NOTES
/// - Static, read-only religious content (Quran surahs, zikir, doa) ships as a
///   versioned JSON asset (assets/data/content.json) instead of being copied
///   into SQLite. User-generated state about it (favorites) lives here.
/// - Prayer zones are bundled in code (lib/data/static/jakim_zones.dart) and
///   mirrored into [PrayerZones] so timetables have a foreign-key target.
/// - All timestamps are stored as UTC.

@DataClassName('PrayerZoneRow')
class PrayerZones extends Table {
  TextColumn get code => text().withLength(min: 4, max: 8)();
  TextColumn get state => text()();
  TextColumn get areas => text()();
  RealColumn get lat => real().nullable()();
  RealColumn get lng => real().nullable()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  @override
  Set<Column> get primaryKey => {code};
}

@DataClassName('PrayerTimeRow')
@TableIndex(name: 'idx_prayer_times_zone_date', columns: {#zone, #date}, unique: true)
class PrayerTimes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get zone => text().references(PrayerZones, #code)();
  TextColumn get date => text()(); // yyyy-MM-dd (Malaysian civil date)
  IntColumn get imsak => integer().nullable()(); // epoch ms UTC
  IntColumn get subuh => integer()();
  IntColumn get syuruk => integer()();
  IntColumn get zohor => integer()();
  IntColumn get asar => integer()();
  IntColumn get maghrib => integer()();
  IntColumn get isyak => integer()();
  TextColumn get hijri => text().nullable()();
  TextColumn get source => text()(); // jakim | mirror
  DateTimeColumn get fetchedAt => dateTime()();
}

/// Officially confirmed (or user-entered) dates of Islamic events, overriding
/// the calculated Hijri date for a given Hijri year.
@DataClassName('IslamicEventRow')
@TableIndex(name: 'idx_events_key_year', columns: {#eventKey, #hijriYear}, unique: true)
class IslamicEvents extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get eventKey => text()();
  IntColumn get hijriYear => integer()();
  TextColumn get gregorianDate => text()(); // yyyy-MM-dd
  TextColumn get source => text()(); // official | user
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// User adjustments to the calculated Hijri calendar per Hijri month.
@DataClassName('HijriAdjustmentRow')
class IslamicCalendar extends Table {
  IntColumn get hijriYear => integer()();
  IntColumn get hijriMonth => integer()();
  IntColumn get adjustDays => integer().withDefault(const Constant(0))();
  TextColumn get source => text().withDefault(const Constant('user'))();
  @override
  Set<Column> get primaryKey => {hijriYear, hijriMonth};
}

@DataClassName('AudioRow')
@TableIndex(name: 'idx_audio_category', columns: {#category})
class AudioLibrary extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get category => text()(); // azan | quran | zikr | doa | selawat | other
  TextColumn get filePath => text().unique()();
  TextColumn get sourceUrl => text().nullable()();
  TextColumn get contentId => text().nullable()(); // link to content.json item
  IntColumn get durationMs => integer().nullable()();
  TextColumn get licenseNote => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('PlaylistRow')
class AudioPlaylists extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('PlaylistItemRow')
@TableIndex(name: 'idx_playlist_items_playlist', columns: {#playlistId, #position})
class AudioPlaylistItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get playlistId => integer().references(AudioPlaylists, #id, onDelete: KeyAction.cascade)();
  IntColumn get audioId => integer().references(AudioLibrary, #id, onDelete: KeyAction.cascade)();
  IntColumn get position => integer()();
}

/// Per-prayer audio scheduling configuration (before / at / after prayer),
/// stored as JSON (see PrayerAudioConfig).
@DataClassName('AudioScheduleRow')
class AudioSchedules extends Table {
  TextColumn get prayer => text()();
  TextColumn get configJson => text()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  @override
  Set<Column> get primaryKey => {prayer};
}

@DataClassName('PlaybackHistoryRow')
@TableIndex(name: 'idx_playback_started', columns: {#startedAt})
class AudioPlaybackHistory extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get eventId => text().nullable()();
  TextColumn get title => text()();
  TextColumn get status => text()(); // played | skipped | error | missed
  TextColumn get detail => text().nullable()();
  DateTimeColumn get startedAt => dateTime()();
  @override
  List<Set<Column>> get uniqueKeys => [
        {eventId, startedAt},
      ];
}

@DataClassName('WallpaperRow')
class Wallpapers extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get filePath => text().unique()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('SettingRow')
class UserSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  @override
  Set<Column> get primaryKey => {key};
}

@DataClassName('FavoriteRow')
class Favorites extends Table {
  TextColumn get contentId => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  @override
  Set<Column> get primaryKey => {contentId};
}

@DataClassName('TasbihRow')
@TableIndex(name: 'idx_tasbih_date', columns: {#date})
class TasbihRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get zikr => text()();
  IntColumn get count => integer()();
  IntColumn get target => integer()();
  TextColumn get date => text()(); // yyyy-MM-dd MYT
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('NotificationSettingRow')
class NotificationSettings extends Table {
  TextColumn get prayer => text()();
  TextColumn get configJson => text()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  @override
  Set<Column> get primaryKey => {prayer};
}

@DataClassName('DiagnosticRow')
@TableIndex(name: 'idx_diag_created', columns: {#createdAt})
class AppDiagnostics extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get level => text()(); // info | warn | error
  TextColumn get tag => text()();
  TextColumn get message => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [
  PrayerZones,
  PrayerTimes,
  IslamicEvents,
  IslamicCalendar,
  AudioLibrary,
  AudioPlaylists,
  AudioPlaylistItems,
  AudioSchedules,
  AudioPlaybackHistory,
  Wallpapers,
  UserSettings,
  Favorites,
  TasbihRecords,
  NotificationSettings,
  AppDiagnostics,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  /// Increment and add a step in [migration] whenever the schema changes.
  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async => m.createAll(),
        onUpgrade: (m, from, to) async {
          // Future migrations go here, e.g.:
          // if (from < 2) await m.addColumn(audioLibrary, audioLibrary.someColumn);
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}
