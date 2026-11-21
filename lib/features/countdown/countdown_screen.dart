import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/l10n/l10n.dart';
import '../../core/services/app_controller.dart';
import '../../core/utilities/myt_time.dart';
import '../../data/providers/providers.dart';
import '../../shared/widgets/common.dart';
import '../dashboard/dashboard_screen.dart' show formatGregorian;
import '../islamic_calendar/domain/islamic_events.dart';
import 'day_countdown.dart';

final dayCountdownsProvider = Provider<List<DayCountdown>>((ref) {
  final raw = ref.watch(settingsProvider.select((s) => s.dayCountdownsRaw));
  return [for (final j in raw) ?DayCountdown.fromJson(j)];
});

/// All countdowns resolved for today, soonest first.
final countdownTargetsProvider = Provider<List<CountdownTarget>>((ref) {
  final list = ref.watch(dayCountdownsProvider);
  final cal = ref.watch(calendarServiceProvider).value;
  final today = ref.watch(todayKeyProvider);
  if (cal == null) return const [];
  return sortTargets([for (final c in list) resolveCountdown(c, today, cal)]);
});

final pinnedCountdownsProvider = Provider<List<CountdownTarget>>(
  (ref) => ref.watch(countdownTargetsProvider).where((t) => t.countdown.pinned).toList(),
);

Future<void> saveCountdowns(WidgetRef ref, List<DayCountdown> list) async {
  await ref.read(settingsProvider.notifier).update({'dayCountdowns': [for (final c in list) c.toJson()]});
  // Home-screen widget shows the first pinned countdown.
  await ref.read(appControllerProvider).updateHomeWidget();
}

String countdownLabel(BuildContext context, int? days) {
  final (key, args) = daysLabel(days);
  return context.tr(key, args);
}

class CountdownScreen extends ConsumerWidget {
  const CountdownScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final targets = ref.watch(countdownTargetsProvider);
    final all = ref.watch(dayCountdownsProvider);
    final lang = ref.watch(settingsProvider.select((s) => s.language));
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    Future<void> edit([DayCountdown? existing]) async {
      final result = await showDialog<DayCountdown>(
        context: context,
        builder: (_) => CountdownEditorDialog(existing: existing, lang: lang),
      );
      if (result == null) return;
      final list = [...all];
      final i = list.indexWhere((c) => c.id == result.id);
      i >= 0 ? list[i] = result : list.add(result);
      await saveCountdowns(ref, list);
    }

    return PlainScaffold(
      title: context.tr('countdown_title'),
      fab: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: Text(context.tr('cd_add')),
        onPressed: () => edit(),
      ),
      body: targets.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(context.tr('cd_empty'), textAlign: TextAlign.center),
              ),
            )
          : ListView(padding: const EdgeInsets.fromLTRB(12, 12, 12, 96), children: [
              for (final t in targets)
                Card(
                  child: ListTile(
                    leading: SizedBox(
                      width: 64,
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text(
                          t.days == null ? '–' : '${t.days!.abs()}',
                          style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.w700, color: cs.secondary),
                        ),
                        Text(context.tr('cd_days_unit'), style: tt.labelSmall),
                      ]),
                    ),
                    title: Text(t.countdown.title),
                    subtitle: Text([
                      countdownLabel(context, t.days),
                      if (t.dateKey != null) formatGregorian(context, t.dateKey!),
                      if (t.countdown.yearly) context.tr('cd_yearly'),
                      if (t.isCalculated) context.tr('cd_calculated'),
                    ].join(' · ')),
                    isThreeLine: true,
                    onTap: () => edit(t.countdown),
                    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                      IconButton(
                        tooltip: context.tr('cd_pin'),
                        icon: Icon(t.countdown.pinned ? Icons.push_pin : Icons.push_pin_outlined),
                        onPressed: () => saveCountdowns(ref, [
                          for (final c in all) c.id == t.countdown.id ? c.copyWith(pinned: !c.pinned) : c,
                        ]),
                      ),
                      IconButton(
                        tooltip: context.tr('delete'),
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () async {
                          if (await confirmDialog(context, context.tr('delete'), t.countdown.title)) {
                            await saveCountdowns(ref, all.where((c) => c.id != t.countdown.id).toList());
                          }
                        },
                      ),
                    ]),
                  ),
                ),
            ]),
    );
  }
}

/// Create/edit a countdown: a date (optionally yearly) or an Islamic event.
class CountdownEditorDialog extends StatefulWidget {
  const CountdownEditorDialog({super.key, this.existing, required this.lang});
  final DayCountdown? existing;
  final String lang;
  @override
  State<CountdownEditorDialog> createState() => _CountdownEditorDialogState();
}

class _CountdownEditorDialogState extends State<CountdownEditorDialog> {
  late final _title = TextEditingController(text: widget.existing?.title ?? '');
  late bool _isEvent = widget.existing?.isEvent ?? false;
  late String? _eventKey = widget.existing?.eventKey ?? 'awal_ramadan';
  late String? _dateKey = widget.existing?.dateKey;
  late bool _yearly = widget.existing?.yearly ?? false;
  late bool _pinned = widget.existing?.pinned ?? true;

  bool get _valid => _title.text.trim().isNotEmpty && (_isEvent ? _eventKey != null : _dateKey != null);

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final today = Myt.parseDateKey(Myt.todayKey());
    final initial = _dateKey == null ? today.add(const Duration(days: 30)) : Myt.parseDateKey(_dateKey!);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.utc(today.year - 100),
      lastDate: DateTime.utc(today.year + 50),
    );
    if (picked != null) {
      setState(() => _dateKey = Myt.dateKeyFromWall(DateTime.utc(picked.year, picked.month, picked.day)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.tr(widget.existing == null ? 'cd_add' : 'cd_edit')),
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          SegmentedButton<bool>(
            segments: [
              ButtonSegment(value: false, label: Text(context.tr('cd_type_date'))),
              ButtonSegment(value: true, label: Text(context.tr('cd_type_event'))),
            ],
            selected: {_isEvent},
            showSelectedIcon: false,
            onSelectionChanged: (v) => setState(() {
              _isEvent = v.first;
              // Suggest the event name as title if still empty.
              if (_isEvent && _title.text.trim().isEmpty && _eventKey != null) {
                _title.text = eventByKey(_eventKey!)?.name(widget.lang) ?? '';
              }
            }),
          ),
          const SizedBox(height: 12),
          if (_isEvent)
            DropdownButtonFormField<String>(
              initialValue: _eventKey,
              isExpanded: true,
              decoration: InputDecoration(labelText: context.tr('cd_type_event')),
              items: [
                for (final e in islamicEventDefs) DropdownMenuItem(value: e.key, child: Text(e.name(widget.lang))),
              ],
              onChanged: (v) => setState(() {
                final oldName = _eventKey == null ? null : eventByKey(_eventKey!)?.name(widget.lang);
                _eventKey = v;
                if (_title.text.trim().isEmpty || _title.text == oldName) {
                  _title.text = v == null ? '' : (eventByKey(v)?.name(widget.lang) ?? '');
                }
              }),
            )
          else ...[
            OutlinedButton.icon(
              icon: const Icon(Icons.event),
              label: Text(_dateKey == null ? context.tr('cd_pick_date') : formatGregorian(context, _dateKey!)),
              onPressed: _pickDate,
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _yearly,
              title: Text(context.tr('cd_yearly_q')),
              onChanged: (v) => setState(() => _yearly = v ?? false),
            ),
          ],
          TextField(
            controller: _title,
            decoration: InputDecoration(labelText: context.tr('title'), hintText: context.tr('cd_title_hint')),
            onChanged: (_) => setState(() {}),
          ),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: _pinned,
            title: Text(context.tr('cd_pin_q')),
            onChanged: (v) => setState(() => _pinned = v ?? true),
          ),
        ]),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(context.tr('cancel'))),
        FilledButton(
          onPressed: !_valid
              ? null
              : () => Navigator.pop(
                    context,
                    DayCountdown(
                      id: widget.existing?.id ?? 'cd_${DateTime.now().microsecondsSinceEpoch}',
                      title: _title.text.trim(),
                      dateKey: _isEvent ? null : _dateKey,
                      eventKey: _isEvent ? _eventKey : null,
                      yearly: !_isEvent && _yearly,
                      pinned: _pinned,
                    ),
                  ),
          child: Text(context.tr('save')),
        ),
      ],
    );
  }
}

/// Compact dashboard card with the pinned countdowns (max 3).
class PinnedCountdownsCard extends ConsumerWidget {
  const PinnedCountdownsCard({super.key, this.max = 3});
  final int max;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pinned = ref.watch(pinnedCountdownsProvider).take(max).toList();
    if (pinned.isEmpty) return const SizedBox.shrink();
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return GlassCard(
      onTap: () => push(context, const CountdownScreen()),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(context.tr('countdown_title'), style: tt.titleSmall),
        const SizedBox(height: 6),
        for (final t in pinned)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(children: [
              Expanded(child: Text(t.countdown.title, maxLines: 1, overflow: TextOverflow.ellipsis)),
              Text(
                '${countdownLabel(context, t.days)}${t.isCalculated ? ' *' : ''}',
                style: tt.titleSmall?.copyWith(color: cs.secondary, fontWeight: FontWeight.w700),
              ),
            ]),
          ),
      ]),
    );
  }
}
