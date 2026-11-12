# Religious content — verification status

**Every item in `assets/data/content.json` has `"verification": "perlu_semakan"`
(needs review).** The app shows a visible notice on each item until a
qualified reviewer changes it to `"disahkan"`.

## What is included (32 items)

| Type | Items |
|---|---|
| Surah pendek (per ayah: Arabic, Rumi, Malay meaning) | Al-Fatihah (7), Al-Ikhlas (4), Al-Falaq (5), An-Nas (6), Al-‘Asr (3), Al-Kauthar (3), Al-Kafirun (6), An-Nasr (3), Al-Ma‘un (7) |
| Ayat pilihan | Ayat al-Kursi (2:255) |
| Zikir selepas solat | Istighfar ×3, Allahumma antas-salam, Tasbih/Tahmid/Takbir ×33, completing-the-hundred tahlil (Muslim 591, 597) |
| Zikir pagi/petang | 3 Qul ×3 (Abu Dawud 5082, Tirmizi 3575), Bismillahil-lazi la yadhurru ×3, Subhanallah wa bihamdih ×100, Radhitu billahi rabba ×3 (grading discussed; noted in-app) |
| Selawat | Selawat Ibrahimiyyah (Bukhari 3370) |
| Doa | Waking, sleeping, before/after eating, leaving/entering home (entering: chain disputed, noted in-app), travel (43:13–14), parents (17:24; 14:41), protection (Muslim 2708/2709), dunya-akhirah (2:201), knowledge (20:114) |

Ayah counts and structure are checked by `test/unit/content_and_misc_test.dart`.

## Required review before release

1. **Arabic Quran text:** compare letter by letter, including harakat,
   against an authorised mushaf. The bundled text uses simplified (imla'i)
   spelling with harakat for reliable rendering, **not** Rasm Uthmani. If the
   release must use Rasm Uthmani, replace it with a licensed source (e.g. the
   Tanzil Uthmani text, CC BY 3.0, keeping its attribution and unmodified-text
   terms) and render it with an appropriate font.
2. **Malay meanings:** the meanings are concise renderings written for this
   app, *not* verbatim quotations of Tafsir Pimpinan Ar-Rahman. Have them
   checked, or replace them with a licensed official translation.
3. **Hadith references:** confirm the numbering edition (e.g. Ayat al-Kursi
   after prayer: an-Nasa'i, *as-Sunan al-Kubra*; the number is marked as
   needing a check).
4. **Rumi transliteration:** follow one consistent transliteration standard.
5. After review, set `"verification": "disahkan"` per item and record the
   reviewer and date in this file.

## Rules for adding content

- Never add text without a source reference.
- Mark weak or disputed narrations in `note`.
- Do not paraphrase the Quran as if it were a quotation; label meanings as meanings.
