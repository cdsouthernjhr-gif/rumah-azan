import '../../../core/utilities/myt_time.dart';
import '../../../data/models/prayer_audio_config.dart';
import '../../../data/models/prayer_day.dart';

class AudioRef {
  const AudioRef({required this.path, required this.title});
  final String path;
  final String title;
  Map<String, Object?> toJson() => {'path': path, 'title': title};
}

enum ScheduledKind { reminder, before, azan, after }

/// One alarm the native scheduler will fire. Serialised to JSON and handed to
/// the Android AlarmManager layer, which stores it (survives reboot) and
/// executes it.
class ScheduledEvent {
  const ScheduledEvent({
    required this.id,
    required this.triggerAt,
    required this.kind,
    required this.prayer,
    required this.title,
    required this.body,
    this.items = const [],
    this.volume = 1.0,
    this.maxDurationMs = 0,
    this.repeat = 1,
    this.notify = true,
    this.notifySound = false,
    this.vibrate = false,
    this.graceMs = 5 * 60 * 1000,
    this.estimated = false,
  });

  /// Deterministic id → re-planning never duplicates an alarm.
  final String id;
  final DateTime triggerAt;
  final ScheduledKind kind;
  final Prayer prayer;
  final String title;
  final String body;
  final List<AudioRef> items;
  final double volume;

  /// 0 = no limit.
  final int maxDurationMs;
  final int repeat;
  final bool notify;

  /// Use the notification channel's default sound (azan fallback when no
  /// azan audio file is configured).
  final bool notifySound;
  final bool vibrate;

  /// If the alarm fires later than this (device off / dozing), audio is
  /// skipped and only a "missed" notification is shown.
  final int graceMs;
  final bool estimated;

  /// Higher priority interrupts lower priority playback; equal or lower
  /// priority is queued after the current item (prevents overlap).
  int get priority => kind == ScheduledKind.azan ? 3 : 1;

  Map<String, Object?> toJson() => {
        'id': id,
        'triggerAtMs': triggerAt.millisecondsSinceEpoch,
        'kind': kind.name,
        'prayer': prayer.name,
        'title': title,
        'body': body,
        'items': items.map((e) => e.toJson()).toList(),
        'volume': volume,
        'maxDurationMs': maxDurationMs,
        'repeat': repeat,
        'notify': notify,
        'notifySound': notifySound,
        'vibrate': vibrate,
        'graceMs': graceMs,
        'priority': priority,
        'estimated': estimated,
      };
}

class PlannerInput {
  const PlannerInput({
    required this.now,
    required this.days,
    required this.configs,
    required this.audio,
    required this.playlists,
    required this.prayerNames,
    required this.texts,
    this.autoAudioEnabled = true,
    this.allowEstimate = false,
    this.sleepWindow,
  });

  final DateTime now;
  final List<PrayerDay> days;
  final Map<Prayer, PrayerAudioConfig> configs;
  final Map<int, AudioRef> audio;
  final Map<int, List<AudioRef>> playlists;
  final Map<Prayer, String> prayerNames;

  /// Localised templates: reminderTitle, reminderBody, azanTitle, azanBody,
  /// beforeTitle, afterTitle. `{prayer}` and `{min}` are substituted.
  final Map<String, String> texts;
  final bool autoAudioEnabled;
  final bool allowEstimate;

  /// (startMinute, endMinute) MYT wall clock during which non-essential audio
  /// (before/after recitation) is suppressed. Null = no suppression.
  final (int, int)? sleepWindow;
}

class SchedulePlanner {
  const SchedulePlanner();

  List<ScheduledEvent> plan(PlannerInput input) {
    final out = <String, ScheduledEvent>{};
    final sortedDays = [...input.days]..sort((a, b) => a.date.compareTo(b.date));

    String txt(String k, Prayer p, [int min = 0]) => (input.texts[k] ?? k)
        .replaceAll('{prayer}', input.prayerNames[p] ?? p.name)
        .replaceAll('{min}', '$min');

    bool inSleep(DateTime t) {
      final w = input.sleepWindow;
      if (w == null) return false;
      final wall = Myt.toWall(t);
      return Myt.inWindow(wall.hour * 60 + wall.minute, w.$1, w.$2);
    }

    List<AudioRef> playlist(int? id) => id == null ? const [] : (input.playlists[id] ?? const []);

    for (var di = 0; di < sortedDays.length; di++) {
      final day = sortedDays[di];
      final estimated = !day.source.isVerified;
      if (estimated && !input.allowEstimate) continue;

      for (final p in Prayer.obligatory) {
        final cfg = input.configs[p] ?? PrayerAudioConfig.defaultFor(p);
        final t = day.timeOf(p);
        final nextTime = _nextBoundary(sortedDays, di, p, input);

        void add(ScheduledEvent e) {
          if (!e.triggerAt.isAfter(input.now)) return; // past → not scheduled
          out[e.id] = e;
        }

        // Advance reminder notification.
        if (cfg.notifyEnabled && cfg.reminderMinutes > 0) {
          add(ScheduledEvent(
            id: '${day.date}_${p.name}_reminder',
            triggerAt: t.subtract(Duration(minutes: cfg.reminderMinutes)),
            kind: ScheduledKind.reminder,
            prayer: p,
            title: txt('reminderTitle', p, cfg.reminderMinutes),
            body: txt('reminderBody', p, cfg.reminderMinutes),
            notifySound: true,
            vibrate: cfg.vibrate,
            estimated: estimated,
          ));
        }

        // A. Before prayer.
        final beforeItems = playlist(cfg.beforePlaylistId);
        if (input.autoAudioEnabled && cfg.beforeEnabled && beforeItems.isNotEmpty) {
          final start = t.subtract(Duration(minutes: cfg.beforeMinutes));
          if (!inSleep(start)) {
            add(ScheduledEvent(
              id: '${day.date}_${p.name}_before',
              triggerAt: start,
              kind: ScheduledKind.before,
              prayer: p,
              title: txt('beforeTitle', p, cfg.beforeMinutes),
              body: beforeItems.map((e) => e.title).join(' · '),
              items: beforeItems,
              volume: cfg.beforeVolume,
              // Finish 5 s before the azan so they never overlap.
              maxDurationMs: cfg.beforeMinutes * 60000 - 5000,
              notify: false,
              estimated: estimated,
            ));
          }
        }

        // B. At prayer time.
        final azanId = switch (cfg.atMode) {
          AtPrayerMode.fullAzan => cfg.fullAzanAudioId,
          AtPrayerMode.shortAzan => cfg.shortAzanAudioId ?? cfg.fullAzanAudioId,
          _ => null,
        };
        final azan = azanId == null ? null : input.audio[azanId];
        final wantsAudio = input.autoAudioEnabled &&
            (cfg.atMode == AtPrayerMode.fullAzan || cfg.atMode == AtPrayerMode.shortAzan);
        if (wantsAudio || cfg.notifyEnabled) {
          final hasAzanFile = wantsAudio && azan != null;
          add(ScheduledEvent(
            id: '${day.date}_${p.name}_azan',
            triggerAt: t,
            kind: ScheduledKind.azan,
            prayer: p,
            title: txt('azanTitle', p),
            body: txt('azanBody', p),
            items: hasAzanFile ? [azan] : const [],
            volume: cfg.atVolume,
            notify: cfg.notifyEnabled || (wantsAudio && !hasAzanFile),
            // No azan file configured → fall back to the default
            // notification sound rather than silently doing nothing.
            notifySound: cfg.atMode != AtPrayerMode.silent && !hasAzanFile,
            vibrate: cfg.vibrate && cfg.atMode != AtPrayerMode.silent,
            graceMs: 3 * 60 * 1000,
            estimated: estimated,
          ));
        }

        // C. After prayer.
        final afterItems = playlist(cfg.afterPlaylistId);
        if (input.autoAudioEnabled && cfg.afterEnabled && afterItems.isNotEmpty) {
          final start = t.add(Duration(minutes: cfg.afterDelayMinutes));
          var maxMs = cfg.afterMaxMinutes * 60000;
          if (nextTime != null) {
            // Stop at least one minute before the next prayer's events.
            final room = nextTime.difference(start).inMilliseconds - 60000;
            if (room < maxMs) maxMs = room;
          }
          if (maxMs > 0 && !inSleep(start)) {
            add(ScheduledEvent(
              id: '${day.date}_${p.name}_after',
              triggerAt: start,
              kind: ScheduledKind.after,
              prayer: p,
              title: txt('afterTitle', p),
              body: afterItems.map((e) => e.title).join(' · '),
              items: afterItems,
              volume: cfg.afterVolume,
              maxDurationMs: maxMs,
              repeat: cfg.afterRepeat,
              notify: false,
              estimated: estimated,
            ));
          }
        }
      }
    }
    final list = out.values.toList()..sort((a, b) => a.triggerAt.compareTo(b.triggerAt));
    return list;
  }

  /// Start of the next prayer's scheduled content after prayer [p] on day
  /// [di]: its time minus its before-recitation lead time (if enabled).
  DateTime? _nextBoundary(List<PrayerDay> days, int di, Prayer p, PlannerInput input) {
    final idx = Prayer.obligatory.indexOf(p);
    final Prayer nextP;
    final DateTime nextT;
    if (idx < Prayer.obligatory.length - 1) {
      nextP = Prayer.obligatory[idx + 1];
      nextT = days[di].timeOf(nextP);
    } else if (di + 1 < days.length) {
      nextP = Prayer.subuh;
      nextT = days[di + 1].subuh;
    } else {
      return null;
    }
    final cfg = input.configs[nextP];
    if (cfg != null && cfg.beforeEnabled) {
      return nextT.subtract(Duration(minutes: cfg.beforeMinutes));
    }
    return nextT;
  }
}
