import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/l10n/l10n.dart';
import '../../core/services/app_controller.dart';
import '../../core/utilities/test_tone.dart';
import '../../data/providers/providers.dart';
import '../../shared/widgets/common.dart';

/// Kept alive for the dashboard banner; invalidated when the app resumes.
final phoneSoundProvider = FutureProvider<Map<String, Object?>>(
  (ref) => ref.read(nativeBridgeProvider).soundStatus(),
);

/// Sound status of the phone as seen by the native layer (empty without it).
final soundStatusProvider = FutureProvider.autoDispose<Map<String, Object?>>(
  (ref) => ref.read(nativeBridgeProvider).soundStatus(),
);

/// One problem that can make Rumah Azan silent, with how to fix it.
class SoundIssue {
  const SoundIssue(this.key, {this.blocking = true, this.args = const {}});
  final String key; // l10n key suffix: snd_<key>
  final bool blocking; // true = no sound at all for that path
  final Map<String, Object?> args;
}

int _cur(Object? v) => v is Map ? ((v['cur'] as num?)?.toInt() ?? 0) : 0;

/// Pure analysis of [soundStatus] (unit-testable).
List<SoundIssue> analyseSound(Map<String, Object?> s) {
  if (s.isEmpty) return const [];
  final out = <SoundIssue>[];
  if (s['notificationsEnabled'] == false) out.add(const SoundIssue('notif_off'));
  final channels = s['channels'];
  if (channels is Map) {
    final alert = channels['prayer_alert'];
    if (alert is Map && ((alert['importance'] as num?) ?? 3) == 0) {
      out.add(const SoundIssue('channel_blocked'));
    } else if (alert is Map && alert['hasSound'] == false) {
      out.add(const SoundIssue('channel_silent'));
    }
  }
  if (s['exactAlarmAllowed'] == false) out.add(const SoundIssue('exact_off'));
  final ringer = s['ringerMode'];
  if (ringer != 'normal') {
    out.add(SoundIssue(s['respectSilent'] == false ? 'ringer_ignored' : 'ringer_silent',
        blocking: s['respectSilent'] != false, args: {'mode': ringer}));
  }
  if (s['dnd'] == true) out.add(SoundIssue('dnd', blocking: s['respectSilent'] != false));
  if (_cur(s['alarm']) == 0) out.add(const SoundIssue('alarm_vol0'));
  if (_cur(s['music']) == 0) out.add(const SoundIssue('music_vol0'));
  if (_cur(s['notification']) == 0) out.add(const SoundIssue('notif_vol0'));
  return out;
}

class SoundTestScreen extends ConsumerStatefulWidget {
  const SoundTestScreen({super.key});
  @override
  ConsumerState<SoundTestScreen> createState() => _SoundTestScreenState();
}

class _SoundTestScreenState extends ConsumerState<SoundTestScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Back from system settings → re-check.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) ref.invalidate(soundStatusProvider);
  }

  Future<String> _tone() async => ensureTestToneFile(await ref.read(appDirResolverProvider)('test'));

  Widget _fixButton(BuildContext context, SoundIssue i) {
    final b = ref.read(nativeBridgeProvider);
    VoidCallback? action;
    switch (i.key) {
      case 'notif_off':
        action = () async {
          final ok = await b.requestNotificationPermission();
          if (!ok) await b.openNotificationSettings();
          ref.invalidate(soundStatusProvider);
        };
      case 'channel_blocked' || 'channel_silent':
        action = b.openNotificationSettings;
      case 'exact_off':
        action = b.openExactAlarmSettings;
      case 'ringer_silent' || 'dnd':
        action = () async {
          await ref.read(settingsProvider.notifier).update({'respectSilent': false});
          await ref.read(appControllerProvider).resyncSchedule();
          ref.invalidate(soundStatusProvider);
        };
      default:
        action = null; // volume: user uses the phone's volume keys/panel
    }
    if (action == null) return const SizedBox.shrink();
    return TextButton(onPressed: action, child: Text(context.tr('snd_fix_${i.key}')));
  }

  @override
  Widget build(BuildContext context) {
    final status = ref.watch(soundStatusProvider);
    final b = ref.read(nativeBridgeProvider);
    final tt = Theme.of(context).textTheme;
    return PlainScaffold(
      title: context.tr('sound_test'),
      actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: () => ref.invalidate(soundStatusProvider))],
      body: ListView(padding: const EdgeInsets.all(12), children: [
        SectionHeader(context.tr('sound_checks')),
        ...status.when(
          loading: () => [const LinearProgressIndicator()],
          error: (e, _) => [Text('$e')],
          data: (s) {
            if (s.isEmpty) return [Text(context.tr('native_missing'))];
            final issues = analyseSound(s);
            final vol = [
              for (final k in ['alarm', 'music', 'notification'])
                '${context.tr('snd_stream_$k')} ${_cur(s[k])}/${(s[k] as Map?)?['max'] ?? '-'}',
            ].join(' · ');
            return [
              if (issues.isEmpty)
                ListTile(
                  leading: const Icon(Icons.check_circle, color: Colors.green),
                  title: Text(context.tr('snd_all_ok')),
                ),
              for (final i in issues)
                Card(
                  child: ListTile(
                    leading: Icon(
                      i.blocking ? Icons.volume_off : Icons.info_outline,
                      color: i.blocking ? Colors.redAccent : Colors.orange,
                    ),
                    title: Text(context.tr('snd_${i.key}', i.args)),
                    subtitle: Text(context.tr('snd_${i.key}_why')),
                    isThreeLine: true,
                    trailing: _fixButton(context, i),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Text('${context.tr('snd_volumes')}: $vol', style: tt.bodySmall),
              ),
            ];
          },
        ),
        SectionHeader(context.tr('sound_tests')),
        _TestTile(
          icon: Icons.play_circle_outline,
          title: context.tr('snd_test_player'),
          subtitle: context.tr('snd_test_player_sub'),
          onTap: () async {
            final title = context.tr('snd_test_player');
            await b.play(items: [{'path': await _tone(), 'title': title}]);
          },
        ),
        _TestTile(
          icon: Icons.notifications_active_outlined,
          title: context.tr('snd_test_notif'),
          subtitle: context.tr('snd_test_notif_sub'),
          onTap: () async {
            final ok = await b.testNotification(context.tr('snd_test_notif'), context.tr('test_alarm_body'));
            if (!ok && context.mounted) showSnack(context, context.tr('snd_notif_off'));
          },
        ),
        _TestTile(
          icon: Icons.alarm,
          title: context.tr('snd_test_azan'),
          subtitle: context.tr('snd_test_azan_sub'),
          onTap: () async {
            final path = await _tone();
            if (!context.mounted) return;
            final ok = await b.scheduleTestEvent(15, context.tr('snd_test_azan'), context.tr('test_alarm_body'), audioPath: path);
            if (context.mounted) showSnack(context, ok ? context.tr('test_alarm_set') : context.tr('native_missing'));
          },
        ),
        _TestTile(
          icon: Icons.touch_app_outlined,
          title: context.tr('snd_test_click'),
          subtitle: context.tr('snd_test_click_sub'),
          onTap: () => b.playClick(),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(context.tr('snd_footer'), style: tt.bodySmall),
        ),
      ]),
    );
  }
}

class _TestTile extends StatelessWidget {
  const _TestTile({required this.icon, required this.title, required this.subtitle, required this.onTap});
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(
          leading: Icon(icon, color: Theme.of(context).colorScheme.secondary),
          title: Text(title),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.play_arrow),
          onTap: onTap,
        ),
      );
}
