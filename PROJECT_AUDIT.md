# PROJECT_AUDIT.md — Rumah Azan

Audit date: 2026-11-12 · Branch: `claude/upbeat-cori-hwj8n6`

## 1. Phase 0 — State of the workspace before development

| Item inspected | Finding |
|---|---|
| Git history | Repository initialised with **no commits** and **no files**. |
| Flutter project structure / Dart sources | None. |
| `pubspec.yaml`, dependencies, assets | None. |
| Android native config / Gradle | None. |
| Database, API integration, notifications, audio, prayer calculation | None. |
| Existing errors/warnings | None (nothing to analyse). |
| Flutter SDK on the machine | **Not installed.** Installed Flutter **3.50.0 stable** (Dart 3.14.0). |
| Android SDK | **Not installed and not installable here**: `dl.google.com` (SDK, platforms, build-tools; `maven.google.com` redirects there) is blocked by the environment's network policy. |
| JAKIM e-Solat / community mirror | `www.e-solat.gov.my` and `api.waktusolat.app` are **blocked** from this environment, so live responses could not be verified here. |

Because nothing existed, there was no working code to preserve, no duplicate
implementation to avoid and no broken module to repair. Every module was built
new, following the architecture in [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).

### About "Target of URI doesn't exist: package:flutter/material.dart"

Investigated as the brief requested:

- The usual causes are running `flutter analyze` outside the project folder, a
  missing `pubspec.yaml`, or `flutter pub get` not completed (no
  `.dart_tool/package_config.json`).
- **New in Flutter ≥ 3.47:** Material moved into the separate
  `material_ui` package. `package:flutter/material.dart` still exists but is
  **deprecated**, and the `flutter create` template now imports
  `package:material_ui/material_ui.dart`. This project uses `material_ui`
  (declared in `pubspec.yaml`). If an IDE still reports the error, run
  `flutter pub get` in the project root and make sure the IDE uses the same
  Flutter SDK (3.50.x).

### Android 6.0 (API 23) feasibility

The brief asks for API 23 "where feasible". **It is not feasible with a
current Flutter:** Flutter 3.50's engine and Gradle plugin set
`minSdkVersion = 24` (verified in
`packages/flutter_tools/gradle/src/main/kotlin/FlutterExtension.kt`).
The app therefore targets **Android 7.0 (API 24) and newer**. API 23 would
require pinning an old Flutter release (≤ 3.22), which would lose current
security and compatibility fixes, so it is not recommended.

## 2. Module classification (after this development round)

Legend: **A** working correctly (verified by tests) · **B** partially
implemented · **C** not implemented · **D** broken · **E** works but needs
improvement / on-device verification.

| Module | Status | Notes |
|---|---|---|
| Project structure, Riverpod state, routing | A | `flutter analyze`: no issues. |
| Malaysian time handling (fixed UTC+8, rollover) | A | Unit-tested. |
| JAKIM zone directory (60 zones), search, state filter | A/E | Codes bundled; must be re-checked against the portal before each release. |
| GPS zone *suggestion* (user confirms) | E | Uses approximate town coordinates; special zones excluded. Needs device test. |
| JAKIM e-Solat provider (year → month fallback, validation) | E | Parser unit-tested against documented response shape; **live endpoint not reachable from this environment**. |
| Community mirror provider (optional) | E | Same as above. |
| Offline astronomical estimate (labelled, opt-in for alarms) | A | Unit-tested for plausibility; never stored as data. |
| Prayer status / countdown engine | A | Midnight, before-Subuh, after-Isyak and missing-data cases tested. |
| Dashboard (date, Hijri, events, next prayer, six times, audio, quick access) | A | Widget-tested (ms/en, warnings, estimate label). |
| Monthly timetable screen | A | Verified data only. |
| Hijri calendar (JAKIM Hijri → official override → calculation ±2) | A | Unit-tested; calculated dates are labelled. |
| Islamic events (11 events, official-date entry) | A | Unit-tested. |
| Quran / zikr / doa library (search, favourites, copy, share) | B | Structure complete; **32 texts included, all marked `perlu_semakan` (needs review)**. Full mushaf not bundled. |
| Audio library (import, HTTPS download manager, playlists) | E | No audio bundled (no licensed recordings available). Needs device test. |
| Native audio engine (foreground service, focus, queue, priority) | E | Kotlin type-checks against the Android framework; **not run on a device**. |
| Audio scheduler planner (before/at/after, overlap, duplicates, sleep) | A | Unit-tested. |
| Native AlarmManager scheduler, boot/time/tz/update receivers | E | Kotlin type-checks; needs on-device verification (see the test matrix). |
| Notifications (channels, per-prayer, reminder, silent, DND) | E | Implemented natively; needs device test. |
| Wallpapers (9 procedural built-ins, import, brightness/overlay/blur, fit, time slots) | A/E | Crop is not implemented (fit/fill only). |
| Themes (4) + automatic theme by time slot + font scale | A | |
| Smart Display / TV mode (D-pad, screensaver, slideshow, keep-screen-on opt-in, auto-return) | A/E | Widget-tested at 1280×720; needs a real TV remote test. |
| Sleep Mode (manual/scheduled, window brightness only, Subuh countdown) | A | Widget-tested. |
| Qiblah (bearing, tilt-compensated compass, accuracy, manual fallback) | A/E | Maths unit-tested; sensor behaviour needs a device. |
| Digital tasbih (targets, vibration, sound, history, 7-day stats, resume) | A | Widget-tested. |
| Settings, backup/restore (with ID remapping), cache management | A | Backup round-trip unit-tested. |
| Diagnostics (system, permissions, scheduler, last playback/error, self-test, test alarm, log) | E | Native values need a device. |
| Database (15 tables, indexes, FKs, migration hook) | A | Unit-tested in-memory. |
| Localisation (Bahasa Melayu primary, English) | A | Key parity unit-tested. |
| Integration tests | B | Written (`integration_test/`), **not executed** (no device). |
| Debug / release APK | C | **Not built**: no Android SDK in this environment. |

## 3. Integration strategy for future work

1. Build on a workstation with Android Studio + SDK (see [docs/BUILD.md](docs/BUILD.md)).
2. Verify the JAKIM endpoint live, then run the on-device matrix in
   [docs/TESTING_REPORT.md](docs/TESTING_REPORT.md).
3. Have a qualified reviewer verify all religious texts
   ([docs/CONTENT_VERIFICATION.md](docs/CONTENT_VERIFICATION.md)) and flip
   `verification` to `disahkan`.
4. Add licensed audio and (optionally) photographic wallpapers per
   [docs/ASSETS.md](docs/ASSETS.md).
