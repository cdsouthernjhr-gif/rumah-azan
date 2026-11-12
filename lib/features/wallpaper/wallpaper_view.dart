import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utilities/myt_time.dart';
import '../../data/models/app_settings.dart';
import '../../data/providers/providers.dart';
import 'builtin_wallpapers.dart';

const wallpaperSlots = ['morning', 'afternoon', 'evening', 'night'];

/// Which time-of-day slot applies at wall-clock minute [minuteOfDay].
String currentSlot(AppSettings s, int minuteOfDay) {
  final starts = <(String, int)>[
    for (final slot in wallpaperSlots) (slot, Myt.parseHm(s.slotStart(slot)) ?? 0),
  ]..sort((a, b) => a.$2.compareTo(b.$2));
  var result = starts.last.$1; // before the first start → previous day's last slot
  for (final (slot, start) in starts) {
    if (minuteOfDay >= start) result = slot;
  }
  return result;
}

/// Theme suggested for a slot when "automatic theme" is on.
AppThemeId themeForSlot(String slot) => switch (slot) {
      'morning' => AppThemeId.emeraldGold,
      'afternoon' => AppThemeId.cream,
      'evening' => AppThemeId.sunset,
      _ => AppThemeId.emeraldGold,
    };

/// Active wallpaper reference (`builtin:<key>` or `custom:<id>`).
final activeWallpaperProvider = Provider<String>((ref) {
  final s = ref.watch(settingsProvider);
  if (!s.wallpaperAuto) return s.wallpaperFixed;
  final now = ref.watch(secondTickProvider).value ?? Myt.nowInstant();
  final w = Myt.toWall(now);
  return s.wallpaperForSlot(currentSlot(s, w.hour * 60 + w.minute));
});

final activeSlotProvider = Provider<String>((ref) {
  final s = ref.watch(settingsProvider);
  final now = ref.watch(secondTickProvider).value ?? Myt.nowInstant();
  final w = Myt.toWall(now);
  return currentSlot(s, w.hour * 60 + w.minute);
});

/// Renders a wallpaper reference with the user's brightness/overlay/blur.
class WallpaperView extends ConsumerWidget {
  const WallpaperView({super.key, required this.refString, this.applyEffects = true, this.extraDim = 0});

  final String refString;
  final bool applyEffects;

  /// Additional dimming (used by Sleep Mode and the screensaver).
  final double extraDim;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    Widget base;
    if (refString.startsWith('custom:')) {
      final id = int.tryParse(refString.substring(7));
      base = id == null ? _fallback() : _CustomWallpaper(id: id, fit: s.wpFit == 'contain' ? BoxFit.contain : BoxFit.cover);
    } else {
      final w = builtinByKey(refString.replaceFirst('builtin:', ''));
      base = w == null ? _fallback() : CustomPaint(painter: BuiltinWallpaperPainter(w), size: Size.infinite);
    }
    if (!applyEffects) return RepaintBoundary(child: base);

    final b = s.wpBrightness;
    if (b < 0.999) {
      base = ColorFiltered(
        colorFilter: ColorFilter.matrix([
          b, 0, 0, 0, 0, //
          0, b, 0, 0, 0,
          0, 0, b, 0, 0,
          0, 0, 0, 1, 0,
        ]),
        child: base,
      );
    }
    if (s.wpBlur > 0.1) {
      base = ImageFiltered(
        imageFilter: ui.ImageFilter.blur(sigmaX: s.wpBlur, sigmaY: s.wpBlur, tileMode: TileMode.clamp),
        child: base,
      );
    }
    final overlay = (s.wpOverlay + extraDim).clamp(0.0, 0.95);
    return RepaintBoundary(
      child: Stack(fit: StackFit.expand, children: [
        Container(color: Colors.black),
        base,
        if (overlay > 0) ColoredBox(color: Colors.black.withValues(alpha: overlay)),
      ]),
    );
  }

  Widget _fallback() => CustomPaint(painter: BuiltinWallpaperPainter(builtinWallpapers.last), size: Size.infinite);
}

class _CustomWallpaper extends ConsumerWidget {
  const _CustomWallpaper({required this.id, required this.fit});
  final int id;
  final BoxFit fit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rows = ref.watch(_wallpaperRowsProvider).value ?? const [];
    final row = rows.where((r) => r.id == id).firstOrNull;
    if (row == null || !File(row.filePath).existsSync()) {
      return CustomPaint(painter: BuiltinWallpaperPainter(builtinWallpapers.last), size: Size.infinite);
    }
    // Decode at screen resolution only — keeps memory low on TV boxes.
    final mq = MediaQuery.of(context);
    final px = (mq.size.longestSide * mq.devicePixelRatio).round().clamp(480, 2560);
    return Image.file(
      File(row.filePath),
      fit: fit,
      cacheWidth: mq.size.width >= mq.size.height ? px : null,
      cacheHeight: mq.size.width < mq.size.height ? px : null,
      gaplessPlayback: true,
      errorBuilder: (_, _, _) =>
          CustomPaint(painter: BuiltinWallpaperPainter(builtinWallpapers.last), size: Size.infinite),
    );
  }
}

final _wallpaperRowsProvider = StreamProvider((ref) => ref.read(wallpaperRepoProvider).watchAll());
final customWallpapersProvider = _wallpaperRowsProvider;
