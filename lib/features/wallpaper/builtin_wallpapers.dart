import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

/// Procedurally drawn Islamic wallpapers. Being vector-drawn they cost no APK
/// space, scale to 4K TVs, and carry no image-licensing risk.
class BuiltinWallpaper {
  const BuiltinWallpaper({
    required this.key,
    required this.nameMs,
    required this.nameEn,
    required this.slot,
    required this.colors,
    this.stars = false,
    this.crescent = false,
    this.mosque = false,
    this.sun = false,
    this.pattern = false,
    this.patternColor = const Color(0x22FFFFFF),
    this.silhouetteColor = const Color(0xCC000000),
    this.hills = false,
  });

  final String key;
  final String nameMs;
  final String nameEn;
  final String slot; // morning | afternoon | evening | night
  final List<Color> colors;
  final bool stars, crescent, mosque, sun, pattern, hills;
  final Color patternColor;
  final Color silhouetteColor;

  String name(String lang) => lang == 'en' ? nameEn : nameMs;
  String get ref => 'builtin:$key';
}

const builtinWallpapers = <BuiltinWallpaper>[
  BuiltinWallpaper(
    key: 'morning_sunrise', nameMs: 'Fajar Menyingsing', nameEn: 'Sunrise', slot: 'morning',
    colors: [Color(0xFF2E5E4E), Color(0xFF8CBF88), Color(0xFFF6D49A), Color(0xFFFBE8C4)],
    sun: true, hills: true, silhouetteColor: Color(0xFF214A3B),
  ),
  BuiltinWallpaper(
    key: 'morning_garden', nameMs: 'Taman Pagi', nameEn: 'Morning Garden', slot: 'morning',
    colors: [Color(0xFF0F5F48), Color(0xFF3E9C6E), Color(0xFFBFE3B4)],
    pattern: true, patternColor: Color(0x1FFFFFFF), hills: true, silhouetteColor: Color(0xFF0B4535),
  ),
  BuiltinWallpaper(
    key: 'afternoon_cream', nameMs: 'Krim Minimalis', nameEn: 'Minimal Cream', slot: 'afternoon',
    colors: [Color(0xFFFFFCF4), Color(0xFFF4EBD6), Color(0xFFE9DCBC)],
    pattern: true, patternColor: Color(0x22B08D3C),
  ),
  BuiltinWallpaper(
    key: 'afternoon_sky', nameMs: 'Langit Cerah', nameEn: 'Clear Sky', slot: 'afternoon',
    colors: [Color(0xFF7FC4E8), Color(0xFFCFE9F6), Color(0xFFFFFFFF)],
    mosque: true, silhouetteColor: Color(0x33204060),
  ),
  BuiltinWallpaper(
    key: 'evening_sunset', nameMs: 'Senja Masjid', nameEn: 'Mosque at Sunset', slot: 'evening',
    colors: [Color(0xFF2B1E4F), Color(0xFF7A3E7A), Color(0xFFE8833A), Color(0xFFFFC27A)],
    sun: true, mosque: true, silhouetteColor: Color(0xF0140D24),
  ),
  BuiltinWallpaper(
    key: 'evening_dusk', nameMs: 'Lembayung', nameEn: 'Dusk', slot: 'evening',
    colors: [Color(0xFF1E1436), Color(0xFF5B2C6F), Color(0xFFD9704A)],
    pattern: true, patternColor: Color(0x18FFD8A8), crescent: true,
  ),
  BuiltinWallpaper(
    key: 'night_crescent', nameMs: 'Bulan Sabit', nameEn: 'Crescent Night', slot: 'night',
    colors: [Color(0xFF040B1F), Color(0xFF0A1F3D), Color(0xFF0B3A33)],
    stars: true, crescent: true, mosque: true, silhouetteColor: Color(0xF0020812),
  ),
  BuiltinWallpaper(
    key: 'night_emerald', nameMs: 'Zamrud Emas', nameEn: 'Emerald Gold', slot: 'night',
    colors: [Color(0xFF031A14), Color(0xFF06231B), Color(0xFF0B3328)],
    pattern: true, patternColor: Color(0x33D4AF37), stars: true,
  ),
  BuiltinWallpaper(
    key: 'ocean_calm', nameMs: 'Lautan Tenang', nameEn: 'Calm Ocean', slot: 'night',
    colors: [Color(0xFF0A1A33), Color(0xFF113D5C), Color(0xFF1FB5B0)],
    pattern: true, patternColor: Color(0x1A7FE3DF), crescent: true,
  ),
];

BuiltinWallpaper? builtinByKey(String key) {
  for (final w in builtinWallpapers) {
    if (w.key == key) return w;
  }
  return null;
}

class BuiltinWallpaperPainter extends CustomPainter {
  BuiltinWallpaperPainter(this.w);
  final BuiltinWallpaper w;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: w.colors,
        ).createShader(rect),
    );
    final s = size.shortestSide;

    if (w.stars) {
      final rnd = math.Random(7);
      final p = Paint()..color = Colors.white;
      for (var i = 0; i < 90; i++) {
        final o = Offset(rnd.nextDouble() * size.width, rnd.nextDouble() * size.height * 0.6);
        p.color = Colors.white.withValues(alpha: 0.25 + rnd.nextDouble() * 0.6);
        canvas.drawCircle(o, 0.6 + rnd.nextDouble() * 1.4, p);
      }
    }

    if (w.sun) {
      final c = Offset(size.width * 0.5, size.height * 0.62);
      canvas.drawCircle(
        c,
        s * 0.42,
        Paint()
          ..shader = RadialGradient(colors: [
            const Color(0xFFFFE7B0).withValues(alpha: 0.55),
            const Color(0x00FFE7B0),
          ]).createShader(Rect.fromCircle(center: c, radius: s * 0.42)),
      );
      canvas.drawCircle(c, s * 0.09, Paint()..color = const Color(0xFFFFF1CF).withValues(alpha: 0.9));
    }

    if (w.crescent) {
      final c = Offset(size.width * 0.78, size.height * 0.16);
      final r = s * 0.075;
      final moon = Path()..addOval(Rect.fromCircle(center: c, radius: r));
      final cut = Path()..addOval(Rect.fromCircle(center: c.translate(r * 0.42, -r * 0.18), radius: r * 0.9));
      canvas.drawPath(
        Path.combine(PathOperation.difference, moon, cut),
        Paint()..color = const Color(0xFFF5D98B),
      );
    }

    if (w.pattern) _drawStarLattice(canvas, size, w.patternColor);
    if (w.hills) _drawHills(canvas, size, w.silhouetteColor);
    if (w.mosque) _drawMosque(canvas, size, w.silhouetteColor);
  }

  /// Classic Islamic 8-point star (two overlapping squares) tiled on a grid.
  void _drawStarLattice(Canvas canvas, Size size, Color color) {
    final cell = math.max(size.shortestSide / 6, 48.0);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    for (double y = 0; y < size.height + cell; y += cell) {
      for (double x = 0; x < size.width + cell; x += cell) {
        final c = Offset(x, y);
        final r = cell * 0.36;
        canvas.drawPath(_square(c, r, 0), paint);
        canvas.drawPath(_square(c, r, math.pi / 4), paint);
        canvas.drawCircle(c, r * 0.42, paint);
      }
    }
  }

  Path _square(Offset c, double r, double rot) {
    final path = Path();
    for (var i = 0; i < 4; i++) {
      final a = rot + i * math.pi / 2 + math.pi / 4;
      final pt = c + Offset(math.cos(a) * r, math.sin(a) * r);
      i == 0 ? path.moveTo(pt.dx, pt.dy) : path.lineTo(pt.dx, pt.dy);
    }
    return path..close();
  }

  void _drawHills(Canvas canvas, Size size, Color color) {
    final h = size.height;
    final w = size.width;
    final back = Path()
      ..moveTo(0, h * 0.8)
      ..quadraticBezierTo(w * 0.25, h * 0.68, w * 0.55, h * 0.78)
      ..quadraticBezierTo(w * 0.8, h * 0.86, w, h * 0.74)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(back, Paint()..color = color.withValues(alpha: 0.55));
    final front = Path()
      ..moveTo(0, h * 0.9)
      ..quadraticBezierTo(w * 0.4, h * 0.8, w, h * 0.9)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(front, Paint()..color = color);
  }

  /// Simple mosque silhouette: central dome, two side domes, two minarets.
  void _drawMosque(Canvas canvas, Size size, Color color) {
    final w = size.width, h = size.height;
    final base = h * 0.86;
    final unit = math.min(w, h) * 0.11;
    final cx = w * 0.5;
    final paint = Paint()..color = color;
    final path = Path()
      ..addRect(Rect.fromLTRB(cx - unit * 2.6, base - unit * 1.1, cx + unit * 2.6, h))
      ..addOval(Rect.fromCenter(center: Offset(cx, base - unit * 1.1), width: unit * 2.4, height: unit * 2.6))
      ..addRect(Rect.fromLTRB(cx - unit * 0.08, base - unit * 3.0, cx + unit * 0.08, base - unit * 2.3))
      ..addOval(Rect.fromCenter(center: Offset(cx - unit * 1.9, base - unit * 1.1), width: unit * 1.2, height: unit * 1.3))
      ..addOval(Rect.fromCenter(center: Offset(cx + unit * 1.9, base - unit * 1.1), width: unit * 1.2, height: unit * 1.3));
    for (final dx in [-3.3, 3.3]) {
      final mx = cx + unit * dx;
      path
        ..addRect(Rect.fromLTRB(mx - unit * 0.22, base - unit * 3.6, mx + unit * 0.22, h))
        ..addRect(Rect.fromLTRB(mx - unit * 0.32, base - unit * 2.6, mx + unit * 0.32, base - unit * 2.45))
        ..moveTo(mx - unit * 0.22, base - unit * 3.6)
        ..lineTo(mx, base - unit * 4.3)
        ..lineTo(mx + unit * 0.22, base - unit * 3.6)
        ..close();
    }
    path.addRect(Rect.fromLTRB(0, base + unit * 0.2, w, h));
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(BuiltinWallpaperPainter old) => old.w.key != w.key;
}
