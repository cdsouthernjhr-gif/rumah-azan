import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/constants/app_constants.dart';
import '../../core/l10n/l10n.dart';
import '../../core/services/app_controller.dart';
import '../../core/utilities/myt_time.dart';
import '../../data/local/database.dart';
import '../../data/providers/providers.dart';
import '../../shared/widgets/common.dart';

/// Flutter injects these at build time (flutter build/run).
const _flutterVersion = String.fromEnvironment('FLUTTER_VERSION', defaultValue: '-');

class _CheckResult {
  const _CheckResult(this.label, this.ok, this.detail);
  final String label;
  final bool? ok; // null = warning / not applicable
  final String detail;
}

final _nativeDiagProvider = FutureProvider.autoDispose((ref) async {
  final b = ref.read(nativeBridgeProvider);
  final available = await b.ping();
  return (available, await b.diagnostics(), await b.schedulerStatus());
});

final _diagLogProvider = FutureProvider.autoDispose<List<DiagnosticRow>>((ref) => ref.read(diagnosticsRepoProvider).recent(60));

class DiagnosticsScreen extends ConsumerStatefulWidget {
  const DiagnosticsScreen({super.key});
  @override
  ConsumerState<DiagnosticsScreen> createState() => _DiagnosticsScreenState();
}

class _DiagnosticsScreenState extends ConsumerState<DiagnosticsScreen> {
  List<_CheckResult>? _results;
  bool _running = false;

  String _time(Object? ms) {
    if (ms is! num || ms <= 0) return '-';
    final t = DateTime.fromMillisecondsSinceEpoch(ms.toInt(), isUtc: true);
    return '${Myt.dateKey(t)} ${Myt.hhmmss(t)}';
  }

  Future<void> _selfTest() async {
    setState(() => _running = true);
    final l = L10nScope.of(context); // captured before async gaps
    final r = <_CheckResult>[];
    final ctl = ref.read(appControllerProvider);
    final bridge = ref.read(nativeBridgeProvider);
    // 1. Database
    try {
      await ref.read(databaseProvider).customSelect('SELECT 1').get();
      r.add(_CheckResult(l.t('chk_database'), true, 'OK'));
    } catch (e) {
      r.add(_CheckResult(l.t('chk_database'), false, '$e'));
    }
    // 2. Native layer
    final native = await bridge.ping();
    r.add(_CheckResult(l.t('chk_native'), native, native ? 'OK' : l.t('native_missing')));
    final d = await bridge.diagnostics();
    if (native) {
      r.add(_CheckResult(l.t('notification_permission'), d['notificationsEnabled'] == true, '${d['notificationsEnabled']}'));
      r.add(_CheckResult(l.t('exact_alarm_permission'), d['exactAlarmAllowed'] == true, '${d['exactAlarmAllowed']}'));
      r.add(_CheckResult(l.t('battery_optimisation'), d['batteryOptimizationIgnored'] == true ? true : null,
          d['batteryOptimizationIgnored'] == true ? l.t('exempt') : l.t('battery_restricted_hint')));
    }
    // 3. Prayer API connectivity
    await ctl.refreshPrayerData(force: true);
    final sync = ref.read(syncStatusProvider);
    r.add(_CheckResult(l.t('chk_prayer_api'), sync.lastOk, sync.lastOk == true ? (sync.provider ?? 'OK') : (sync.lastError ?? '-')));
    // 4. Verified data for today
    final zone = ref.read(settingsProvider).zoneCode;
    final today = zone == null ? null : await ref.read(prayerRepoProvider).cachedDay(zone, Myt.todayKey());
    r.add(_CheckResult(l.t('chk_verified_today'), today != null, today == null ? l.t('warn_no_verified') : today.source.name));
    // 5. Scheduler
    final n = await ctl.resyncSchedule();
    r.add(_CheckResult(l.t('chk_scheduler'), n > 0 ? true : null, l.t('n_events', {'n': n})));
    if (mounted) {
      setState(() {
        _results = r;
        _running = false;
      });
    }
    ref.invalidate(_nativeDiagProvider);
    ref.invalidate(_diagLogProvider);
  }

  @override
  Widget build(BuildContext context) {
    final native = ref.watch(_nativeDiagProvider);
    final snap = ref.watch(schedulerSnapshotProvider);
    final log = ref.watch(_diagLogProvider).value ?? const [];
    final bridge = ref.read(nativeBridgeProvider);
    final tt = Theme.of(context).textTheme;

    Widget kv(String k, String v, {bool? ok}) => ListTile(
          dense: true,
          leading: ok == null
              ? const Icon(Icons.info_outline, size: 20)
              : Icon(ok ? Icons.check_circle : Icons.error, color: ok ? Colors.green : Colors.redAccent, size: 20),
          title: Text(k),
          trailing: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 220),
            child: Text(v, textAlign: TextAlign.right, style: tt.bodySmall),
          ),
        );

    return PlainScaffold(
      title: context.tr('diagnostics'),
      actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: () => ref.invalidate(_nativeDiagProvider))],
      body: ListView(children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            icon: _running
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.play_circle_outline),
            label: Text(context.tr('run_self_test')),
            onPressed: _running ? null : _selfTest,
          ),
        ),
        if (_results != null) ...[
          SectionHeader(context.tr('self_test_results')),
          for (final c in _results!) kv(c.label, c.detail, ok: c.ok),
        ],
        SectionHeader(context.tr('system')),
        kv('Rumah Azan', '${AppConstants.appVersion} · ${AppConstants.packageId}'),
        kv('Flutter', _flutterVersion),
        kv('Dart', Platform.version.split(' ').first),
        ...native.when(
          loading: () => [const LinearProgressIndicator()],
          error: (e, _) => [kv('Native', '$e', ok: false)],
          data: (v) {
            final (available, d, sch) = v;
            if (!available) return [kv(context.tr('chk_native'), context.tr('native_missing'), ok: false)];
            return [
              kv(context.tr('android_version'), '${d['androidVersion']} (API ${d['sdkInt']})'),
              kv(context.tr('device_model'), '${d['manufacturer']} ${d['model']}${d['isTv'] == true ? ' · TV' : ''}'),
              kv(context.tr('memory'), '${d['availMemMb']} / ${d['totalMemMb']} MB${d['lowMemory'] == true ? ' (low)' : ''}'),
              kv(context.tr('notification_permission'), '${d['notificationsEnabled']}', ok: d['notificationsEnabled'] == true),
              kv(context.tr('exact_alarm_permission'), '${d['exactAlarmAllowed']}', ok: d['exactAlarmAllowed'] == true),
              kv(context.tr('battery_optimisation'),
                  d['batteryOptimizationIgnored'] == true ? context.tr('exempt') : context.tr('restricted'),
                  ok: d['batteryOptimizationIgnored'] == true ? true : null),
              kv(context.tr('dnd_status'), '${d['interruptionFilter']}'),
              SectionHeader(context.tr('scheduler_status')),
              kv(context.tr('scheduled_events'), '${sch['count'] ?? 0}', ok: (sch['count'] as num? ?? 0) > 0 ? true : null),
              kv(context.tr('next_scheduled'), '${sch['nextTitle'] ?? '-'}\n${_time(sch['nextAtMs'])}'),
              kv(context.tr('alarm_mode'), '${sch['alarmMode'] ?? '-'}'),
              kv(context.tr('background_service'), d['playbackActive'] == true ? context.tr('running') : context.tr('idle')),
              kv(context.tr('last_alarm_fired'), _time(sch['lastFiredAtMs'])),
              kv(context.tr('last_playback'), '${sch['lastPlaybackTitle'] ?? '-'}\n${_time(sch['lastPlaybackAtMs'])}'),
              kv(context.tr('last_playback_error'), '${sch['lastError'] ?? '-'}\n${_time(sch['lastErrorAtMs'])}',
                  ok: sch['lastError'] == null ? true : false),
            ];
          },
        ),
        kv(context.tr('last_plan'), snap.at == null ? '-' : '${snap.planned} @ ${snap.at!.toLocal().toString().substring(0, 19)}',
            ok: snap.error == null ? null : false),
        kv(context.tr('last_sync'), ref.watch(settingsProvider).lastSyncAt?.toLocal().toString().substring(0, 19) ?? '-'),
        SectionHeader(context.tr('actions')),
        Wrap(spacing: 8, runSpacing: 8, children: [
          OutlinedButton(onPressed: bridge.requestNotificationPermission, child: Text(context.tr('allow_notifications'))),
          OutlinedButton(onPressed: bridge.openExactAlarmSettings, child: Text(context.tr('open_exact_alarm'))),
          OutlinedButton(onPressed: bridge.openBatteryOptimizationSettings, child: Text(context.tr('open_battery'))),
          OutlinedButton(onPressed: bridge.openNotificationSettings, child: Text(context.tr('open_notification_settings'))),
          OutlinedButton(
            onPressed: () async {
              final ok = await bridge.scheduleTestEvent(15, context.tr('test_alarm_title'), context.tr('test_alarm_body'));
              if (context.mounted) showSnack(context, ok ? context.tr('test_alarm_set') : context.tr('native_missing'));
            },
            child: Text(context.tr('test_alarm')),
          ),
        ].map((w) => Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: w)).toList()),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(context.tr('oem_note'), style: tt.bodySmall),
        ),
        SectionHeader(context.tr('log')),
        for (final e in log)
          ListTile(
            dense: true,
            leading: Icon(
              e.level == 'error' ? Icons.error_outline : (e.level == 'warn' ? Icons.warning_amber : Icons.info_outline),
              size: 18,
            ),
            title: Text('[${e.tag}] ${e.message}', style: tt.bodySmall),
            subtitle: Text(e.createdAt.toLocal().toString().substring(0, 19), style: tt.labelSmall),
          ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextButton(
            onPressed: () async {
              await ref.read(diagnosticsRepoProvider).clear();
              ref.invalidate(_diagLogProvider);
            },
            child: Text(context.tr('clear_log')),
          ),
        ),
      ]),
    );
  }
}
