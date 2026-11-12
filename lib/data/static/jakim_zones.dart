import '../models/prayer_zone.dart';

/// Malaysian prayer zones as published by JAKIM e-Solat.
///
/// SOURCE: zone codes and coverage as used by the JAKIM e-Solat portal
/// (www.e-solat.gov.my). This list is bundled so the app works offline; it
/// must be re-checked against the official portal before each release because
/// JAKIM occasionally revises zone boundaries. See docs/PRAYER_DATA_SOURCE.md.
///
/// Coordinates are approximate positions of the main town and are NOT part of
/// the official data. They are only used for GPS *suggestions* (always
/// confirmed by the user) and for the labelled offline estimate.
const List<PrayerZone> jakimZones = [
  // JOHOR
  PrayerZone(code: 'JHR01', state: 'Johor', areas: 'Pulau Aur, Pulau Pemanggil', lat: 2.45, lng: 104.52, special: true),
  PrayerZone(code: 'JHR02', state: 'Johor', areas: 'Johor Bahru, Kota Tinggi, Mersing, Kulai', lat: 1.49, lng: 103.74),
  PrayerZone(code: 'JHR03', state: 'Johor', areas: 'Kluang, Pontian', lat: 2.03, lng: 103.32),
  PrayerZone(code: 'JHR04', state: 'Johor', areas: 'Batu Pahat, Muar, Segamat, Gemas Johor, Tangkak', lat: 1.85, lng: 102.93),
  // KEDAH
  PrayerZone(code: 'KDH01', state: 'Kedah', areas: 'Kota Setar, Kubang Pasu, Pokok Sena (Daerah Kecil)', lat: 6.12, lng: 100.37),
  PrayerZone(code: 'KDH02', state: 'Kedah', areas: 'Kuala Muda, Yan, Pendang', lat: 5.65, lng: 100.49),
  PrayerZone(code: 'KDH03', state: 'Kedah', areas: 'Padang Terap, Sik', lat: 6.25, lng: 100.61),
  PrayerZone(code: 'KDH04', state: 'Kedah', areas: 'Baling', lat: 5.68, lng: 100.92),
  PrayerZone(code: 'KDH05', state: 'Kedah', areas: 'Bandar Baharu, Kulim', lat: 5.37, lng: 100.56),
  PrayerZone(code: 'KDH06', state: 'Kedah', areas: 'Langkawi', lat: 6.35, lng: 99.80),
  PrayerZone(code: 'KDH07', state: 'Kedah', areas: 'Puncak Gunung Jerai', lat: 5.79, lng: 100.43, special: true),
  // KELANTAN
  PrayerZone(code: 'KTN01', state: 'Kelantan', areas: 'Bachok, Kota Bharu, Machang, Pasir Mas, Pasir Puteh, Tanah Merah, Tumpat, Kuala Krai, Mukim Chiku', lat: 6.13, lng: 102.24),
  PrayerZone(code: 'KTN02', state: 'Kelantan', areas: 'Gua Musang (Daerah Galas dan Bertam), Jeli, Jajahan Kecil Lojing', lat: 4.88, lng: 101.97),
  // MELAKA
  PrayerZone(code: 'MLK01', state: 'Melaka', areas: 'Seluruh Negeri Melaka', lat: 2.19, lng: 102.25),
  // NEGERI SEMBILAN
  PrayerZone(code: 'NGS01', state: 'Negeri Sembilan', areas: 'Tampin, Jempol', lat: 2.47, lng: 102.23),
  PrayerZone(code: 'NGS02', state: 'Negeri Sembilan', areas: 'Jelebu, Kuala Pilah, Rembau', lat: 2.74, lng: 102.25),
  PrayerZone(code: 'NGS03', state: 'Negeri Sembilan', areas: 'Port Dickson, Seremban', lat: 2.73, lng: 101.94),
  // PAHANG
  PrayerZone(code: 'PHG01', state: 'Pahang', areas: 'Pulau Tioman', lat: 2.79, lng: 104.17, special: true),
  PrayerZone(code: 'PHG02', state: 'Pahang', areas: 'Kuantan, Pekan, Muadzam Shah', lat: 3.81, lng: 103.33),
  PrayerZone(code: 'PHG03', state: 'Pahang', areas: 'Jerantut, Temerloh, Maran, Bera, Chenor, Jengka', lat: 3.45, lng: 102.42),
  PrayerZone(code: 'PHG04', state: 'Pahang', areas: 'Bentong, Lipis, Raub', lat: 3.79, lng: 101.86),
  PrayerZone(code: 'PHG05', state: 'Pahang', areas: 'Genting Sempah, Janda Baik, Bukit Tinggi', lat: 3.35, lng: 101.82, special: true),
  PrayerZone(code: 'PHG06', state: 'Pahang', areas: 'Cameron Highlands, Genting Highlands, Bukit Fraser', lat: 4.47, lng: 101.38, special: true),
  PrayerZone(code: 'PHG07', state: 'Pahang', areas: 'Zon Khas Daerah Rompin (Mukim Rompin, Mukim Endau, Mukim Pontian)', lat: 2.80, lng: 103.49),
  // PERLIS
  PrayerZone(code: 'PLS01', state: 'Perlis', areas: 'Kangar, Padang Besar, Arau', lat: 6.44, lng: 100.20),
  // PULAU PINANG
  PrayerZone(code: 'PNG01', state: 'Pulau Pinang', areas: 'Seluruh Negeri Pulau Pinang', lat: 5.41, lng: 100.33),
  // PERAK
  PrayerZone(code: 'PRK01', state: 'Perak', areas: 'Tapah, Slim River, Tanjung Malim', lat: 4.20, lng: 101.26),
  PrayerZone(code: 'PRK02', state: 'Perak', areas: 'Kuala Kangsar, Sg. Siput, Ipoh, Batu Gajah, Kampar', lat: 4.60, lng: 101.08),
  PrayerZone(code: 'PRK03', state: 'Perak', areas: 'Lenggong, Pengkalan Hulu, Grik', lat: 5.43, lng: 101.13),
  PrayerZone(code: 'PRK04', state: 'Perak', areas: 'Temengor, Belum', lat: 5.55, lng: 101.40, special: true),
  PrayerZone(code: 'PRK05', state: 'Perak', areas: 'Kg Gajah, Teluk Intan, Bagan Datuk, Seri Iskandar, Beruas, Parit, Lumut, Sitiawan, Pulau Pangkor', lat: 4.02, lng: 101.02),
  PrayerZone(code: 'PRK06', state: 'Perak', areas: 'Selama, Taiping, Bagan Serai, Parit Buntar', lat: 4.85, lng: 100.74),
  PrayerZone(code: 'PRK07', state: 'Perak', areas: 'Bukit Larut', lat: 4.86, lng: 100.79, special: true),
  // SABAH
  PrayerZone(code: 'SBH01', state: 'Sabah', areas: 'Bahagian Sandakan (Timur), Bukit Garam, Semawang, Temanggong, Tambisan, Bandar Sandakan, Sukau', lat: 5.84, lng: 118.12),
  PrayerZone(code: 'SBH02', state: 'Sabah', areas: 'Beluran, Telupid, Pinangah, Terusan, Kuamut, Bahagian Sandakan (Barat)', lat: 5.89, lng: 117.56),
  PrayerZone(code: 'SBH03', state: 'Sabah', areas: 'Lahad Datu, Silabukan, Kunak, Sahabat, Semporna, Tungku, Bahagian Tawau (Timur)', lat: 5.03, lng: 118.33),
  PrayerZone(code: 'SBH04', state: 'Sabah', areas: 'Bandar Tawau, Balong, Merotai, Kalabakan, Bahagian Tawau (Barat)', lat: 4.24, lng: 117.89),
  PrayerZone(code: 'SBH05', state: 'Sabah', areas: 'Kudat, Kota Marudu, Pitas, Pulau Banggi, Bahagian Kudat', lat: 6.88, lng: 116.85),
  PrayerZone(code: 'SBH06', state: 'Sabah', areas: 'Gunung Kinabalu', lat: 6.07, lng: 116.56, special: true),
  PrayerZone(code: 'SBH07', state: 'Sabah', areas: 'Kota Kinabalu, Ranau, Kota Belud, Tuaran, Penampang, Papar, Putatan, Bahagian Pantai Barat', lat: 5.98, lng: 116.07),
  PrayerZone(code: 'SBH08', state: 'Sabah', areas: 'Pensiangan, Keningau, Tambunan, Nabawan, Bahagian Pendalaman (Atas)', lat: 5.34, lng: 116.16),
  PrayerZone(code: 'SBH09', state: 'Sabah', areas: 'Beaufort, Kuala Penyu, Sipitang, Tenom, Long Pasia, Membakut, Weston, Bahagian Pendalaman (Bawah)', lat: 5.35, lng: 115.75),
  // SELANGOR
  PrayerZone(code: 'SGR01', state: 'Selangor', areas: 'Gombak, Petaling, Sepang, Hulu Langat, Hulu Selangor, Shah Alam', lat: 3.07, lng: 101.52),
  PrayerZone(code: 'SGR02', state: 'Selangor', areas: 'Kuala Selangor, Sabak Bernam', lat: 3.34, lng: 101.25),
  PrayerZone(code: 'SGR03', state: 'Selangor', areas: 'Klang, Kuala Langat', lat: 3.04, lng: 101.45),
  // SARAWAK
  PrayerZone(code: 'SWK01', state: 'Sarawak', areas: 'Limbang, Lawas, Sundar, Trusan', lat: 4.75, lng: 115.01),
  PrayerZone(code: 'SWK02', state: 'Sarawak', areas: 'Miri, Niah, Bekenu, Sibuti, Marudi', lat: 4.40, lng: 113.99),
  PrayerZone(code: 'SWK03', state: 'Sarawak', areas: 'Pandan, Belaga, Suai, Tatau, Sebauh, Bintulu', lat: 3.17, lng: 113.04),
  PrayerZone(code: 'SWK04', state: 'Sarawak', areas: 'Sibu, Mukah, Dalat, Song, Igan, Oya, Balingian, Kanowit, Kapit', lat: 2.29, lng: 111.83),
  PrayerZone(code: 'SWK05', state: 'Sarawak', areas: 'Sarikei, Matu, Julau, Rajang, Daro, Bintangor, Belawai', lat: 2.13, lng: 111.52),
  PrayerZone(code: 'SWK06', state: 'Sarawak', areas: 'Lubok Antu, Sri Aman, Roban, Debak, Kabong, Lingga, Engkelili, Betong, Spaoh, Pusa, Saratok', lat: 1.24, lng: 111.46),
  PrayerZone(code: 'SWK07', state: 'Sarawak', areas: 'Serian, Simunjan, Samarahan, Sebuyau, Meludam', lat: 1.17, lng: 110.57),
  PrayerZone(code: 'SWK08', state: 'Sarawak', areas: 'Kuching, Bau, Lundu, Sematan', lat: 1.55, lng: 110.34),
  PrayerZone(code: 'SWK09', state: 'Sarawak', areas: 'Zon Khas (Kampung Patarikan)', special: true),
  // TERENGGANU
  PrayerZone(code: 'TRG01', state: 'Terengganu', areas: 'Kuala Terengganu, Marang, Kuala Nerus', lat: 5.33, lng: 103.14),
  PrayerZone(code: 'TRG02', state: 'Terengganu', areas: 'Besut, Setiu', lat: 5.74, lng: 102.49),
  PrayerZone(code: 'TRG03', state: 'Terengganu', areas: 'Hulu Terengganu', lat: 5.07, lng: 103.01),
  PrayerZone(code: 'TRG04', state: 'Terengganu', areas: 'Dungun, Kemaman', lat: 4.76, lng: 103.42),
  // WILAYAH PERSEKUTUAN
  PrayerZone(code: 'WLY01', state: 'Wilayah Persekutuan', areas: 'Kuala Lumpur, Putrajaya', lat: 3.14, lng: 101.69),
  PrayerZone(code: 'WLY02', state: 'Wilayah Persekutuan', areas: 'Labuan', lat: 5.28, lng: 115.24),
];

PrayerZone? zoneByCode(String? code) {
  if (code == null) return null;
  for (final z in jakimZones) {
    if (z.code == code) return z;
  }
  return null;
}

List<String> get zoneStates {
  final seen = <String>[];
  for (final z in jakimZones) {
    if (!seen.contains(z.state)) seen.add(z.state);
  }
  return seen;
}
