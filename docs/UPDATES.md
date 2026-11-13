# Kemas kini aplikasi tanpa nyahpasang

Android membenarkan APK baharu dipasang **di atas** versi lama (data, tetapan
dan jadual kekal) hanya jika:

1. nama pakej sama — `com.rumahazan.app` ✅
2. **kunci tandatangan sama** — kunci tetap disimpan dalam GitHub Secrets
3. **versionCode lebih tinggi** — diambil automatik daripada nombor larian GitHub Actions ✅

Sebelum langkah di bawah, setiap binaan menggunakan kunci *debug* rawak, maka
anda terpaksa nyahpasang. Selepas langkah di bawah, tidak perlu lagi.

## Persediaan sekali sahaja (boleh dibuat dari pelayar telefon)

Repositori ini awam, jadi kunci **tidak** boleh diletakkan dalam kod atau fail
muat turun. Aliran kerja "Cipta Kunci Tandatangan" menciptanya terus ke dalam
Secrets yang tersulit — tiada sesiapa (termasuk anda) melihat kunci itu.

### Langkah 1 — Token sementara

1. GitHub → gambar profil → **Settings** → **Developer settings** →
   **Personal access tokens** → **Fine-grained tokens** → **Generate new token**.
2. Nama: `rumah-azan-kunci`; Expiration: **7 days**.
3. Repository access: **Only select repositories** → `rumah-azan`.
4. Permissions → Repository permissions → **Secrets: Read and write**.
5. **Generate token** dan salin token itu.

### Langkah 2 — Simpan token sebagai secret

Repositori `rumah-azan` → **Settings** → **Secrets and variables** →
**Actions** → **New repository secret**:
- Name: `RA_ADMIN_TOKEN`
- Secret: tampal token tadi → **Add secret**.

### Langkah 3 — Cipta kunci

**Actions** → **Cipta Kunci Tandatangan** → **Run workflow** → taip `YA` →
**Run workflow**. Tunggu tanda hijau ✓ (± 1 minit).

Secrets baharu akan muncul: `RA_KEYSTORE_B64`, `RA_KEYSTORE_PASSWORD`,
`RA_KEY_ALIAS`, `RA_KEY_PASSWORD`.

### Langkah 4 — Bersihkan token

- Padam secret `RA_ADMIN_TOKEN` (Settings → Secrets → Actions).
- Padam token di Developer settings → Fine-grained tokens.

### Langkah 5 — Bina & pasang (kali terakhir perlu nyahpasang)

1. **Actions** → **Bina APK** → **Run workflow** (atau tolak apa-apa perubahan).
2. Apabila ketiga-tiga kerja hijau (*build*, *smoke-test*, *publish*), buka
   **Releases** (halaman utama repositori, lajur kanan) → binaan terbaru →
   muat turun **rumah-azan.apk**.
3. **Kali ini sahaja** nyahpasang versi debug lama (kuncinya berbeza), kemudian
   pasang APK baharu.

Mulai sekarang, setiap versi baharu dalam **Releases** boleh dipasang terus —
Android akan memaparkan **"Kemas kini"**, bukan "Pasang", dan data anda kekal.

## Kemas kini automatik (pilihan): Obtainium

[Obtainium](https://github.com/ImranR98/Obtainium) ialah aplikasi sumber
terbuka yang memantau GitHub Releases dan memaklumkan/memasang versi baharu.

1. Pasang Obtainium (daripada GitHub Releases-nya atau F-Droid).
2. **Add App** → URL: `https://github.com/cdsouthernjhr-gif/rumah-azan`
3. Obtainium akan memberitahu apabila binaan baharu diterbitkan; ketik
   **Update**.

## Soalan lazim

- **"Aplikasi tidak dipasang" / "bercanggah dengan pakej sedia ada"** — APK
  ditandatangani dengan kunci lain (contohnya versi debug lama). Nyahpasang
  sekali, kemudian pasang versi Release.
- **Bolehkah kunci ditukar?** Jangan. Aliran kerja enggan menukar kunci yang
  sudah wujud, kerana semua pemasangan sedia ada tidak akan boleh dikemas kini.
- **Kunci hilang?** Kunci hanya wujud dalam Secrets repositori ini dan tidak
  boleh dibaca semula. Jangan padam secrets `RA_*`. Jika suatu hari aplikasi
  diterbitkan di Play Store, gunakan *Play App Signing* dengan kunci ini
  sebagai *upload key* (perlu dieksport semasa itu melalui aliran kerja khas).
- **Play Store?** Untuk pengedaran awam, Google Play (trek ujian dalaman)
  memberikan kemas kini automatik sepenuhnya. Ia memerlukan akaun pembangun
  Google Play (bayaran sekali) dan semakan dasar.
