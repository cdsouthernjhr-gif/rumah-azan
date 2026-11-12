import 'dart:math' as math;

import '../../core/constants/app_constants.dart';

double _rad(double d) => d * math.pi / 180;
double _deg(double r) => r * 180 / math.pi;

/// Initial great-circle bearing (degrees from TRUE north, 0..360) from the
/// given point to the Kaabah.
double qiblahBearing(double lat, double lng) {
  final phi = _rad(lat);
  final phiK = _rad(AppConstants.kaabahLat);
  final dLng = _rad(AppConstants.kaabahLng - lng);
  final y = math.sin(dLng) * math.cos(phiK);
  final x = math.cos(phi) * math.sin(phiK) - math.sin(phi) * math.cos(phiK) * math.cos(dLng);
  return (_deg(math.atan2(y, x)) + 360) % 360;
}

/// Device azimuth (degrees from magnetic north, 0..360) of the top edge of the
/// device, tilt-compensated using gravity. Mirrors Android's
/// SensorManager.getRotationMatrix + getOrientation. Returns null when the
/// readings are degenerate (free fall, no magnetic field).
double? azimuthFrom({
  required double ax,
  required double ay,
  required double az,
  required double ex,
  required double ey,
  required double ez,
}) {
  var hx = ey * az - ez * ay;
  var hy = ez * ax - ex * az;
  var hz = ex * ay - ey * ax;
  final normH = math.sqrt(hx * hx + hy * hy + hz * hz);
  final normA = math.sqrt(ax * ax + ay * ay + az * az);
  if (normH < 0.1 || normA < 0.1) return null;
  hx /= normH;
  hy /= normH;
  hz /= normH;
  final nax = ax / normA, naz = az / normA;
  final my = naz * hx - nax * hz;
  final az2 = math.atan2(hy, my);
  return (_deg(az2) + 360) % 360;
}

/// Rough compass reliability from the magnetic field magnitude (µT). Earth's
/// field is ~25–65 µT; values far outside indicate interference.
enum CompassQuality { good, fair, poor }

CompassQuality qualityFromField(double magnitudeMicroTesla, double headingJitterDeg) {
  final fieldOk = magnitudeMicroTesla >= 25 && magnitudeMicroTesla <= 65;
  if (fieldOk && headingJitterDeg < 4) return CompassQuality.good;
  if (magnitudeMicroTesla >= 15 && magnitudeMicroTesla <= 80 && headingJitterDeg < 12) return CompassQuality.fair;
  return CompassQuality.poor;
}

/// Smallest signed angle difference a−b in degrees (−180..180).
double angleDiff(double a, double b) => ((a - b + 540) % 360) - 180;
