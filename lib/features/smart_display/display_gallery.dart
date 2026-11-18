import '../../core/utilities/myt_time.dart';
import '../wallpaper/builtin_wallpapers.dart';

/// How the Display Mode background changes.
enum GalleryRotation {
  /// Follow the normal (time-slot or fixed) wallpaper.
  off,

  /// The day (24 h) is split evenly between the gallery images:
  /// N images → each shown for 24/N hours, starting at 00:00.
  day,

  /// Cycle through the gallery every N seconds.
  interval,
}

GalleryRotation parseRotation(String? s) =>
    GalleryRotation.values.firstWhere((r) => r.name == s, orElse: () => GalleryRotation.off);

const minutesPerDay = 24 * 60;

/// Index of the image shown at [minuteOfDay] when [count] images share the
/// day evenly. Returns -1 for an empty gallery.
int galleryIndexAt(int count, int minuteOfDay) {
  if (count <= 0) return -1;
  final m = minuteOfDay.clamp(0, minutesPerDay - 1);
  return (m * count ~/ minutesPerDay).clamp(0, count - 1);
}

/// Start minute of image [index] (inclusive) — consistent with
/// [galleryIndexAt] even when 1440 is not divisible by [count].
int galleryStartMinute(int count, int index) => (index * minutesPerDay + count - 1) ~/ count;

/// (start, end) wall-clock minutes for each image; end of the last is 24:00.
List<(int, int)> gallerySlots(int count) => [
      for (var i = 0; i < count; i++)
        (galleryStartMinute(count, i), i == count - 1 ? minutesPerDay : galleryStartMinute(count, i + 1)),
    ];

/// "HH:mm" with 24:00 for the end of the day.
String formatSlotMinute(int m) => m >= minutesPerDay ? '24:00' : Myt.formatHm(m);

/// Human duration per image, e.g. 6 images → (4, 0); 7 → (3, 25).
(int, int) slotLength(int count) {
  if (count <= 0) return (0, 0);
  final mins = minutesPerDay ~/ count;
  return (mins ~/ 60, mins % 60);
}

/// Keeps only references that still exist (deleted custom images and unknown
/// built-ins are dropped) and removes duplicates, preserving order.
List<String> validGallery(List<String> refs, Set<int> customIds) {
  final seen = <String>{};
  return [
    for (final r in refs)
      if (seen.add(r) &&
          ((r.startsWith('builtin:') && builtinByKey(r.substring(8)) != null) ||
              (r.startsWith('custom:') && customIds.contains(int.tryParse(r.substring(7))))))
        r,
  ];
}
