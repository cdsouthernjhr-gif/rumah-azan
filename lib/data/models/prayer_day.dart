/// The six daily times shown by Rumah Azan.
///
/// [syuruk] is a sunrise reference time, NOT one of the five obligatory
/// prayers; [Prayer.isObligatory] reflects that.
enum Prayer {
  subuh,
  syuruk,
  zohor,
  asar,
  maghrib,
  isyak;

  bool get isObligatory => this != Prayer.syuruk;

  static const obligatory = [subuh, zohor, asar, maghrib, isyak];
}

/// Where a timetable came from. Only [jakim] and [mirror] are considered
/// verified/official data; [estimate] is an offline astronomical approximation
/// and is always shown with a warning.
enum PrayerSource {
  jakim,
  mirror,
  estimate;

  bool get isVerified => this != PrayerSource.estimate;
}

class PrayerDay {
  const PrayerDay({
    required this.zone,
    required this.date,
    required this.imsak,
    required this.subuh,
    required this.syuruk,
    required this.zohor,
    required this.asar,
    required this.maghrib,
    required this.isyak,
    required this.source,
    required this.fetchedAt,
    this.hijri,
  });

  final String zone;

  /// Malaysian civil date, yyyy-MM-dd.
  final String date;

  /// Absolute instants (UTC).
  final DateTime? imsak;
  final DateTime subuh;
  final DateTime syuruk;
  final DateTime zohor;
  final DateTime asar;
  final DateTime maghrib;
  final DateTime isyak;

  final PrayerSource source;
  final DateTime fetchedAt;

  /// Hijri date as provided by the source (yyyy-MM-dd), if any.
  final String? hijri;

  DateTime timeOf(Prayer p) => switch (p) {
        Prayer.subuh => subuh,
        Prayer.syuruk => syuruk,
        Prayer.zohor => zohor,
        Prayer.asar => asar,
        Prayer.maghrib => maghrib,
        Prayer.isyak => isyak,
      };

  /// Validates basic sanity: all times on the stated day and strictly ordered.
  bool get isConsistent {
    final list = [subuh, syuruk, zohor, asar, maghrib, isyak];
    for (var i = 1; i < list.length; i++) {
      if (!list[i].isAfter(list[i - 1])) return false;
    }
    if (imsak != null && !imsak!.isBefore(subuh)) return false;
    final span = isyak.difference(subuh);
    return span > const Duration(hours: 10) && span < const Duration(hours: 18);
  }
}
