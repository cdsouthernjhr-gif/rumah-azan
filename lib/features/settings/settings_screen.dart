import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants/app_constants.dart';
import '../../core/l10n/l10n.dart';
import '../../core/services/app_controller.dart';
import '../../core/utilities/myt_time.dart';
import '../../data/models/app_settings.dart';
import '../../data/providers/providers.dart';
import '../../data/static/jakim_zones.dart';
import '../../shared/widgets/common.dart';
import '../audio_player/audio_library_screen.dart';
import '../audio_scheduler/scheduler_settings_screen.dart';
import '../diagnostics/diagnostics_screen.dart';
import '../location/zone_picker_screen.dart';
import '../smart_display/display_mode_screen.dart';
import '../wallpaper/wallpaper_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    final n = ref.read(settingsProvider.notifier);
    final ctl = ref.read(appControllerProvider);
    final zone = zoneByCode(s.zoneCode);

    Future<void> resync(Map<String, Object?> patch) async {
      await n.update(patch);
      await ctl.resyncSchedule();
    }

    Future<void> pickTime(String key, String current) async {
      final m = Myt.parseHm(current) ?? 0;
      final t = await showTimePicker(
        context: context,
        initialTime: TimeOfDay(hour: m ~/ 60, minute: m % 60),
        builder: (c, child) => MediaQuery(data: MediaQuery.of(c).copyWith(alwaysUse24HourFormat: true), child: child!),
      );
      if (t != null) await resync({key: Myt.formatHm(t.hour * 60 + t.minute)});
    }

    Widget minutesTile(String title, String key, int value, List<int> options) => ListTile(
          title: Text(title),
          trailing: DropdownButton<int>(
            value: options.contains(value) ? value : options.first,
            items: [
              for (final o in options)
                DropdownMenuItem(value: o, child: Text(o == 0 ? context.tr('off') : context.tr('n_min', {'n': o}))),
            ],
            onChanged: (v) => n.update({key: v}),
          ),
        );

    return PlainScaffold(
      title: context.tr('settings'),
      body: ListView(children: [
        // LOCATION
        SectionHeader(context.tr('location')),
        ListTile(
          leading: const Icon(Icons.place_outlined),
          title: Text(zone == null ? context.tr('choose_zone') : '${zone.code} · ${zone.state}'),
          subtitle: Text(zone?.areas ?? ''),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => push(context, const ZonePickerScreen()),
        ),

        // PRAYER
        SectionHeader(context.tr('prayer')),
        ListTile(
          title: Text(context.tr('data_source')),
          subtitle: Text(context.tr(s.prayerProvider == 'mirror' ? 'provider_mirror_desc' : 'provider_jakim_desc')),
          trailing: DropdownButton<String>(
            value: s.prayerProvider,
            items: [
              DropdownMenuItem(value: 'jakim', child: Text(context.tr('source_jakim'))),
              DropdownMenuItem(value: 'mirror', child: Text(context.tr('source_mirror'))),
            ],
            onChanged: (v) async {
              await n.update({'prayerProvider': v});
              ctl.refreshPrayerData(force: true);
            },
          ),
        ),
        ListTile(
          leading: const Icon(Icons.refresh),
          title: Text(context.tr('refresh_now')),
          subtitle: Text('${context.tr('last_sync')}: ${s.lastSyncAt == null ? '-' : '${Myt.dateKey(s.lastSyncAt!)} ${Myt.hhmm(s.lastSyncAt!)}'}'),
          onTap: () async {
            await ctl.refreshPrayerData(force: true);
            final st = ref.read(syncStatusProvider);
            if (context.mounted) {
              showSnack(context, st.lastOk == true ? context.tr('sync_ok') : '${context.tr('sync_failed')}: ${st.lastError ?? ''}');
            }
          },
        ),
        SwitchListTile(
          title: Text(context.tr('allow_estimate_display')),
          subtitle: Text(context.tr('allow_estimate_display_sub')),
          value: s.allowEstimateDisplay,
          onChanged: (v) async {
            await n.update({'allowEstimateDisplay': v});
            ref.invalidate(dayWindowProvider);
          },
        ),
        SwitchListTile(
          title: Text(context.tr('allow_estimate_alarms')),
          subtitle: Text(context.tr('allow_estimate_alarms_sub')),
          value: s.allowEstimateForAlarms,
          onChanged: (v) => resync({'allowEstimateForAlarms': v}),
        ),
        SwitchListTile(
          title: Text(context.tr('show_imsak')),
          value: s.showImsak,
          onChanged: (v) => n.update({'showImsak': v}),
        ),

        // AUDIO
        SectionHeader(context.tr('audio')),
        ListTile(
          leading: const Icon(Icons.alarm),
          title: Text(context.tr('audio_schedule')),
          subtitle: Text(context.tr('audio_schedule_sub')),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => push(context, const SchedulerSettingsScreen()),
        ),
        ListTile(
          leading: const Icon(Icons.library_music_outlined),
          title: Text(context.tr('audio_library')),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => push(context, const AudioLibraryScreen()),
        ),
        SwitchListTile(
          title: Text(context.tr('respect_silent')),
          subtitle: Text(context.tr('respect_silent_sub')),
          value: s.respectSilentMode,
          onChanged: (v) => resync({'respectSilentMode': v}),
        ),

        // EXTRA NOTIFICATIONS
        SectionHeader(context.tr('extra_notifications')),
        SwitchListTile(
          title: Text(context.tr('zikir_morning_reminder')),
          subtitle: Text(s.zikrMorningTime),
          value: s.zikrMorningReminder,
          onChanged: (v) => resync({'zikrMorningReminder': v}),
          secondary: IconButton(
            tooltip: context.tr('change_time'),
            icon: const Icon(Icons.schedule),
            onPressed: () => pickTime('zikrMorningTime', s.zikrMorningTime),
          ),
        ),
        SwitchListTile(
          title: Text(context.tr('zikir_evening_reminder')),
          subtitle: Text(s.zikrEveningTime),
          value: s.zikrEveningReminder,
          onChanged: (v) => resync({'zikrEveningReminder': v}),
          secondary: IconButton(
            tooltip: context.tr('change_time'),
            icon: const Icon(Icons.schedule),
            onPressed: () => pickTime('zikrEveningTime', s.zikrEveningTime),
          ),
        ),
        SwitchListTile(
          title: Text(context.tr('event_reminder')),
          subtitle: Text('${context.tr('event_reminder_sub')} · ${s.eventReminderTime}'),
          value: s.eventReminder,
          onChanged: (v) => resync({'eventReminder': v}),
          secondary: IconButton(
            tooltip: context.tr('change_time'),
            icon: const Icon(Icons.schedule),
            onPressed: () => pickTime('eventReminderTime', s.eventReminderTime),
          ),
        ),
        SwitchListTile(
          title: Text(context.tr('notify_before_recitation')),
          subtitle: Text(context.tr('notify_before_recitation_sub')),
          value: s.notifyBeforeRecitation,
          onChanged: (v) => resync({'notifyBeforeRecitation': v}),
        ),

        // APPEARANCE
        SectionHeader(context.tr('appearance')),
        ListTile(
          leading: const Icon(Icons.palette_outlined),
          title: Text(context.tr('theme_wallpaper_font')),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => push(context, const WallpaperScreen()),
        ),

        // DISPLAY
        SectionHeader(context.tr('display')),
        ListTile(
          leading: const Icon(Icons.tv),
          title: Text(context.tr('open_display_mode')),
          subtitle: Text(context.tr('display_mode_sub')),
          onTap: () => push(context, const DisplayModeScreen()),
        ),
        SwitchListTile(
          title: Text(context.tr('start_in_display')),
          subtitle: Text(context.tr('start_in_display_sub')),
          value: s.startInDisplayMode,
          onChanged: (v) => n.update({'startInDisplayMode': v}),
        ),
        ListTile(
          title: Text(context.tr('orientation')),
          trailing: DropdownButton<String>(
            value: s.orientation,
            items: [
              for (final o in const ['auto', 'portrait', 'landscape'])
                DropdownMenuItem(value: o, child: Text(context.tr('orientation_$o'))),
            ],
            onChanged: (v) => n.update({'orientation': v}),
          ),
        ),
        SwitchListTile(
          title: Text(context.tr('keep_screen_on')),
          subtitle: Text(context.tr('keep_screen_on_sub')),
          value: s.keepScreenOn,
          onChanged: (v) => n.update({'keepScreenOn': v}),
        ),
        minutesTile(context.tr('auto_return_display'), 'displayAutoReturnMin', s.displayAutoReturnMin, const [0, 2, 5, 10, 30]),
        minutesTile(context.tr('screensaver_after'), 'screensaverMin', s.screensaverMin, const [0, 5, 10, 30, 60]),
        SwitchListTile(
          title: Text(context.tr('slideshow')),
          value: s.slideshow,
          onChanged: (v) => n.update({'slideshow': v}),
        ),
        if (s.slideshow)
          ListTile(
            title: Text(context.tr('slideshow_interval')),
            trailing: DropdownButton<int>(
              value: const [30, 60, 300, 900].contains(s.slideshowSec) ? s.slideshowSec : 60,
              items: [for (final o in const [30, 60, 300, 900]) DropdownMenuItem(value: o, child: Text('${o}s'))],
              onChanged: (v) => n.update({'slideshowSec': v}),
            ),
          ),

        // SLEEP
        SectionHeader(context.tr('sleep_mode')),
        SwitchListTile(
          title: Text(context.tr('sleep_scheduled')),
          subtitle: Text('${s.sleepStart} – ${s.sleepEnd}'),
          value: s.sleepScheduled,
          onChanged: (v) => resync({'sleepScheduled': v}),
        ),
        ListTile(
          title: Text(context.tr('start_time')),
          trailing: Text(s.sleepStart),
          onTap: () => pickTime('sleepStart', s.sleepStart),
        ),
        ListTile(
          title: Text(context.tr('end_time')),
          trailing: Text(s.sleepEnd),
          onTap: () => pickTime('sleepEnd', s.sleepEnd),
        ),
        ListTile(
          title: Text(context.tr('sleep_dim')),
          subtitle: CommitSlider(value: s.sleepDim, max: 0.9, divisions: 9, onCommit: (v) => n.update({'sleepDim': v})),
        ),
        SwitchListTile(
          title: Text(context.tr('sleep_mute')),
          subtitle: Text(context.tr('sleep_mute_sub')),
          value: s.sleepMuteNonEssential,
          onChanged: (v) => resync({'sleepMuteNonEssential': v}),
        ),

        // LANGUAGE
        SectionHeader(context.tr('language')),
        RadioGroup<String>(
          groupValue: s.language,
          onChanged: (v) async {
            await n.update({'language': v});
            await ctl.resyncSchedule(); // notification texts are localised
          },
          child: const Column(children: [
            RadioListTile(value: 'ms', title: Text('Bahasa Melayu')),
            RadioListTile(value: 'en', title: Text('English')),
          ]),
        ),

        // GENERAL
        SectionHeader(context.tr('general')),
        ListTile(
          leading: const Icon(Icons.backup_outlined),
          title: Text(context.tr('backup')),
          subtitle: Text(context.tr('backup_sub')),
          onTap: () => _backup(context, ref),
        ),
        ListTile(
          leading: const Icon(Icons.restore_page_outlined),
          title: Text(context.tr('restore')),
          onTap: () => _restore(context, ref),
        ),
        ListTile(
          leading: const Icon(Icons.cleaning_services_outlined),
          title: Text(context.tr('clear_prayer_cache')),
          subtitle: Text(context.tr('clear_prayer_cache_sub')),
          onTap: () async {
            if (!await confirmDialog(context, context.tr('clear_prayer_cache'), context.tr('clear_prayer_cache_q'))) return;
            await ref.read(prayerRepoProvider).clearCache();
            ref.read(dataVersionProvider.notifier).bump();
            await ctl.refreshPrayerData(force: true);
          },
        ),
        ListTile(
          leading: const Icon(Icons.monitor_heart_outlined),
          title: Text(context.tr('diagnostics')),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => push(context, const DiagnosticsScreen()),
        ),
        ListTile(
          leading: const Icon(Icons.privacy_tip_outlined),
          title: Text(context.tr('privacy')),
          subtitle: Text(context.tr('privacy_body')),
        ),
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: Text(context.tr('app_version')),
          subtitle: Text('${AppConstants.appName} ${AppConstants.appVersion} (${AppConstants.packageId})'),
        ),
        const SizedBox(height: 32),
      ]),
    );
  }

  Future<void> _backup(BuildContext context, WidgetRef ref) async {
    try {
      final json = await ref.read(backupRepoProvider).exportJson();
      final dir = await getApplicationDocumentsDirectory();
      final file = File(p.join(dir.path, 'rumah_azan_backup_${Myt.todayKey()}.json'));
      await file.writeAsString(json);
      await SharePlus.instance.share(ShareParams(files: [XFile(file.path, mimeType: 'application/json')], subject: 'Rumah Azan backup'));
    } catch (e) {
      if (context.mounted) showSnack(context, '${context.tr('backup_failed')}: $e');
    }
  }

  Future<void> _restore(BuildContext context, WidgetRef ref) async {
    final f = await FilePicker.pickFile(type: FileType.custom, allowedExtensions: const ['json']);
    if (f == null || !context.mounted) return;
    if (!await confirmDialog(context, context.tr('restore'), context.tr('restore_q'))) return;
    try {
      final raw = utf8.decode(await f.readAsBytes());
      await ref.read(backupRepoProvider).importJson(raw);
      final restored = await ref.read(settingsRepoProvider).load();
      await ref.read(settingsProvider.notifier).replace(AppSettings({...restored.raw}));
      ref.invalidate(audioConfigsProvider);
      ref.read(dataVersionProvider.notifier).bump();
      await ref.read(appControllerProvider).resyncSchedule();
      if (context.mounted) showSnack(context, context.tr('restore_ok'));
    } catch (e) {
      if (context.mounted) showSnack(context, '${context.tr('restore_failed')}: $e');
    }
  }
}
