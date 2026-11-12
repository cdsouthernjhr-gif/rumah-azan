import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/prayer_day.dart';
import '../../data/providers/providers.dart';
import '../../features/audio_scheduler/domain/schedule_planner.dart';
import '../constants/app_constants.dart';
import '../l10n/l10n.dart';
import '../utilities/myt_time.dart';

/// Orchestrates data refresh and audio schedule synchronisation.
///
/// Called on start-up, app resume, zone/provider change and whenever audio
/// configuration changes. Every step is idempotent: the planner produces
/// deterministic event ids and the native layer replaces its whole list.
class AppController {
  AppController(this.ref);
  final Ref ref;

  bool _refreshing = false;

  /// Fetches the timetable if the cache does not cover the next week, or if
  /// [force] is set. Errors are recorded, never thrown to the UI.
  Future<void> refreshPrayerData({bool force = false}) async {
    final settings = ref.read(settingsProvider);
    final zone = settings.zoneCode;
    if (zone == null || _refreshing) return;
    final repo = ref.read(prayerRepoProvider);
    if (!force) {
      final last = await repo.lastCachedDate(zone);
      final fetched = await repo.lastFetchedAt(zone);
      final horizon = Myt.addDays(Myt.todayKey(), AppConstants.schedulerHorizonDays);
      final recent = fetched != null && DateTime.now().toUtc().difference(fetched) < const Duration(days: 3);
      // Enough recent data cached for the scheduler horizon → avoid requests.
      if (last != null && last.compareTo(horizon) >= 0 && recent) return;
      // Source may only publish the current month (end-of-month gap): do not
      // re-request more than every 6 hours.
      if (last != null && last.compareTo(Myt.todayKey()) >= 0 && fetched != null &&
          DateTime.now().toUtc().difference(fetched) < const Duration(hours: 6)) {
        return;
      }
    }
    _refreshing = true;
    final status = ref.read(syncStatusProvider.notifier);
    status.set(SyncStatus(inProgress: true, lastAttempt: DateTime.now()));
    try {
      final provider = ref.read(prayerProviderImplProvider);
      final r = await repo.refresh(zone, provider);
      status.set(SyncStatus(
        lastOk: r.ok,
        lastError: r.error,
        lastAttempt: DateTime.now(),
        provider: r.providerName,
      ));
      if (r.ok) {
        await ref.read(settingsProvider.notifier).update({'lastSyncAt': DateTime.now().toUtc().toIso8601String()});
        ref.read(dataVersionProvider.notifier).bump();
        await resyncSchedule();
      }
    } finally {
      _refreshing = false;
    }
  }

  /// Rebuilds the audio/notification plan and hands it to the native layer.
  Future<int> resyncSchedule() async {
    final settings = ref.read(settingsProvider);
    final zone = settings.zoneCode;
    final bridge = ref.read(nativeBridgeProvider);
    final diag = ref.read(diagnosticsRepoProvider);
    final snap = ref.read(schedulerSnapshotProvider.notifier);
    if (zone == null) return 0;
    try {
      final l10n = L10n(settings.language);
      final configs = await ref.read(audioConfigsProvider.future);
      final (audio, playlists) = await ref.read(audioRepoProvider).plannerMaps();
      final days = await ref.read(prayerRepoProvider).resolveRange(
            zone,
            Myt.todayKey(),
            AppConstants.schedulerHorizonDays,
            allowEstimate: settings.allowEstimateForAlarms,
          );
      final start = Myt.parseHm(settings.sleepStart), end = Myt.parseHm(settings.sleepEnd);
      final events = const SchedulePlanner().plan(PlannerInput(
        now: Myt.nowInstant(),
        days: days,
        configs: configs,
        audio: audio,
        playlists: playlists,
        prayerNames: {for (final p in Prayer.values) p: l10n.t('prayer_${p.name}')},
        texts: {
          'reminderTitle': l10n.t('notif_reminder_title'),
          'reminderBody': l10n.t('notif_reminder_body'),
          'azanTitle': l10n.t('notif_azan_title'),
          'azanBody': l10n.t('notif_azan_body'),
          'beforeTitle': l10n.t('notif_before_title'),
          'afterTitle': l10n.t('notif_after_title'),
        },
        autoAudioEnabled: settings.autoAudioEnabled,
        allowEstimate: settings.allowEstimateForAlarms,
        sleepWindow: settings.sleepScheduled && settings.sleepMuteNonEssential && start != null && end != null
            ? (start, end)
            : null,
      ));
      final accepted = await bridge.syncSchedule(
        [for (final e in events) e.toJson()],
        options: {
          'respectSilent': settings.respectSilentMode,
          'refreshTitle': l10n.t('notif_refresh_title'),
          'refreshBody': l10n.t('notif_refresh_body'),
          'missedTitle': l10n.t('notif_missed_title'),
          'silentSkippedBody': l10n.t('notif_silent_skipped'),
          'stopLabel': l10n.t('stop'),
        },
      );
      snap.set(SchedulerSnapshot(
        planned: events.length,
        accepted: accepted,
        at: DateTime.now(),
        nextTitle: events.isEmpty ? null : events.first.title,
        nextAt: events.isEmpty ? null : events.first.triggerAt,
      ));
      if (days.isEmpty) {
        await diag.warn('scheduler', 'Tiada jadual waktu solat disahkan untuk dijadualkan ($zone)');
      } else {
        await diag.info('scheduler', '${events.length} acara dirancang, ${days.length} hari');
      }
      return events.length;
    } catch (e) {
      snap.set(SchedulerSnapshot(at: DateTime.now(), error: e.toString()));
      await diag.error('scheduler', '$e');
      return 0;
    }
  }

  /// Imports playback history recorded natively (while app was closed).
  Future<void> importNativeHistory() async {
    try {
      final entries = await ref.read(nativeBridgeProvider).drainPlaybackHistory();
      if (entries.isNotEmpty) await ref.read(audioRepoProvider).addHistory(entries);
    } catch (e) {
      await ref.read(diagnosticsRepoProvider).warn('history', '$e');
    }
  }

  Future<void> onResume() async {
    await importNativeHistory();
    await refreshPrayerData();
    await resyncSchedule();
  }
}

final appControllerProvider = Provider<AppController>((ref) => AppController(ref));
