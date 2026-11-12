import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/l10n/l10n.dart';
import '../../core/utilities/myt_time.dart';
import '../../data/providers/providers.dart';
import '../../shared/widgets/common.dart';
import '../dashboard/dashboard_screen.dart' show formatGregorian, hijriSourceLabel;
import 'domain/calendar_service.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});
  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  late DateTime _month = () {
    final t = Myt.parseDateKey(Myt.todayKey());
    return DateTime.utc(t.year, t.month);
  }();
  String? _selected;

  @override
  Widget build(BuildContext context) {
    final cal = ref.watch(calendarServiceProvider).value;
    final s = ref.watch(settingsProvider);
    final today = ref.watch(todayKeyProvider);
    final cs = Theme.of(context).colorScheme;
    if (cal == null) return PlainScaffold(title: context.tr('calendar'), body: const Center(child: CircularProgressIndicator()));

    final first = _month;
    final daysInMonth = DateTime.utc(first.year, first.month + 1, 0).day;
    final leading = (first.weekday + 6) % 7; // Monday-first grid
    final monthStartKey = Myt.dateKeyFromWall(first);
    final monthEvents = cal.eventsBetween(monthStartKey, daysInMonth);
    final eventDays = {for (final e in monthEvents) e.dateKey};
    final selected = _selected ?? (today.startsWith(monthStartKey.substring(0, 7)) ? today : monthStartKey);
    final selHijri = cal.hijriFor(selected);
    final hStart = cal.hijriFor(monthStartKey).date;
    final hEnd = cal.hijriFor(Myt.addDays(monthStartKey, daysInMonth - 1)).date;

    return PlainScaffold(
      title: context.tr('calendar'),
      body: ListView(padding: const EdgeInsets.all(12), children: [
        Row(children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => setState(() {
              _month = DateTime.utc(_month.year, _month.month - 1);
              _selected = null;
            }),
          ),
          Expanded(
            child: Column(children: [
              Text('${context.tr('month_${first.month}')} ${first.year}', style: Theme.of(context).textTheme.titleMedium),
              Text(
                hStart.month == hEnd.month
                    ? '${hStart.monthName(s.language)} ${hStart.year} H'
                    : '${hStart.monthName(s.language)} – ${hEnd.monthName(s.language)} ${hEnd.year} H',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ]),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => setState(() {
              _month = DateTime.utc(_month.year, _month.month + 1);
              _selected = null;
            }),
          ),
        ]),
        Row(children: [
          for (var i = 1; i <= 7; i++)
            Expanded(child: Center(child: Text(context.tr('day_short_$i'), style: Theme.of(context).textTheme.labelSmall))),
        ]),
        const SizedBox(height: 4),
        GridView.count(
          crossAxisCount: 7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 0.85,
          children: [
            for (var i = 0; i < leading; i++) const SizedBox.shrink(),
            for (var d = 1; d <= daysInMonth; d++)
              Builder(builder: (context) {
                final key = Myt.addDays(monthStartKey, d - 1);
                final h = cal.hijriFor(key).date;
                final isToday = key == today;
                final isSel = key == selected;
                final hasEvent = eventDays.contains(key);
                return InkWell(
                  onTap: () => setState(() => _selected = key),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: isSel ? cs.secondary.withValues(alpha: 0.3) : null,
                      border: isToday ? Border.all(color: cs.secondary, width: 1.5) : null,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text('$d', style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text('${h.day}', style: Theme.of(context).textTheme.labelSmall),
                      if (hasEvent) Icon(Icons.circle, size: 6, color: cs.secondary),
                    ]),
                  ),
                );
              }),
          ],
        ),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            title: Text(formatGregorian(context, selected)),
            subtitle: Text('${selHijri.date.format(s.language)}\n${hijriSourceLabel(context, selHijri.source)}'),
            isThreeLine: true,
          ),
        ),
        for (final e in cal.eventsOn(selected)) _EventTile(e: e, lang: s.language, onChanged: () => setState(() {})),
        SectionHeader(context.tr('events_this_month')),
        if (monthEvents.isEmpty) Padding(padding: const EdgeInsets.all(8), child: Text(context.tr('no_events'))),
        for (final e in monthEvents) _EventTile(e: e, lang: s.language, onChanged: () => setState(() {})),
        SectionHeader(context.tr('hijri_adjust')),
        ListTile(
          title: Text(context.tr('hijri_adjust_desc')),
          subtitle: Text(context.tr('hijri_adjust_note')),
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: s.hijriAdjust > -2 ? () => ref.read(settingsProvider.notifier).update({'hijriAdjust': s.hijriAdjust - 1}) : null,
            ),
            Text(s.hijriAdjust > 0 ? '+${s.hijriAdjust}' : '${s.hijriAdjust}'),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: s.hijriAdjust < 2 ? () => ref.read(settingsProvider.notifier).update({'hijriAdjust': s.hijriAdjust + 1}) : null,
            ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(context.tr('calendar_disclaimer'), style: Theme.of(context).textTheme.bodySmall),
        ),
      ]),
    );
  }
}

class _EventTile extends ConsumerWidget {
  const _EventTile({required this.e, required this.lang, required this.onChanged});
  final EventOccurrence e;
  final String lang;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: ExpansionTile(
        leading: Icon(
          e.source == HijriSource.official ? Icons.verified_rounded : Icons.event_rounded,
          color: Theme.of(context).colorScheme.secondary,
        ),
        title: Text(e.def.name(lang)),
        subtitle: Text('${formatGregorian(context, e.dateKey)} · ${hijriSourceLabel(context, e.source)}'),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(e.def.desc(lang)),
          if (e.note != null) Padding(padding: const EdgeInsets.only(top: 6), child: Text(e.note!)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, children: [
            OutlinedButton.icon(
              icon: const Icon(Icons.edit_calendar_outlined),
              label: Text(context.tr('set_official_date')),
              onPressed: () => _setOfficial(context, ref),
            ),
            if (e.source == HijriSource.official)
              TextButton(
                onPressed: () async {
                  await ref.read(calendarRepoProvider).removeOverride(e.def.key, e.hijriYear);
                  ref.read(dataVersionProvider.notifier).bump();
                  onChanged();
                },
                child: Text(context.tr('remove_official_date')),
              ),
          ]),
        ],
      ),
    );
  }

  Future<void> _setOfficial(BuildContext context, WidgetRef ref) async {
    final initial = Myt.parseDateKey(e.dateKey);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: initial.subtract(const Duration(days: 5)),
      lastDate: initial.add(const Duration(days: 5)),
      helpText: context.tr('set_official_date'),
    );
    if (picked == null || !context.mounted) return;
    final note = await textInputDialog(context, context.tr('official_source_note'), hint: context.tr('official_source_hint'));
    await ref.read(calendarRepoProvider).setOverride(
          eventKey: e.def.key,
          hijriYear: e.hijriYear,
          dateKey: Myt.dateKeyFromWall(DateTime.utc(picked.year, picked.month, picked.day)),
          note: (note == null || note.isEmpty) ? null : note,
        );
    ref.read(dataVersionProvider.notifier).bump();
    onChanged();
  }
}

