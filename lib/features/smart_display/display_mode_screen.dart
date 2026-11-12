import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/l10n/l10n.dart';
import '../../core/services/native_bridge.dart';
import '../../core/utilities/myt_time.dart';
import '../../data/models/prayer_day.dart';
import '../../data/providers/providers.dart';
import '../../data/static/jakim_zones.dart';
import '../../shared/widgets/common.dart';
import '../dashboard/dashboard_screen.dart' show formatGregorian;
import '../wallpaper/builtin_wallpapers.dart';
import '../wallpaper/wallpaper_view.dart';

/// Full-screen Smart Mosque / Home Display, landscape-first, for Android TV
/// boxes, smart TVs and wall-mounted tablets. Fully usable with a D-pad.
class DisplayModeScreen extends ConsumerStatefulWidget {
  const DisplayModeScreen({super.key});
  @override
  ConsumerState<DisplayModeScreen> createState() => _DisplayModeScreenState();
}

class _DisplayModeScreenState extends ConsumerState<DisplayModeScreen> {
  late final NativeBridge _bridge;
  Timer? _idle;
  Timer? _slide;
  bool _saver = false;
  int _slideIndex = 0;

  @override
  void initState() {
    super.initState();
    _bridge = ref.read(nativeBridgeProvider);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    final s = ref.read(settingsProvider);
    // Keep-screen-on only if the user enabled it (never forced).
    if (s.keepScreenOn) _bridge.setKeepScreenOn(true);
    _resetIdle();
    if (s.slideshow) {
      _slide = Timer.periodic(Duration(seconds: s.slideshowSec), (_) => setState(() => _slideIndex++));
    }
  }

  void _resetIdle() {
    _idle?.cancel();
    if (_saver) setState(() => _saver = false);
    final min = ref.read(settingsProvider).screensaverMin;
    if (min > 0) _idle = Timer(Duration(minutes: min), () => setState(() => _saver = true));
  }

  @override
  void dispose() {
    _idle?.cancel();
    _slide?.cancel();
    _bridge.setKeepScreenOn(false);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  String _wallpaperRef() {
    final s = ref.read(settingsProvider);
    if (!s.slideshow) return ref.watch(activeWallpaperProvider);
    final customs = ref.watch(customWallpapersProvider).value ?? const [];
    final all = [
      for (final w in builtinWallpapers) w.ref,
      for (final c in customs) 'custom:${c.id}',
    ];
    return all[_slideIndex % all.length];
  }

  @override
  Widget build(BuildContext context) {
    final now = ref.watch(secondTickProvider).value ?? Myt.nowInstant();
    return Focus(
      autofocus: true,
      onKeyEvent: (_, e) {
        if (e is KeyDownEvent) _resetIdle();
        return KeyEventResult.ignored;
      },
      child: Listener(
        onPointerDown: (_) => _resetIdle(),
        behavior: HitTestBehavior.translucent,
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Stack(fit: StackFit.expand, children: [
            AnimatedSwitcher(
              duration: const Duration(seconds: 2),
              child: WallpaperView(
                key: ValueKey(_saver ? 'saver' : _wallpaperRef()),
                refString: _wallpaperRef(),
                extraDim: _saver ? 0.55 : 0,
              ),
            ),
            if (_saver) _Screensaver(now: now) else _DisplayLayout(now: now),
            if (!_saver)
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  tooltip: context.tr('close'),
                  icon: const Icon(Icons.close_rounded, color: Colors.white70),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
          ]),
        ),
      ),
    );
  }
}

class _DisplayLayout extends ConsumerWidget {
  const _DisplayLayout({required this.now});
  final DateTime now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    final win = ref.watch(dayWindowProvider).value;
    final st = ref.watch(prayerStatusProvider);
    final cal = ref.watch(calendarServiceProvider).value;
    final player = ref.watch(playerStateProvider).value;
    final today = Myt.dateKey(now);
    final zone = zoneByCode(s.zoneCode);
    final hijri = cal?.hijriFor(today);
    final events = cal?.eventsBetween(today, 30) ?? const [];
    final w = Myt.toWall(now);
    const white = Colors.white;
    final accent = Theme.of(context).colorScheme.secondary;

    return LayoutBuilder(builder: (context, c) {
      final scale = (c.maxWidth / 1280).clamp(0.6, 2.2);
      final showSide = c.maxWidth > c.maxHeight * 1.3 && (events.isNotEmpty || (player != null && !player.isIdle));
      TextStyle t(double size, [FontWeight wgt = FontWeight.w400]) => TextStyle(
            color: white,
            fontSize: size * scale,
            fontWeight: wgt,
            fontFeatures: const [FontFeature.tabularFigures()],
            shadows: const [Shadow(blurRadius: 8, color: Colors.black54)],
          );

      final portrait = c.maxWidth < c.maxHeight;
      final clock = Text(
        '${w.hour.toString().padLeft(2, '0')}:${w.minute.toString().padLeft(2, '0')}'
        ':${w.second.toString().padLeft(2, '0')}',
        style: t(72, FontWeight.w300),
      );
      final dateInfo = Column(
        crossAxisAlignment: portrait ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          Text(formatGregorian(context, today), style: t(24, FontWeight.w600), textAlign: TextAlign.center),
          if (hijri != null) Text(hijri.date.format(s.language), style: t(20)),
          if (zone != null)
            Text('${zone.code} · ${zone.areas}', style: t(16), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      );

      Widget tile(Prayer p) => Container(
            margin: EdgeInsets.all(5 * scale),
            padding: EdgeInsets.symmetric(vertical: 12 * scale, horizontal: 6 * scale),
            decoration: BoxDecoration(
              color: (st != null && !st.nextIsTomorrow && st.next == p)
                  ? accent.withValues(alpha: 0.85)
                  : Colors.black.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(16 * scale),
            ),
            // FittedBox keeps names/times on one line at any size or language.
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(prayerName(context, p), style: t(p == Prayer.syuruk ? 18 : 22, FontWeight.w600)),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(Myt.hhmm(win!.today!.timeOf(p)), style: t(p == Prayer.syuruk ? 26 : 34, FontWeight.w500)),
              ),
            ]),
          );

      final main = Column(children: [
        // TOP: time, date, location
        Padding(
          padding: EdgeInsets.fromLTRB(24 * scale, 16 * scale, 56, 0),
          child: portrait
              ? Column(children: [FittedBox(fit: BoxFit.scaleDown, child: clock), dateInfo])
              : Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  clock,
                  SizedBox(width: 24 * scale),
                  Expanded(child: dateInfo),
                ]),
        ),
        // CENTER: next prayer + countdown (scales down rather than overflow)
        Expanded(
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16 * scale),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: st == null
                    ? Text(context.tr('no_next_prayer'), style: t(28))
                    : Column(mainAxisSize: MainAxisSize.min, children: [
                        Text('${context.tr('next_prayer')} · ${prayerName(context, st.next)} ${Myt.hhmm(st.nextTime)}',
                            style: t(34, FontWeight.w600).copyWith(color: accent)),
                        Text(Myt.countdown(st.remaining), style: t(120, FontWeight.w200)),
                        if (win?.today != null && !win!.today!.source.isVerified)
                          Text(context.tr('estimate_short'), style: t(16).copyWith(color: Colors.amberAccent)),
                      ]),
              ),
            ),
          ),
        ),
        // BOTTOM: complete timetable — one row (landscape) or 3×2 (portrait)
        if (win?.today != null)
          Padding(
            padding: EdgeInsets.all(12 * scale),
            child: portrait
                ? Column(children: [
                    for (final row in [Prayer.values.sublist(0, 3), Prayer.values.sublist(3)])
                      Row(children: [for (final p in row) Expanded(child: tile(p))]),
                  ])
                : Row(children: [for (final p in Prayer.values) Expanded(child: tile(p))]),
          ),
      ]);

      if (!showSide) return main;
      return Row(children: [
        Expanded(flex: 3, child: main),
        Container(
          width: c.maxWidth * 0.24,
          margin: EdgeInsets.fromLTRB(0, 64, 16 * scale, 16 * scale),
          padding: EdgeInsets.all(16 * scale),
          decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.45), borderRadius: BorderRadius.circular(16)),
          child: ListView(children: [
            if (player != null && !player.isIdle) ...[
              Text(context.tr('now_playing'), style: t(16, FontWeight.w600).copyWith(color: accent)),
              Text(player.title ?? '-', style: t(18)),
              SizedBox(height: 16 * scale),
            ],
            if (events.isNotEmpty) Text(context.tr('announcements'), style: t(16, FontWeight.w600).copyWith(color: accent)),
            for (final e in events.take(4))
              Padding(
                padding: EdgeInsets.only(top: 8 * scale),
                child: Text('${e.def.name(s.language)}\n${formatGregorian(context, e.dateKey, withDay: false)}', style: t(16)),
              ),
          ]),
        ),
      ]);
    });
  }
}

/// Burn-in friendly screensaver: dim, minimal, slowly moving content.
class _Screensaver extends ConsumerWidget {
  const _Screensaver({required this.now});
  final DateTime now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final st = ref.watch(prayerStatusProvider);
    final w = Myt.toWall(now);
    // Shift position every minute to avoid burn-in.
    final pos = [Alignment.topLeft, Alignment.topRight, Alignment.center, Alignment.bottomLeft, Alignment.bottomRight][w.minute % 5];
    const style = TextStyle(color: Colors.white70, fontWeight: FontWeight.w200);
    return Padding(
      padding: const EdgeInsets.all(48),
      child: Align(
        alignment: pos,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('${w.hour.toString().padLeft(2, '0')}:${w.minute.toString().padLeft(2, '0')}', style: style.copyWith(fontSize: 72)),
          if (st != null)
            Text('${prayerName(context, st.next)} ${Myt.hhmm(st.nextTime)} · −${Myt.countdown(st.remaining)}',
                style: style.copyWith(fontSize: 24)),
        ]),
      ),
    );
  }
}

/// Wraps the dashboard: after N idle minutes returns automatically to the
/// display mode (if the user enabled it).
class IdleReturnToDisplay extends ConsumerStatefulWidget {
  const IdleReturnToDisplay({super.key, required this.child});
  final Widget child;
  @override
  ConsumerState<IdleReturnToDisplay> createState() => _IdleReturnToDisplayState();
}

class _IdleReturnToDisplayState extends ConsumerState<IdleReturnToDisplay> {
  Timer? _t;

  void _reset() {
    _t?.cancel();
    final min = ref.read(settingsProvider).displayAutoReturnMin;
    if (min <= 0) return;
    _t = Timer(Duration(minutes: min), () {
      if (!mounted) return;
      final route = ModalRoute.of(context);
      if (route != null && route.isCurrent) {
        push(context, const DisplayModeScreen()).then((_) => _reset());
      } else {
        _reset(); // another page is open; check again later
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _reset();
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(settingsProvider.select((s) => s.displayAutoReturnMin), (_, _) => _reset());
    // Observes key events from focused descendants (they bubble up) without
    // becoming a focus stop itself — otherwise a TV remote would land on an
    // invisible full-page node.
    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onKeyEvent: (_, _) {
        _reset();
        return KeyEventResult.ignored;
      },
      child: Listener(behavior: HitTestBehavior.translucent, onPointerDown: (_) => _reset(), child: widget.child),
    );
  }
}
