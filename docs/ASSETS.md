# Assets & licensing

## Audio — none bundled

No Quran recitation, azan or zikr recordings are shipped, because no
recordings with a verified licence were available. The rule is: do not use
unlicensed Quranic audio. Users can:

- **Import** their own files (*Audio → +*), stored privately in the app; or
- **Download** over HTTPS (*Audio → download*). Only download from sources
  whose licence permits it; the source host is kept with the file.

To bundle audio later, place licensed files in `assets/audio/{azan,quran,zikr,doa}/`,
add the folders to `pubspec.yaml`, record the licence in this file, and seed
`audio_library` rows on first run. When no azan file is chosen, the app falls
back to the **system notification sound**, so prayer alerts never fail silently.

## Wallpapers

The nine built-in wallpapers are **drawn in code**
(`lib/features/wallpaper/builtin_wallpapers.dart`): gradients, an 8-point star
lattice, crescent and stars, a mosque silhouette, sunrise/sunset hills. They
need no image licence and cost no APK space. Photographic wallpapers may be
added to `assets/images/wallpapers/<slot>/` with a recorded licence (compress
to ≤ 1920 px, WebP/JPEG). User images are decoded at screen resolution to save
memory on TV boxes.

## Fonts

Arabic uses the Android system Arabic font (Noto Naskh Arabic on most devices)
with RTL direction and correct shaping. An OFL font (e.g. Amiri or
Scheherazade New) can be added to `assets/fonts/` and declared in `pubspec.yaml`.

## Icons

`android/app/src/main/res/drawable/ic_stat_azan.xml` (notification) and
`tv_banner.xml` (Android TV) are original vector drawables. The launcher icon
is original: an adaptive vector icon (`mipmap-anydpi-v26`, Android 8+) and
PNGs for Android 7.x, both an emerald tile with a gold crescent and star.
