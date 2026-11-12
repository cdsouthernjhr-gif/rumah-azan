/// An official JAKIM e-Solat prayer zone.
class PrayerZone {
  const PrayerZone({
    required this.code,
    required this.state,
    required this.areas,
    this.lat,
    this.lng,
    this.special = false,
  });

  /// Official JAKIM zone code, e.g. "JHR03".
  final String code;

  /// State / federal territory name.
  final String state;

  /// Districts and localities covered, as listed by JAKIM.
  final String areas;

  /// Approximate coordinates of the zone's main town. Used only to *suggest*
  /// a zone from GPS (the user must confirm) and for the clearly-labelled
  /// astronomical estimate. Null where no reliable reference point exists.
  final double? lat;
  final double? lng;

  /// Mountain/island/special zones. Never auto-suggested from GPS, because
  /// the nearest town is not a reliable indicator for these zones.
  final bool special;

  bool matches(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return code.toLowerCase().contains(q) ||
        state.toLowerCase().contains(q) ||
        areas.toLowerCase().contains(q);
  }

  String get label => '$code · $areas';
}
