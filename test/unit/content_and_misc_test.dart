import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:rumah_azan/core/l10n/strings_en.dart';
import 'package:rumah_azan/core/l10n/strings_ms.dart';
import 'package:rumah_azan/data/models/app_settings.dart';
import 'package:rumah_azan/data/models/content_item.dart';
import 'package:rumah_azan/data/repositories/content_repository.dart';
import 'package:rumah_azan/features/location/zone_picker_screen.dart';
import 'package:rumah_azan/features/qiblah/qiblah_math.dart';
import 'package:rumah_azan/features/wallpaper/wallpaper_view.dart';

void main() {
  group('Content library integrity', () {
    final items = ContentRepository.parseContent(File('assets/data/content.json').readAsStringSync());

    test('every item has Arabic, meaning, reference and a known category', () {
      expect(items, isNotEmpty);
      final ids = <String>{};
      for (final i in items) {
        expect(ids.add(i.id), isTrue, reason: 'duplicate id ${i.id}');
        expect(i.arabicFull.trim(), isNotEmpty, reason: i.id);
        expect(i.meaningFull.trim(), isNotEmpty, reason: i.id);
        expect(i.reference.trim(), isNotEmpty, reason: i.id);
        expect(i.verification, isIn(['perlu_semakan', 'disahkan']));
        for (final c in i.categories) {
          expect(contentCategories, contains(c), reason: '${i.id}: $c');
        }
      }
    });

    test('required short surahs present with correct ayah counts', () {
      const expected = {
        'surah_1': 7, 'surah_112': 4, 'surah_113': 5, 'surah_114': 6, 'surah_103': 3,
        'surah_108': 3, 'surah_109': 6, 'surah_110': 3, 'surah_107': 7,
      };
      expected.forEach((id, n) {
        final s = items.firstWhere((i) => i.id == id);
        expect(s.ayat.length, n, reason: id);
        expect(s.ayat.map((a) => a.n).toList(), List.generate(n, (i) => i + 1), reason: id);
      });
    });

    test('every content category used by the brief has at least one item', () {
      for (final c in contentCategories) {
        expect(items.any((i) => i.categories.contains(c)), isTrue, reason: c);
      }
    });

    test('share text always carries the reference', () {
      expect(items.first.shareText('ms'), contains('Rujukan:'));
    });
  });

  group('Qiblah', () {
    test('bearing from Kuala Lumpur is about 292–293°', () {
      expect(qiblahBearing(3.139, 101.687), closeTo(292.6, 0.6));
    });

    test('azimuth: flat device pointing to magnetic north reads ~0°', () {
      // Device flat (gravity on +z), field pointing north (+y) and down (−z).
      final a = azimuthFrom(ax: 0, ay: 0, az: 9.81, ex: 0, ey: 30, ez: -30)!;
      expect(angleDiff(a, 0).abs(), lessThan(0.5));
      // Field pointing to device's −x  ⇒ top edge faces east (90°).
      final b = azimuthFrom(ax: 0, ay: 0, az: 9.81, ex: -30, ey: 0, ez: -30)!;
      expect(angleDiff(b, 90).abs(), lessThan(0.5));
      expect(azimuthFrom(ax: 0, ay: 0, az: 0, ex: 1, ey: 1, ez: 1), isNull);
    });

    test('compass quality reflects field strength and jitter', () {
      expect(qualityFromField(45, 2), CompassQuality.good);
      expect(qualityFromField(120, 2), CompassQuality.poor);
    });
  });

  group('Zones & GPS suggestion', () {
    test('nearest zone to Kluang town is JHR03; special zones never suggested', () {
      final n = nearestZones(2.03, 103.32);
      expect(n.first.$1.code, 'JHR03');
      expect(nearestZones(2.79, 104.17).any((z) => z.$1.code == 'PHG01'), isFalse);
    });
  });

  group('Wallpaper slots', () {
    test('time-based slot selection including before first slot', () {
      final s = AppSettings.initial();
      expect(currentSlot(s, 6 * 60), 'morning');
      expect(currentSlot(s, 12 * 60), 'afternoon');
      expect(currentSlot(s, 18 * 60), 'evening');
      expect(currentSlot(s, 21 * 60), 'night');
      expect(currentSlot(s, 2 * 60), 'night');
    });
  });

  group('Localisation', () {
    test('Malay and English tables have identical keys', () {
      expect(stringsEn.keys.toSet().difference(stringsMs.keys.toSet()), isEmpty);
      expect(stringsMs.keys.toSet().difference(stringsEn.keys.toSet()), isEmpty);
    });
  });
}
