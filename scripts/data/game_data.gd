class_name GameData
extends RefCounted
## Data untuk permainan "Main Bareng" dan tips harian.

const MENU := [
	{"id": "game_kata", "judul": "Tangkap Kata Baik", "ket": "Ketuk gelembung kalimat positif, hindari kata yang menyakiti.", "ikon": "g_kata", "warna": "sun"},
	{"id": "game_emosi", "judul": "Tebak Perasaan", "ket": "Kenali perasaan anggota keluarga dari wajah dan ceritanya.", "ikon": "g_emosi", "warna": "sky"},
	{"id": "game_memori", "judul": "Memori Kebersamaan", "ket": "Cocokkan kartu kegiatan seru bersama keluarga.", "ikon": "g_memori", "warna": "coral"},
	{"id": "kesepakatan", "judul": "Kartu Kesepakatan", "ket": "Susun aturan keluarga bersama, lalu tanda tangani.", "ikon": "g_kesepakatan", "warna": "teal"},
]

# --- Tangkap Kata Baik -----------------------------------------------------------
const KATA_BAIK := [
	"Terima kasih sudah cerita", "Bunda bangga sama usahamu", "Ayah dengar, lanjutkan ceritamu",
	"Yuk cari solusinya bareng", "Maaf ya, tadi Ayah salah", "Kamu pasti kecewa, ya",
	"Aku sayang kamu", "Boleh Bunda bantu?", "Hebat, kamu sudah berusaha!",
	"Kita sepakati bersama, ya", "Ceritakan harimu, dong", "Salah itu wajar, kita perbaiki",
	"Terima kasih sudah jujur", "Ayah percaya padamu", "Semangat ya, Nak!",
	"Maaf ya, Bun", "Makasih, Yah!", "Aku bantu cuci piring, ya",
]

const KATA_BURUK := [
	{"kata": "Dasar pemalas!", "ganti": "Yuk, Bunda temani mulai mengerjakannya."},
	{"kata": "Lihat tuh anak tetangga!", "ganti": "Bunda lihat kamu sudah berusaha. Ayo tingkatkan lagi."},
	{"kata": "Pokoknya nurut saja!", "ganti": "Ayah jelaskan alasannya, ya. Menurutmu bagaimana?"},
	{"kata": "Kamu selalu bikin masalah", "ganti": "Ada apa? Yuk kita perbaiki bersama."},
	{"kata": "Diam! Anak kecil tahu apa?", "ganti": "Coba ceritakan pendapatmu, Ayah dengarkan."},
	{"kata": "Terserah, Ayah nggak peduli", "ganti": "Ayah peduli. Kita bicarakan setelah tenang, ya."},
	{"kata": "Kamu nggak bisa apa-apa", "ganti": "Belum bisa itu wajar. Kita latihan pelan-pelan."},
	{"kata": "Gitu aja nangis", "ganti": "Kamu sedih, ya? Nggak apa-apa, Bunda di sini."},
	{"kata": "Bodoh banget sih", "ganti": "Salah itu bagian dari belajar."},
	{"kata": "Ah, masalah sepele itu", "ganti": "Kelihatannya ini penting buatmu. Ceritakan, ya."},
	{"kata": "Bunda capek ngurusin kamu", "ganti": "Bunda lelah. Bunda istirahat sebentar, ya."},
	{"kata": "Bunda nggak asyik!", "ganti": "Aku kesal, Bun. Boleh kita bicarakan?"},
]

# --- Tebak Perasaan ----------------------------------------------------------------
const EMOSI := {
	"senang": "Senang", "sedih": "Sedih", "marah": "Marah", "cemas": "Cemas", "kaget": "Kaget", "malu": "Malu",
}

const SITUASI := [
	{"tokoh": "raka", "emosi": "sedih", "teks": "Raka gagal terpilih masuk tim futsal sekolah.",
		"tips": "Validasi perasaannya: “Kamu pasti kecewa, ya.”"},
	{"tokoh": "nara", "emosi": "senang", "teks": "Nara dipuji guru karena tariannya bagus.",
		"tips": "Ikut bergembira dan puji usahanya."},
	{"tokoh": "raka", "emosi": "marah", "teks": "Raka dituduh mengambil pulpen temannya, padahal tidak.",
		"tips": "Biarkan ia meluapkan perasaan dengan aman, lalu ajak bicara saat tenang."},
	{"tokoh": "nara", "emosi": "cemas", "teks": "Besok Nara harus presentasi di depan kelas.",
		"tips": "Tenangkan: “Wajar gugup. Yuk, latihan bareng Bunda.”"},
	{"tokoh": "raka", "emosi": "kaget", "teks": "Raka tiba-tiba diberi kejutan ulang tahun oleh keluarganya.", "bukan": ["senang"],
		"tips": "Kejutan kecil membuat anak merasa diperhatikan."},
	{"tokoh": "nara", "emosi": "malu", "teks": "Nara tersandung di depan teman-temannya.",
		"tips": "Jangan menertawakan. Katakan: “Itu bisa terjadi pada siapa saja.”"},
	{"tokoh": "bunda", "emosi": "cemas", "teks": "Bunda menunggu Nara yang belum pulang, padahal sudah malam.",
		"tips": "Untuk anak: kabari orang tua jika terlambat agar mereka tidak khawatir."},
	{"tokoh": "ayah", "emosi": "senang", "teks": "Ayah melihat Raka mencuci piring tanpa disuruh.",
		"tips": "Bantuan kecil membuat orang tua bahagia."},
	{"tokoh": "ayah", "emosi": "sedih", "teks": "Ayah mendengar Raka berkata kasar kepadanya.",
		"tips": "Kata-kata kasar bisa melukai. Minta maaflah jika terlanjur."},
	{"tokoh": "bunda", "emosi": "marah", "teks": "Rumah kembali berantakan padahal baru saja dibersihkan Bunda.",
		"tips": "Orang tua juga bisa kesal. Bantu membereskan dan minta maaf."},
	{"tokoh": "raka", "emosi": "malu", "teks": "Raka digoda kakaknya karena ketahuan menyukai teman sekelas.",
		"tips": "Hormati perasaannya, jangan jadikan bahan ejekan."},
	{"tokoh": "nara", "emosi": "sedih", "teks": "Sahabat Nara pindah sekolah ke kota lain.",
		"tips": "Dengarkan dan temani. Rasa kehilangan butuh waktu."},
	{"tokoh": "oyen", "emosi": "kaget", "teks": "Oyen mendengar suara petasan yang tiba-tiba.", "bukan": ["cemas"],
		"tips": "Kaget itu reaksi alami. Tenangkan diri dulu sebelum bertindak."},
	{"tokoh": "raka", "emosi": "cemas", "teks": "Raka belum mengerjakan PR, padahal besok dikumpulkan.",
		"tips": "Bantu ia membuat rencana, jangan langsung dimarahi."},
	{"tokoh": "bunda", "emosi": "senang", "teks": "Nara memeluk Bunda dan berkata, “Terima kasih, Bun!”",
		"tips": "Ungkapan sayang membuat hati orang tua hangat."},
	{"tokoh": "nara", "emosi": "marah", "teks": "Nara kesal karena HP-nya dibuka tanpa izin.",
		"tips": "Hormati privasi. Minta izin dan bicarakan baik-baik."},
	{"tokoh": "oyen", "emosi": "sedih", "teks": "Oyen tidak diajak bermain seharian.",
		"tips": "Semua makhluk butuh perhatian. Luangkan waktu untuk bermain bersama."},
]

# --- Memori Kebersamaan ------------------------------------------------------------
const KEGIATAN := [
	{"ikon": "a_makan", "nama": "Makan Bersama", "tips": "Makan bersama tanpa gawai membuka banyak obrolan."},
	{"ikon": "a_ngobrol", "nama": "Ngobrol Santai", "tips": "Mengobrol 15 menit setiap hari membuat anak lebih terbuka."},
	{"ikon": "a_olahraga", "nama": "Main Bulu Tangkis", "tips": "Bergerak bersama menyehatkan tubuh dan hati."},
	{"ikon": "a_masak", "nama": "Masak Bareng", "tips": "Memasak bersama melatih kerja sama dan tanggung jawab."},
	{"ikon": "a_berkebun", "nama": "Berkebun", "tips": "Merawat tanaman bersama mengajarkan kesabaran."},
	{"ikon": "a_membaca", "nama": "Membaca Bersama", "tips": "Membaca bersama menumbuhkan minat belajar."},
	{"ikon": "a_layangan", "nama": "Main Layangan", "tips": "Permainan tradisional seru dimainkan lintas generasi."},
	{"ikon": "a_sepeda", "nama": "Bersepeda Sore", "tips": "Bersepeda sore jadi momen mengobrol yang santai."},
]

# --- Kartu Kesepakatan -------------------------------------------------------------
const KESEPAKATAN := [
	{"judul": "Waktu Gawai", "ikon": "t_digital", "warna": "sky", "butir": [
		"Main HP/game paling lama 2 jam di hari sekolah",
		"HP diisi daya di ruang tengah saat tidur",
		"Bebas gawai 1 jam sebelum tidur",
		"Tidak main HP saat makan bersama",
	]},
	{"judul": "Aman di Dunia Maya", "ikon": "t_kesepakatan", "warna": "teal", "butir": [
		"Tidak membagikan alamat, nomor HP, dan kata sandi",
		"Minta izin sebelum mengunduh aplikasi atau game baru",
		"Cerita ke orang tua jika ada pesan yang membuat tidak nyaman",
	]},
	{"judul": "Tanggung Jawab", "ikon": "t_remaja", "warna": "sun", "butir": [
		"Pulang sesuai jam yang disepakati, kabari jika terlambat",
		"Belajar dulu sebelum bermain",
		"Membantu pekerjaan rumah setiap hari",
	]},
	{"judul": "Kebersamaan", "ikon": "t_kedekatan", "warna": "coral", "butir": [
		"Mengobrol 15 menit setiap hari",
		"Makan malam bersama",
		"Akhir pekan bermain atau berolahraga bersama",
	]},
	{"judul": "Janji Orang Tua", "ikon": "t_komunikasi", "warna": "berry", "butir": [
		"Mendengarkan dulu sebelum menasihati",
		"Tidak membentak saat marah, tenang dulu",
		"Ikut menaruh HP saat waktu keluarga",
		"Menghargai privasi anak",
	]},
]

# --- Tips harian di beranda ----------------------------------------------------------
const TIPS := [
	"Taruh HP saat anak bercerita. Tatapan mata membuat anak merasa didengar.",
	"Puji usahanya, bukan hanya hasilnya.",
	"Marah boleh, membentak jangan. Tarik napas dulu, ya!",
	"Ajak anak menyusun aturan bersama. Aturan buatan bersama lebih mudah ditaati.",
	"Kenali teman-teman anak dan sambut mereka di rumah.",
	"Makan bersama tanpa gawai adalah waktu terbaik untuk mengobrol.",
	"Berani minta maaf itu tanda sayang, bukan tanda lemah.",
	"Tanyakan game atau aplikasi favorit anak dengan rasa ingin tahu.",
	"Biasakan berkata “tolong”, “terima kasih”, dan “maaf” di rumah.",
	"Anak belajar dari contoh. Jadilah teladan kebiasaan baik.",
	"Untuk anak: kabari orang tua jika pulang terlambat, ya!",
	"Untuk anak: ceritakan ke orang tua jika ada pesan aneh dari orang asing.",
]


static func color(name: String) -> Color:
	match name:
		"teal":
			return UI.TEAL
		"sky":
			return UI.SKY
		"coral":
			return UI.CORAL
		"sun":
			return UI.SUN
		"berry":
			return UI.BERRY
	return UI.TEAL


static func color_light(name: String) -> Color:
	match name:
		"teal":
			return UI.TEAL_L
		"sky":
			return UI.SKY_L
		"coral":
			return UI.CORAL_L
		"sun":
			return UI.SUN_L
		"berry":
			return UI.BERRY_L
	return UI.TEAL_L
