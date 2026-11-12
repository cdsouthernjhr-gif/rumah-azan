# Prayer time data source

## Primary: JAKIM e-Solat

- **Endpoint used:**
  `https://www.e-solat.gov.my/index.php?r=esolatApi/TakwimSolat&period=<year|month>&zone=<ZONE>`
- **What it is:** the public JSON endpoint behind JAKIM's e-Solat portal. It is
  widely used, but JAKIM does **not** publish formal API documentation, an SLA
  or explicit terms for programmatic use. Before a public release, contact
  JAKIM (e-Solat / Bahagian Falak) to confirm permission and rate limits.
- **Verification status:** this endpoint was **not reachable from the
  development environment** (blocked egress), so live responses were not
  checked there. The parser is unit-tested against the documented shape
  (`test/unit/prayer_sources_test.dart`). The first task on a networked
  machine is to run *Diagnostics → Run self-test*, which performs a live fetch.
- **Response shape handled:**
  `{ "prayerTime": [ { "hijri": "1448-05-22", "date": "12-Nov-2026", "imsak": "05:31:00", "fajr": …, "syuruk": …, "dhuhr": …, "asr": …, "maghrib": …, "isha": … } ], "status": "OK!", "zone": "JHR03" }`
- **Request policy:** `period=year` first (best offline coverage), falling
  back to `period=month`. No re-request while ≥ 7 days are cached and data is
  < 3 days old, and never more than once per 6 h at a month boundary. HTTPS
  only, 20 s timeout, generic User-Agent, no personal data sent.

## Validation (every day, before caching)

- All six times present and parseable; the date parses (English or Malay month
  abbreviations).
- Strictly ordered Subuh < Syuruk < Zohor < Asar < Maghrib < Isyak, and
  Imsak < Subuh.
- Subuh→Isyak span between 10 h and 18 h.
- Response `zone` equals the requested zone.
- Invalid days are dropped. If none remain, the fetch fails loudly (logged in
  Diagnostics) and the cache is left untouched.

## Secondary (optional): community mirror

`https://api.waktusolat.app/v2/solat/<ZONE>`, an open-source community
project that republishes JAKIM data (unix timestamps). It is **off by default**
and labelled "Cermin data JAKIM (komuniti)" wherever it is shown.

## Offline estimate (not official)

`EstimateCalculator`: Subuh 20°, Isyak 18°, Asar Syafie (shadow 1), +2 min
ihtiyati (−2 min for Syuruk), Imsak = Subuh − 10 min, using the zone's
**approximate** main-town coordinates.

- Never written to the database.
- Shown only with the "ANGGARAN" warning (it can be disabled in Settings).
- Not used for azan/reminders unless *Guna anggaran untuk azan & peringatan*
  is enabled (default **off**).
- Special zones without a reference point produce no estimate at all.

## Zones

`lib/data/static/jakim_zones.dart` bundles 60 JAKIM zone codes with coverage
text. Re-check them against the e-Solat portal before each release. Kluang is
in **JHR03** (Kluang, Pontian). Coordinates are approximate and only used for
GPS *suggestions* (the user always confirms; island and highland zones are
never auto-suggested) and for the estimate.

## Replacing the source

Implement `PrayerTimeProvider` (`lib/data/remote/prayer_time_provider.dart`),
return validated `PrayerDay`s, and select it in `prayerProviderImplProvider`.
Nothing else needs to change.
