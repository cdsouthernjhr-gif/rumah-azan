import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/l10n/l10n.dart';
import '../../data/local/database.dart';
import '../../data/providers/providers.dart';
import '../../shared/widgets/common.dart';

const tasbihPresets = ['Subhanallah', 'Alhamdulillah', 'Allahu Akbar', 'La ilaha illallah', 'Astaghfirullah', 'Selawat'];

final _tasbihHistoryProvider = StreamProvider<List<TasbihRow>>((ref) => ref.read(tasbihRepoProvider).watchHistory());
final _tasbihDailyProvider = FutureProvider.autoDispose<List<(String, int)>>((ref) {
  ref.watch(_tasbihHistoryProvider);
  return ref.read(tasbihRepoProvider).dailyTotals(7);
});

class TasbihScreen extends ConsumerStatefulWidget {
  const TasbihScreen({super.key, this.initialZikr, this.initialTarget});
  final String? initialZikr;
  final int? initialTarget;
  @override
  ConsumerState<TasbihScreen> createState() => _TasbihScreenState();
}

class _TasbihScreenState extends ConsumerState<TasbihScreen> {
  late String _zikr;
  late int _target;
  int _count = 0;
  bool _vibrate = true;
  bool _sound = false;
  late final SettingsNotifier _settings;

  @override
  void initState() {
    super.initState();
    _settings = ref.read(settingsProvider.notifier);
    // Restore unsaved progress from the previous session.
    final raw = ref.read(settingsProvider).raw;
    final saved = raw['tasbihCurrent'];
    _vibrate = raw['tasbihVibrate'] as bool? ?? true;
    _sound = raw['tasbihSound'] as bool? ?? false;
    if (widget.initialZikr != null) {
      _zikr = widget.initialZikr!;
      _target = widget.initialTarget ?? 33;
    } else if (saved is Map) {
      _zikr = '${saved['zikr'] ?? tasbihPresets.first}';
      _target = (saved['target'] as num?)?.toInt() ?? 33;
      _count = (saved['count'] as num?)?.toInt() ?? 0;
    } else {
      _zikr = tasbihPresets.first;
      _target = 33;
    }
  }

  void _persist() => ref.read(settingsProvider.notifier).update({
        'tasbihCurrent': {'zikr': _zikr, 'target': _target, 'count': _count},
      });

  void _tap() {
    setState(() => _count++);
    if (_vibrate) {
      _count == _target ? HapticFeedback.heavyImpact() : HapticFeedback.selectionClick();
    }
    if (_sound) SystemSound.play(SystemSoundType.click);
    if (_count % 10 == 0 || _count == _target) _persist();
  }

  Future<void> _saveAndReset() async {
    await ref.read(tasbihRepoProvider).save(zikr: _zikr, count: _count, target: _target);
    setState(() => _count = 0);
    _persist();
  }

  @override
  void dispose() {
    // Persist progress (fire-and-forget; settings write is async).
    _settings.update({
      'tasbihCurrent': {'zikr': _zikr, 'target': _target, 'count': _count},
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final progress = _target > 0 ? (_count % _target) / _target : 0.0;
    final rounds = _target > 0 ? _count ~/ _target : 0;
    return PlainScaffold(
      title: context.tr('tasbih'),
      actions: [
        IconButton(
          tooltip: context.tr('history'),
          icon: const Icon(Icons.history),
          onPressed: () => showModalBottomSheet(context: context, builder: (_) => const _HistorySheet()),
        ),
      ],
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Wrap(spacing: 6, runSpacing: 6, children: [
          for (final z in {...tasbihPresets, _zikr})
            ChoiceChip(
              label: Text(z),
              selected: z == _zikr,
              onSelected: (_) async {
                if (_count > 0) await _saveAndReset();
                setState(() => _zikr = z);
                _persist();
              },
            ),
          ActionChip(
            avatar: const Icon(Icons.edit, size: 16),
            label: Text(context.tr('custom')),
            onPressed: () async {
              final t = await textInputDialog(context, context.tr('custom_zikr'));
              if (t != null && t.isNotEmpty) {
                if (_count > 0) await _saveAndReset();
                setState(() => _zikr = t);
                _persist();
              }
            },
          ),
        ]),
        const SizedBox(height: 12),
        Wrap(spacing: 6, runSpacing: 6, crossAxisAlignment: WrapCrossAlignment.center, children: [
          Padding(padding: const EdgeInsets.only(right: 6), child: Text(context.tr('target'))),
          for (final t in [33, 99, 100, 1000])
            Padding(
              padding: EdgeInsets.zero,
              child: ChoiceChip(
                label: Text('$t'),
                selected: _target == t,
                onSelected: (_) {
                  setState(() => _target = t);
                  _persist();
                },
              ),
            ),
        ]),
        const SizedBox(height: 16),
        Semantics(
          button: true,
          label: context.tr('tap_to_count'),
          child: GestureDetector(
            onTap: _tap,
            child: Focus(
              autofocus: true,
              onKeyEvent: (_, e) {
                if (e is KeyDownEvent &&
                    (e.logicalKey == LogicalKeyboardKey.select || e.logicalKey == LogicalKeyboardKey.enter || e.logicalKey == LogicalKeyboardKey.space)) {
                  _tap();
                  return KeyEventResult.handled;
                }
                return KeyEventResult.ignored;
              },
              child: AspectRatio(
                aspectRatio: 1,
                child: Stack(alignment: Alignment.center, children: [
                  SizedBox.expand(child: CircularProgressIndicator(value: progress, strokeWidth: 14, color: cs.secondary, backgroundColor: cs.surface)),
                  Column(mainAxisSize: MainAxisSize.min, children: [
                    Text(_zikr, style: tt.titleLarge, textAlign: TextAlign.center),
                    Text('$_count', style: tt.displayLarge?.copyWith(fontWeight: FontWeight.w300, fontFeatures: const [FontFeature.tabularFigures()])),
                    Text('${context.tr('target')}: $_target · ${context.tr('rounds')}: $rounds', style: tt.bodyMedium),
                    const SizedBox(height: 4),
                    Text(context.tr('tap_to_count'), style: tt.labelSmall),
                  ]),
                ]),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(
            child: OutlinedButton.icon(
              icon: const Icon(Icons.restart_alt),
              label: Text(context.tr('save_reset')),
              onPressed: _count == 0 ? null : _saveAndReset,
            ),
          ),
        ]),
        SwitchListTile(
          title: Text(context.tr('vibrate')),
          value: _vibrate,
          onChanged: (v) {
            setState(() => _vibrate = v);
            ref.read(settingsProvider.notifier).update({'tasbihVibrate': v});
          },
        ),
        SwitchListTile(
          title: Text(context.tr('sound')),
          value: _sound,
          onChanged: (v) {
            setState(() => _sound = v);
            ref.read(settingsProvider.notifier).update({'tasbihSound': v});
          },
        ),
        SectionHeader(context.tr('daily_stats')),
        const _DailyChart(),
      ]),
    );
  }
}

class _DailyChart extends ConsumerWidget {
  const _DailyChart();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(_tasbihDailyProvider).value ?? const [];
    if (data.isEmpty) return const SizedBox(height: 120);
    final maxV = data.map((e) => e.$2).fold(0, (a, b) => a > b ? a : b);
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      height: 140,
      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        for (final (day, v) in data)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                Text('$v', style: Theme.of(context).textTheme.labelSmall),
                const SizedBox(height: 2),
                Container(
                  height: maxV == 0 ? 2 : (90 * v / maxV).clamp(2, 90).toDouble(),
                  decoration: BoxDecoration(color: cs.secondary, borderRadius: BorderRadius.circular(4)),
                ),
                const SizedBox(height: 4),
                Text(day.substring(8), style: Theme.of(context).textTheme.labelSmall),
              ]),
            ),
          ),
      ]),
    );
  }
}

class _HistorySheet extends ConsumerWidget {
  const _HistorySheet();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rows = ref.watch(_tasbihHistoryProvider).value ?? const [];
    return Column(children: [
      ListTile(
        title: Text(context.tr('history')),
        trailing: TextButton(
          onPressed: () async {
            if (await confirmDialog(context, context.tr('clear_history'), context.tr('clear_history_q'))) {
              await ref.read(tasbihRepoProvider).clear();
            }
          },
          child: Text(context.tr('clear')),
        ),
      ),
      Expanded(
        child: rows.isEmpty
            ? Center(child: Text(context.tr('no_history')))
            : ListView(children: [
                for (final r in rows)
                  ListTile(
                    title: Text(r.zikr),
                    subtitle: Text(r.date),
                    trailing: Text('${r.count} / ${r.target}'),
                  ),
              ]),
      ),
    ]);
  }
}
