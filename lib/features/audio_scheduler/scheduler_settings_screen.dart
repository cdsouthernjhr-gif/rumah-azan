import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/l10n/l10n.dart';
import '../../core/services/app_controller.dart';
import '../../data/local/database.dart';
import '../../data/models/prayer_audio_config.dart';
import '../../data/models/prayer_day.dart';
import '../../data/providers/providers.dart';
import '../../shared/widgets/common.dart';
import '../audio_player/audio_library_screen.dart';
import '../diagnostics/diagnostics_screen.dart';

class SchedulerSettingsScreen extends ConsumerWidget {
  const SchedulerSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configs = ref.watch(audioConfigsProvider);
    final s = ref.watch(settingsProvider);
    return DefaultTabController(
      length: Prayer.obligatory.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.tr('audio_schedule')),
          actions: [
            IconButton(
              tooltip: context.tr('diagnostics'),
              icon: const Icon(Icons.monitor_heart_outlined),
              onPressed: () => push(context, const DiagnosticsScreen()),
            ),
          ],
          bottom: TabBar(
            isScrollable: true,
            tabs: [for (final p in Prayer.obligatory) Tab(text: prayerName(context, p))],
          ),
        ),
        body: Column(children: [
          SwitchListTile(
            title: Text(context.tr('auto_audio')),
            subtitle: Text(context.tr('auto_audio_sub')),
            value: s.autoAudioEnabled,
            onChanged: (v) async {
              await ref.read(settingsProvider.notifier).update({'autoAudioEnabled': v});
              ref.read(appControllerProvider).resyncSchedule();
            },
          ),
          const Divider(height: 1),
          Expanded(
            child: configs.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('$e')),
              data: (map) => TabBarView(children: [
                for (final p in Prayer.obligatory) _PrayerConfigForm(config: map[p] ?? PrayerAudioConfig.defaultFor(p)),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}

class _PrayerConfigForm extends ConsumerWidget {
  const _PrayerConfigForm({required this.config});
  final PrayerAudioConfig config;

  Future<void> _save(WidgetRef ref, Map<String, Object?> patch) async {
    await ref.read(audioConfigsProvider.notifier).save(config.copyWithJson(patch));
    await ref.read(appControllerProvider).resyncSchedule();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = config;
    final audio = ref.watch(audioListProvider).value ?? const <AudioRow>[];
    final lists = ref.watch(playlistListProvider).value ?? const <PlaylistRow>[];
    final azans = audio.where((a) => a.category == 'azan').toList();

    Widget minutes(String label, int value, int min, int max, void Function(int) onChanged) => ListTile(
          title: Text(label),
          subtitle: CommitSlider(
            value: value.clamp(min, max).toDouble(),
            min: min.toDouble(),
            max: max.toDouble(),
            divisions: max - min,
            labelOf: (v) => '${v.round()}',
            onCommit: (v) => onChanged(v.round()),
          ),
          trailing: Text(context.tr('n_min', {'n': value})),
        );

    Widget volume(double value, void Function(double) onChanged) => ListTile(
          leading: const Icon(Icons.volume_up_outlined),
          title: CommitSlider(value: value, onCommit: onChanged, divisions: 10, labelOf: (v) => '${(v * 100).round()}%'),
        );

    Widget playlistPicker(int? selected, void Function(int?) onChanged) => ListTile(
          title: Text(context.tr('playlist')),
          trailing: DropdownButton<int?>(
            value: lists.any((l) => l.id == selected) ? selected : null,
            hint: Text(context.tr('none')),
            items: [
              DropdownMenuItem(value: null, child: Text(context.tr('none'))),
              for (final l in lists) DropdownMenuItem(value: l.id, child: Text(l.name)),
            ],
            onChanged: onChanged,
          ),
        );

    Widget azanPicker(String label, int? selected, void Function(int?) onChanged) => ListTile(
          title: Text(label),
          trailing: DropdownButton<int?>(
            value: azans.any((a) => a.id == selected) ? selected : null,
            hint: Text(context.tr('none')),
            items: [
              DropdownMenuItem(value: null, child: Text(context.tr('none'))),
              for (final a in azans) DropdownMenuItem(value: a.id, child: Text(a.title, overflow: TextOverflow.ellipsis)),
            ],
            onChanged: onChanged,
          ),
        );

    final needsAzanFile = (c.atMode == AtPrayerMode.fullAzan && c.fullAzanAudioId == null) ||
        (c.atMode == AtPrayerMode.shortAzan && c.shortAzanAudioId == null && c.fullAzanAudioId == null);

    return ListView(padding: const EdgeInsets.only(bottom: 32), children: [
      // A. Before prayer
      SectionHeader(context.tr('before_prayer')),
      SwitchListTile(
        title: Text(context.tr('before_enable')),
        value: c.beforeEnabled,
        onChanged: (v) => _save(ref, {'beforeEnabled': v}),
      ),
      if (c.beforeEnabled) ...[
        minutes(context.tr('minutes_before'), c.beforeMinutes, 1, 60, (v) => _save(ref, {'beforeMinutes': v})),
        playlistPicker(c.beforePlaylistId, (v) => _save(ref, {'beforePlaylistId': v})),
        volume(c.beforeVolume, (v) => _save(ref, {'beforeVolume': v})),
        if (c.beforePlaylistId == null)
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: WarningBanner(text: context.tr('need_playlist'))),
      ],

      // B. At prayer time
      SectionHeader(context.tr('at_prayer')),
      RadioGroup<AtPrayerMode>(
        groupValue: c.atMode,
        onChanged: (v) => v == null ? null : _save(ref, {'atMode': v.name}),
        child: Column(children: [
          for (final m in AtPrayerMode.values)
            RadioListTile<AtPrayerMode>(value: m, title: Text(context.tr('at_${m.name}'))),
        ]),
      ),
      if (c.atMode == AtPrayerMode.fullAzan || c.atMode == AtPrayerMode.shortAzan) ...[
        azanPicker(context.tr('full_azan_audio'), c.fullAzanAudioId, (v) => _save(ref, {'fullAzanAudioId': v})),
        azanPicker(context.tr('short_azan_audio'), c.shortAzanAudioId, (v) => _save(ref, {'shortAzanAudioId': v})),
        volume(c.atVolume, (v) => _save(ref, {'atVolume': v})),
        if (needsAzanFile)
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: WarningBanner(text: context.tr('need_azan_file'))),
      ],

      // C. After prayer
      SectionHeader(context.tr('after_prayer')),
      SwitchListTile(
        title: Text(context.tr('after_enable')),
        value: c.afterEnabled,
        onChanged: (v) => _save(ref, {'afterEnabled': v}),
      ),
      if (c.afterEnabled) ...[
        minutes(context.tr('start_delay'), c.afterDelayMinutes, 0, 60, (v) => _save(ref, {'afterDelayMinutes': v})),
        minutes(context.tr('max_duration'), c.afterMaxMinutes, 1, 120, (v) => _save(ref, {'afterMaxMinutes': v})),
        ListTile(
          title: Text(context.tr('repeat_count')),
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: c.afterRepeat > 1 ? () => _save(ref, {'afterRepeat': c.afterRepeat - 1}) : null,
            ),
            Text('${c.afterRepeat}×'),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: c.afterRepeat < 10 ? () => _save(ref, {'afterRepeat': c.afterRepeat + 1}) : null,
            ),
          ]),
        ),
        playlistPicker(c.afterPlaylistId, (v) => _save(ref, {'afterPlaylistId': v})),
        volume(c.afterVolume, (v) => _save(ref, {'afterVolume': v})),
        if (c.afterPlaylistId == null)
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: WarningBanner(text: context.tr('need_playlist'))),
      ],

      // Notifications
      SectionHeader(context.tr('notifications')),
      SwitchListTile(
        title: Text(context.tr('notify_at_time')),
        value: c.notifyEnabled,
        onChanged: (v) => _save(ref, {'notifyEnabled': v}),
      ),
      minutes(context.tr('reminder_before'), c.reminderMinutes, 0, 60, (v) => _save(ref, {'reminderMinutes': v})),
      SwitchListTile(
        title: Text(context.tr('vibrate')),
        value: c.vibrate,
        onChanged: (v) => _save(ref, {'vibrate': v}),
      ),
      Padding(
        padding: const EdgeInsets.all(16),
        child: OutlinedButton.icon(
          icon: const Icon(Icons.library_music_outlined),
          label: Text(context.tr('manage_audio')),
          onPressed: () => push(context, const AudioLibraryScreen()),
        ),
      ),
    ]);
  }
}
