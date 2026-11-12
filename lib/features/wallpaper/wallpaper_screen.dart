import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path/path.dart' as p;

import '../../core/l10n/l10n.dart';
import '../../core/utilities/myt_time.dart';
import '../../data/models/app_settings.dart';
import '../../data/providers/providers.dart';
import '../../shared/widgets/common.dart';
import 'builtin_wallpapers.dart';
import 'wallpaper_view.dart';

class WallpaperScreen extends ConsumerWidget {
  const WallpaperScreen({super.key});

  Future<void> _import(BuildContext context, WidgetRef ref) async {
    final f = await FilePicker.pickFile(type: FileType.image);
    if (f == null || !context.mounted) return;
    try {
      final id = await ref.read(wallpaperRepoProvider).import(f.readAsByteStream(), f.name, p.basenameWithoutExtension(f.name));
      if (!context.mounted) return;
      final use = await confirmDialog(context, context.tr('wallpaper_imported'), context.tr('use_now_q'));
      if (use) await ref.read(settingsProvider.notifier).update({'wallpaperAuto': false, 'wallpaperFixed': 'custom:$id'});
    } catch (e) {
      if (context.mounted) showSnack(context, '$e');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    final customs = ref.watch(customWallpapersProvider).value ?? const [];
    final active = ref.watch(activeWallpaperProvider);
    final all = <(String, String)>[
      for (final w in builtinWallpapers) (w.ref, w.name(s.language)),
      for (final c in customs) ('custom:${c.id}', c.name),
    ];
    final notifier = ref.read(settingsProvider.notifier);

    Future<void> chooseFor(String? slot) async {
      final chosen = await showModalBottomSheet<String>(
        context: context,
        isScrollControlled: true,
        builder: (c) => _WallpaperGrid(options: all, selected: slot == null ? s.wallpaperFixed : s.wallpaperForSlot(slot)),
      );
      if (chosen == null) return;
      if (slot == null) {
        await notifier.update({'wallpaperFixed': chosen, 'wallpaperAuto': false});
      } else {
        await notifier.update({'wallpaper${slot[0].toUpperCase()}${slot.substring(1)}': chosen});
      }
    }

    return PlainScaffold(
      title: context.tr('appearance'),
      body: ListView(children: [
        // Preview
        Padding(
          padding: const EdgeInsets.all(16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(fit: StackFit.expand, children: [
                WallpaperView(refString: active),
                Center(
                  child: Text('12:34', style: Theme.of(context).textTheme.displayMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w300)),
                ),
              ]),
            ),
          ),
        ),
        SectionHeader(context.tr('theme')),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(spacing: 8, runSpacing: 8, children: [
            for (final t in ['emeraldGold', 'cream', 'ocean', 'sunset'])
              ChoiceChip(
                label: Text(context.tr('theme_$t')),
                selected: s.raw['theme'] == t || (s.raw['theme'] == null && t == 'emeraldGold'),
                onSelected: (_) => notifier.update({'theme': t}),
              ),
          ]),
        ),
        SwitchListTile(
          title: Text(context.tr('auto_theme')),
          subtitle: Text(context.tr('auto_theme_sub')),
          value: s.autoThemeFromSlot,
          onChanged: (v) => notifier.update({'autoThemeFromSlot': v}),
        ),
        ListTile(
          title: Text(context.tr('font_size')),
          subtitle: CommitSlider(
            value: s.fontScale,
            min: 0.8,
            max: 1.6,
            divisions: 8,
            labelOf: (v) => '${(v * 100).round()}%',
            onCommit: (v) => notifier.update({'fontScale': v}),
          ),
        ),
        SectionHeader(context.tr('wallpaper')),
        SwitchListTile(
          title: Text(context.tr('wallpaper_auto')),
          subtitle: Text(context.tr('wallpaper_auto_sub')),
          value: s.wallpaperAuto,
          onChanged: (v) => notifier.update({'wallpaperAuto': v}),
        ),
        if (s.wallpaperAuto)
          for (final slot in wallpaperSlots)
            ListTile(
              leading: SizedBox(
                width: 56,
                height: 40,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: WallpaperView(refString: s.wallpaperForSlot(slot), applyEffects: false),
                ),
              ),
              title: Text(context.tr('slot_$slot')),
              subtitle: Text('${context.tr('starts_at')} ${s.slotStart(slot)}'),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                IconButton(
                  tooltip: context.tr('change_time'),
                  icon: const Icon(Icons.schedule),
                  onPressed: () => _pickTime(context, ref, s, slot),
                ),
                const Icon(Icons.chevron_right),
              ]),
              onTap: () => chooseFor(slot),
            )
        else
          ListTile(
            title: Text(context.tr('wallpaper_fixed')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => chooseFor(null),
          ),
        ListTile(
          leading: const Icon(Icons.add_photo_alternate_outlined),
          title: Text(context.tr('import_image')),
          onTap: () => _import(context, ref),
        ),
        for (final c in customs)
          ListTile(
            leading: const Icon(Icons.image_outlined),
            title: Text(c.name),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                if (await confirmDialog(context, context.tr('delete'), c.name)) {
                  final refStr = 'custom:${c.id}';
                  // Never leave a deleted image selected.
                  final patch = <String, Object?>{
                    if (s.wallpaperFixed == refStr) 'wallpaperFixed': AppSettings.defaults['wallpaperFixed'],
                    for (final slot in wallpaperSlots)
                      if (s.wallpaperForSlot(slot) == refStr)
                        'wallpaper${slot[0].toUpperCase()}${slot.substring(1)}':
                            AppSettings.defaults['wallpaper${slot[0].toUpperCase()}${slot.substring(1)}'],
                  };
                  if (patch.isNotEmpty) await notifier.update(patch);
                  await ref.read(wallpaperRepoProvider).delete(c.id);
                }
              },
            ),
          ),
        if (active.startsWith('custom:')) ...[
          SectionHeader(context.tr('frame_image')),
          ListTile(
            title: Text(context.tr('zoom')),
            subtitle: CommitSlider(
              value: s.wpZoom,
              min: 1,
              max: 3,
              divisions: 20,
              labelOf: (v) => '${v.toStringAsFixed(1)}×',
              onCommit: (v) => notifier.update({'wpZoom': v}),
            ),
          ),
          ListTile(
            title: Text(context.tr('position_x')),
            subtitle: CommitSlider(value: s.wpAlignX, min: -1, max: 1, divisions: 20, onCommit: (v) => notifier.update({'wpAlignX': v})),
          ),
          ListTile(
            title: Text(context.tr('position_y')),
            subtitle: CommitSlider(value: s.wpAlignY, min: -1, max: 1, divisions: 20, onCommit: (v) => notifier.update({'wpAlignY': v})),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => notifier.update({'wpZoom': 1.0, 'wpAlignX': 0.0, 'wpAlignY': 0.0}),
              child: Text(context.tr('reset')),
            ),
          ),
        ],
        SectionHeader(context.tr('wallpaper_effects')),
        ListTile(
          title: Text(context.tr('brightness')),
          subtitle: CommitSlider(value: s.wpBrightness, min: 0.3, max: 1, divisions: 14, onCommit: (v) => notifier.update({'wpBrightness': v})),
        ),
        ListTile(
          title: Text(context.tr('dark_overlay')),
          subtitle: CommitSlider(value: s.wpOverlay, max: 0.8, divisions: 16, onCommit: (v) => notifier.update({'wpOverlay': v})),
        ),
        ListTile(
          title: Text(context.tr('blur')),
          subtitle: CommitSlider(value: s.wpBlur, max: 12, divisions: 12, onCommit: (v) => notifier.update({'wpBlur': v})),
        ),
        ListTile(
          title: Text(context.tr('image_fit')),
          trailing: SegmentedButton<String>(
            segments: [
              ButtonSegment(value: 'cover', label: Text(context.tr('fit_fill'))),
              ButtonSegment(value: 'contain', label: Text(context.tr('fit_fit'))),
            ],
            selected: {s.wpFit},
            onSelectionChanged: (v) => notifier.update({'wpFit': v.first}),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: OutlinedButton.icon(
            icon: const Icon(Icons.restore),
            label: Text(context.tr('restore_default_wallpaper')),
            onPressed: () => notifier.update({
              for (final k in [
                'wallpaperAuto', 'wallpaperFixed', 'wallpaperMorning', 'wallpaperAfternoon', 'wallpaperEvening',
                'wallpaperNight', 'slotMorning', 'slotAfternoon', 'slotEvening', 'slotNight', 'wpBrightness',
                'wpOverlay', 'wpBlur', 'wpFit', 'wpZoom', 'wpAlignX', 'wpAlignY',
              ])
                k: AppSettings.defaults[k],
            }),
          ),
        ),
      ]),
    );
  }

  Future<void> _pickTime(BuildContext context, WidgetRef ref, AppSettings s, String slot) async {
    final m = Myt.parseHm(s.slotStart(slot)) ?? 0;
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: m ~/ 60, minute: m % 60),
      builder: (c, child) => MediaQuery(data: MediaQuery.of(c).copyWith(alwaysUse24HourFormat: true), child: child!),
    );
    if (t == null) return;
    await ref.read(settingsProvider.notifier).update({
      'slot${slot[0].toUpperCase()}${slot.substring(1)}': Myt.formatHm(t.hour * 60 + t.minute),
    });
  }
}

class _WallpaperGrid extends StatelessWidget {
  const _WallpaperGrid({required this.options, required this.selected});
  final List<(String, String)> options;
  final String selected;

  @override
  Widget build(BuildContext context) => SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: GridView.count(
            padding: const EdgeInsets.all(12),
            crossAxisCount: MediaQuery.of(context).size.width > 700 ? 4 : 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.4,
            children: [
              for (final (refStr, name) in options)
                InkWell(
                  onTap: () => Navigator.pop(context, refStr),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: refStr == selected ? Theme.of(context).colorScheme.secondary : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(fit: StackFit.expand, children: [
                      WallpaperView(refString: refStr, applyEffects: false),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Container(
                          width: double.infinity,
                          color: Colors.black45,
                          padding: const EdgeInsets.all(6),
                          child: Text(name, style: const TextStyle(color: Colors.white)),
                        ),
                      ),
                    ]),
                  ),
                ),
            ],
          ),
        ),
      );
}
