// Bahasa Melayu (primary language).
const Map<String, String> stringsMs = {
  // General
  'tagline': 'Waktu solat, al-Quran, zikir & paparan rumah',
  'ok': 'OK', 'cancel': 'Batal', 'close': 'Tutup', 'delete': 'Padam', 'rename': 'Namakan semula',
  'retry': 'Cuba lagi', 'refresh': 'Muat semula', 'search': 'Cari', 'all': 'Semua', 'none': 'Tiada',
  'off': 'Mati', 'title': 'Tajuk', 'category': 'Kategori', 'date': 'Tarikh', 'clear': 'Kosongkan',
  'settings': 'Tetapan', 'history': 'Sejarah', 'actions': 'Tindakan', 'custom': 'Sendiri',
  'tomorrow': 'esok', 'running': 'Berjalan', 'idle': 'Tidak aktif', 'exempt': 'Dikecualikan',
  'restricted': 'Dihadkan', 'online': 'Dalam talian', 'offline': 'Luar talian',
  'status_unknown': 'Status rangkaian belum diketahui', 'syncing': 'Menyegerak…',
  'n_min': '{n} min', 'n_events': '{n} acara', 'repeat_n': 'Ulang {n} kali',

  // Prayers
  'prayer_subuh': 'Subuh', 'prayer_syuruk': 'Syuruk', 'prayer_zohor': 'Zohor',
  'prayer_asar': 'Asar', 'prayer_maghrib': 'Maghrib', 'prayer_isyak': 'Isyak', 'imsak': 'Imsak',

  // Days & months
  'day_1': 'Isnin', 'day_2': 'Selasa', 'day_3': 'Rabu', 'day_4': 'Khamis', 'day_5': 'Jumaat',
  'day_6': 'Sabtu', 'day_7': 'Ahad',
  'day_short_1': 'Isn', 'day_short_2': 'Sel', 'day_short_3': 'Rab', 'day_short_4': 'Kha',
  'day_short_5': 'Jum', 'day_short_6': 'Sab', 'day_short_7': 'Ahd',
  'month_1': 'Januari', 'month_2': 'Februari', 'month_3': 'Mac', 'month_4': 'April', 'month_5': 'Mei',
  'month_6': 'Jun', 'month_7': 'Julai', 'month_8': 'Ogos', 'month_9': 'September', 'month_10': 'Oktober',
  'month_11': 'November', 'month_12': 'Disember',

  // Dashboard
  'next_prayer': 'Waktu seterusnya', 'current_period': 'Kini dalam waktu {p}',
  'no_next_prayer': 'Waktu seterusnya tidak dapat ditentukan — tiada jadual yang disahkan.',
  'upcoming_events': 'Peristiwa Islam akan datang',
  'calculated_note': '* Tarikh kiraan, belum disahkan pengumuman rasmi.',
  'data_source': 'Sumber data', 'last_update': 'Kemas kini', 'last_sync': 'Segerak terakhir',
  'source_jakim': 'JAKIM e-Solat', 'source_mirror': 'Cermin data JAKIM (komuniti)',
  'source_estimate': 'Anggaran kiraan (bukan rasmi)',
  'warn_no_verified':
      'Tiada jadual waktu solat yang disahkan untuk hari ini. Sambung ke Internet untuk memuat turun jadual JAKIM.',
  'warn_estimate':
      'Waktu dipaparkan ialah ANGGARAN kiraan astronomi, bukan jadual rasmi JAKIM. Mungkin berbeza beberapa minit.',
  'warn_sync_failed': 'Gagal mengemas kini data. Menggunakan data simpanan terakhir.',
  'estimate_short': 'Anggaran — bukan data rasmi',
  'quran': 'Al-Quran', 'zikir': 'Zikir', 'doa': 'Doa', 'tasbih': 'Tasbih', 'qiblah': 'Kiblat',
  'calendar': 'Kalendar', 'audio': 'Audio', 'audio_schedule': 'Jadual Audio', 'sleep_mode': 'Mod Tidur',
  'display_mode': 'Mod Paparan', 'choose_zone': 'Pilih zon waktu solat',
  'hijri_src_official': 'Rasmi (disahkan)', 'hijri_src_jakim': 'Takwim JAKIM',
  'hijri_src_calculated': 'Kiraan (belum rasmi)',

  // Onboarding & zones
  'language': 'Bahasa', 'onboard_zone_title': 'Zon waktu solat',
  'onboard_zone_hint':
      'Kluang, Johor (zon JHR03) dipilih sebagai cadangan. Pastikan zon ini betul untuk lokasi anda — nama daerah sahaja tidak semestinya menentukan zon.',
  'choose_other_zone': 'Pilih zon lain', 'confirm_zone_start': 'Sahkan zon {z} & mula',
  'onboard_notif_title': 'Pemberitahuan & azan',
  'onboard_notif_body':
      'Benarkan pemberitahuan supaya peringatan waktu solat dan azan berjadual boleh dipaparkan.',
  'allow_notifications': 'Benarkan pemberitahuan',
  'search_zone_hint': 'Cari negeri, daerah atau kod zon (cth. Kluang, JHR03)',
  'all_states': 'Semua negeri', 'use_gps': 'Gunakan GPS',
  'gps_suggest_note': 'Mencadangkan zon berhampiran. Lokasi tidak disimpan atau dihantar.',
  'gps_confirm_note':
      'Cadangan berdasarkan jarak ke bandar utama setiap zon. Sila sahkan zon anda; zon khas (pulau/tanah tinggi) mesti dipilih secara manual.',
  'gps_off': 'Perkhidmatan lokasi dimatikan.', 'gps_denied': 'Kebenaran lokasi ditolak.',
  'gps_failed': 'Gagal mendapatkan lokasi',

  // Timetable
  'timetable': 'Jadual Waktu Solat',
  'timetable_empty': 'Tiada data disahkan untuk bulan ini. Tekan muat semula ketika dalam talian.',
  'timetable_source_note': 'Sumber: {src}. Hanya data disahkan dipaparkan dalam jadual ini.',

  // Calendar
  'events_this_month': 'Peristiwa bulan ini', 'no_events': 'Tiada peristiwa.',
  'hijri_adjust': 'Pelarasan Hijrah', 'hijri_adjust_desc': 'Laraskan tarikh Hijrah kiraan',
  'hijri_adjust_note': 'Hanya mempengaruhi tarikh kiraan (bukan tarikh JAKIM atau rasmi).',
  'calendar_disclaimer':
      'Tarikh Hijrah diambil daripada takwim JAKIM (jika tersedia dalam data waktu solat) atau dikira secara aritmetik. Tarikh rasmi Awal Ramadan, Aidilfitri dan Aidiladha ditentukan oleh pengumuman Penyimpan Mohor Besar Raja-Raja; tandakan tarikh rasmi selepas pengumuman.',
  'set_official_date': 'Tetapkan tarikh rasmi', 'remove_official_date': 'Buang tarikh rasmi',
  'official_source_note': 'Sumber pengumuman (pilihan)', 'official_source_hint': 'cth. Pengumuman PMBRR',

  // Content
  'library_title': 'Al-Quran, Zikir & Doa',
  'ctype_quran': 'Al-Quran', 'ctype_zikr': 'Zikir', 'ctype_doa': 'Doa', 'ctype_fav': 'Kegemaran',
  'cat_surah_pendek': 'Surah pendek', 'cat_ayat_pilihan': 'Ayat pilihan', 'cat_zikir_pagi': 'Zikir pagi',
  'cat_zikir_petang': 'Zikir petang', 'cat_zikir_selepas_solat': 'Zikir selepas solat', 'cat_selawat': 'Selawat',
  'cat_doa_harian': 'Doa harian', 'cat_doa_bangun_tidur': 'Doa bangun tidur', 'cat_doa_tidur': 'Doa sebelum tidur',
  'cat_doa_makan': 'Doa makan', 'cat_doa_perjalanan': 'Doa perjalanan', 'cat_doa_rumah': 'Doa masuk & keluar rumah',
  'cat_doa_ibu_bapa': 'Doa ibu bapa', 'cat_doa_selepas_solat': 'Doa selepas solat',
  'cat_doa_perlindungan': 'Doa memohon perlindungan',
  'no_results': 'Tiada hasil.', 'no_favorites': 'Belum ada kegemaran.',
  'favorite': 'Kegemaran', 'copy': 'Salin', 'copied': 'Disalin', 'share': 'Kongsi', 'reference': 'Rujukan',
  'content_unverified':
      'Teks ini belum disahkan oleh penyemak bertauliah. Sila rujuk mushaf dan sumber muktabar.',
  'count_with_tasbih': 'Kira dengan tasbih', 'link_audio': 'Pautkan audio',

  // Audio
  'library': 'Pustaka', 'playlists': 'Senarai main', 'import_audio': 'Import audio',
  'download_audio': 'Muat turun audio (HTTPS)', 'https_only': 'Hanya pautan HTTPS dibenarkan.',
  'download_done': 'Muat turun selesai.', 'download_failed': 'Muat turun gagal', 'imported_n': '{n} fail diimport.',
  'audio_empty':
      'Tiada audio. Aplikasi tidak membundel rakaman — import fail audio berlesen anda sendiri atau muat turun daripada sumber yang dibenarkan.',
  'acat_azan': 'Azan', 'acat_quran': 'Al-Quran', 'acat_zikr': 'Zikir', 'acat_selawat': 'Selawat',
  'acat_doa': 'Doa', 'acat_other': 'Lain-lain',
  'nothing_playing': 'Tiada audio dimainkan', 'now_playing': 'Sedang dimainkan',
  'play': 'Main', 'pause': 'Jeda', 'stop': 'Henti', 'next': 'Seterusnya', 'previous': 'Sebelumnya',
  'repeat': 'Ulang', 'shuffle': 'Rawak', 'new_playlist': 'Senarai main baharu', 'add_audio': 'Tambah audio',
  'audio_library': 'Pustaka audio', 'manage_audio': 'Urus pustaka audio',

  // Scheduler
  'auto_audio': 'Audio automatik',
  'auto_audio_sub': 'Mainkan bacaan dan azan mengikut jadual. Jika dimatikan, hanya pemberitahuan dihantar.',
  'before_prayer': 'A. Sebelum waktu solat', 'before_enable': 'Mainkan bacaan sebelum waktu',
  'minutes_before': 'Mula sebelum waktu', 'playlist': 'Senarai main',
  'need_playlist': 'Pilih senarai main yang mengandungi audio, jika tidak tiada apa akan dimainkan.',
  'at_prayer': 'B. Pada waktu solat',
  'at_fullAzan': 'Azan penuh', 'at_shortAzan': 'Azan pendek', 'at_notificationOnly': 'Pemberitahuan sahaja',
  'at_silent': 'Senyap (pemberitahuan tanpa bunyi)',
  'full_azan_audio': 'Audio azan penuh', 'short_azan_audio': 'Audio azan pendek',
  'need_azan_file':
      'Tiada fail azan dipilih (kategori "Azan" dalam pustaka). Bunyi pemberitahuan lalai akan digunakan.',
  'after_prayer': 'C. Selepas solat', 'after_enable': 'Mainkan zikir/bacaan selepas solat',
  'start_delay': 'Lewat mula selepas waktu', 'max_duration': 'Tempoh maksimum', 'repeat_count': 'Bilangan ulangan',
  'notifications': 'Pemberitahuan', 'notify_at_time': 'Pemberitahuan pada waktu solat',
  'reminder_before': 'Peringatan awal (0 = mati)', 'vibrate': 'Getaran', 'sound': 'Bunyi',
  'notif_reminder_title': '{prayer} dalam {min} minit', 'notif_reminder_body': 'Bersedia untuk solat {prayer}.',
  'notif_azan_title': 'Telah masuk waktu {prayer}', 'notif_azan_body': 'Waktu solat {prayer} bagi zon anda.',
  'notif_before_title': 'Bacaan sebelum {prayer}', 'notif_after_title': 'Zikir selepas {prayer}',

  // Tasbih
  'target': 'Sasaran', 'rounds': 'Pusingan', 'tap_to_count': 'Ketik untuk mengira',
  'save_reset': 'Simpan & set semula', 'custom_zikr': 'Zikir sendiri', 'daily_stats': 'Statistik 7 hari',
  'clear_history': 'Kosongkan sejarah', 'clear_history_q': 'Padam semua rekod tasbih?', 'no_history': 'Tiada rekod.',

  // Qiblah
  'qiblah_bearing': 'Arah kiblat: {deg}° dari utara benar',
  'qiblah_loc_gps': 'Lokasi: GPS', 'qiblah_loc_zone': 'Lokasi: anggaran bandar utama zon (guna GPS untuk ketepatan)',
  'qiblah_no_location': 'Tiada lokasi. Gunakan GPS untuk mengira arah kiblat.',
  'compass_unavailable':
      'Penderia kompas tidak tersedia pada peranti ini (biasa bagi Android TV). Gunakan arah dalam darjah dengan kompas fizikal.',
  'compass_waiting': 'Menunggu bacaan penderia…', 'sensor_accuracy': 'Ketepatan penderia',
  'quality_good': 'Baik', 'quality_fair': 'Sederhana', 'quality_poor': 'Lemah',
  'compass_poor':
      'Bacaan kompas tidak boleh dipercayai. Jauhkan daripada logam/elektronik dan lakukan kalibrasi.',
  'calibration_title': 'Kalibrasi kompas',
  'calibration_body':
      'Gerakkan telefon dalam corak angka 8 beberapa kali, jauh daripada objek logam, magnet dan peralatan elektrik.',
  'qiblah_manual_title': 'Kaedah manual',
  'qiblah_manual_body':
      'Gunakan kompas fizikal dan hadap {deg}° dari utara. Sisihan magnet di Malaysia adalah kecil (lebih kurang 0–1°).',

  // Display & sleep
  'announcements': 'Pengumuman', 'upcoming_subuh': 'Subuh seterusnya', 'exit_sleep': 'Keluar mod tidur',
  'open_display_mode': 'Buka Mod Paparan', 'display_mode_sub': 'Paparan skrin penuh untuk TV, TV Box atau tablet dinding.',
  'keep_screen_on': 'Kekalkan skrin hidup', 'keep_screen_on_sub': 'Hanya ketika Mod Paparan atau Mod Tidur dibuka.',
  'auto_return_display': 'Kembali automatik ke Mod Paparan', 'screensaver_after': 'Penyelamat skrin selepas',
  'slideshow': 'Tayangan slaid wallpaper', 'slideshow_interval': 'Selang tayangan slaid',
  'sleep_scheduled': 'Mod tidur berjadual', 'start_time': 'Masa mula', 'end_time': 'Masa tamat',
  'sleep_dim': 'Kelamkan skrin (tetingkap aplikasi sahaja)',
  'sleep_mute': 'Senyapkan audio tidak penting',
  'sleep_mute_sub': 'Bacaan sebelum/selepas solat tidak dimainkan dalam tempoh tidur. Azan tidak terjejas.',

  // Appearance
  'appearance': 'Penampilan', 'theme': 'Tema', 'theme_emeraldGold': 'Zamrud Emas', 'theme_cream': 'Krim Minimalis',
  'theme_ocean': 'Biru Lautan', 'theme_sunset': 'Senja', 'auto_theme': 'Tema automatik ikut masa',
  'auto_theme_sub': 'Tukar tema mengikut slot pagi/tengah hari/petang/malam.', 'font_size': 'Saiz fon',
  'wallpaper': 'Wallpaper', 'wallpaper_auto': 'Tukar wallpaper automatik',
  'wallpaper_auto_sub': 'Wallpaper berbeza untuk pagi, tengah hari, petang dan malam.',
  'wallpaper_fixed': 'Pilih wallpaper', 'slot_morning': 'Pagi', 'slot_afternoon': 'Tengah hari',
  'slot_evening': 'Petang', 'slot_night': 'Malam', 'starts_at': 'Mula', 'change_time': 'Tukar masa',
  'import_image': 'Import imej sendiri', 'wallpaper_imported': 'Imej diimport', 'use_now_q': 'Gunakan sekarang?',
  'wallpaper_effects': 'Kesan wallpaper', 'brightness': 'Kecerahan', 'dark_overlay': 'Lapisan gelap', 'blur': 'Kabur',
  'image_fit': 'Muatan imej', 'fit_fill': 'Penuh', 'fit_fit': 'Muat',
  'restore_default_wallpaper': 'Pulihkan wallpaper lalai', 'theme_wallpaper_font': 'Tema, wallpaper & saiz fon',

  // Settings
  'location': 'Lokasi', 'prayer': 'Waktu solat', 'display': 'Paparan', 'general': 'Umum',
  'provider_jakim_desc': 'Sumber rasmi JAKIM e-Solat.',
  'provider_mirror_desc': 'API komuniti yang menyalin data JAKIM. Bukan perkhidmatan rasmi JAKIM.',
  'refresh_now': 'Kemas kini data sekarang', 'sync_ok': 'Data dikemas kini.', 'sync_failed': 'Kemas kini gagal',
  'allow_estimate_display': 'Papar anggaran jika tiada data',
  'allow_estimate_display_sub': 'Dipaparkan dengan amaran jelas. Tidak pernah disimpan sebagai data rasmi.',
  'allow_estimate_alarms': 'Guna anggaran untuk azan & peringatan',
  'allow_estimate_alarms_sub': 'Tidak disyorkan. Lalai: hanya jadual disahkan digunakan untuk penjadualan.',
  'show_imsak': 'Papar waktu Imsak', 'audio_schedule_sub': 'Sebelum, pada dan selepas waktu solat',
  'respect_silent': 'Hormati mod senyap & Jangan Ganggu',
  'respect_silent_sub': 'Audio automatik tidak dimainkan ketika telefon senyap atau Jangan Ganggu aktif.',
  'backup': 'Sandaran', 'backup_sub': 'Eksport tetapan, jadual, senarai main, kegemaran & tasbih (JSON).',
  'backup_failed': 'Sandaran gagal', 'restore': 'Pulihkan sandaran',
  'restore_q': 'Data daripada fail sandaran akan digabungkan dan tetapan semasa diganti. Teruskan?',
  'restore_ok': 'Sandaran dipulihkan.', 'restore_failed': 'Pemulihan gagal',
  'clear_prayer_cache': 'Kosongkan cache waktu solat', 'clear_prayer_cache_sub': 'Data akan dimuat turun semula.',
  'clear_prayer_cache_q': 'Padam semua jadual waktu solat yang disimpan?',
  'privacy': 'Privasi',
  'privacy_body':
      'Tiada akaun diperlukan. Tiada data peribadi dikumpul. Lokasi GPS hanya digunakan dalam peranti dan tidak disimpan.',
  'app_version': 'Versi aplikasi',

  // Diagnostics
  'diagnostics': 'Diagnostik', 'run_self_test': 'Jalankan ujian kendiri', 'self_test_results': 'Keputusan ujian',
  'system': 'Sistem', 'chk_database': 'Pangkalan data', 'chk_native': 'Lapisan Android (native)',
  'native_missing': 'Lapisan native tidak tersedia (bukan peranti Android?)',
  'chk_prayer_api': 'Sambungan API waktu solat', 'chk_verified_today': 'Jadual disahkan hari ini',
  'chk_scheduler': 'Penjadual audio', 'notification_permission': 'Kebenaran pemberitahuan',
  'exact_alarm_permission': 'Kebenaran penggera tepat', 'battery_optimisation': 'Pengoptimuman bateri',
  'battery_restricted_hint': 'Aplikasi mungkin dihadkan di latar belakang',
  'android_version': 'Versi Android', 'device_model': 'Model peranti', 'memory': 'Memori tersedia',
  'dnd_status': 'Penapis gangguan (DND)', 'scheduler_status': 'Status penjadual', 'scheduled_events': 'Acara dijadualkan',
  'next_scheduled': 'Acara seterusnya', 'alarm_mode': 'Mod penggera', 'background_service': 'Perkhidmatan main balik',
  'last_alarm_fired': 'Penggera terakhir berbunyi', 'last_playback': 'Main balik terakhir berjaya',
  'last_playback_error': 'Ralat main balik terakhir', 'last_plan': 'Perancangan terakhir',
  'open_exact_alarm': 'Tetapan penggera tepat', 'open_battery': 'Tetapan bateri',
  'open_notification_settings': 'Tetapan pemberitahuan', 'test_alarm': 'Uji penggera (15 saat)',
  'test_alarm_title': 'Ujian Rumah Azan', 'test_alarm_body': 'Penggera ujian berjaya.',
  'test_alarm_set': 'Penggera ujian dijadualkan dalam 15 saat. Anda boleh tutup aplikasi.',
  'oem_note':
      'Sesetengah pengeluar (cth. Xiaomi, Oppo, Vivo, Huawei, Samsung dan TV Box tertentu) menghadkan aplikasi latar belakang. Jika azan tidak berbunyi ketika aplikasi ditutup, benarkan "autostart" dan kecualikan Rumah Azan daripada pengoptimuman bateri.',
  'notif_refresh_title': 'Kemas kini jadual Rumah Azan',
  'notif_refresh_body': 'Jadual azan hampir tamat. Buka aplikasi ketika dalam talian untuk mengemas kini.',
  'notif_missed_title': 'Audio tidak dimainkan',
  'notif_silent_skipped': 'Mod senyap/Jangan Ganggu aktif — audio dilangkau.',
  'extra_notifications': 'Pemberitahuan lain',
  'zikir_morning_reminder': 'Peringatan zikir pagi',
  'zikir_evening_reminder': 'Peringatan zikir petang',
  'event_reminder': 'Peringatan peristiwa Islam',
  'event_reminder_sub': 'Pada hari peristiwa',
  'notify_before_recitation': 'Maklumkan apabila bacaan sebelum solat bermula',
  'notify_before_recitation_sub': 'Pemberitahuan senyap semasa audio mula dimainkan.',
  'notif_zikir_pagi_title': 'Zikir pagi',
  'notif_zikir_pagi_body': 'Masa untuk zikir pagi. Buka Rumah Azan → Zikir → Zikir pagi.',
  'notif_zikir_petang_title': 'Zikir petang',
  'notif_zikir_petang_body': 'Masa untuk zikir petang. Buka Rumah Azan → Zikir → Zikir petang.',
  'notif_event_calculated': '(Tarikh kiraan — tertakluk kepada pengumuman rasmi.)',
  'duration': 'Tempoh', 'playback_history': 'Sejarah main balik', 'status_played': 'Dimainkan',
  'status_skipped': 'Dilangkau', 'status_missed': 'Terlepas', 'status_error': 'Ralat',
  'status_interrupted': 'Dipintas', 'status_stopped': 'Dihentikan', 'status_focus_lost': 'Fokus audio hilang',
  'frame_image': 'Bingkai imej (zum & kedudukan)', 'zoom': 'Zum', 'position_x': 'Kedudukan mendatar',
  'position_y': 'Kedudukan menegak', 'reset': 'Set semula',
  'log': 'Log', 'clear_log': 'Kosongkan log',
};
