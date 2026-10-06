# PARENTVERSE

Multimedia Interaktif Parenting Remaja untuk Penguatan Relasi Keluarga.
Game edukasi untuk orang tua dan anak — mitra: PKK Desa Muntang, Telkom University Kampus Purwokerto.

## Menjalankan

1. Buka **Godot 4.7.2** → `Import` → pilih `project.godot` di folder ini.
2. Tekan **F5** (atau tombol Play). Scene utama: `scenes/main.tscn`.
3. Jendela uji berukuran 405×720 (potret ponsel). Klik mouse = sentuhan layar.

Tanpa internet, tanpa dependensi/plugin tambahan. Renderer: **Compatibility (OpenGL)** agar ringan di ponsel kelas bawah.

## Ekspor Android / iOS

`export_presets.cfg` sudah disiapkan (ikon, nama paket `id.ac.telkomuniversity.parentverse`, orientasi potret, arsitektur arm).

- **Android:** pasang export template 4.7.2 (`Editor → Manage Export Templates`), isi Android SDK + debug keystore di `Editor Settings → Export → Android`, lalu `Project → Export → Android`.
- **iOS:** ekspor harus dari macOS + Xcode, isi Team ID & bundle identifier pada preset.

## Struktur

```
project.godot            konfigurasi (autoload, potret 720×1280, canvas_items stretch)
scenes/main.tscn         titik masuk
scripts/autoload/        game_state (simpan progres), audio_manager (SFX/musik/TTS), router (navigasi)
scripts/ui/              UI kit: ui.gd (token warna & font), chunky.gd (tombol timbul),
                         character_view.gd (karakter berlapis), screen.gd (dasar layar), dll.
scripts/screens/         14 layar: splash, home, materi, cerita, 3 permainan, kesepakatan, evaluasi, kuis, info
scripts/data/            konten: 7 materi, 10 cerita, 12 soal tes, data permainan, identitas tim
assets/art/              102 ilustrasi SVG (karakter, latar, ikon) — tajam di semua resolusi
assets/audio/            11 efek suara + musik latar (ogg)
assets/fonts/            Fredoka & Nunito (SIL OFL 1.1, lisensi disertakan)
assets/icons/            ikon aplikasi Android adaptif + iOS 1024px
```

## Isi aplikasi

**4 kartu menu di beranda:**

| Menu | Isi |
| --- | --- |
| Jelajah Materi | 7 topik: dunia remaja, komunikasi positif, kelola emosi (rumus 3T + latihan napas), selesaikan konflik (langkah DAMAI), batasan & kesepakatan, parenting digital, kedekatan. Tiap topik: cerita pembuka, poin materi, bandingkan respons, tips bercentang, cek pemahaman. |
| Cerita Keluarga | 10 simulasi bercabang — 6 sebagai orang tua, 4 sebagai remaja. Tiap pilihan memberi reaksi tokoh, ulasan, dan meter kedekatan. |
| Main Bareng | Tangkap Kata Baik, Tebak Perasaan, Memori Kebersamaan, Kartu Kesepakatan (aturan keluarga + cap tanda tangan). |
| Evaluasi | Pre-test & post-test (12 soal acak), pembahasan, rapor belajar: pengetahuan, keterampilan, pemanfaatan. |

**Info Aplikasi** (tombol `i` di beranda) memuat ketua tim, anggota tim, anggota mahasiswa beserta NIM, mitra sasaran, program, tokoh, dan kredit.

Progres, nilai tes, dan kesepakatan tersimpan otomatis di perangkat (`user://parentverse_save.cfg`).

## Catatan teknis

- Bintang: materi (3 bintang bila cek pemahaman benar sekali coba), cerita (poin respons), permainan (skor/langkah).
- Pengaturan: musik, efek suara, teks lebih besar, panduan, dan hapus progres.
- Suara bacaan materi memakai TTS bawaan perangkat; tombolnya otomatis disembunyikan bila tidak tersedia.
- Tombol Back Android dan Esc ditangani per layar (menutup dialog → kembali → konfirmasi keluar).
