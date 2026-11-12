import 'package:flutter_test/flutter_test.dart';
import 'package:rumah_azan/data/models/prayer_audio_config.dart';
import 'package:rumah_azan/data/models/prayer_day.dart';
import 'package:rumah_azan/features/audio_scheduler/domain/schedule_planner.dart';

import '../helpers.dart';

const azanFile = AudioRef(path: '/a/azan.mp3', title: 'Azan');
const quranFile = AudioRef(path: '/a/kahf.mp3', title: 'Bacaan');

PlannerInput input({
  required DateTime now,
  List<PrayerDay>? days,
  Map<Prayer, PrayerAudioConfig>? configs,
  bool auto = true,
  bool allowEstimate = false,
  (int, int)? sleep,
  List<InfoNotice> notices = const [],
  bool notifyBefore = false,
}) =>
    PlannerInput(
      now: now,
      days: days ?? [day('2026-11-12'), day('2026-11-13')],
      configs: configs ??
          {
            for (final p in Prayer.obligatory)
              p: PrayerAudioConfig.defaultFor(p).copyWithJson({
                'beforeEnabled': true,
                'beforePlaylistId': 1,
                'atMode': 'fullAzan',
                'fullAzanAudioId': 10,
                'afterEnabled': true,
                'afterPlaylistId': 1,
                'afterMaxMinutes': 600, // deliberately huge → must be clipped
                'reminderMinutes': 10,
              }),
          },
      audio: const {10: azanFile, 11: quranFile},
      playlists: const {1: [quranFile]},
      prayerNames: {for (final p in Prayer.values) p: p.name},
      texts: const {'azanTitle': 'Azan {prayer}', 'reminderTitle': '{prayer} in {min}'},
      autoAudioEnabled: auto,
      allowEstimate: allowEstimate,
      sleepWindow: sleep,
      notices: notices,
      notifyBeforeRecitation: notifyBefore,
    );

void main() {
  const planner = SchedulePlanner();

  test('plans before/azan/after/reminder with deterministic unique ids', () {
    final events = planner.plan(input(now: myt('2026-11-12', '00:00')));
    final ids = events.map((e) => e.id).toList();
    expect(ids.toSet().length, ids.length, reason: 'no duplicates');
    // 2 days × 5 prayers × 4 kinds
    expect(events.length, 40);
    // Re-planning yields identical ids (idempotent → no duplicate alarms).
    expect(planner.plan(input(now: myt('2026-11-12', '00:00'))).map((e) => e.id).toList(), ids);
    // Sorted by trigger time.
    for (var i = 1; i < events.length; i++) {
      expect(events[i].triggerAt.isBefore(events[i - 1].triggerAt), isFalse);
    }
  });

  test('before-prayer recitation always ends before the azan', () {
    final events = planner.plan(input(now: myt('2026-11-12', '00:00')));
    for (final e in events.where((e) => e.kind == ScheduledKind.before)) {
      final azan = events.firstWhere((a) => a.id == e.id.replaceAll('_before', '_azan'));
      expect(e.triggerAt.add(Duration(milliseconds: e.maxDurationMs)).isBefore(azan.triggerAt), isTrue);
    }
  });

  test('after-prayer playback is clipped before the next prayer content', () {
    final events = planner.plan(input(now: myt('2026-11-12', '00:00')));
    final afterZohor = events.firstWhere((e) => e.id == '2026-11-12_zohor_after');
    final beforeAsar = events.firstWhere((e) => e.id == '2026-11-12_asar_before');
    final end = afterZohor.triggerAt.add(Duration(milliseconds: afterZohor.maxDurationMs));
    expect(end.isAfter(beforeAsar.triggerAt), isFalse);
  });

  test('past events are not scheduled (missed transitions)', () {
    final events = planner.plan(input(now: myt('2026-11-12', '14:00')));
    expect(events.any((e) => e.id.startsWith('2026-11-12_subuh')), isFalse);
    expect(events.any((e) => e.id == '2026-11-12_zohor_azan'), isFalse);
    expect(events.any((e) => e.id == '2026-11-12_asar_azan'), isTrue);
  });

  test('estimated days are skipped unless explicitly allowed', () {
    final days = [day('2026-11-12', source: PrayerSource.estimate)];
    expect(planner.plan(input(now: myt('2026-11-12', '00:00'), days: days)), isEmpty);
    final allowed = planner.plan(input(now: myt('2026-11-12', '00:00'), days: days, allowEstimate: true));
    expect(allowed, isNotEmpty);
    expect(allowed.every((e) => e.estimated), isTrue);
  });

  test('automatic audio off → no recitation, azan becomes notification with sound', () {
    final events = planner.plan(input(now: myt('2026-11-12', '00:00'), auto: false));
    expect(events.where((e) => e.kind == ScheduledKind.before || e.kind == ScheduledKind.after), isEmpty);
    final azan = events.firstWhere((e) => e.kind == ScheduledKind.azan);
    expect(azan.items, isEmpty);
    expect(azan.notifySound, isTrue);
  });

  test('no azan file configured → default notification sound fallback', () {
    final cfg = {
      for (final p in Prayer.obligatory)
        p: PrayerAudioConfig.defaultFor(p).copyWithJson({'atMode': 'fullAzan'}),
    };
    final azan = planner.plan(input(now: myt('2026-11-12', '00:00'), configs: cfg)).firstWhere((e) => e.kind == ScheduledKind.azan);
    expect(azan.items, isEmpty);
    expect(azan.notify, isTrue);
    expect(azan.notifySound, isTrue);
    expect(azan.priority, 3);
  });

  test('silent mode: notification without sound, no audio', () {
    final cfg = {for (final p in Prayer.obligatory) p: PrayerAudioConfig.defaultFor(p).copyWithJson({'atMode': 'silent'})};
    final azan = planner.plan(input(now: myt('2026-11-12', '00:00'), configs: cfg)).firstWhere((e) => e.kind == ScheduledKind.azan);
    expect(azan.notifySound, isFalse);
    expect(azan.vibrate, isFalse);
  });

  test('sleep window suppresses non-essential recitation but not azan', () {
    // 04:00–06:00 covers Subuh before-recitation (05:30) but azan stays.
    final events = planner.plan(input(now: myt('2026-11-12', '00:00'), sleep: (4 * 60, 6 * 60)));
    expect(events.any((e) => e.id == '2026-11-12_subuh_before'), isFalse);
    expect(events.any((e) => e.id == '2026-11-12_subuh_azan'), isTrue);
    expect(events.any((e) => e.id == '2026-11-12_zohor_before'), isTrue);
  });

  test('config JSON round-trip clamps invalid values', () {
    final c = PrayerAudioConfig.fromJson(Prayer.asar, {'beforeMinutes': 999, 'beforeVolume': 5, 'atMode': 'bogus', 'afterRepeat': 0});
    expect(c.beforeMinutes, 60);
    expect(c.beforeVolume, 1.0);
    expect(c.atMode, AtPrayerMode.notificationOnly);
    expect(c.afterRepeat, 1);
    expect(PrayerAudioConfig.defaultFor(Prayer.subuh).beforeMinutes, 15);
    expect(PrayerAudioConfig.defaultFor(Prayer.zohor).beforeMinutes, 10);
  });

  group('info notices (daily zikr, Islamic events)', () {
    const morning = InfoNotice(key: 'zikir_pagi', minuteOfDay: 7 * 60, title: 'Zikir pagi', body: 'b');
    const event = InfoNotice(
        key: 'event_x', minuteOfDay: 8 * 60, title: 'Maulidur Rasul', body: 'b', dateKey: '2026-11-13', nonEssential: false);

    test('daily notice once per day in horizon, dated notice only on its date', () {
      final events = planner.plan(input(now: myt('2026-11-12', '00:00'), notices: const [morning, event]));
      final info = events.where((e) => e.kind == ScheduledKind.info).map((e) => e.id).toList();
      expect(info, ['2026-11-12_info_zikir_pagi', '2026-11-13_info_zikir_pagi', '2026-11-13_info_event_x']);
      final ev = events.firstWhere((e) => e.id == '2026-11-13_info_event_x');
      expect(ev.triggerAt, myt('2026-11-13', '08:00'));
      expect(ev.notifySound, isTrue);
      expect(ev.items, isEmpty);
    });

    test('past notices skipped; sleep window mutes only non-essential ones', () {
      final late = planner.plan(input(now: myt('2026-11-12', '09:00'), notices: const [morning]));
      expect(late.any((e) => e.id == '2026-11-12_info_zikir_pagi'), isFalse);
      final sleeping = planner.plan(input(
        now: myt('2026-11-12', '00:00'),
        notices: const [morning, InfoNotice(key: 'event_y', minuteOfDay: 7 * 60, title: 't', body: 'b', nonEssential: false)],
        sleep: (6 * 60, 8 * 60),
      ));
      expect(sleeping.any((e) => e.id.endsWith('zikir_pagi')), isFalse);
      expect(sleeping.any((e) => e.id.endsWith('event_y')), isTrue);
    });

    test('before-recitation notification is optional', () {
      bool notifies(bool on) => planner
          .plan(input(now: myt('2026-11-12', '00:00'), notifyBefore: on))
          .firstWhere((e) => e.kind == ScheduledKind.before)
          .notify;
      expect(notifies(false), isFalse);
      expect(notifies(true), isTrue);
    });
  });
}
