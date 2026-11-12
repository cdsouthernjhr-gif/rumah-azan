import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/l10n/l10n.dart';
import '../../data/models/prayer_day.dart';
import '../../features/wallpaper/wallpaper_view.dart';

String prayerName(BuildContext context, Prayer p) => context.tr('prayer_${p.name}');

/// Translucent card that keeps text readable over any wallpaper.
class GlassCard extends StatelessWidget {
  const GlassCard({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.onTap, this.highlight = false});
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.surface.withValues(alpha: highlight ? 0.92 : 0.72),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: highlight ? cs.secondary : cs.secondary.withValues(alpha: 0.18), width: highlight ? 1.6 : 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(onTap: onTap, child: Padding(padding: padding, child: child)),
    );
  }
}

/// Scaffold drawn over the active wallpaper.
class WallpaperScaffold extends ConsumerWidget {
  const WallpaperScaffold({super.key, this.appBar, required this.body, this.floatingActionButton, this.bottom});
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final Widget? bottom;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wp = ref.watch(activeWallpaperProvider);
    return Stack(children: [
      Positioned.fill(child: WallpaperView(refString: wp)),
      Scaffold(
        backgroundColor: Colors.transparent,
        appBar: appBar,
        body: body,
        floatingActionButton: floatingActionButton,
        bottomNavigationBar: bottom,
      ),
    ]);
  }
}

/// Plain scaffold for settings-like pages (better readability).
class PlainScaffold extends StatelessWidget {
  const PlainScaffold({super.key, required this.title, required this.body, this.actions, this.fab});
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? fab;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(title), actions: actions),
        body: body,
        floatingActionButton: fab,
      );
}

class SectionHeader extends StatelessWidget {
  const SectionHeader(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
        child: Text(
          text.toUpperCase(),
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Theme.of(context).colorScheme.secondary,
                letterSpacing: 1.1,
                fontWeight: FontWeight.w700,
              ),
        ),
      );
}

class WarningBanner extends StatelessWidget {
  const WarningBanner({super.key, required this.text, this.icon = Icons.warning_amber_rounded, this.action});
  final String text;
  final IconData icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF5A3E00).withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFFFC94D)),
        ),
        child: Row(children: [
          Icon(icon, color: const Color(0xFFFFD873)),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(color: Colors.white))),
          ?action,
        ]),
      );
}

/// Arabic text with right-to-left direction and generous line height.
class ArabicText extends StatelessWidget {
  const ArabicText(this.text, {super.key, this.size = 26, this.align = TextAlign.right});
  final String text;
  final double size;
  final TextAlign align;
  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Text(
          text,
          textAlign: align,
          locale: const Locale('ar'),
          style: TextStyle(fontSize: size, height: 1.9, fontFamilyFallback: const ['Noto Naskh Arabic', 'Noto Sans Arabic']),
        ),
      );
}

Future<bool> confirmDialog(BuildContext context, String title, String body) async =>
    await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: Text(context.tr('cancel'))),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: Text(context.tr('ok'))),
        ],
      ),
    ) ??
    false;

Future<String?> textInputDialog(BuildContext context, String title, {String initial = '', String? hint}) {
  final ctl = TextEditingController(text: initial);
  return showDialog<String>(
    context: context,
    builder: (c) => AlertDialog(
      title: Text(title),
      content: TextField(controller: ctl, autofocus: true, decoration: InputDecoration(hintText: hint)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c), child: Text(context.tr('cancel'))),
        FilledButton(onPressed: () => Navigator.pop(c, ctl.text.trim()), child: Text(context.tr('ok'))),
      ],
    ),
  );
}

void showSnack(BuildContext context, String msg) =>
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(content: Text(msg)));

Future<T?> push<T>(BuildContext context, Widget page) =>
    Navigator.of(context).push<T>(MaterialPageRoute(builder: (_) => page));

/// Slider that updates locally while dragging and commits on release, so
/// expensive work (DB writes, alarm re-planning) runs once per gesture.
class CommitSlider extends StatefulWidget {
  const CommitSlider({
    super.key,
    required this.value,
    required this.onCommit,
    this.min = 0,
    this.max = 1,
    this.divisions,
    this.labelOf,
  });
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final String Function(double)? labelOf;
  final ValueChanged<double> onCommit;

  @override
  State<CommitSlider> createState() => _CommitSliderState();
}

class _CommitSliderState extends State<CommitSlider> {
  double? _drag;

  @override
  Widget build(BuildContext context) {
    final v = (_drag ?? widget.value).clamp(widget.min, widget.max);
    return Slider(
      value: v,
      min: widget.min,
      max: widget.max,
      divisions: widget.divisions,
      label: widget.labelOf?.call(v),
      onChanged: (x) => setState(() => _drag = x),
      onChangeEnd: (x) {
        setState(() => _drag = null);
        widget.onCommit(x);
      },
    );
  }
}
