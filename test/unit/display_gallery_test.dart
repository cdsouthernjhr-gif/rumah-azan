import 'package:flutter_test/flutter_test.dart';
import 'package:rumah_azan/data/models/app_settings.dart';
import 'package:rumah_azan/features/smart_display/display_gallery.dart';

void main() {
  test('6 images → 4 hours each, from 00:00', () {
    expect(galleryIndexAt(6, 0), 0);
    expect(galleryIndexAt(6, 4 * 60 - 1), 0);
    expect(galleryIndexAt(6, 4 * 60), 1);
    expect(galleryIndexAt(6, 12 * 60), 3);
    expect(galleryIndexAt(6, 23 * 60 + 59), 5);
    expect(gallerySlots(6).map((s) => '${formatSlotMinute(s.$1)}-${formatSlotMinute(s.$2)}').toList(),
        ['00:00-04:00', '04:00-08:00', '08:00-12:00', '12:00-16:00', '16:00-20:00', '20:00-24:00']);
    expect(slotLength(6), (4, 0));
  });

  test('any count: every minute maps to exactly the slot that contains it', () {
    for (final n in [1, 2, 3, 5, 7, 11, 13, 24, 50]) {
      final slots = gallerySlots(n);
      expect(slots.first.$1, 0);
      expect(slots.last.$2, minutesPerDay);
      for (var m = 0; m < minutesPerDay; m++) {
        final i = galleryIndexAt(n, m);
        expect(m >= slots[i].$1 && m < slots[i].$2, isTrue, reason: 'n=$n m=$m i=$i');
      }
    }
    expect(slotLength(7), (3, 25));
    expect(galleryIndexAt(0, 100), -1);
  });

  test('deleted custom images and unknown built-ins are dropped; duplicates removed', () {
    expect(
      validGallery(['builtin:night_crescent', 'custom:3', 'custom:9', 'builtin:nope', 'custom:3'], {3}),
      ['builtin:night_crescent', 'custom:3'],
    );
  });

  test('settings: gallery list and rotation, with legacy slideshow mapping', () {
    expect(AppSettings.initial().displayRotation, 'off');
    expect(AppSettings.initial().displayGallery, isEmpty);
    expect(AppSettings.initial().copyWith({'slideshow': true}).displayRotation, 'interval');
    final s = AppSettings.initial().copyWith({
      'displayRotation': 'day',
      'displayGallery': ['builtin:night_crescent', 7],
    });
    expect(s.displayRotation, 'day');
    expect(s.displayGallery, ['builtin:night_crescent']);
    expect(parseRotation('day'), GalleryRotation.day);
    expect(parseRotation('bogus'), GalleryRotation.off);
  });
}
