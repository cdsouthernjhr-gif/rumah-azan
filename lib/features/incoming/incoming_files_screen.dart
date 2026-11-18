import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/l10n/l10n.dart';
import '../../core/services/app_controller.dart';
import '../../core/services/native_bridge.dart';
import '../../data/local/database.dart';
import '../../data/providers/providers.dart';
import '../../data/repositories/audio_repository.dart';
import '../../shared/widgets/common.dart';
import '../audio_player/audio_library_screen.dart' show audioListProvider;
import '../wallpaper/wallpaper_view.dart' show customWallpapersProvider;
import 'incoming_files.dart';

/// Shown when audio/images are shared to Rumah Azan from another app.
/// For each file the user chooses: add as new, or replace an existing item
/// (which keeps its playlists, azan choice and wallpaper selections).
class IncomingFilesScreen extends ConsumerStatefulWidget {
  const IncomingFilesScreen({super.key, required this.files});
  final List<IncomingFile> files;

  @override
  ConsumerState<IncomingFilesScreen> createState() => _IncomingFilesScreenState();
}

class _IncomingFilesScreenState extends ConsumerState<IncomingFilesScreen> {
  late final List<IncomingChoice> _choices = [for (final f in widget.files) IncomingChoice(f)];
  bool _saving = false;
  bool _done = false;

  @override
  void dispose() {
    // Leaving without saving: remove the cached copies.
    if (!_done) IncomingFilesProcessor.discard(widget.files);
    super.dispose();
  }

  bool get _canSave => _choices.every((c) =>
      c.action != IncomingAction.replaceExisting || c.targetId != null);

  Future<void> _save() async {
    setState(() => _saving = true);
    final l = L10nScope.of(context);
    final result = await IncomingFilesProcessor(
      audio: ref.read(audioRepoProvider),
      wallpapers: ref.read(wallpaperRepoProvider),
    ).apply(_choices);
    _done = true;
    if (result.newWallpaperToUse != null) {
      await ref.read(settingsProvider.notifier).update({
        'wallpaperAuto': false,
        'wallpaperFixed': 'custom:${result.newWallpaperToUse}',
      });
    }
    if (result.audioChanged) {
      final bridge = ref.read(nativeBridgeProvider);
      await ref.read(audioRepoProvider).backfillDurations(bridge.audioDuration);
      // Replaced files have new paths stored in the native alarm plan.
      await ref.read(appControllerProvider).resyncSchedule();
    }
    if (!mounted) return;
    final msg = l.t('incoming_result', {'a': result.added, 'r': result.replaced, 's': result.skipped});
    final messenger = ScaffoldMessenger.maybeOf(context);
    Navigator.of(context).pop();
    messenger?.showSnackBar(SnackBar(
      content: Text(result.errors.isEmpty ? msg : '$msg\n${result.errors.join('\n')}'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final audio = ref.watch(audioListProvider).value ?? const <AudioRow>[];
    final walls = ref.watch(customWallpapersProvider).value ?? const <WallpaperRow>[];
    return PlainScaffold(
      title: context.tr('incoming_title'),
      body: ListView(padding: const EdgeInsets.all(12), children: [
        Text(context.tr('incoming_intro')),
        const SizedBox(height: 8),
        for (final c in _choices) _card(context, c, audio, walls),
        const SizedBox(height: 12),
        FilledButton.icon(
          icon: _saving
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.save_alt),
          label: Text(context.tr('save')),
          onPressed: _saving || !_canSave ? null : _save,
        ),
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: Text(context.tr('cancel')),
        ),
      ]),
    );
  }

  Widget _card(BuildContext context, IncomingChoice c, List<AudioRow> audio, List<WallpaperRow> walls) {
    final f = c.file;
    final isAudio = f.kind == 'audio';
    final targets = isAudio
        ? [for (final a in audio) (a.id, '${a.title} · ${context.tr('acat_${a.category}')}')]
        : [for (final w in walls) (w.id, w.name)];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(isAudio ? Icons.audiotrack : (f.kind == 'image' ? Icons.image : Icons.block)),
            const SizedBox(width: 8),
            Expanded(child: Text(f.name, style: Theme.of(context).textTheme.titleSmall)),
          ]),
          if (!f.usable) ...[
            const SizedBox(height: 6),
            Text(context.tr('incoming_unsupported', {'e': f.error ?? f.kind}),
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ] else ...[
            const SizedBox(height: 8),
            SegmentedButton<IncomingAction>(
              segments: [
                ButtonSegment(value: IncomingAction.addNew, label: Text(context.tr('add_new'))),
                ButtonSegment(
                  value: IncomingAction.replaceExisting,
                  label: Text(context.tr('replace_existing')),
                  enabled: targets.isNotEmpty,
                ),
                ButtonSegment(value: IncomingAction.skip, label: Text(context.tr('skip'))),
              ],
              selected: {c.action},
              showSelectedIcon: false,
              onSelectionChanged: (v) => setState(() => c.action = v.first),
            ),
            const SizedBox(height: 8),
            if (c.action == IncomingAction.addNew && isAudio)
              DropdownButtonFormField<String>(
                initialValue: c.category,
                decoration: InputDecoration(labelText: context.tr('category')),
                items: [
                  for (final cat in audioCategories)
                    DropdownMenuItem(value: cat, child: Text(context.tr('acat_$cat'))),
                ],
                onChanged: (v) => setState(() => c.category = v ?? c.category),
              ),
            if (c.action == IncomingAction.addNew && !isAudio)
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: c.useAsWallpaper,
                title: Text(context.tr('use_as_wallpaper_now')),
                onChanged: (v) => setState(() => c.useAsWallpaper = v ?? false),
              ),
            if (c.action == IncomingAction.replaceExisting) ...[
              DropdownButtonFormField<int>(
                initialValue: c.targetId,
                isExpanded: true,
                decoration: InputDecoration(labelText: context.tr(isAudio ? 'replace_which_audio' : 'replace_which_image')),
                items: [
                  for (final (id, label) in targets)
                    DropdownMenuItem(value: id, child: Text(label, overflow: TextOverflow.ellipsis)),
                ],
                onChanged: (v) => setState(() => c.targetId = v),
              ),
              const SizedBox(height: 4),
              Text(context.tr(isAudio ? 'replace_keeps_audio' : 'replace_keeps_image'),
                  style: Theme.of(context).textTheme.bodySmall),
            ],
          ],
        ]),
      ),
    );
  }
}
