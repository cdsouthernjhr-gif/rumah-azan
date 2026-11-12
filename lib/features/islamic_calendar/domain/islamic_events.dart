import 'hijri.dart';

/// Important Islamic dates observed in Malaysia, defined by Hijri date.
class IslamicEventDef {
  const IslamicEventDef({
    required this.key,
    required this.nameMs,
    required this.nameEn,
    required this.month,
    required this.day,
    this.lengthDays = 1,
    required this.descMs,
    required this.descEn,
  });

  final String key;
  final String nameMs;
  final String nameEn;
  final int month;
  final int day;
  final int lengthDays;
  final String descMs;
  final String descEn;

  String name(String lang) => lang == 'en' ? nameEn : nameMs;
  String desc(String lang) => lang == 'en' ? descEn : descMs;
}

const islamicEventDefs = <IslamicEventDef>[
  IslamicEventDef(
    key: 'awal_muharram', nameMs: 'Awal Muharram', nameEn: 'Islamic New Year',
    month: 1, day: 1,
    descMs: 'Permulaan tahun baharu Hijrah, sempena peristiwa hijrah Rasulullah SAW dari Makkah ke Madinah.',
    descEn: 'Beginning of the new Hijri year, commemorating the Prophet\'s migration from Makkah to Madinah.',
  ),
  IslamicEventDef(
    key: 'asyura', nameMs: 'Hari Asyura', nameEn: 'Day of Ashura',
    month: 1, day: 10,
    descMs: '10 Muharram. Disunatkan berpuasa pada hari ini (riwayat Muslim).',
    descEn: '10 Muharram. Fasting on this day is recommended (narrated by Muslim).',
  ),
  IslamicEventDef(
    key: 'maulidur_rasul', nameMs: 'Maulidur Rasul', nameEn: 'Prophet\'s Birthday (Mawlid)',
    month: 3, day: 12,
    descMs: 'Sambutan keputeraan Nabi Muhammad SAW yang diraikan di Malaysia pada 12 Rabiulawal.',
    descEn: 'Commemoration of the birth of Prophet Muhammad, observed in Malaysia on 12 Rabi\' al-Awwal.',
  ),
  IslamicEventDef(
    key: 'israk_mikraj', nameMs: 'Israk dan Mikraj', nameEn: 'Isra\' and Mi\'raj',
    month: 7, day: 27,
    descMs: 'Memperingati peristiwa Israk dan Mikraj; disambut di Malaysia pada 27 Rejab.',
    descEn: 'Commemoration of the Night Journey and Ascension; observed in Malaysia on 27 Rajab.',
  ),
  IslamicEventDef(
    key: 'nisfu_syaaban', nameMs: 'Nisfu Syaaban', nameEn: 'Mid-Sha\'ban',
    month: 8, day: 15,
    descMs: 'Pertengahan bulan Syaaban (malam 15 Syaaban).',
    descEn: 'The middle of Sha\'ban (the night of 15 Sha\'ban).',
  ),
  IslamicEventDef(
    key: 'awal_ramadan', nameMs: 'Awal Ramadan', nameEn: 'First of Ramadan',
    month: 9, day: 1,
    descMs: 'Permulaan ibadah puasa Ramadan. Tarikh rasmi ditentukan melalui pengumuman Penyimpan Mohor Besar Raja-Raja.',
    descEn: 'Start of the Ramadan fast. The official date is set by the announcement of the Keeper of the Rulers\' Seal.',
  ),
  IslamicEventDef(
    key: 'nuzul_quran', nameMs: 'Nuzul Al-Quran', nameEn: 'Nuzul al-Quran',
    month: 9, day: 17,
    descMs: 'Memperingati penurunan al-Quran; disambut di Malaysia pada 17 Ramadan.',
    descEn: 'Commemorating the revelation of the Quran; observed in Malaysia on 17 Ramadan.',
  ),
  IslamicEventDef(
    key: 'aidilfitri', nameMs: 'Hari Raya Aidilfitri', nameEn: 'Eid al-Fitr',
    month: 10, day: 1,
    descMs: '1 Syawal. Tarikh rasmi ditentukan melalui pengumuman Penyimpan Mohor Besar Raja-Raja.',
    descEn: '1 Shawwal. The official date is set by the announcement of the Keeper of the Rulers\' Seal.',
  ),
  IslamicEventDef(
    key: 'arafah', nameMs: 'Hari Arafah', nameEn: 'Day of Arafah',
    month: 12, day: 9,
    descMs: '9 Zulhijjah. Disunatkan berpuasa bagi yang tidak menunaikan haji (riwayat Muslim).',
    descEn: '9 Dhu al-Hijjah. Fasting is recommended for those not performing Hajj (narrated by Muslim).',
  ),
  IslamicEventDef(
    key: 'aidiladha', nameMs: 'Hari Raya Aidiladha', nameEn: 'Eid al-Adha',
    month: 12, day: 10,
    descMs: '10 Zulhijjah. Hari raya korban.',
    descEn: '10 Dhu al-Hijjah. The festival of sacrifice.',
  ),
  IslamicEventDef(
    key: 'tasyrik', nameMs: 'Hari Tasyrik', nameEn: 'Days of Tashriq',
    month: 12, day: 11, lengthDays: 3,
    descMs: '11, 12 dan 13 Zulhijjah. Diharamkan berpuasa pada hari-hari ini.',
    descEn: '11, 12 and 13 Dhu al-Hijjah. Fasting is prohibited on these days.',
  ),
];

IslamicEventDef? eventByKey(String key) {
  for (final e in islamicEventDefs) {
    if (e.key == key) return e;
  }
  return null;
}

/// Events falling on Hijri date [h].
List<IslamicEventDef> eventsOnHijri(HijriDate h) => [
      for (final e in islamicEventDefs)
        if (e.month == h.month && h.day >= e.day && h.day < e.day + e.lengthDays) e,
    ];
