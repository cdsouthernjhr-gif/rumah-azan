import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:path/path.dart' as p;

/// A short sine-wave WAV (16-bit PCM mono) used by Diagnostics → "Uji bunyi"
/// to test the real audio player without bundling any recording.
Uint8List buildTestToneWav({
  int sampleRate = 44100,
  double seconds = 1.5,
  double frequency = 660,
  double amplitude = 0.6,
}) {
  final samples = (sampleRate * seconds).round();
  final data = ByteData(44 + samples * 2);
  void ascii(int offset, String s) {
    for (var i = 0; i < s.length; i++) {
      data.setUint8(offset + i, s.codeUnitAt(i));
    }
  }

  ascii(0, 'RIFF');
  data.setUint32(4, 36 + samples * 2, Endian.little);
  ascii(8, 'WAVE');
  ascii(12, 'fmt ');
  data.setUint32(16, 16, Endian.little); // PCM chunk size
  data.setUint16(20, 1, Endian.little); // PCM
  data.setUint16(22, 1, Endian.little); // mono
  data.setUint32(24, sampleRate, Endian.little);
  data.setUint32(28, sampleRate * 2, Endian.little); // byte rate
  data.setUint16(32, 2, Endian.little); // block align
  data.setUint16(34, 16, Endian.little); // bits per sample
  ascii(36, 'data');
  data.setUint32(40, samples * 2, Endian.little);
  final fade = (sampleRate * 0.05).round(); // 50 ms fade in/out: no clicks
  for (var i = 0; i < samples; i++) {
    final env = math.min(1.0, math.min(i, samples - 1 - i) / fade);
    final v = math.sin(2 * math.pi * frequency * i / sampleRate) * amplitude * env;
    data.setInt16(44 + i * 2, (v * 32767).round(), Endian.little);
  }
  return data.buffer.asUint8List();
}

/// Writes the test tone into [dir] (once) and returns its path.
Future<String> ensureTestToneFile(Directory dir) async {
  if (!await dir.exists()) await dir.create(recursive: true);
  final f = File(p.join(dir.path, 'rumah_azan_test_tone.wav'));
  if (!await f.exists()) await f.writeAsBytes(buildTestToneWav(), flush: true);
  return f.path;
}
