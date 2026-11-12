import '../../../core/utilities/myt_time.dart';
import 'hijri.dart';
import 'islamic_events.dart';

/// How a Hijri date / event date was determined.
enum HijriSource {
  /// Confirmed by authority announcement and entered/imported as official.
  official,

  /// From the Hijri field of the JAKIM e-Solat timetable.
  jakim,

  /// Offline tabular calculation (+ user adjustment). Not official.
  calculated,
}

class HijriInfo {
  const HijriInfo(this.date, this.source);
  final HijriDate date;
  final HijriSource source;
}

class EventOccurrence {
  const EventOccurrence({
    required this.dateKey,
    required this.def,
    required this.hijriYear,
    required this.source,
    this.note,
  });
  final String dateKey;
  final IslamicEventDef def;
  final int hijriYear;
  final HijriSource source;
  final String? note;
}

class OfficialEventDate {
  const OfficialEventDate({
    required this.eventKey,
    required this.hijriYear,
    required this.dateKey,
    required this.source,
    this.note,
  });
  final String eventKey;
  final int hijriYear;
  final String dateKey;
  final String source; // official | user
  final String? note;
}

/// Pure calendar logic, independent of storage (unit-testable).
class CalendarService {
  const CalendarService({
    this.jakimHijri = const {},
    this.overrides = const [],
    this.userAdjust = 0,
  });

  /// Gregorian yyyy-MM-dd → Hijri yyyy-MM-dd as published by JAKIM.
  final Map<String, String> jakimHijri;
  final List<OfficialEventDate> overrides;
  final int userAdjust;

  HijriInfo hijriFor(String dateKey) {
    final j = HijriDate.tryParse(jakimHijri[dateKey]);
    if (j != null) return HijriInfo(j, HijriSource.jakim);
    return HijriInfo(
      TabularHijri.fromGregorian(Myt.parseDateKey(dateKey), adjustDays: userAdjust),
      HijriSource.calculated,
    );
  }

  /// Event occurrences between [fromKey] (inclusive) and +[days].
  List<EventOccurrence> eventsBetween(String fromKey, int days) {
    final out = <EventOccurrence>[];
    final toKey = Myt.addDays(fromKey, days - 1);
    for (var i = 0; i < days; i++) {
      final key = Myt.addDays(fromKey, i);
      final h = hijriFor(key);
      for (final def in eventsOnHijri(h.date)) {
        out.add(EventOccurrence(dateKey: key, def: def, hijriYear: h.date.year, source: h.source));
      }
    }
    // Official/user-confirmed dates replace calculated ones for that year.
    for (final o in overrides) {
      final def = eventByKey(o.eventKey);
      if (def == null) continue;
      out.removeWhere((e) => e.def.key == o.eventKey && e.hijriYear == o.hijriYear);
      for (var d = 0; d < def.lengthDays; d++) {
        final key = Myt.addDays(o.dateKey, d);
        if (key.compareTo(fromKey) >= 0 && key.compareTo(toKey) <= 0) {
          out.add(EventOccurrence(
            dateKey: key,
            def: def,
            hijriYear: o.hijriYear,
            source: HijriSource.official,
            note: o.note,
          ));
        }
      }
    }
    out.sort((a, b) => a.dateKey.compareTo(b.dateKey));
    return out;
  }

  List<EventOccurrence> eventsOn(String dateKey) => eventsBetween(dateKey, 1);
}
