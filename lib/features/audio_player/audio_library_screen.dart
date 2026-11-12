import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path/path.dart' as p;

import '../../core/l10n/l10n.dart';
import '../../core/services/app_controller.dart';
import '../../data/local/database.dart';
import '../../data/providers/providers.dart';
import '../../data/repositories/audio_repository.dart';
import '../../shared/widgets/common.dart';
import 'player_bar.dart';

final audioListProvider = StreamProvider<List<AudioRow>>((ref) => ref.read(audioRepoProvider).watchAll());
final playlistListProvider = StreamProvider<List<PlaylistRow>>((ref) => ref.read(audioRepoProvider).watchPlaylists());

class AudioLibraryScreen extends ConsumerStatefulWidget {
  const AudioLibraryScreen({super.key});
  @override
  ConsumerState<AudioLibraryScreen> createState() => _AudioLibraryScreenState();
}

class _AudioLibraryScreenState extends ConsumerState<AudioLibraryScreen> {
  String? _category;
  double? _download;
  bool _downloading = false;

  Future<void> _import() async {
    final res = await FilePicker.pickFiles(type: FileType.audio);
    if (res.isEmpty || !mounted) return;
    final category = await _askCategory(context);
    if (category == null) return;
    var ok = 0;
    for (final f in res) {
      try {
        final title = p.basenameWithoutExtension(f.name);
        final repo = ref.read(audioRepoProvider);
        if (f.path != null) {
          await repo.importFile(f.path!, title: title, category: category);
        } else {
          await repo.importStream(f.readAsByteStream(), f.name, title: title, category: category);
        }
        ok++;
      } catch (e) {
        if (mounted) showSnack(context, '${f.name}: $e');
      }
    }
    if (mounted) showSnack(context, context.tr('imported_n', {'n': ok}));
    ref.read(appControllerProvider).resyncSchedule();
  }

  Future<void> _downloadDialog() async {
    final url = await textInputDialog(context, context.tr('download_audio'), hint: 'https://…/audio.mp3');
    if (url == null || url.isEmpty || !mounted) return;
    final uri = Uri.tryParse(url);
    if (uri == null || uri.scheme != 'https') {
      showSnack(context, context.tr('https_only'));
      return;
    }
    final title = await textInputDialog(context, context.tr('title'), initial: p.basenameWithoutExtension(uri.path));
    if (title == null || !mounted) return;
    final category = await _askCategory(context);
    if (category == null) return;
    setState(() {
      _downloading = true;
      _download = null;
    });
    try {
      await ref.read(audioRepoProvider).download(
            uri,
            title: title.isEmpty ? uri.pathSegments.last : title,
            category: category,
            licenseNote: uri.host,
            onProgress: (pr) => mounted ? setState(() => _download = pr.fraction) : null,
          );
      if (mounted) showSnack(context, context.tr('download_done'));
    } catch (e) {
      if (mounted) showSnack(context, '${context.tr('download_failed')}: $e');
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  Future<String?> _askCategory(BuildContext context) => showDialog<String>(
        context: context,
        builder: (c) => SimpleDialog(
          title: Text(context.tr('category')),
          children: [
            for (final cat in audioCategories)
              SimpleDialogOption(onPressed: () => Navigator.pop(c, cat), child: Text(context.tr('acat_$cat'))),
          ],
        ),
      );

  void _playList(List<AudioRow> rows, int start) {
    ref.read(nativeBridgeProvider).play(
          items: [for (final r in rows) {'path': r.filePath, 'title': r.title}],
          startIndex: start,
          title: rows[start].title,
        );
  }

  @override
  Widget build(BuildContext context) {
    final rows = ref.watch(audioListProvider).value ?? const [];
    final filtered = _category == null ? rows : rows.where((r) => r.category == _category).toList();
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.tr('audio')),
          bottom: TabBar(tabs: [Tab(text: context.tr('library')), Tab(text: context.tr('playlists'))]),
          actions: [
            IconButton(tooltip: context.tr('download_audio'), icon: const Icon(Icons.download_rounded), onPressed: _downloadDialog),
            IconButton(tooltip: context.tr('import_audio'), icon: const Icon(Icons.add_rounded), onPressed: _import),
          ],
        ),
        body: Column(children: [
          if (_downloading) LinearProgressIndicator(value: _download),
          const Padding(padding: EdgeInsets.all(12), child: _FullPlayer()),
          Expanded(
            child: TabBarView(children: [
              Column(children: [
                SizedBox(
                  height: 48,
                  child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 12), children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ChoiceChip(label: Text(context.tr('all')), selected: _category == null, onSelected: (_) => setState(() => _category = null)),
                    ),
                    for (final c in audioCategories)
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(label: Text(context.tr('acat_$c')), selected: _category == c, onSelected: (_) => setState(() => _category = c)),
                      ),
                  ]),
                ),
                if (rows.isEmpty)
                  Padding(padding: const EdgeInsets.all(24), child: Text(context.tr('audio_empty'), textAlign: TextAlign.center)),
                Expanded(
                  child: ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final r = filtered[i];
                      return ListTile(
                        leading: const Icon(Icons.audiotrack_rounded),
                        title: Text(r.title),
                        subtitle: Text(context.tr('acat_${r.category}')),
                        onTap: () => _playList(filtered, i),
                        trailing: PopupMenuButton<String>(
                          onSelected: (v) async {
                            if (v == 'rename') {
                              final t = await textInputDialog(context, context.tr('rename'), initial: r.title);
                              if (t != null && t.isNotEmpty) await ref.read(audioRepoProvider).rename(r.id, t, r.category);
                            } else if (v == 'delete') {
                              if (await confirmDialog(context, context.tr('delete'), r.title)) {
                                await ref.read(audioRepoProvider).delete(r.id);
                                ref.read(appControllerProvider).resyncSchedule();
                              }
                            }
                          },
                          itemBuilder: (_) => [
                            PopupMenuItem(value: 'rename', child: Text(context.tr('rename'))),
                            PopupMenuItem(value: 'delete', child: Text(context.tr('delete'))),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ]),
              const _PlaylistsTab(),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _FullPlayer extends ConsumerWidget {
  const _FullPlayer();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final st = ref.watch(playerStateProvider).value;
    final b = ref.read(nativeBridgeProvider);
    if (st == null || st.isIdle) return const PlayerBar(compact: true);
    final repeatIcon = switch (st.repeatMode) {
      'one' => Icons.repeat_one_rounded,
      _ => Icons.repeat_rounded,
    };
    return GlassCard(
      child: Column(children: [
        Text(st.title ?? '-', style: Theme.of(context).textTheme.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
        Slider(
          value: st.durationMs > 0 ? st.positionMs.clamp(0, st.durationMs).toDouble() : 0,
          max: st.durationMs > 0 ? st.durationMs.toDouble() : 1,
          onChanged: st.durationMs > 0 ? (v) => b.seek(v.round()) : null,
        ),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(fmtMs(st.positionMs)),
          Text(fmtMs(st.durationMs)),
        ]),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          IconButton(
            tooltip: context.tr('shuffle'),
            icon: Icon(Icons.shuffle_rounded, color: st.shuffle ? Theme.of(context).colorScheme.secondary : null),
            onPressed: () => b.setShuffle(!st.shuffle),
          ),
          IconButton(tooltip: context.tr('previous'), icon: const Icon(Icons.skip_previous_rounded), onPressed: b.previous),
          IconButton(
            iconSize: 48,
            icon: Icon(st.isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded),
            onPressed: () => st.isPlaying ? b.pause() : b.resume(),
          ),
          IconButton(tooltip: context.tr('next'), icon: const Icon(Icons.skip_next_rounded), onPressed: b.next),
          IconButton(
            tooltip: context.tr('repeat'),
            icon: Icon(repeatIcon, color: st.repeatMode != 'off' ? Theme.of(context).colorScheme.secondary : null),
            onPressed: () => b.setRepeatMode(switch (st.repeatMode) { 'off' => 'all', 'all' => 'one', _ => 'off' }),
          ),
          IconButton(tooltip: context.tr('stop'), icon: const Icon(Icons.stop_rounded), onPressed: b.stop),
        ]),
        Row(children: [
          const Icon(Icons.volume_down_rounded),
          Expanded(child: Slider(value: st.volume.clamp(0, 1), onChanged: (v) => b.setVolume(v))),
          const Icon(Icons.volume_up_rounded),
        ]),
      ]),
    );
  }
}

class _PlaylistsTab extends ConsumerWidget {
  const _PlaylistsTab();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lists = ref.watch(playlistListProvider).value ?? const [];
    final repo = ref.read(audioRepoProvider);
    return ListView(children: [
      ListTile(
        leading: const Icon(Icons.playlist_add_rounded),
        title: Text(context.tr('new_playlist')),
        onTap: () async {
          final name = await textInputDialog(context, context.tr('new_playlist'));
          if (name != null && name.isNotEmpty) await repo.createPlaylist(name);
        },
      ),
      for (final pl in lists)
        ListTile(
          leading: const Icon(Icons.queue_music_rounded),
          title: Text(pl.name),
          onTap: () => push(context, PlaylistEditorScreen(playlist: pl)),
          trailing: IconButton(
            tooltip: context.tr('play'),
            icon: const Icon(Icons.play_arrow_rounded),
            onPressed: () async {
              final items = await repo.playlistItems(pl.id);
              if (items.isEmpty) return;
              await ref.read(nativeBridgeProvider).play(
                    items: [for (final r in items) {'path': r.filePath, 'title': r.title}],
                    title: pl.name,
                  );
            },
          ),
        ),
    ]);
  }
}

class PlaylistEditorScreen extends ConsumerStatefulWidget {
  const PlaylistEditorScreen({super.key, required this.playlist});
  final PlaylistRow playlist;
  @override
  ConsumerState<PlaylistEditorScreen> createState() => _PlaylistEditorScreenState();
}

class _PlaylistEditorScreenState extends ConsumerState<PlaylistEditorScreen> {
  List<AudioRow>? _items;

  @override
  void initState() {
    super.initState();
    ref.read(audioRepoProvider).playlistItems(widget.playlist.id).then((v) => setState(() => _items = v));
  }

  Future<void> _save() async {
    await ref.read(audioRepoProvider).setPlaylistItems(widget.playlist.id, [for (final r in _items!) r.id]);
    ref.read(appControllerProvider).resyncSchedule();
  }

  @override
  Widget build(BuildContext context) {
    final all = ref.watch(audioListProvider).value ?? const [];
    final items = _items;
    return PlainScaffold(
      title: widget.playlist.name,
      actions: [
        IconButton(
          tooltip: context.tr('delete'),
          icon: const Icon(Icons.delete_outline),
          onPressed: () async {
            if (await confirmDialog(context, context.tr('delete'), widget.playlist.name)) {
              await ref.read(audioRepoProvider).deletePlaylist(widget.playlist.id);
              ref.read(appControllerProvider).resyncSchedule();
              if (context.mounted) Navigator.pop(context);
            }
          },
        ),
      ],
      fab: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: Text(context.tr('add_audio')),
        onPressed: items == null
            ? null
            : () async {
                final picked = await showDialog<AudioRow>(
                  context: context,
                  builder: (c) => SimpleDialog(
                    title: Text(context.tr('add_audio')),
                    children: [
                      if (all.isEmpty) Padding(padding: const EdgeInsets.all(16), child: Text(context.tr('audio_empty'))),
                      for (final r in all)
                        SimpleDialogOption(onPressed: () => Navigator.pop(c, r), child: Text(r.title)),
                    ],
                  ),
                );
                if (picked != null) {
                  setState(() => items.add(picked));
                  await _save();
                }
              },
      ),
      body: items == null
          ? const Center(child: CircularProgressIndicator())
          : ReorderableListView.builder(
              itemCount: items.length,
              onReorderItem: (a, b) async {
                setState(() => items.insert(b, items.removeAt(a)));
                await _save();
              },
              itemBuilder: (_, i) => ListTile(
                key: ValueKey('${items[i].id}_$i'),
                leading: Text('${i + 1}'),
                title: Text(items[i].title),
                trailing: IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () async {
                    setState(() => items.removeAt(i));
                    await _save();
                  },
                ),
              ),
            ),
    );
  }
}
