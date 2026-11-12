# Database (SQLite via Drift)

Source: `lib/data/local/database.dart` (generated `database.g.dart`).
Schema version **1**. All timestamps are stored in UTC; prayer instants are
stored as epoch milliseconds.

| Table | Key | Purpose / notable constraints |
|---|---|---|
| `prayer_zones` | `code` PK | Mirror of the bundled JAKIM zone list (FK target). |
| `prayer_times` | `id` PK; **unique (`zone`,`date`)** | Verified timetables only (source `jakim`/`mirror`), plus Hijri from the source and `fetched_at`. FK `zone → prayer_zones.code`. Upserts never duplicate. |
| `islamic_events` | `id` PK; **unique (`event_key`,`hijri_year`)** | Officially confirmed / user-entered event dates overriding calculation. |
| `islamic_calendar` | (`hijri_year`,`hijri_month`) PK | Per-month Hijri adjustment (reserved for monthly official corrections). |
| `audio_library` | `id` PK; unique `file_path` | Imported/downloaded audio; `content_id` links to content.json; `source_url` prevents re-download. Index on `category`. |
| `audio_playlists` | `id` PK | |
| `audio_playlist_items` | `id` PK; index (`playlist_id`,`position`) | FKs with `ON DELETE CASCADE` to playlists and audio. |
| `audio_schedules` | `prayer` PK | Before/at/after audio config (JSON). |
| `notification_settings` | `prayer` PK | Notification part of the per-prayer config (JSON). |
| `audio_playback_history` | `id` PK; unique (`event_id`,`started_at`); index `started_at` | Imported from the native layer. |
| `wallpapers` | `id` PK; unique `file_path` | User images (built-ins are procedural). |
| `user_settings` | `key` PK | `app_settings` JSON (forward-compatible: unknown keys preserved). |
| `favorites` | `content_id` PK | |
| `tasbih_records` | `id` PK; index `date` | Saved sessions; daily totals via GROUP BY. |
| `app_diagnostics` | `id` PK; index `created_at` | Bounded log (500 rows), no personal data. |

**Not stored in SQLite (by design):** static Quran/zikr/doa content ships as a
versioned JSON asset (`assets/data/content.json`, read-only, offline). Only
user state about it (favourites, linked audio) is in the database. The brief's
`quran_surahs`, `quran_content`, `zikr_content` and `doa_content` tables are
therefore represented by that asset.

## Migrations

`AppDatabase.schemaVersion` + `MigrationStrategy.onUpgrade`. To change the
schema: edit the tables, bump `schemaVersion`, add an `if (from < N)` step,
then run `dart run build_runner build`. `PRAGMA foreign_keys = ON` runs on
every open.

## Backup / restore

`BackupRepository` exports JSON (format 1): settings, audio/notification
configs, favourites, events, tasbih, audio library metadata, playlists and
items. Restore validates the file, runs in **one transaction**, re-creates
playlists and audio rows with **new ids and remaps them inside the per-prayer
configs**, and skips audio whose file no longer exists. Audio and image files
themselves are not embedded.
