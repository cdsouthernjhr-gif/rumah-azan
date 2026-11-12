# Testing report

Environment: Linux container, Flutter 3.50.0 / Dart 3.14.0, no Android SDK, no
device, no access to the JAKIM host.

## Executed

| Command | Result |
|---|---|
| `flutter analyze` | **No issues found** |
| `flutter test` | **63 tests passed, 0 failed** |
| Kotlin type-check (kotlinc 2.4.20 vs Android framework + Flutter embedding) | **0 errors**; all 15 classes compiled |
| `flutter build apk --debug` | **Not possible**: "No Android SDK found" (SDK download host blocked) |

### What the automated tests cover (`test/`)

- **Time & countdown:** MYT date independent of device timezone, month/year/
  leap rollover, non-negative countdown, sleep windows across midnight,
  current/next prayer before Subuh / mid-day / exactly at a prayer time /
  after Isyak, unknown when tomorrow's data is missing, Syuruk not obligatory.
- **Prayer retrieval:** e-Solat parser (valid days, Malay month abbreviations,
  dropping inconsistent/incomplete days, zone mismatch, error status, URL),
  year→month fallback and network failure (mocked HTTP), mirror parser,
  offline estimate plausibility and labelling.
- **Hijri & events:** round-trip, ±1 day of known Malaysian dates, user
  adjustment, JAKIM Hijri preferred, Tasyrik multi-day, official override.
- **Audio scheduling:** deterministic ids, no duplicates, idempotent
  re-planning, before ends before azan, after clipped before the next
  content, past events skipped (missed transitions), estimates opt-in,
  automatic audio off, no azan file → sound fallback, silent mode, sleep
  window, config clamping.
- **Database:** schema creation (migration v1), zone seeding, idempotent
  upsert, estimates never persisted, verified→estimate→null resolution,
  settings/config persistence, backup round-trip with id remapping, invalid
  backup rejected, tasbih aggregation, bounded diagnostics log.
- **Content:** unique ids; Arabic, meaning and reference present; correct
  ayah counts for all 9 required surahs; every category populated.
- **Qiblah:** KL bearing ≈ 292.6°, tilt-compensated azimuth (N/E), degenerate
  input, quality grading. **Zones:** Kluang → JHR03 suggestion, special zones
  excluded. **Wallpaper** slot selection. **l10n** key parity (ms/en).
- **Widget tests (real app, in-memory DB, fixed clock, no native layer):**
  onboarding with Kluang/JHR03 pre-selected; dashboard times, next prayer and
  countdown; no-data warning with no invented times; estimate label; English;
  scheduled Sleep Mode with Subuh countdown; TV Display mode at 1280×720;
  tasbih counting.

Bugs found and fixed by these tests: the player event stream subscribed
without a native layer; overflows at phone width (next-prayer name in English,
tasbih target chips).

## NOT executed: required on-device matrix

Run on at least one phone (Android 13/14/15), one tablet and one Android TV
box (Android 9–11), and record the results here.

| Scenario | Expected |
|---|---|
| First launch online | Onboarding → JHR03 confirmed → year timetable cached; source "JAKIM e-Solat" shown. |
| Internet disconnected | Cached data and last update shown; offline status; no invented times. |
| Fresh install offline | "No verified timetable" warning (+ labelled estimate if enabled). |
| App closed (swiped away) | Reminder, azan and after-recitation play/notify on time. |
| Device rebooted | Next alarm re-armed (*Diagnostics → Next event*); azan fires. |
| App updated (`adb install -r`) | Alarm re-armed via MY_PACKAGE_REPLACED. |
| Date/time/timezone changed | Alarm re-armed; prayer instants unchanged (MYT). |
| Exact alarm permission denied (12+) | Diagnostics shows "inexact"; alarms may be late; FGS start failure is recorded and falls back to a notification. |
| Notifications denied (13+) | Diagnostics ✗; audio still plays. |
| Silent / DND on | Audio skipped with a silent notification (if "respect silent" is on). |
| Battery saver / OEM killer (Xiaomi, Oppo, Vivo, Samsung) | Check that alarms fire; document the OEM steps needed. |
| Phone call during azan | Transient focus loss pauses; resumes after the call. |
| Two events overlap | Azan interrupts recitation; recitation queues after the azan. |
| Location changed (new zone) | New zone fetched, schedule re-planned. |
| TV remote | All screens reachable with the D-pad; Display mode readable at 3 m. |
| Low-RAM TV box | Wallpaper slideshow and custom images do not cause OOM. |
| Test alarm (Diagnostics) | Notification after 15 s with the app closed. |

## Known limitations

See [../README.md#known-limitations](../README.md#known-limitations).
