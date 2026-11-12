class Ayah {
  const Ayah({required this.n, required this.ar, this.rumi, required this.ms});
  final int n;
  final String ar;
  final String? rumi;
  final String ms;
}

/// A Quran / zikr / doa entry from assets/data/content.json.
class ContentItem {
  const ContentItem({
    required this.id,
    required this.type,
    required this.categories,
    required this.titleMs,
    required this.titleEn,
    required this.reference,
    required this.verification,
    this.ayat = const [],
    this.ar,
    this.rumi,
    this.ms,
    this.repeat,
    this.note,
  });

  final String id;
  final String type; // quran | zikr | doa
  final List<String> categories;
  final String titleMs;
  final String titleEn;
  final String reference;
  final String verification; // perlu_semakan | disahkan
  final List<Ayah> ayat;
  final String? ar;
  final String? rumi;
  final String? ms;
  final int? repeat;
  final String? note;

  String title(String lang) => lang == 'en' ? titleEn : titleMs;
  bool get isVerified => verification == 'disahkan';

  String get arabicFull => ayat.isNotEmpty ? ayat.map((a) => '${a.ar} (${a.n})').join(' ') : (ar ?? '');
  String get rumiFull => ayat.isNotEmpty ? ayat.map((a) => a.rumi ?? '').join(' ') : (rumi ?? '');
  String get meaningFull => ayat.isNotEmpty ? ayat.map((a) => '(${a.n}) ${a.ms}').join(' ') : (ms ?? '');

  /// Plain-text form for copy/share, always including the reference.
  String shareText(String lang) => [
        title(lang),
        arabicFull,
        if (rumiFull.trim().isNotEmpty) rumiFull,
        meaningFull,
        'Rujukan: $reference',
      ].join('\n\n');

  bool matches(String q) {
    final s = q.trim().toLowerCase();
    if (s.isEmpty) return true;
    return titleMs.toLowerCase().contains(s) ||
        titleEn.toLowerCase().contains(s) ||
        meaningFull.toLowerCase().contains(s) ||
        rumiFull.toLowerCase().contains(s) ||
        reference.toLowerCase().contains(s) ||
        arabicFull.contains(q.trim());
  }

  factory ContentItem.fromJson(Map<String, dynamic> j) => ContentItem(
        id: j['id'] as String,
        type: j['type'] as String,
        categories: (j['categories'] as List).cast<String>(),
        titleMs: j['titleMs'] as String,
        titleEn: j['titleEn'] as String? ?? j['titleMs'] as String,
        reference: j['reference'] as String,
        verification: j['verification'] as String? ?? 'perlu_semakan',
        ayat: [
          for (final a in (j['ayat'] as List?) ?? const [])
            Ayah(
              n: (a['n'] as num).toInt(),
              ar: a['ar'] as String,
              rumi: a['rumi'] as String?,
              ms: a['ms'] as String,
            ),
        ],
        ar: j['ar'] as String?,
        rumi: j['rumi'] as String?,
        ms: j['ms'] as String?,
        repeat: (j['repeat'] as num?)?.toInt(),
        note: j['note'] as String?,
      );
}

/// Category keys used across the content library (labels in l10n: `cat_<key>`).
const contentCategories = [
  'surah_pendek',
  'ayat_pilihan',
  'zikir_pagi',
  'zikir_petang',
  'zikir_selepas_solat',
  'selawat',
  'doa_harian',
  'doa_bangun_tidur',
  'doa_tidur',
  'doa_makan',
  'doa_perjalanan',
  'doa_rumah',
  'doa_ibu_bapa',
  'doa_selepas_solat',
  'doa_perlindungan',
];
