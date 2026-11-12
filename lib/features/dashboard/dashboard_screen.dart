import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/l10n/l10n.dart';
import '../../core/services/app_controller.dart';
import '../../core/utilities/myt_time.dart';
import '../../data/models/prayer_day.dart';
import '../../data/providers/providers.dart';
import '../../data/static/jakim_zones.dart';
import '../../shared/widgets/common.dart';
import '../audio_player/audio_library_screen.dart';
import '../audio_player/player_bar.dart';
import '../audio_scheduler/scheduler_settings_screen.dart';
import '../islamic_calendar/calendar_screen.dart';
import '../islamic_calendar/domain/calendar_service.dart';
import '../location/zone_picker_screen.dart';
import '../prayer_times/timetable_screen.dart';
import '../qiblah/qiblah_screen.dart';
import '../quran/content_library_screen.dart';
import '../settings/settings_screen.dart';
import '../sleep_mode/sleep_mode_screen.dart';
import '../smart_display/display_mode_screen.dart';
import '../tasbih/tasbih_screen.dart';

String formatGregorian(BuildContext context, String dateKey, {bool withDay = true}) {
  final d = Myt.parseDateKey(dateKey);
  final day = context.tr('day_${d.weekday}');
  final month = context.tr('month_${d.month}');
  return withDay ? '$day, ${d.day} $month ${d.year}' : '${d.day} $month ${d.year}';
}

String hijriSourceLabel(BuildContext context, HijriSource s) => context.tr('hijri_src_${s.name}');

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return WallpaperScaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.read(appControllerProvider).refreshPrayerData(force: true),
          child: LayoutBuilder(builder: (context, c) {
            final wide = c.maxWidth >= 900;
            final left = <Widget>[
              const _Header(),
              const SizedBox(height: 12),
              const _DateCard(),
              const _DataWarnings(),
              const SizedBox(height: 12),
              const NextPrayerCard(),
            ];
            final right = <Widget>[
              const PrayerTimesCard(),
              const SizedBox(height: 12),
              const PlayerBar(),
              const SizedBox(height: 12),
              const _QuickAccess(),
              const SizedBox(height: 12),
              const _UpcomingEvents(),
              const SizedBox(height: 8),
              const _SyncFooter(),
            ];
            if (wide) {
              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(child: Column(children: left)),
                    const SizedBox(width: 20),
                    Expanded(child: Column(children: right)),
                  ]),
                ],
              );
            }
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [...left, const SizedBox(height: 12), ...right],
            );
          }),
        ),
      ),
    );
  }
}

class _Header extends ConsumerWidget {
  const _Header();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final zone = zoneByCode(ref.watch(settingsProvider.select((s) => s.zoneCode)));
    final cs = Theme.of(context).colorScheme;
    return Row(children: [
      Icon(Icons.mosque_rounded, color: cs.secondary, size: 32),
      const SizedBox(width: 8),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Rumah Azan', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
          InkWell(
            onTap: () => push(context, const ZonePickerScreen()),
            child: Row(children: [
              Icon(Icons.place_outlined, size: 16, color: cs.secondary),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  zone == null ? context.tr('choose_zone') : '${zone.code} · ${zone.areas}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ]),
          ),
        ]),
      ),
      IconButton(
        tooltip: context.tr('display_mode'),
        icon: const Icon(Icons.tv_rounded),
        onPressed: () => push(context, const DisplayModeScreen()),
      ),
      IconButton(
        tooltip: context.tr('settings'),
        icon: const Icon(Icons.settings_outlined),
        onPressed: () => push(context, const SettingsScreen()),
      ),
    ]);
  }
}

class _DateCard extends ConsumerWidget {
  const _DateCard();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = ref.watch(todayKeyProvider);
    final cal = ref.watch(calendarServiceProvider).value;
    final lang = ref.watch(settingsProvider.select((s) => s.language));
    final h = cal?.hijriFor(today);
    final events = cal?.eventsOn(today) ?? const [];
    final tt = Theme.of(context).textTheme;
    return GlassCard(
      onTap: () => push(context, const CalendarScreen()),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(formatGregorian(context, today), style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            if (h != null)
              Text('${h.date.format(lang)} · ${hijriSourceLabel(context, h.source)}', style: tt.bodyMedium),
            for (final e in events)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Row(children: [
                  Icon(Icons.star_rounded, size: 18, color: Theme.of(context).colorScheme.secondary),
                  const SizedBox(width: 6),
                  Expanded(child: Text(e.def.name(lang), style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600))),
                ]),
              ),
          ]),
        ),
        const Icon(Icons.calendar_month_outlined),
      ]),
    );
  }
}

class _DataWarnings extends ConsumerWidget {
  const _DataWarnings();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final w = ref.watch(dayWindowProvider);
    final sync = ref.watch(syncStatusProvider);
    final children = <Widget>[];
    w.whenData((win) {
      if (win.today == null) {
        children.add(WarningBanner(
          text: context.tr('warn_no_verified'),
          action: TextButton(
            onPressed: () => ref.read(appControllerProvider).refreshPrayerData(force: true),
            child: Text(context.tr('retry')),
          ),
        ));
      } else if (!win.today!.source.isVerified) {
        children.add(WarningBanner(text: context.tr('warn_estimate')));
      }
    });
    if (sync.lastOk == false && sync.lastError != null) {
      children.add(WarningBanner(icon: Icons.cloud_off_rounded, text: context.tr('warn_sync_failed')));
    }
    if (children.isEmpty) return const SizedBox.shrink();
    return Padding(padding: const EdgeInsets.only(top: 8), child: Column(children: children));
  }
}

class NextPrayerCard extends ConsumerWidget {
  const NextPrayerCard({super.key, this.large = false});
  final bool large;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final st = ref.watch(prayerStatusProvider);
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    if (st == null) {
      return GlassCard(child: Text(context.tr('no_next_prayer'), style: tt.bodyLarge));
    }
    return GlassCard(
      highlight: true,
      onTap: () => push(context, const TimetableScreen()),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(context.tr('next_prayer'), style: tt.labelLarge?.copyWith(color: cs.secondary)),
        const SizedBox(height: 4),
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(prayerName(context, st.next),
                  style: (large ? tt.displaySmall : tt.headlineMedium)?.copyWith(fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(width: 12),
          Text(Myt.hhmm(st.nextTime), style: tt.headlineSmall),
          if (st.nextIsTomorrow) ...[
            const SizedBox(width: 6),
            Text('(${context.tr('tomorrow')})', style: tt.bodySmall),
          ],
        ]),
        const SizedBox(height: 8),
        Text(
          Myt.countdown(st.remaining),
          style: (large ? tt.displayLarge : tt.displaySmall)?.copyWith(
            fontFeatures: const [FontFeature.tabularFigures()],
            fontWeight: FontWeight.w300,
          ),
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(value: st.progress, minHeight: 8, color: cs.secondary),
        ),
        const SizedBox(height: 8),
        if (st.current != null)
          Text(context.tr('current_period', {'p': prayerName(context, st.current!)}), style: tt.bodySmall),
      ]),
    );
  }
}

class PrayerTimesCard extends ConsumerWidget {
  const PrayerTimesCard({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final win = ref.watch(dayWindowProvider).value;
    final st = ref.watch(prayerStatusProvider);
    final showImsak = ref.watch(settingsProvider.select((s) => s.showImsak));
    final day = win?.today;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    if (day == null) return const SizedBox.shrink();
    Widget row(String name, DateTime t, {bool next = false, bool minor = false}) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: next ? cs.secondary.withValues(alpha: 0.22) : null,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(children: [
            Expanded(
              child: Text(name,
                  style: (minor ? tt.bodyMedium : tt.titleMedium)
                      ?.copyWith(fontWeight: next ? FontWeight.w700 : FontWeight.w500)),
            ),
            Text(Myt.hhmm(t),
                style: (minor ? tt.bodyMedium : tt.titleMedium)?.copyWith(
                  fontWeight: next ? FontWeight.w700 : FontWeight.w500,
                  fontFeatures: const [FontFeature.tabularFigures()],
                )),
          ]),
        );
    return GlassCard(
      padding: const EdgeInsets.all(8),
      onTap: () => push(context, const TimetableScreen()),
      child: Column(children: [
        if (showImsak && day.imsak != null) row(context.tr('imsak'), day.imsak!, minor: true),
        for (final p in Prayer.values)
          row(
            p == Prayer.syuruk ? '${prayerName(context, p)} ☀' : prayerName(context, p),
            day.timeOf(p),
            next: st != null && !st.nextIsTomorrow && st.next == p,
            minor: p == Prayer.syuruk,
          ),
      ]),
    );
  }
}

class _QuickAccess extends ConsumerWidget {
  const _QuickAccess();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void open(Widget page) => push(context, page);
    final items = <(IconData, String, VoidCallback)>[
      (Icons.menu_book_rounded, 'quran', () => open(const ContentLibraryScreen(initialType: 'quran'))),
      (Icons.auto_awesome_rounded, 'zikir', () => open(const ContentLibraryScreen(initialType: 'zikr'))),
      (Icons.touch_app_rounded, 'tasbih', () => open(const TasbihScreen())),
      (Icons.explore_rounded, 'qiblah', () => open(const QiblahScreen())),
      (Icons.calendar_month_rounded, 'calendar', () => open(const CalendarScreen())),
      (Icons.volunteer_activism_rounded, 'doa', () => open(const ContentLibraryScreen(initialType: 'doa'))),
      (Icons.library_music_rounded, 'audio', () => open(const AudioLibraryScreen())),
      (Icons.alarm_rounded, 'audio_schedule', () => open(const SchedulerSettingsScreen())),
      (Icons.bedtime_rounded, 'sleep_mode', () => enterSleepMode(ref)),
    ];
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.25,
      children: [
        for (final (icon, key, onTap) in items)
          GlassCard(
            padding: const EdgeInsets.all(8),
            onTap: onTap,
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(icon, size: 28, color: Theme.of(context).colorScheme.secondary),
              const SizedBox(height: 6),
              Text(context.tr(key), textAlign: TextAlign.center, maxLines: 2, style: Theme.of(context).textTheme.bodySmall),
            ]),
          ),
      ],
    );
  }
}

class _UpcomingEvents extends ConsumerWidget {
  const _UpcomingEvents();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cal = ref.watch(calendarServiceProvider).value;
    final today = ref.watch(todayKeyProvider);
    final lang = ref.watch(settingsProvider.select((s) => s.language));
    if (cal == null) return const SizedBox.shrink();
    final events = cal.eventsBetween(Myt.addDays(today, 1), 90);
    final seen = <String>{};
    final unique = [for (final e in events) if (seen.add('${e.def.key}${e.hijriYear}')) e].take(3).toList();
    if (unique.isEmpty) return const SizedBox.shrink();
    return GlassCard(
      onTap: () => push(context, const CalendarScreen()),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(context.tr('upcoming_events'), style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 6),
        for (final e in unique)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(children: [
              Expanded(child: Text(e.def.name(lang))),
              Text(
                '${formatGregorian(context, e.dateKey, withDay: false)}'
                '${e.source == HijriSource.calculated ? ' *' : ''}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ]),
          ),
        if (unique.any((e) => e.source == HijriSource.calculated))
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(context.tr('calculated_note'), style: Theme.of(context).textTheme.labelSmall),
          ),
      ]),
    );
  }
}

class _SyncFooter extends ConsumerWidget {
  const _SyncFooter();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final win = ref.watch(dayWindowProvider).value;
    final sync = ref.watch(syncStatusProvider);
    final today = win?.today;
    final source = today == null
        ? '-'
        : context.tr('source_${today.source.name}');
    final last = win?.lastFetched;
    final online = sync.lastOk == null ? context.tr('status_unknown') : (sync.lastOk! ? context.tr('online') : context.tr('offline'));
    return Text(
      '${context.tr('data_source')}: $source · ${context.tr('last_update')}: '
      '${last == null ? '-' : '${Myt.dateKey(last)} ${Myt.hhmm(last)}'} · $online'
      '${sync.inProgress ? ' · ${context.tr('syncing')}' : ''}',
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.labelSmall,
    );
  }
}
