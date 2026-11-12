import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/l10n/l10n.dart';
import '../../core/services/app_controller.dart';
import '../../core/utilities/myt_time.dart';
import '../../data/models/prayer_day.dart';
import '../../data/providers/providers.dart';
import '../../data/static/jakim_zones.dart';
import '../../shared/widgets/common.dart';

final _monthDaysProvider = FutureProvider.family<List<PrayerDay>, String>((ref, monthKey) async {
  ref.watch(dataVersionProvider);
  final zone = ref.watch(settingsProvider.select((s) => s.zoneCode));
  if (zone == null) return const [];
  final start = '$monthKey-01';
  final d = Myt.parseDateKey(start);
  final end = Myt.dateKeyFromWall(DateTime.utc(d.year, d.month + 1, 0));
  return ref.read(prayerRepoProvider).cachedRange(zone, start, end);
});

/// Monthly timetable of cached verified data (no estimates).
class TimetableScreen extends ConsumerStatefulWidget {
  const TimetableScreen({super.key});
  @override
  ConsumerState<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends ConsumerState<TimetableScreen> {
  late DateTime _month = () {
    final t = Myt.parseDateKey(Myt.todayKey());
    return DateTime.utc(t.year, t.month);
  }();

  String get _key => '${_month.year}-${_month.month.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final days = ref.watch(_monthDaysProvider(_key));
    final today = ref.watch(todayKeyProvider);
    final zone = zoneByCode(ref.watch(settingsProvider.select((s) => s.zoneCode)));
    final sync = ref.watch(syncStatusProvider);
    return PlainScaffold(
      title: context.tr('timetable'),
      actions: [
        IconButton(
          tooltip: context.tr('refresh'),
          icon: sync.inProgress
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.refresh),
          onPressed: () => ref.read(appControllerProvider).refreshPrayerData(force: true),
        ),
      ],
      body: Column(children: [
        ListTile(
          leading: IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => setState(() => _month = DateTime.utc(_month.year, _month.month - 1)),
          ),
          title: Text('${context.tr('month_${_month.month}')} ${_month.year}', textAlign: TextAlign.center),
          subtitle: Text(zone?.label ?? '-', textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
          trailing: IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => setState(() => _month = DateTime.utc(_month.year, _month.month + 1)),
          ),
        ),
        Expanded(
          child: days.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('$e')),
            data: (list) {
              if (list.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(context.tr('timetable_empty'), textAlign: TextAlign.center),
                );
              }
              return SingleChildScrollView(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 18,
                    columns: [
                      DataColumn(label: Text(context.tr('date'))),
                      DataColumn(label: Text(context.tr('imsak'))),
                      for (final p in Prayer.values) DataColumn(label: Text(prayerName(context, p))),
                    ],
                    rows: [
                      for (final d in list)
                        DataRow(
                          selected: d.date == today,
                          cells: [
                            DataCell(Text(d.date.substring(8))),
                            DataCell(Text(d.imsak == null ? '-' : Myt.hhmm(d.imsak!))),
                            for (final p in Prayer.values) DataCell(Text(Myt.hhmm(d.timeOf(p)))),
                          ],
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            context.tr('timetable_source_note', {
              'src': list(days.value).isEmpty ? '-' : context.tr('source_${list(days.value).first.source.name}'),
            }),
            style: Theme.of(context).textTheme.labelSmall,
            textAlign: TextAlign.center,
          ),
        ),
      ]),
    );
  }

  List<PrayerDay> list(List<PrayerDay>? v) => v ?? const [];
}
