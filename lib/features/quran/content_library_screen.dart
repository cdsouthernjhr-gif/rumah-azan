import 'package:drift/drift.dart' show Value;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/l10n/l10n.dart';
import '../../data/local/database.dart';
import '../../data/models/content_item.dart';
import '../../data/providers/providers.dart';
import '../../shared/widgets/common.dart';
import '../audio_player/audio_library_screen.dart';
import '../tasbih/tasbih_screen.dart';

/// Library of Quran surahs, zikr and doa with search, categories and favorites.
class ContentLibraryScreen extends ConsumerStatefulWidget {
  const ContentLibraryScreen({super.key, this.initialType = 'quran'});
  final String initialType; // quran | zikr | doa | fav
  @override
  ConsumerState<ContentLibraryScreen> createState() => _ContentLibraryScreenState();
}

class _ContentLibraryScreenState extends ConsumerState<ContentLibraryScreen> {
  static const _types = ['quran', 'zikr', 'doa', 'fav'];
  late String _type = widget.initialType;
  String _query = '';
  String? _cat;

  @override
  Widget build(BuildContext context) {
    final all = ref.watch(contentProvider);
    final favs = ref.watch(favoritesProvider).value ?? const <String>{};
    final lang = ref.watch(settingsProvider.select((s) => s.language));
    return PlainScaffold(
      title: context.tr('library_title'),
      body: all.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (items) {
          final ofType = items.where((i) => _type == 'fav' ? favs.contains(i.id) : i.type == _type).toList();
          final cats = <String>{for (final i in ofType) ...i.categories}.toList()
            ..sort((a, b) => contentCategories.indexOf(a).compareTo(contentCategories.indexOf(b)));
          final shown = ofType.where((i) => (_cat == null || i.categories.contains(_cat)) && i.matches(_query)).toList();
          return Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
              child: SegmentedButton<String>(
                segments: [for (final t in _types) ButtonSegment(value: t, label: Text(context.tr('ctype_$t')))],
                selected: {_type},
                showSelectedIcon: false,
                onSelectionChanged: (v) => setState(() {
                  _type = v.first;
                  _cat = null;
                }),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: TextField(
                decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: context.tr('search'), isDense: true),
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            SizedBox(
              height: 48,
              child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), children: [
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(label: Text(context.tr('all')), selected: _cat == null, onSelected: (_) => setState(() => _cat = null)),
                ),
                for (final c in cats)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(label: Text(context.tr('cat_$c')), selected: _cat == c, onSelected: (_) => setState(() => _cat = c)),
                  ),
              ]),
            ),
            Expanded(
              child: shown.isEmpty
                  ? Center(child: Text(context.tr(_type == 'fav' ? 'no_favorites' : 'no_results')))
                  : ListView.builder(
                      itemCount: shown.length,
                      itemBuilder: (_, i) {
                        final it = shown[i];
                        return ListTile(
                          title: Text(it.title(lang)),
                          subtitle: Text(it.reference, maxLines: 1, overflow: TextOverflow.ellipsis),
                          leading: Icon(switch (it.type) {
                            'quran' => Icons.menu_book_rounded,
                            'zikr' => Icons.auto_awesome_rounded,
                            _ => Icons.volunteer_activism_rounded,
                          }),
                          trailing: favs.contains(it.id) ? const Icon(Icons.favorite, size: 18) : null,
                          onTap: () => push(context, ContentDetailScreen(item: it)),
                        );
                      },
                    ),
            ),
          ]);
        },
      ),
    );
  }
}

class ContentDetailScreen extends ConsumerWidget {
  const ContentDetailScreen({super.key, required this.item});
  final ContentItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(settingsProvider.select((s) => s.language));
    final fav = (ref.watch(favoritesProvider).value ?? const {}).contains(item.id);
    final audio = (ref.watch(audioListProvider).value ?? const <AudioRow>[]).where((a) => a.contentId == item.id).toList();
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return PlainScaffold(
      title: item.title(lang),
      actions: [
        IconButton(
          tooltip: context.tr('favorite'),
          icon: Icon(fav ? Icons.favorite : Icons.favorite_border),
          onPressed: () => ref.read(contentRepoProvider).toggleFavorite(item.id),
        ),
        IconButton(
          tooltip: context.tr('copy'),
          icon: const Icon(Icons.copy_rounded),
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: item.shareText(lang)));
            if (context.mounted) showSnack(context, context.tr('copied'));
          },
        ),
        IconButton(
          tooltip: context.tr('share'),
          icon: const Icon(Icons.share_rounded),
          onPressed: () => SharePlus.instance.share(ShareParams(text: item.shareText(lang), subject: item.title(lang))),
        ),
      ],
      body: ListView(padding: const EdgeInsets.all(16), children: [
        if (!item.isVerified)
          WarningBanner(icon: Icons.fact_check_outlined, text: context.tr('content_unverified')),
        if (item.note != null) WarningBanner(icon: Icons.info_outline, text: item.note!),
        if (item.ayat.isNotEmpty)
          for (final a in item.ayat)
            Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                ArabicText('${a.ar} ﴿${a.n}﴾'),
                if (a.rumi != null) Text(a.rumi!, style: tt.bodyMedium?.copyWith(fontStyle: FontStyle.italic, color: cs.secondary)),
                const SizedBox(height: 4),
                Text('(${a.n}) ${a.ms}', style: tt.bodyLarge),
              ]),
            )
        else ...[
          ArabicText(item.ar ?? ''),
          if (item.rumi != null) Text(item.rumi!, style: tt.bodyMedium?.copyWith(fontStyle: FontStyle.italic, color: cs.secondary)),
          const SizedBox(height: 8),
          Text(item.ms ?? '', style: tt.bodyLarge),
        ],
        if (item.repeat != null) ...[
          const SizedBox(height: 12),
          Chip(avatar: const Icon(Icons.repeat, size: 18), label: Text(context.tr('repeat_n', {'n': item.repeat}))),
        ],
        const Divider(height: 32),
        Text(context.tr('reference'), style: tt.labelLarge),
        Text(item.reference),
        const SizedBox(height: 16),
        Wrap(spacing: 8, runSpacing: 8, children: [
          if (item.repeat != null)
            OutlinedButton.icon(
              icon: const Icon(Icons.touch_app_rounded),
              label: Text(context.tr('count_with_tasbih')),
              onPressed: () => push(context, TasbihScreen(initialZikr: item.titleMs, initialTarget: item.repeat)),
            ),
          for (final a in audio)
            FilledButton.icon(
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text(a.title),
              onPressed: () => ref.read(nativeBridgeProvider).play(items: [{'path': a.filePath, 'title': a.title}], title: a.title),
            ),
          OutlinedButton.icon(
            icon: const Icon(Icons.link_rounded),
            label: Text(context.tr('link_audio')),
            onPressed: () async {
              final all = ref.read(audioListProvider).value ?? const <AudioRow>[];
              final picked = await showDialog<AudioRow>(
                context: context,
                builder: (c) => SimpleDialog(title: Text(context.tr('link_audio')), children: [
                  if (all.isEmpty) Padding(padding: const EdgeInsets.all(16), child: Text(context.tr('audio_empty'))),
                  for (final r in all) SimpleDialogOption(onPressed: () => Navigator.pop(c, r), child: Text(r.title)),
                ]),
              );
              if (picked == null) return;
              final db = ref.read(databaseProvider);
              await (db.update(db.audioLibrary)..where((t) => t.id.equals(picked.id)))
                  .write(AudioLibraryCompanion(contentId: Value(item.id)));
            },
          ),
        ]),
      ]),
    );
  }
}
