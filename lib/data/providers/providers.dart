import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../core/services/native_bridge.dart';
import '../../core/utilities/myt_time.dart';
import '../../features/islamic_calendar/domain/calendar_service.dart';
import '../../features/prayer_times/domain/prayer_status.dart';
import '../local/database.dart';
import '../models/app_settings.dart';
import '../models/content_item.dart';
import '../models/prayer_audio_config.dart';
import '../models/prayer_day.dart';
import '../remote/prayer_time_provider.dart';
import '../repositories/audio_repository.dart';
import '../repositories/content_repository.dart';
import '../repositories/diagnostics_repository.dart';
import '../repositories/misc_repositories.dart';
import '../repositories/prayer_repository.dart';
import '../repositories/settings_repository.dart';

// ---- Infrastructure (overridden in main / tests) --------------------------
final databaseProvider = Provider<AppDatabase>((ref) => throw UnimplementedError('override in main'));
final initialSettingsProvider = Provider<AppSettings>((ref) => AppSettings.initial());
final nativeBridgeProvider = Provider<NativeBridge>((ref) => NativeBridge());

Future<Directory> _appSubdir(String name) async =>
    Directory(p.join((await getApplicationDocumentsDirectory()).path, name));

final appDirResolverProvider = Provider<Future<Directory> Function(String)>((ref) => _appSubdir);

// ---- Repositories -----------------------------------------------------------
final diagnosticsRepoProvider = Provider((ref) => DiagnosticsRepository(ref.watch(databaseProvider)));
final settingsRepoProvider = Provider((ref) => SettingsRepository(ref.watch(databaseProvider)));
final prayerRepoProvider =
    Provider((ref) => PrayerRepository(ref.watch(databaseProvider), ref.watch(diagnosticsRepoProvider)));
final audioRepoProvider = Provider((ref) {
  final dirs = ref.watch(appDirResolverProvider);
  return AudioRepository(ref.watch(databaseProvider), () => dirs('audio'));
});
final contentRepoProvider = Provider((ref) => ContentRepository(ref.watch(databaseProvider)));
final tasbihRepoProvider = Provider((ref) => TasbihRepository(ref.watch(databaseProvider)));
final calendarRepoProvider = Provider((ref) => CalendarRepository(ref.watch(databaseProvider)));
final wallpaperRepoProvider = Provider((ref) {
  final dirs = ref.watch(appDirResolverProvider);
  return WallpaperRepository(ref.watch(databaseProvider), () => dirs('wallpapers'));
});
final backupRepoProvider = Provider((ref) => BackupRepository(ref.watch(databaseProvider)));

final prayerProviderImplProvider = Provider<PrayerTimeProvider>((ref) {
  final id = ref.watch(settingsProvider.select((s) => s.prayerProvider));
  return id == 'mirror' ? WaktuSolatMirrorProvider() : JakimESolatProvider();
});

// ---- Settings ---------------------------------------------------------------
class SettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() => ref.read(initialSettingsProvider);

  Future<void> update(Map<String, Object?> patch) async {
    state = state.copyWith(patch);
    await ref.read(settingsRepoProvider).save(state);
  }

  Future<void> replace(AppSettings s) async {
    state = s;
    await ref.read(settingsRepoProvider).save(s);
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);

class AudioConfigsNotifier extends AsyncNotifier<Map<Prayer, PrayerAudioConfig>> {
  @override
  Future<Map<Prayer, PrayerAudioConfig>> build() => ref.read(settingsRepoProvider).loadAudioConfigs();

  Future<void> save(PrayerAudioConfig c) async {
    await ref.read(settingsRepoProvider).saveAudioConfig(c);
    state = AsyncData({...?state.value, c.prayer: c});
  }
}

final audioConfigsProvider =
    AsyncNotifierProvider<AudioConfigsNotifier, Map<Prayer, PrayerAudioConfig>>(AudioConfigsNotifier.new);

// ---- Clock ------------------------------------------------------------------
/// Ticks every second. Only small widgets (countdowns, clocks) watch this.
final secondTickProvider = StreamProvider<DateTime>((ref) async* {
  yield Myt.nowInstant();
  yield* Stream.periodic(const Duration(seconds: 1), (_) => Myt.nowInstant());
});

/// Current Malaysian civil date; changes at midnight MYT (date rollover).
final todayKeyProvider = Provider<String>((ref) {
  final now = ref.watch(secondTickProvider).value ?? Myt.nowInstant();
  return Myt.dateKey(now);
});

/// Bumped whenever cached timetables change, to reload dependent providers.
class DataVersion extends Notifier<int> {
  @override
  int build() => 0;
  void bump() => state++;
}

final dataVersionProvider = NotifierProvider<DataVersion, int>(DataVersion.new);

// ---- Prayer data --------------------------------------------------------------
class DayWindow {
  const DayWindow({this.yesterday, this.today, this.tomorrow, this.lastFetched});
  final PrayerDay? yesterday;
  final PrayerDay? today;
  final PrayerDay? tomorrow;
  final DateTime? lastFetched;

  bool get hasVerifiedToday => today != null && today!.source.isVerified;
}

final dayWindowProvider = FutureProvider<DayWindow>((ref) async {
  ref.watch(dataVersionProvider);
  final zone = ref.watch(settingsProvider.select((s) => s.zoneCode));
  final allowEst = ref.watch(settingsProvider.select((s) => s.allowEstimateDisplay));
  final today = ref.watch(todayKeyProvider);
  if (zone == null) return const DayWindow();
  final repo = ref.read(prayerRepoProvider);
  return DayWindow(
    yesterday: await repo.resolveDay(zone, Myt.addDays(today, -1), allowEstimate: allowEst),
    today: await repo.resolveDay(zone, today, allowEstimate: allowEst),
    tomorrow: await repo.resolveDay(zone, Myt.addDays(today, 1), allowEstimate: allowEst),
    lastFetched: await repo.lastFetchedAt(zone),
  );
});

/// Live prayer status, recomputed every second.
final prayerStatusProvider = Provider<PrayerStatus?>((ref) {
  final w = ref.watch(dayWindowProvider).value;
  final now = ref.watch(secondTickProvider).value ?? Myt.nowInstant();
  if (w == null) return null;
  return computePrayerStatus(now: now, today: w.today, yesterday: w.yesterday, tomorrow: w.tomorrow);
});

// ---- Calendar ---------------------------------------------------------------
final calendarServiceProvider = FutureProvider<CalendarService>((ref) async {
  ref.watch(dataVersionProvider);
  final adjust = ref.watch(settingsProvider.select((s) => s.hijriAdjust));
  final repo = ref.read(calendarRepoProvider);
  return CalendarService(
    jakimHijri: await repo.jakimHijriMap(),
    overrides: await repo.overrides(),
    userAdjust: adjust,
  );
});

// ---- Content ----------------------------------------------------------------
final contentProvider = FutureProvider<List<ContentItem>>((ref) => ref.read(contentRepoProvider).all());
final favoritesProvider = StreamProvider<Set<String>>((ref) => ref.read(contentRepoProvider).watchFavorites());

// ---- Player -----------------------------------------------------------------
final playerStateProvider = StreamProvider<PlayerState>((ref) async* {
  final bridge = ref.read(nativeBridgeProvider);
  // Without the native layer (tests, non-Android hosts) stay idle instead of
  // subscribing to a channel that does not exist.
  if (!await bridge.ping()) {
    yield const PlayerState();
    return;
  }
  yield await bridge.playerState();
  yield* bridge.playerEvents();
});

// ---- Sync status (online/offline as observed by the last attempt) -----------
class SyncStatus {
  const SyncStatus({this.inProgress = false, this.lastOk, this.lastError, this.lastAttempt, this.provider});
  final bool inProgress;
  final bool? lastOk;
  final String? lastError;
  final DateTime? lastAttempt;
  final String? provider;
}

class SyncStatusNotifier extends Notifier<SyncStatus> {
  @override
  SyncStatus build() => const SyncStatus();
  void set(SyncStatus s) => state = s;
}

final syncStatusProvider = NotifierProvider<SyncStatusNotifier, SyncStatus>(SyncStatusNotifier.new);

// ---- Scheduler status --------------------------------------------------------
class SchedulerSnapshot {
  const SchedulerSnapshot({this.planned = 0, this.accepted = 0, this.at, this.error, this.nextTitle, this.nextAt});
  final int planned;
  final int accepted;
  final DateTime? at;
  final String? error;
  final String? nextTitle;
  final DateTime? nextAt;
}

class SchedulerSnapshotNotifier extends Notifier<SchedulerSnapshot> {
  @override
  SchedulerSnapshot build() => const SchedulerSnapshot();
  void set(SchedulerSnapshot s) => state = s;
}

final schedulerSnapshotProvider =
    NotifierProvider<SchedulerSnapshotNotifier, SchedulerSnapshot>(SchedulerSnapshotNotifier.new);

/// Sleep mode manual toggle (session only; scheduled mode is in settings).
class SleepManual extends Notifier<bool> {
  @override
  bool build() => false;
  void set(bool v) => state = v;
}

final sleepManualProvider = NotifierProvider<SleepManual, bool>(SleepManual.new);

/// Instant until which the *scheduled* sleep window is dismissed by the user.
class SleepDismissedUntil extends Notifier<DateTime?> {
  @override
  DateTime? build() => null;
  void set(DateTime? v) => state = v;
}

final sleepDismissedUntilProvider = NotifierProvider<SleepDismissedUntil, DateTime?>(SleepDismissedUntil.new);

/// Whether the scheduled sleep window contains [now].
bool sleepWindowActive(AppSettings s, DateTime now) {
  if (!s.sleepScheduled) return false;
  final w = Myt.toWall(now);
  final start = Myt.parseHm(s.sleepStart), end = Myt.parseHm(s.sleepEnd);
  if (start == null || end == null) return false;
  return Myt.inWindow(w.hour * 60 + w.minute, start, end);
}

/// Next instant at which the scheduled sleep window ends.
DateTime sleepWindowEnd(AppSettings s, DateTime now) {
  final end = Myt.parseHm(s.sleepEnd) ?? 0;
  final w = Myt.toWall(now);
  var candidate = Myt.instantFromWall(w.year, w.month, w.day, end ~/ 60, end % 60);
  if (!candidate.isAfter(now)) candidate = candidate.add(const Duration(days: 1));
  return candidate;
}

/// True when Sleep Mode should be shown (manual or scheduled window).
final sleepActiveProvider = Provider<bool>((ref) {
  if (ref.watch(sleepManualProvider)) return true;
  final s = ref.watch(settingsProvider);
  if (!s.sleepScheduled) return false;
  final now = ref.watch(secondTickProvider).value ?? Myt.nowInstant();
  final dismissed = ref.watch(sleepDismissedUntilProvider);
  if (dismissed != null && now.isBefore(dismissed)) return false;
  return sleepWindowActive(s, now);
});
