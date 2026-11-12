# Rumah Azan — Islamic Prayer & Lifestyle

Aplikasi Android (Flutter + Kotlin) untuk waktu solat JAKIM, azan dan bacaan
al-Quran/zikir berjadual, kalendar Hijrah, doa, tasbih, kiblat, serta **Mod
Paparan** skrin penuh untuk TV, TV Box dan tablet dinding. Antara muka utama
dalam Bahasa Melayu (English tersedia). Berfungsi luar talian.

Package: `com.rumahazan.app` · Flutter 3.50 · Android 7.0 (API 24) dan ke atas.

## Ciri-ciri utama

- **Waktu solat JAKIM e-Solat** (Subuh, Syuruk, Zohor, Asar, Maghrib, Isyak +
  Imsak) mengikut **zon rasmi** (60 zon, carian, negeri, cadangan GPS yang
  perlu disahkan pengguna). Data disimpan untuk setahun bagi kegunaan luar talian.
- **Tiada waktu rekaan:** jika tiada data disahkan, amaran jelas dipaparkan.
  Anggaran astronomi hanya dipaparkan dengan label "ANGGARAN", tidak disimpan,
  dan tidak digunakan untuk azan kecuali dibenarkan pengguna.
- **Kiraan detik langsung** dengan bar kemajuan, pertukaran tarikh tengah
  malam, dan sumber serta masa kemas kini terakhir.
- **Enjin audio berjadual** setiap waktu: **A.** bacaan sebelum waktu,
  **B.** azan penuh/pendek/pemberitahuan/senyap, **C.** zikir/bacaan selepas
  solat (lewat mula, tempoh maksimum, ulangan, kelantangan, senarai main).
  Satu enjin audio native: azan memintas bacaan, bacaan beratur, tiada
  pertindihan.
- **Pemberitahuan** setiap waktu, peringatan awal, getaran, peringatan zikir
  pagi/petang, peringatan peristiwa Islam, notis bacaan bermula; menghormati
  mod senyap dan Jangan Ganggu. Jadual dirancang **30 hari** ke hadapan.
- **Kalendar Hijrah** dengan 11 peristiwa penting; membezakan tarikh
  **takwim JAKIM**, **rasmi** (dimasukkan selepas pengumuman) dan **kiraan**;
  pelarasan ±2 hari.
- **Al-Quran, zikir & doa:** 32 teks (9 surah pendek, Ayat al-Kursi, zikir
  selepas solat/pagi/petang, selawat, doa harian) dengan Arab, Rumi, makna dan
  rujukan; kegemaran, carian, salin, kongsi. *Semua masih perlu semakan
  bertauliah.*
- **Pustaka audio:** import fail sendiri, muat turun HTTPS, senarai main,
  pemain penuh (main/jeda/henti/seterusnya/sebelum/ulang/rawak/kelantangan),
  tempoh audio dan sejarah main balik.
- **Wallpaper & tema:** 9 wallpaper Islamik dilukis secara vektor, import
  imej sendiri, bingkai (zum & kedudukan), kecerahan/lapisan gelap/kabur/muatan, pertukaran automatik
  pagi/tengah hari/petang/malam, 4 tema, saiz fon.
- **Mod Paparan (Smart Mosque/Home Display):** jam besar, tarikh, zon, kiraan
  detik besar, jadual penuh, panel pengumuman, tayangan slaid, penyelamat
  skrin, kawalan alat kawalan jauh TV, skrin kekal hidup *pilihan pengguna*,
  kembali automatik, buka terus ke Mod Paparan, kunci orientasi skrin.
- **Mod Tidur:** manual atau berjadual; gelap, Subuh seterusnya, kecerahan
  tetingkap aplikasi sahaja, senyapkan audio tidak penting.
- **Kiblat** (GPS/zon, kompas dengan pampasan kecondongan, ketepatan, kaedah
  manual), **tasbih digital** (sasaran, getaran, bunyi, sejarah, statistik
  7 hari).
- **Diagnostik:** kebenaran, penjadual, acara seterusnya, main balik/ralat
  terakhir, ujian kendiri, penggera ujian 15 saat, log.
- **Sandaran & pemulihan** JSON, pengurusan cache, privasi (tiada akaun, tiada
  pengumpulan data).

## Mula pantas

```bash
flutter pub get
```

```bash
flutter test
```

```bash
flutter build apk --debug
```

Butiran: [docs/BUILD.md](docs/BUILD.md).

## Dokumentasi

| Dokumen | Isi |
|---|---|
| [PROJECT_AUDIT.md](PROJECT_AUDIT.md) | Audit projek & status setiap modul |
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | Seni bina, pakej, integrasi Android, strategi penjadual, UI, pelan |
| [docs/PRAYER_DATA_SOURCE.md](docs/PRAYER_DATA_SOURCE.md) | Sumber data JAKIM, pengesahan, anggaran |
| [docs/DATABASE.md](docs/DATABASE.md) | Skema, migrasi, sandaran |
| [docs/CONTENT_VERIFICATION.md](docs/CONTENT_VERIFICATION.md) | Status semakan teks agama |
| [docs/ASSETS.md](docs/ASSETS.md) | Audio, wallpaper, fon & lesen |
| [docs/TESTING_REPORT.md](docs/TESTING_REPORT.md) | Keputusan ujian & matriks ujian peranti |
| [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) | Panduan penyelesaian masalah |

## Kebenaran Android

`INTERNET`, `POST_NOTIFICATIONS` (13+), `SCHEDULE_EXACT_ALARM` (12+, boleh
ditolak; aplikasi beralih ke penggera tidak tepat dan memaparkannya),
`RECEIVE_BOOT_COMPLETED`, `WAKE_LOCK`, `FOREGROUND_SERVICE` +
`FOREGROUND_SERVICE_MEDIA_PLAYBACK` (14+), `VIBRATE`, `ACCESS_COARSE_LOCATION`
(pilihan). Tiada `WRITE_SETTINGS` dan tiada
`REQUEST_IGNORE_BATTERY_OPTIMIZATIONS`.

## Known limitations

- **No APK was produced** in the development environment (no Android SDK; its
  download host was blocked). Build on a workstation; see docs/BUILD.md.
- **Android 6.0 (API 23) is not supported:** Flutter 3.50 requires API 24+.
- The **JAKIM endpoint was not reachable** from the development environment.
  The parser is tested against the documented shape and must be verified live.
  JAKIM publishes no formal API terms; confirm permission before a public release.
- Background behaviour (alarms when closed, reboot, Doze, OEM battery killers,
  TV boxes) is implemented but **not yet verified on devices**. See the matrix
  in docs/TESTING_REPORT.md. Exact timing cannot be guaranteed on every
  manufacturer's firmware.
- **No audio bundled** (no licensed recordings). Without an azan file the
  system notification sound is used.
- **Religious texts need qualified review** (all marked `perlu_semakan`). The
  Quran text is simplified spelling, not Rasm Uthmani; no full mushaf is
  included.
- Hijri dates beyond the cached JAKIM data are **calculated** (tabular) and may
  differ by ±1 day from official announcements until an official date is entered.
- Zone coordinates are approximate (GPS suggestion and estimate only).
- Image "crop" is zoom + focal-point framing (non-destructive), not a free-form crop tool.
- Background refresh uses JobScheduler (daily, when a network is available)
  and a headless Flutter engine. Android decides the exact run time and may
  defer it under battery restrictions. Alarms are planned 30 days ahead, so
  even without background runs the schedule lasts about a month (a
  notification warns 24 h before it runs out).

## English summary

Rumah Azan is an offline-first Flutter/Kotlin Android app for Malaysian
(JAKIM) prayer times, scheduled azan and Quran/zikr playback, a Hijri calendar
with official-vs-calculated labelling, a dua/zikr library, wallpapers and
themes, a TV/wall Display Mode, Sleep Mode, Qiblah and tasbih. It never shows
invented prayer times. Build status, test results and limitations are stated
above and in `docs/`.
