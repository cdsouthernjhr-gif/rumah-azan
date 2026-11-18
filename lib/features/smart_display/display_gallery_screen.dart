import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path/path.dart' as p;

import '../../core/l10n/l10n.dart';
import '../../core/utilities/myt_time.dart';
import '../../data/providers/providers.dart';
import '../../shared/widgets/common.dart';
import '../wallpaper/builtin_wallpapers.dart';
import '../wallpaper/wallpaper_view.dart';
import 'display_gallery.dart';

/// Valid gallery for Display Mode (deleted images removed), in order.
final displayGalleryProvider = Provider<List<String>>((ref) {
  final refs = ref.watch(settingsProvider.select((s) => s.displayGallery));
  final customs = ref.watch(customWallpapersProvider).value ?? const [];
  return validGallery(refs, {for (final c in customs) c.id});
});

/// Choose the images Display Mode shows and how they change: spread evenly
/// over 24 hours (N images → 24/N hours each) or every few seconds.
class DisplayGalleryScreen extends ConsumerStatefulWidget {
  const DisplayGalleryScreen({super.key});
  @override
  ConsumerState<DisplayGalleryScreen> createState() => _DisplayGalleryScreenState();
}

class _DisplayGalleryScreenState extends ConsumerState<DisplayGalleryScreen> {
  bool _importing = false;

  Future<void> _save(List<String> gallery, {String? rotation}) async {
    final s = ref.read(settingsProvider);
    await ref.read(settingsProvider.notifier).update({
      'displayGallery': gallery,
      // First images added: switch on the 24-hour rotation automatically.
      'displayRotation': rotation ?? (s.displayRotation == 'off' && gallery.length > 1 ? 'day' : s.displayRotation),
    });
  }

  Future<void> _importFromPhone(List<String> gallery) async {
    final files = await FilePicker.pickFiles(type: FileType.image);
    if (files.isEmpty || !mounted) return;
    setState(() => _importing = true);
    final added = <String>[];
    final errors = <String>[];
    for (final f in files) {
      try {
        final id = await ref
            .read(wallpaperRepoProvider)
            .import(f.readAsByteStream(), f.name, p.basenameWithoutExtension(f.name));
        added.add('custom:$id');
      } catch (e) {
        errors.add('${f.name}: $e');
      }
    }
    await _save([...gallery, ...added]);
    if (!mounted) return;
    setState(() => _importing = false);
    showSnack(context, [context.tr('gallery_added_n', {'n': added.length}), ...errors].join('\n'));
  }

  Future<void> _addExisting(List<String> gallery) async {
    final lang = ref.read(settingsProvider).language;
    final customs = ref.read(customWallpapersProvider).value ?? const [];
    final options = <(String, String)>[
      for (final c in customs) ('custom:${c.id}', c.name),
      for (final w in builtinWallpapers) (w.ref, w.name(lang)),
    ].where((o) => !gallery.contains(o.$1)).toList();
    final picked = await showDialog<List<String>>(
      context: context,
      builder: (c) => _MultiPickDialog(options: options),
    );
    if (picked == null || picked.isEmpty) return;
    await _save([...gallery, ...picked]);
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(settingsProvider);
    final gallery = ref.watch(displayGalleryProvider);
    final rotation = parseRotation(s.displayRotation);
    final now = ref.watch(secondTickProvider).value ?? Myt.nowInstant();
    final wall = Myt.toWall(now);
    final currentIdx = galleryIndexAt(gallery.length, wall.hour * 60 + wall.minute);
    final slots = gallerySlots(gallery.length);
    final (h, m) = slotLength(gallery.length);
    final customs = ref.watch(customWallpapersProvider).value ?? const [];
    String nameOf(String r) {
      if (r.startsWith('builtin:')) return builtinByKey(r.substring(8))?.name(s.language) ?? r;
      final id = int.tryParse(r.substring(7));
      return customs.where((c) => c.id == id).firstOrNull?.name ?? r;
    }

    return PlainScaffold(
      title: context.tr('display_gallery'),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
          child: SegmentedButton<GalleryRotation>(
            segments: [
              ButtonSegment(value: GalleryRotation.off, label: Text(context.tr('rotation_off'))),
              ButtonSegment(value: GalleryRotation.day, label: Text(context.tr('rotation_day'))),
              ButtonSegment(value: GalleryRotation.interval, label: Text(context.tr('rotation_interval'))),
            ],
            selected: {rotation},
            showSelectedIcon: false,
            onSelectionChanged: (v) => _save(gallery, rotation: v.first.name),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Text(
            switch (rotation) {
              GalleryRotation.off => context.tr('rotation_off_desc'),
              GalleryRotation.day => gallery.isEmpty
                  ? context.tr('gallery_empty_hint')
                  : context.tr('rotation_day_desc', {'n': gallery.length, 'h': h, 'm': m}),
              GalleryRotation.interval => context.tr('rotation_interval_desc'),
            },
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        if (rotation == GalleryRotation.interval)
          ListTile(
            title: Text(context.tr('slideshow_interval')),
            trailing: DropdownButton<int>(
              value: const [30, 60, 300, 900, 1800, 3600].contains(s.slideshowSec) ? s.slideshowSec : 60,
              items: [
                for (final o in const [30, 60, 300, 900, 1800, 3600])
                  DropdownMenuItem(value: o, child: Text(o < 60 ? '${o}s' : context.tr('n_min', {'n': o ~/ 60}))),
              ],
              onChanged: (v) => ref.read(settingsProvider.notifier).update({'slideshowSec': v}),
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Wrap(spacing: 8, children: [
            FilledButton.icon(
              icon: _importing
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.add_photo_alternate_outlined),
              label: Text(context.tr('gallery_add_phone')),
              onPressed: _importing ? null : () => _importFromPhone(gallery),
            ),
            OutlinedButton.icon(
              icon: const Icon(Icons.collections_outlined),
              label: Text(context.tr('gallery_add_existing')),
              onPressed: () => _addExisting(gallery),
            ),
          ]),
        ),
        const Divider(),
        Expanded(
          child: gallery.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(context.tr('gallery_empty_hint'), textAlign: TextAlign.center),
                  ),
                )
              : ReorderableListView.builder(
                  itemCount: gallery.length,
                  // newIndex is already adjusted for the removed item.
                  onReorderItem: (a, b) {
                    final list = [...gallery];
                    list.insert(b, list.removeAt(a));
                    _save(list);
                  },
                  itemBuilder: (_, i) {
                    final r = gallery[i];
                    final isNow = rotation == GalleryRotation.day && i == currentIdx;
                    return ListTile(
                      key: ValueKey(r),
                      selected: isNow,
                      leading: SizedBox(
                        width: 72,
                        height: 44,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: WallpaperView(refString: r, applyEffects: false),
                        ),
                      ),
                      title: Text(nameOf(r), maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: rotation == GalleryRotation.day
                          ? Text('${formatSlotMinute(slots[i].$1)} – ${formatSlotMinute(slots[i].$2)}'
                              '${isNow ? ' · ${context.tr('showing_now')}' : ''}')
                          : null,
                      trailing: IconButton(
                        tooltip: context.tr('remove'),
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () => _save([...gallery]..removeAt(i)),
                      ),
                    );
                  },
                ),
        ),
      ]),
    );
  }
}

class _MultiPickDialog extends StatefulWidget {
  const _MultiPickDialog({required this.options});
  final List<(String, String)> options;
  @override
  State<_MultiPickDialog> createState() => _MultiPickDialogState();
}

class _MultiPickDialogState extends State<_MultiPickDialog> {
  final _picked = <String>[];

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(context.tr('gallery_add_existing')),
        content: SizedBox(
          width: 420,
          height: 420,
          child: widget.options.isEmpty
              ? Center(child: Text(context.tr('gallery_none_left')))
              : ListView(children: [
                  for (final (r, name) in widget.options)
                    CheckboxListTile(
                      value: _picked.contains(r),
                      secondary: SizedBox(
                        width: 56,
                        height: 36,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: WallpaperView(refString: r, applyEffects: false),
                        ),
                      ),
                      title: Text(name),
                      onChanged: (v) => setState(() => v == true ? _picked.add(r) : _picked.remove(r)),
                    ),
                ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(context.tr('cancel'))),
          FilledButton(
            onPressed: _picked.isEmpty ? null : () => Navigator.pop(context, _picked),
            child: Text(context.tr('add_n', {'n': _picked.length})),
          ),
        ],
      );
}
