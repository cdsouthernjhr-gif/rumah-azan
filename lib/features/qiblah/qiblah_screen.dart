import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../../core/l10n/l10n.dart';
import '../../data/providers/providers.dart';
import '../../data/static/jakim_zones.dart';
import '../../shared/widgets/common.dart';
import 'qiblah_math.dart';

class QiblahScreen extends ConsumerStatefulWidget {
  const QiblahScreen({super.key});
  @override
  ConsumerState<QiblahScreen> createState() => _QiblahScreenState();
}

class _QiblahScreenState extends ConsumerState<QiblahScreen> {
  StreamSubscription<AccelerometerEvent>? _accSub;
  StreamSubscription<MagnetometerEvent>? _magSub;
  List<double>? _acc;
  List<double>? _mag;
  double? _heading;
  final _recent = <double>[];
  bool _sensorError = false;
  double? _lat, _lng;
  String _locSource = 'zone';

  @override
  void initState() {
    super.initState();
    final z = zoneByCode(ref.read(settingsProvider).zoneCode);
    _lat = z?.lat;
    _lng = z?.lng;
    _accSub = accelerometerEventStream(samplingPeriod: SensorInterval.uiInterval).listen(
      (e) => _acc = [e.x, e.y, e.z],
      onError: (_) => setState(() => _sensorError = true),
      cancelOnError: true,
    );
    _magSub = magnetometerEventStream(samplingPeriod: SensorInterval.uiInterval).listen(
      (e) {
        _mag = [e.x, e.y, e.z];
        _update();
      },
      onError: (_) => setState(() => _sensorError = true),
      cancelOnError: true,
    );
  }

  void _update() {
    final a = _acc, m = _mag;
    if (a == null || m == null) return;
    final h = azimuthFrom(ax: a[0], ay: a[1], az: a[2], ex: m[0], ey: m[1], ez: m[2]);
    if (h == null) return;
    // Low-pass filter on the circle to reduce jitter.
    final prev = _heading;
    final next = prev == null ? h : (prev + angleDiff(h, prev) * 0.15 + 360) % 360;
    _recent.add(h);
    if (_recent.length > 20) _recent.removeAt(0);
    if (mounted) setState(() => _heading = next);
  }

  double get _jitter {
    if (_recent.length < 5 || _heading == null) return 99;
    final diffs = _recent.map((v) => angleDiff(v, _heading!).abs()).toList();
    return diffs.reduce((a, b) => a + b) / diffs.length;
  }

  double get _field {
    final m = _mag;
    if (m == null) return 0;
    return math.sqrt(m[0] * m[0] + m[1] * m[1] + m[2] * m[2]);
  }

  Future<void> _useGps() async {
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
        if (mounted) showSnack(context, context.tr('gps_denied'));
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: AndroidSettings(accuracy: LocationAccuracy.medium, forceLocationManager: true, timeLimit: const Duration(seconds: 30)),
      );
      setState(() {
        _lat = pos.latitude;
        _lng = pos.longitude;
        _locSource = 'gps';
      });
    } catch (e) {
      if (mounted) showSnack(context, '${context.tr('gps_failed')}: $e');
    }
  }

  @override
  void dispose() {
    _accSub?.cancel();
    _magSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final bearing = (_lat != null && _lng != null) ? qiblahBearing(_lat!, _lng!) : null;
    final hasCompass = !_sensorError && _heading != null;
    final quality = hasCompass ? qualityFromField(_field, _jitter) : CompassQuality.poor;
    final rel = (bearing != null && _heading != null) ? angleDiff(bearing, _heading!) : null;
    final aligned = rel != null && rel.abs() < 3 && quality != CompassQuality.poor;

    return PlainScaffold(
      title: context.tr('qiblah'),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        if (bearing == null)
          WarningBanner(text: context.tr('qiblah_no_location'))
        else
          Text(
            context.tr('qiblah_bearing', {'deg': bearing.toStringAsFixed(1)}),
            textAlign: TextAlign.center,
            style: tt.headlineSmall,
          ),
        Text(
          context.tr(_locSource == 'gps' ? 'qiblah_loc_gps' : 'qiblah_loc_zone'),
          textAlign: TextAlign.center,
          style: tt.bodySmall,
        ),
        const SizedBox(height: 16),
        AspectRatio(
          aspectRatio: 1,
          child: hasCompass && bearing != null
              ? CustomPaint(painter: _CompassPainter(heading: _heading!, qiblah: bearing, color: cs.onSurface, accent: aligned ? Colors.greenAccent : cs.secondary))
              : Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.explore_off_rounded, size: 72),
                    const SizedBox(height: 8),
                    Text(context.tr(_sensorError ? 'compass_unavailable' : 'compass_waiting'), textAlign: TextAlign.center),
                  ]),
                ),
        ),
        const SizedBox(height: 12),
        if (hasCompass)
          Chip(
            avatar: Icon(Icons.sensors, color: switch (quality) {
              CompassQuality.good => Colors.green,
              CompassQuality.fair => Colors.orange,
              CompassQuality.poor => Colors.red,
            }),
            label: Text('${context.tr('sensor_accuracy')}: ${context.tr('quality_${quality.name}')} (${_field.toStringAsFixed(0)} µT)'),
          ),
        if (quality == CompassQuality.poor && hasCompass) WarningBanner(text: context.tr('compass_poor')),
        const SizedBox(height: 8),
        OutlinedButton.icon(icon: const Icon(Icons.my_location), label: Text(context.tr('use_gps')), onPressed: _useGps),
        const SizedBox(height: 16),
        Text(context.tr('calibration_title'), style: tt.titleSmall),
        Text(context.tr('calibration_body')),
        const SizedBox(height: 12),
        Text(context.tr('qiblah_manual_title'), style: tt.titleSmall),
        Text(context.tr('qiblah_manual_body', {'deg': bearing?.toStringAsFixed(0) ?? '-'})),
      ]),
    );
  }
}

class _CompassPainter extends CustomPainter {
  _CompassPainter({required this.heading, required this.qiblah, required this.color, required this.accent});
  final double heading;
  final double qiblah;
  final Color color;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2 - 8;
    final ring = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(c, r, ring);
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(-heading * math.pi / 180); // dial rotates so N points north
    for (var i = 0; i < 360; i += 15) {
      final a = i * math.pi / 180;
      final len = i % 90 == 0 ? 18.0 : 8.0;
      final p1 = Offset(math.sin(a) * r, -math.cos(a) * r);
      final p2 = Offset(math.sin(a) * (r - len), -math.cos(a) * (r - len));
      canvas.drawLine(p1, p2, ring);
    }
    final tp = TextPainter(
      text: TextSpan(text: 'U', style: TextStyle(color: Colors.redAccent, fontSize: 22, fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(-tp.width / 2, -r + 22));
    // Qiblah needle
    final qa = qiblah * math.pi / 180;
    final tip = Offset(math.sin(qa) * (r - 30), -math.cos(qa) * (r - 30));
    canvas.drawLine(Offset.zero, tip, Paint()
      ..color = accent
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round);
    canvas.drawRect(Rect.fromCenter(center: tip, width: 26, height: 26), Paint()..color = accent);
    canvas.restore();
    // Fixed device-direction marker at top.
    final path = Path()
      ..moveTo(c.dx, c.dy - r - 4)
      ..lineTo(c.dx - 10, c.dy - r + 14)
      ..lineTo(c.dx + 10, c.dy - r + 14)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_CompassPainter old) => old.heading != heading || old.qiblah != qiblah || old.accent != accent;
}
