import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:rumah_azan/core/utilities/test_tone.dart';
import 'package:rumah_azan/features/diagnostics/sound_test_screen.dart';

Map<String, Object?> healthy() => {
      'ringerMode': 'normal',
      'dnd': false,
      'notificationsEnabled': true,
      'exactAlarmAllowed': true,
      'respectSilent': true,
      'music': {'cur': 8, 'max': 15},
      'alarm': {'cur': 6, 'max': 7},
      'notification': {'cur': 5, 'max': 15},
      'channels': {
        'prayer_alert': {'importance': 4, 'hasSound': true},
      },
    };

List<String> keys(Map<String, Object?> s) => analyseSound(s).map((i) => i.key).toList();

void main() {
  test('healthy phone → no issues; no native layer → nothing to report', () {
    expect(keys(healthy()), isEmpty);
    expect(keys(const {}), isEmpty);
  });

  test('each silencing cause is detected', () {
    expect(keys({...healthy(), 'notificationsEnabled': false}), ['notif_off']);
    expect(keys({...healthy(), 'exactAlarmAllowed': false}), ['exact_off']);
    expect(keys({...healthy(), 'channels': {'prayer_alert': {'importance': 0, 'hasSound': true}}}), ['channel_blocked']);
    expect(keys({...healthy(), 'channels': {'prayer_alert': {'importance': 4, 'hasSound': false}}}), ['channel_silent']);
    expect(keys({...healthy(), 'alarm': {'cur': 0, 'max': 7}}), ['alarm_vol0']);
    expect(keys({...healthy(), 'music': {'cur': 0, 'max': 15}}), ['music_vol0']);
    expect(keys({...healthy(), 'notification': {'cur': 0, 'max': 15}}), ['notif_vol0']);
    expect(keys({...healthy(), 'dnd': true}), ['dnd']);
  });

  test('vibrate mode blocks automatic audio only while "respect silent" is on', () {
    final on = analyseSound({...healthy(), 'ringerMode': 'vibrate'}).single;
    expect(on.key, 'ringer_silent');
    expect(on.blocking, isTrue);
    expect(on.args['mode'], 'vibrate');
    final off = analyseSound({...healthy(), 'ringerMode': 'vibrate', 'respectSilent': false}).single;
    expect(off.key, 'ringer_ignored');
    expect(off.blocking, isFalse);
  });

  test('test tone is a valid 16-bit mono PCM WAV with fades', () {
    final wav = buildTestToneWav(sampleRate: 8000, seconds: 0.5);
    final d = ByteData.sublistView(wav);
    String tag(int o) => String.fromCharCodes(wav.sublist(o, o + 4));
    expect(tag(0), 'RIFF');
    expect(tag(8), 'WAVE');
    expect(tag(36), 'data');
    expect(d.getUint16(20, Endian.little), 1); // PCM
    expect(d.getUint16(22, Endian.little), 1); // mono
    expect(d.getUint32(24, Endian.little), 8000);
    expect(d.getUint16(34, Endian.little), 16);
    expect(d.getUint32(40, Endian.little), 4000 * 2);
    expect(wav.length, 44 + 4000 * 2);
    expect(d.getInt16(44, Endian.little), 0, reason: 'starts silent (fade-in)');
    var peak = 0;
    for (var i = 0; i < 4000; i++) {
      peak = d.getInt16(44 + i * 2, Endian.little).abs() > peak ? d.getInt16(44 + i * 2, Endian.little).abs() : peak;
    }
    expect(peak, greaterThan(15000), reason: 'audible amplitude');
  });
}
