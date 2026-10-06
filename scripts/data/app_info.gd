class_name AppInfo
extends RefCounted
## Identitas aplikasi & tim pengabdian (ubah di sini bila ada perubahan data).

const NAMA := "PARENTVERSE"
const TAGLINE := "Multimedia Interaktif Parenting Remaja untuk Penguatan Relasi Keluarga"
const VERSI := "1.0.0"

const TENTANG := "PARENTVERSE adalah media belajar parenting remaja yang interaktif untuk orang tua dan anak. Di dalamnya ada materi bergambar, cerita keluarga dengan pilihan respons, permainan, serta pre-test dan post-test. Semua materi dapat dipelajari kembali kapan saja, tanpa koneksi internet."

const KETUA := {"nama": "Yohani Setiya Rafika Nur, S.Kom., M.Kom.", "inisial": "YS"}

const ANGGOTA := [
	{"nama": "Mahazam Afrad, S.Kom., M.Kom.", "inisial": "MA"},
	{"nama": "Gusnita Linda, S.Sn., M.Hum.", "inisial": "GL"},
]

const MAHASISWA := [
	{"nama": "Muhammad Nafal Fiqrian", "nim": "101132400003", "inisial": "MN"},
	{"nama": "Elisa Kusumaningsih", "nim": "101132400034", "inisial": "EK"},
	{"nama": "Ichya Ulumiddiin", "nim": "103112400076", "inisial": "IU"},
	{"nama": "Muhammad Zaky Mubarok", "nim": "103112400073", "inisial": "MZ"},
]

const MITRA := {
	"nama": "PKK Desa Muntang",
	"alamat": "Desa Muntang, Kecamatan Kemangkon, Kabupaten Purbalingga, Jawa Tengah",
}

const PROGRAM := [
	"Pengabdian kepada Masyarakat Telkom University 2026",
	"Skema Teknologi Tepat Guna (TTG)",
	"Telkom University Kampus Purwokerto",
	"Program Studi S1 Teknik Informatika",
]

const KREDIT := "Ilustrasi, musik, dan efek suara dibuat khusus untuk PARENTVERSE. Huruf Fredoka dan Nunito berlisensi SIL Open Font License 1.1. Dibuat dengan Godot Engine."

## Tokoh keluarga (dipakai di panduan & info).
const TOKOH := [
	{"id": "ayah", "nama": "Ayah Budi", "ket": "Ayah yang sabar, sedang belajar lebih banyak mendengar."},
	{"id": "bunda", "nama": "Bunda Sari", "ket": "Bunda yang hangat dan aktif di PKK desa."},
	{"id": "nara", "nama": "Nara, 15 th", "ket": "Kakak yang suka menari dan bermain media sosial."},
	{"id": "raka", "nama": "Raka, 14 th", "ket": "Adik yang hobi futsal dan main game."},
	{"id": "oyen", "nama": "Oyen", "ket": "Kucing keluarga yang menemanimu belajar."},
]
