import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/l10n/l10n.dart';
import '../../data/providers/providers.dart';
import '../../shared/widgets/common.dart';
import 'audio_library_screen.dart';

String fmtMs(int ms) {
  final s = (ms / 1000).floor();
  return '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';
}

/// Compact "now playing" card with play/pause/next and progress.
class PlayerBar extends ConsumerWidget {
  const PlayerBar({super.key, this.compact = false});
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final st = ref.watch(playerStateProvider).value;
    final bridge = ref.read(nativeBridgeProvider);
    final tt = Theme.of(context).textTheme;
    if (st == null || st.isIdle) {
      if (compact) return const SizedBox.shrink();
      return GlassCard(
        onTap: () => push(context, const AudioLibraryScreen()),
        child: Row(children: [
          const Icon(Icons.music_note_rounded),
          const SizedBox(width: 12),
          Expanded(child: Text(context.tr('nothing_playing'), style: tt.bodyMedium)),
          const Icon(Icons.chevron_right),
        ]),
      );
    }
    final progress = st.durationMs > 0 ? (st.positionMs / st.durationMs).clamp(0.0, 1.0) : null;
    return GlassCard(
      onTap: compact ? null : () => push(context, const AudioLibraryScreen()),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(st.source == 'scheduled' ? Icons.alarm_on_rounded : Icons.graphic_eq_rounded,
              color: Theme.of(context).colorScheme.secondary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(st.title ?? '-', maxLines: 1, overflow: TextOverflow.ellipsis, style: tt.titleSmall),
              Text('${st.index + 1}/${st.count} · ${fmtMs(st.positionMs)} / ${fmtMs(st.durationMs)}', style: tt.bodySmall),
            ]),
          ),
          IconButton(
            tooltip: st.isPlaying ? context.tr('pause') : context.tr('play'),
            icon: Icon(st.isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded, size: 36),
            onPressed: () => st.isPlaying ? bridge.pause() : bridge.resume(),
          ),
          IconButton(tooltip: context.tr('next'), icon: const Icon(Icons.skip_next_rounded), onPressed: bridge.next),
          IconButton(tooltip: context.tr('stop'), icon: const Icon(Icons.stop_rounded), onPressed: bridge.stop),
        ]),
        const SizedBox(height: 6),
        LinearProgressIndicator(value: progress, minHeight: 4),
      ]),
    );
  }
}
