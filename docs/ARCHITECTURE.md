# Rumah Azan — Technical plan & architecture

This document covers items A–I of the required development workflow. Item A
(existing project assessment) is in [../PROJECT_AUDIT.md](../PROJECT_AUDIT.md).

## B. Technical architecture

Feature-first layering with a shared data layer. UI never talks to SQLite,
HTTP or platform channels directly; it goes through Riverpod providers that
wrap repositories.

```
lib/
  main.dart                 open DB, load settings, ProviderScope
  app.dart                  theme/locale/font scale, lifecycle → resync, TV shortcuts
  core/
    constants/              app constants (package id, MYT offset, channel names)
    l10n/                   Bahasa Melayu (primary) + English tables, fallback to ms
    services/               NativeBridge (platform channel), AppController (sync + scheduling)
    theme/                  4 palettes + sleep palette
    utilities/myt_time.dart Malaysian time (fixed UTC+8), rollover, countdown
  data/
    local/database.dart     Drift schema (15 tables) + migration strategy
    models/                 PrayerDay, PrayerZone, AppSettings, PrayerAudioConfig, ContentItem
    remote/                 PrayerTimeProvider interface, JAKIM e-Solat, mirror, offline estimate
    repositories/           prayer, settings, audio, content, calendar, tasbih, wallpaper, backup, diagnostics
    providers/providers.dart Riverpod graph
    static/jakim_zones.dart bundled zone directory
  features/<feature>/       screens + pure domain logic (domain/ folders are unit-tested)
  shared/widgets/           GlassCard, WallpaperScaffold, ArabicText, CommitSlider …
android/app/src/main/kotlin/com/rumahazan/app/
  MainActivity.kt           MethodChannel + EventChannel, permissions, diagnostics, window flags
  Notifications.kt          channels and posting
  scheduler/                Scheduler (persistent plan, single chained alarm), AlarmReceiver, BootReceiver
  audio/PlaybackService.kt  foreground media service, focus, queue, priorities
```

Pure-Dart domain modules (prayer status, schedule planner, Hijri/calendar,
Qiblah maths, parsers) have no Flutter or I/O dependencies and are covered by
unit tests.

## C. Flutter package selection

All versions were resolved by `flutter pub get` against Flutter 3.50 / Dart 3.14.

| Package | Purpose | Why / compatibility notes |
|---|---|---|
| `material_ui` | Material widgets | Replaces the deprecated `package:flutter/material.dart` (Flutter ≥ 3.47). |
| `flutter_riverpod` 3.x | State management | Compile-safe DI, easy test overrides. |
| `drift` + `drift_flutter` | SQLite ORM, migrations | `sqlite3` 3.x bundles SQLite via build hooks; `sqlite3_flutter_libs` is end-of-life and was removed. |
| `http` | HTTPS client | Platform TLS validation is used; certificate checks are never disabled. |
| `path_provider`, `path` | App-private storage | |
| `file_picker` 13 | Import audio/images/backups | Handles `content://` results through streams. |
| `geolocator` | Optional GPS | Uses `forceLocationManager` so it works **without Google Play Services**. |
| `sensors_plus` | Magnetometer + accelerometer | The tilt-compensated heading is computed in Dart (no Play Services). |
| `share_plus` | Share doa / backup | |
| `intl` | (transitive, available) | Malay day/month names are in the l10n tables, so no async locale init is needed. |

Deliberately **not** used: `flutter_local_notifications`, `just_audio` /
`audio_service`, `android_alarm_manager_plus`, `wakelock_plus`. A single small
Kotlin layer covers alarms, notifications, playback and screen flags. That
avoids two audio engines that could overlap, and keeps background work minimal.

## D. Android native integration plan (implemented)

| Need | Mechanism |
|---|---|
| Exact azan time | `AlarmManager.setAlarmClock` when `canScheduleExactAlarms()`; otherwise `setAndAllowWhileIdle`, with the inexact mode shown in Diagnostics. |
| Android 12 exact-alarm restriction | `SCHEDULE_EXACT_ALARM`, plus a button that opens the system page; reacts to `SCHEDULE_EXACT_ALARM_PERMISSION_STATE_CHANGED`. |
| Android 13 notifications | Runtime `POST_NOTIFICATIONS` request (onboarding, Diagnostics). |
| Android 14 FGS | `foregroundServiceType="mediaPlayback"` + `FOREGROUND_SERVICE_MEDIA_PLAYBACK`. |
| Reboot / update / time / timezone | `BootReceiver` → `Scheduler.scheduleNext`. |
| Background audio | `PlaybackService` (foreground), `MediaPlayer` with partial wake mode. |
| Audio focus | `AudioFocusRequest` (API 26+) or the legacy API; ducking, transient pause, stop on permanent loss. |
| Silent / DND | Checks ringer mode and interruption filter; user option "respect silent mode" (default on); notification channels follow system DND. |
| TV | `LEANBACK_LAUNCHER`, banner, `touchscreen required=false`, D-pad `select`/`enter` → `ActivateIntent`. |
| Screen on | `FLAG_KEEP_SCREEN_ON`, only in Display/Sleep mode and only if the user enabled it. |
| Sleep dimming | `WindowManager.LayoutParams.screenBrightness` (this window only, no `WRITE_SETTINGS`). |
| Background refresh | `BackgroundSyncJob` (JobScheduler, daily, network required, persisted) starts a headless `FlutterEngine` running `backgroundSyncMain`, which reuses `AppController` (refresh-if-needed and re-plan). Scheduler methods are shared via `SharedChannel`. The UI and background isolates share one SQLite connection (`shareAcrossIsolates`). |
| Battery optimisation | Opens the system list (`ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS`); the restricted `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` permission is not requested. |

## E. Database design

See [DATABASE.md](DATABASE.md).

## F. Prayer time data-source strategy

See [PRAYER_DATA_SOURCE.md](PRAYER_DATA_SOURCE.md). In short: JAKIM e-Solat
(year, falling back to month) → validated → cached in SQLite → displayed with
its source and last-update time. When no verified data exists, the app shows a
clear warning, optionally with a labelled astronomical estimate that is never
stored and is not used for alarms unless the user allows it.

## G. Audio scheduling strategy

1. **Plan (Dart, pure):** `SchedulePlanner` turns the next 30 days of verified
   timetable plus the per-prayer config into events (`reminder`, `before`,
   `azan`, `after`), with deterministic ids `yyyy-MM-dd_<prayer>_<kind>`.
   - Before-recitation stops 5 s before the azan (`maxDurationMs`).
   - After-recitation is clipped to end at least 1 min before the next
     prayer's content.
   - Past events are skipped. Estimated days are skipped unless allowed.
   - The sleep window suppresses before/after recitation, never the azan.
   - Automatic audio off → azan becomes a notification with sound.
   - No azan file → the default notification sound is used (never silent failure).
   - `info` events: daily morning/evening zikr reminders and Islamic event
     notices (calculated dates flagged), notification only.
2. **Store & arm (Kotlin):** `Scheduler.sync` replaces the stored list
   (idempotent, de-duplicated) and arms **one** alarm for the earliest pending
   event.
3. **Fire:** `AlarmReceiver` handles every due event (azan first), skips
   audio that is stale beyond `graceMs`, respects silent/DND, starts
   `PlaybackService`, posts notifications, records history, arms the next
   alarm, and warns once a day when fewer than 24 h of events remain.
4. **Play:** `PlaybackService` runs one session at a time. A higher priority
   (azan) interrupts; equal/lower priority is queued, so audio never overlaps.
5. **Re-plan** on start-up, resume, date rollover, zone/provider/config
   change, language change, restore, and the daily background job.
6. **Stale queue protection:** a queued scheduled session that waited more
   than 10 min (or past its window) is skipped and recorded; a late start
   keeps its original end boundary.

## H. UI/UX plan

- *Premium Islamic Modern*: translucent "glass" cards over a time-of-day
  wallpaper; 4 palettes (Emerald Gold, Minimalist Cream, Ocean Blue, Sunset)
  plus a very dark Sleep palette.
- Dashboard order: header (logo, zone, Display, Settings) → date + Hijri +
  event → data warnings → next prayer with countdown and progress → six times
  (Syuruk de-emphasised) → audio → quick access → upcoming events → source and
  sync footer. Two columns at ≥ 900 px (tablet/TV).
- Accessibility: font scale 80–160 %, tabular figures for clocks, RTL Arabic
  with line height 1.9, visible focus colour for TV remotes.
- Wallpapers are drawn in code (8-point star lattice, crescent and stars,
  mosque silhouette, sunrise/sunset hills), so they carry no licensing risk
  and scale to 4K.

## I. Roadmap & status

| Phase | Scope | Status |
|---|---|---|
| 0 | Audit | Done. |
| 1 | Dashboard, prayer engine, location, JAKIM integration, countdown, dates | Done (live endpoint to be verified on a networked machine). |
| 2 | Hijri calendar, events, doa, Quran, zikir | Done; content needs qualified review. |
| 3 | Player, azan, before/after, scheduler, background, diagnostics | Done in code; **needs on-device verification**. |
| 4 | Wallpapers, themes, auto day/night, user images, font size | Done (no crop tool). |
| 5 | Display/TV mode, remote, landscape, Sleep Mode | Done; needs a TV remote test. |
| 6 | Qiblah, tasbih, reminders, statistics | Done. |
| 7 | Tests, docs, APK | Tests and docs done; **APK not built (no Android SDK here)**. |
