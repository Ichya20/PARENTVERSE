class_name CeritaData
extends RefCounted
## Cerita keluarga interaktif (simulasi kasus). Enam cerita peran orang tua mengikuti contoh situasi
## pada proposal; empat cerita peran remaja untuk anak.
## Langkah: narasi, bicara, latar, pilih. Nilai opsi: 2 = terbaik, 1 = cukup, 0 = kurang tepat.
## "aku" = ekspresi tokoh pemain setelah memilih; "siapa" kosong = balasan berupa narasi.

const CERITA := [
	{
		"id": "pendiam", "peran": "ortu", "judul": "Raka Jadi Pendiam", "tema": "Keterbukaan",
		"latar": "ruang_tamu", "pemain": "bunda", "lawan": "raka",
		"langkah": [
			{"t": "narasi", "teks": "Sepulang sekolah, Raka langsung menuju kamar tanpa menyapa. Sudah seminggu ini ia jarang bercerita."},
			{"t": "bicara", "siapa": "bunda", "ekspresi": "netral", "teks": "Raka, sudah pulang? Gimana sekolahnya?"},
			{"t": "bicara", "siapa": "raka", "ekspresi": "sedih", "teks": "Biasa aja, Bun. Aku capek, mau ke kamar."},
			{"t": "pilih", "tanya": "Apa yang sebaiknya Bunda katakan?", "opsi": [
				{"teks": "“Kamu ini kenapa sih? Ditanya orang tua kok jawabnya begitu!”", "nilai": 0, "aku": "marah",
					"siapa": "raka", "ekspresi": "marah", "balas": "Tuh kan, aku belum ngomong apa-apa udah dimarahin.",
					"ulasan": "Nada menuduh membuat anak makin menutup diri. Remaja yang lelah butuh diterima dulu, bukan diinterogasi."},
				{"teks": "“Ya sudah, makan dulu sana.”", "nilai": 1, "aku": "netral",
					"siapa": "raka", "ekspresi": "netral", "balas": "Iya, nanti.",
					"ulasan": "Tidak salah, tetapi kesempatan untuk terhubung terlewat. Anak perlu tanda bahwa Bunda peduli pada perasaannya."},
				{"teks": "“Kelihatannya hari ini berat, ya. Istirahat dulu. Kalau nanti mau cerita, Bunda siap dengar.”", "nilai": 2, "aku": "senang",
					"siapa": "raka", "ekspresi": "malu", "balas": "…Makasih, Bun.",
					"ulasan": "Tepat! Bunda mengakui perasaannya dan membuka pintu tanpa memaksa. Anak merasa aman untuk bercerita saat ia siap."},
			]},
			{"t": "latar", "id": "kamar"},
			{"t": "narasi", "teks": "Malamnya, Bunda mengantar teh hangat ke kamar Raka. Raka tampak murung menatap layar HP-nya."},
			{"t": "bicara", "siapa": "raka", "ekspresi": "sedih", "teks": "Bun… teman-teman main bareng, tapi aku nggak diajak. Kayaknya mereka nggak suka aku."},
			{"t": "pilih", "tanya": "Bagaimana Bunda menanggapinya?", "opsi": [
				{"teks": "“Ah, cuma masalah sepele. Cari teman lain saja.”", "nilai": 0, "aku": "netral",
					"siapa": "raka", "ekspresi": "sedih", "balas": "Bunda nggak ngerti rasanya…",
					"ulasan": "Bagi remaja, pertemanan sangat penting. Meremehkan perasaannya membuat ia enggan bercerita lagi."},
				{"teks": "“Pasti sedih ya rasanya ditinggal teman. Mau cerita apa yang terjadi?”", "nilai": 2, "aku": "senang",
					"siapa": "raka", "ekspresi": "netral", "balas": "Iya, Bun… jadi gini ceritanya…",
					"ulasan": "Bagus! Mendengar aktif dan mengakui perasaan membuat Raka mau membuka diri. Solusi bisa dicari bersama setelahnya."},
				{"teks": "“Besok Bunda datangi sekolahmu, biar Bunda yang bicara sama mereka!”", "nilai": 1, "aku": "marah",
					"siapa": "raka", "ekspresi": "kaget", "balas": "Jangan, Bun! Nanti aku malah diejek!",
					"ulasan": "Niatnya melindungi, tetapi bertindak tanpa bertanya dulu bisa membuat remaja malu. Dengarkan dulu, lalu cari solusi bersama."},
			]},
		],
		"pesan": "Remaja yang jarang bercerita bukan berarti tidak butuh orang tua. Hadir, sabar, dan dengarkan.",
		"suara_hati": "Aku cuma butuh didengar dulu, bukan langsung dinasihati.", "pemilik_hati": "raka",
	},
	{
		"id": "ekskul", "peran": "ortu", "judul": "Beda Pilihan Ekskul", "tema": "Komunikasi",
		"latar": "ruang_makan", "pemain": "ayah", "lawan": "nara",
		"langkah": [
			{"t": "narasi", "teks": "Saat makan malam, Nara bercerita ingin ikut ekstrakurikuler tari tradisional. Padahal Ayah sudah mendaftarkannya les matematika di jam yang sama."},
			{"t": "bicara", "siapa": "nara", "ekspresi": "senang", "teks": "Yah, aku pengen banget ikut ekskul tari. Kata Bu Guru, aku berbakat!"},
			{"t": "pilih", "tanya": "Apa tanggapan Ayah?", "opsi": [
				{"teks": "“Tari itu buat apa? Nggak ada masa depannya. Les saja!”", "nilai": 0, "aku": "marah",
					"siapa": "nara", "ekspresi": "sedih", "balas": "Ayah selalu begitu, nggak pernah dukung aku.",
					"ulasan": "Meremehkan minat anak melukai harga dirinya. Remaja sedang membentuk jati diri, sehingga minatnya sangat berarti baginya."},
				{"teks": "“Wah, Ayah senang kamu punya minat. Ceritakan, apa yang bikin kamu suka menari?”", "nilai": 2, "aku": "senang",
					"siapa": "nara", "ekspresi": "senang", "balas": "Rasanya bebas, Yah! Aku juga jadi belajar budaya kita.",
					"ulasan": "Bagus! Ayah menunjukkan rasa ingin tahu sebelum memberi pendapat. Nara merasa dihargai."},
				{"teks": "“Nanti Ayah pikirkan dulu, ya.”", "nilai": 1, "aku": "netral",
					"siapa": "nara", "ekspresi": "cemas", "balas": "Hmm… iya, Yah.",
					"ulasan": "Menunda boleh, asal benar-benar dibahas lagi. Tunjukkan dulu bahwa Ayah tertarik pada ceritanya."},
			]},
			{"t": "narasi", "teks": "Ternyata jadwal latihan tari memang bentrok dengan les matematika. Nilai matematika Nara juga sedang turun."},
			{"t": "bicara", "siapa": "nara", "ekspresi": "cemas", "teks": "Terus gimana, Yah? Aku pengen ikut tari, tapi nilai matematikaku lagi jelek…"},
			{"t": "pilih", "tanya": "Bagaimana Ayah mencari jalan keluar?", "opsi": [
				{"teks": "“Ayah yang memutuskan: les matematika. Titik.”", "nilai": 0, "aku": "marah",
					"siapa": "nara", "ekspresi": "marah", "balas": "Percuma aku cerita!",
					"ulasan": "Keputusan sepihak membuat anak merasa tidak dianggap dan bisa memicu pemberontakan diam-diam."},
				{"teks": "“Ya sudah, ikut tari saja. Lesnya tidak usah.”", "nilai": 1, "aku": "netral",
					"siapa": "nara", "ekspresi": "senang", "balas": "Yeay! Makasih, Yah!",
					"ulasan": "Anak senang, tetapi masalah nilai belum terselesaikan. Musyawarah untuk mencari jalan tengah lebih baik."},
				{"teks": "“Bagaimana kalau tetap ikut tari, dan lesnya pindah ke hari Sabtu? Kita coba sebulan, lalu evaluasi bersama.”", "nilai": 2, "aku": "senang",
					"siapa": "nara", "ekspresi": "senang", "balas": "Setuju, Yah! Aku janji belajar lebih serius.",
					"ulasan": "Hebat! Ini contoh musyawarah: kebutuhan anak dan orang tua sama-sama diperhatikan, lalu dievaluasi bersama."},
			]},
		],
		"pesan": "Beda pendapat bukan berarti bermusuhan. Dengarkan, lalu cari solusi yang adil bersama.",
		"suara_hati": "Aku jadi semangat karena Ayah mau mendengar dan menghargai pilihanku.", "pemilik_hati": "nara",
	},
	{
		"id": "pintu", "peran": "ortu", "judul": "Pintu yang Dibanting", "tema": "Emosi",
		"latar": "ruang_tamu", "pemain": "bunda", "lawan": "raka",
		"langkah": [
			{"t": "narasi", "teks": "Raka pulang dengan wajah masam. Ia melempar tasnya ke sofa lalu membanting pintu kamar. BRAK!"},
			{"t": "bicara", "siapa": "bunda", "ekspresi": "kaget", "teks": "Astaga, Raka!"},
			{"t": "pilih", "tanya": "Bunda kaget dan mulai kesal. Apa yang Bunda lakukan?", "opsi": [
				{"teks": "Menggedor pintu: “Raka! Buka pintunya! Nggak sopan banget kamu!”", "nilai": 0, "aku": "marah",
					"siapa": "raka", "ekspresi": "marah", "balas": "Biarin aku sendiri!",
					"ulasan": "Membalas emosi dengan emosi membuat konflik makin panas. Saat anak marah, orang tua perlu tenang lebih dulu."},
				{"teks": "Menarik napas dulu, lalu mengetuk pelan: “Bunda di sini kalau kamu butuh. Kita ngobrol kalau kamu sudah tenang.”", "nilai": 2, "aku": "netral",
					"siapa": "raka", "ekspresi": "sedih", "balas": "…Iya, Bun. Nanti aku keluar.",
					"ulasan": "Tepat! Bunda mengelola emosinya dulu (Rumus 3T) dan memberi ruang. Ini juga contoh nyata pengelolaan emosi bagi Raka."},
				{"teks": "Diam saja dan membiarkannya sampai besok tanpa bertanya.", "nilai": 1, "aku": "cemas",
					"siapa": "", "ekspresi": "", "balas": "Raka tetap mengurung diri di kamar sampai malam.",
					"ulasan": "Memberi ruang itu baik, tetapi tetap perlu tanda bahwa Bunda peduli dan siap mendengar."},
			]},
			{"t": "narasi", "teks": "Satu jam kemudian Raka keluar dari kamar. Ia bercerita gagal terpilih masuk tim futsal sekolah."},
			{"t": "bicara", "siapa": "raka", "ekspresi": "sedih", "teks": "Aku udah latihan keras, Bun. Tapi tetap nggak kepilih."},
			{"t": "pilih", "tanya": "Bagaimana Bunda menanggapinya?", "opsi": [
				{"teks": "“Sudahlah, futsal itu nggak penting. Fokus belajar saja.”", "nilai": 1, "aku": "netral",
					"siapa": "raka", "ekspresi": "sedih", "balas": "Buat aku penting, Bun…",
					"ulasan": "Niatnya menghibur, tetapi meremehkan hal yang penting bagi anak. Akui dulu perasaannya."},
				{"teks": "“Kamu pasti kecewa sekali, ya. Bunda bangga kamu sudah berusaha keras. Tadi marah boleh, tapi lain kali pintunya jangan dibanting, ya.”", "nilai": 2, "aku": "senang",
					"siapa": "raka", "ekspresi": "malu", "balas": "Iya, Bun. Maaf tadi aku banting pintu.",
					"ulasan": "Sempurna! Bunda memvalidasi perasaan, menghargai usaha, lalu tetap menegaskan batasan perilaku dengan lembut."},
				{"teks": "“Makanya, kalau marah jangan banting pintu! Bunda malu sama tetangga.”", "nilai": 0, "aku": "marah",
					"siapa": "raka", "ekspresi": "marah", "balas": "Bunda lebih peduli tetangga daripada aku!",
					"ulasan": "Menegur boleh, tetapi bukan saat anak sedang terluka. Dengarkan dan hibur dulu, baru bahas perilakunya."},
			]},
		],
		"pesan": "Emosi remaja yang meledak sering menutupi rasa sedih atau kecewa. Tenangkan diri, beri ruang, lalu hadir.",
		"suara_hati": "Aku sebenarnya bukan marah sama Bunda. Aku cuma kecewa sama diriku sendiri.", "pemilik_hati": "raka",
	},
	{
		"id": "teman", "peran": "ortu", "judul": "Teman Baru Nara", "tema": "Batasan",
		"latar": "teras", "pemain": "ayah", "lawan": "nara",
		"langkah": [
			{"t": "narasi", "teks": "Sore itu Nara minta izin bermain ke rumah teman barunya di desa sebelah. Ayah belum mengenal teman itu."},
			{"t": "bicara", "siapa": "nara", "ekspresi": "senang", "teks": "Yah, aku boleh main ke rumah Dinda? Dia teman baru di kelas, baik banget orangnya!"},
			{"t": "pilih", "tanya": "Apa jawaban Ayah?", "opsi": [
				{"teks": "“Nggak boleh! Ayah nggak kenal anak itu. Di rumah saja!”", "nilai": 0, "aku": "marah",
					"siapa": "nara", "ekspresi": "marah", "balas": "Ayah nggak pernah percaya sama aku!",
					"ulasan": "Larangan tanpa penjelasan membuat anak merasa tidak dipercaya dan bisa mendorongnya pergi diam-diam."},
				{"teks": "“Boleh, Ayah senang kamu punya teman baru. Ayah boleh kenalan dulu sama Dinda dan orang tuanya?”", "nilai": 2, "aku": "senang",
					"siapa": "nara", "ekspresi": "senang", "balas": "Boleh, Yah! Nanti aku kenalkan.",
					"ulasan": "Bagus! Ayah memberi kepercayaan sekaligus tetap terlibat. Mengenal teman anak adalah bentuk pengawasan yang hangat."},
				{"teks": "“Terserah kamu saja, yang penting jangan merepotkan.”", "nilai": 1, "aku": "netral",
					"siapa": "nara", "ekspresi": "netral", "balas": "Oke, Yah…",
					"ulasan": "Terlalu longgar. Remaja tetap butuh pendampingan dan batasan yang jelas dari orang tua."},
			]},
			{"t": "narasi", "teks": "Setelah berkenalan dengan Dinda dan ibunya, Ayah merasa tenang. Kini saatnya menyepakati aturan main."},
			{"t": "bicara", "siapa": "nara", "ekspresi": "senang", "teks": "Jadi aku boleh berangkat sekarang, Yah?"},
			{"t": "pilih", "tanya": "Kesepakatan apa yang Ayah buat?", "opsi": [
				{"teks": "“Boleh. Kita sepakati pulang paling lambat pukul 17.30, ya. Kalau ada perubahan rencana, kabari Ayah.”", "nilai": 2, "aku": "senang",
					"siapa": "nara", "ekspresi": "senang", "balas": "Siap, Yah! Aku janji.",
					"ulasan": "Tepat! Batasan yang jelas (jam pulang & kabar) membuat anak tahu apa yang diharapkan dan orang tua tetap tenang."},
				{"teks": "“Berangkatlah, tapi Ayah akan meneleponmu setiap 15 menit.”", "nilai": 0, "aku": "cemas",
					"siapa": "nara", "ekspresi": "malu", "balas": "Yah… aku malu sama teman-teman.",
					"ulasan": "Pengawasan berlebihan membuat remaja malu dan merasa tidak dipercaya. Pengawasan perlu proporsional."},
				{"teks": "“Berangkatlah, pulangnya terserah kamu.”", "nilai": 1, "aku": "netral",
					"siapa": "nara", "ekspresi": "kaget", "balas": "Beneran, Yah? Hehe…",
					"ulasan": "Tanpa batasan yang jelas, anak tidak tahu apa yang diharapkan. Batasan justru membuat anak merasa aman."},
			]},
		],
		"pesan": "Kenali teman-teman anak, beri kepercayaan, dan sepakati batasan yang jelas.",
		"suara_hati": "Aku senang Ayah percaya padaku. Aku jadi ingin menjaga kepercayaan itu.", "pemilik_hati": "nara",
	},
	{
		"id": "gawai", "peran": "ortu", "judul": "Main Game Sampai Larut", "tema": "Digital",
		"latar": "kamar", "pemain": "bunda", "lawan": "raka",
		"langkah": [
			{"t": "narasi", "teks": "Sudah pukul 22.00. Bunda melihat cahaya HP dari kamar Raka. Besok Raka harus sekolah pagi."},
			{"t": "bicara", "siapa": "raka", "ekspresi": "senang", "teks": "Bentar lagi, Bun! Tanggung, timku hampir menang!"},
			{"t": "pilih", "tanya": "Apa yang Bunda lakukan?", "opsi": [
				{"teks": "Merebut HP-nya: “Sudah! HP ini Bunda sita!”", "nilai": 0, "aku": "marah",
					"siapa": "raka", "ekspresi": "marah", "balas": "Bunda! Timku jadi kalah gara-gara Bunda!",
					"ulasan": "Merampas HP secara tiba-tiba memicu pertengkaran dan bisa membuat anak bermain diam-diam."},
				{"teks": "“Bunda tunggu sampai ronde ini selesai, ya. Setelah itu HP-nya kita isi daya di ruang tengah.”", "nilai": 2, "aku": "netral",
					"siapa": "raka", "ekspresi": "cemas", "balas": "Hmm… oke, Bun. Satu ronde lagi.",
					"ulasan": "Bagus! Bunda menghargai aktivitas Raka sambil tetap tegas pada batasan. Peringatan sebelum berhenti lebih mudah diterima."},
				{"teks": "Membiarkannya karena takut Raka marah.", "nilai": 1, "aku": "cemas",
					"siapa": "raka", "ekspresi": "senang", "balas": "Asyik, lanjut terus!",
					"ulasan": "Membiarkan tanpa batasan dapat mengganggu tidur dan kesehatan anak. Orang tua tetap perlu hadir dengan tegas dan hangat."},
			]},
			{"t": "latar", "id": "ruang_tamu"},
			{"t": "narasi", "teks": "Keesokan harinya, Bunda mengajak Raka berbicara saat santai sore."},
			{"t": "bicara", "siapa": "raka", "ekspresi": "netral", "teks": "Bun, aku tahu semalam kelamaan main. Tapi aku butuh main buat melepas penat."},
			{"t": "pilih", "tanya": "Bagaimana Bunda menyusun aturan bersama?", "opsi": [
				{"teks": "Menyusun kesepakatan bersama: main game 1 jam setelah belajar, HP diisi daya di luar kamar pukul 21.00, dan Bunda juga tidak main HP saat makan.", "nilai": 2, "aku": "senang",
					"siapa": "raka", "ekspresi": "senang", "balas": "Adil, Bun! Aku setuju.",
					"ulasan": "Hebat! Kesepakatan dibuat bersama, jelas, dan berlaku untuk semua anggota keluarga, termasuk orang tua."},
				{"teks": "“Mulai sekarang tidak ada game sama sekali!”", "nilai": 0, "aku": "marah",
					"siapa": "raka", "ekspresi": "sedih", "balas": "Kok gitu sih, Bun…",
					"ulasan": "Larangan total sulit dijalankan dan tidak mengajarkan pengendalian diri. Kesepakatan yang seimbang lebih efektif."},
				{"teks": "“Terserah kamu, asal nilainya bagus.”", "nilai": 1, "aku": "netral",
					"siapa": "raka", "ekspresi": "netral", "balas": "Oke…",
					"ulasan": "Kurang jelas. Tanpa batasan waktu yang disepakati, kebiasaan begadang bisa terulang."},
			]},
		],
		"pesan": "Gawai bukan musuh. Kesepakatan yang jelas, adil, dan dijalankan bersama adalah kuncinya.",
		"suara_hati": "Aku lebih mau ikut aturan kalau aku ikut menyusunnya.", "pemilik_hati": "raka",
	},
	{
		"id": "telat", "peran": "ortu", "judul": "Pulang Terlambat", "tema": "Kesepakatan",
		"latar": "malam", "pemain": "ayah", "lawan": "nara",
		"langkah": [
			{"t": "narasi", "teks": "Kesepakatan keluarga: Nara pulang paling lambat pukul 18.00. Sekarang sudah pukul 19.30. Nara baru sampai di depan rumah, dan HP-nya tidak bisa dihubungi."},
			{"t": "bicara", "siapa": "ayah", "ekspresi": "cemas", "teks": "Nara! Dari mana saja kamu?"},
			{"t": "bicara", "siapa": "nara", "ekspresi": "cemas", "teks": "Maaf, Yah… tadi kerja kelompok, terus HP-ku mati."},
			{"t": "pilih", "tanya": "Ayah sangat khawatir. Apa yang Ayah katakan?", "opsi": [
				{"teks": "“Kamu ini nggak bisa dipercaya! Mulai besok nggak boleh keluar rumah!”", "nilai": 0, "aku": "marah",
					"siapa": "nara", "ekspresi": "sedih", "balas": "(Nara menangis dan masuk ke kamar.)",
					"ulasan": "Kemarahan dan hukuman mendadak menutup kesempatan mendengar alasan anak. Anak juga bisa belajar menyembunyikan masalah."},
				{"teks": "“Syukurlah kamu selamat. Ayah khawatir sekali tadi. Masuk dulu, kita bicarakan setelah kamu makan.”", "nilai": 2, "aku": "netral",
					"siapa": "nara", "ekspresi": "malu", "balas": "Iya, Yah. Maaf sudah bikin khawatir.",
					"ulasan": "Tepat! Ayah mengungkapkan perasaan dengan pesan “Aku” dan menunda pembahasan sampai suasana tenang."},
				{"teks": "Diam saja dan tidak menyapa Nara sampai besok.", "nilai": 1, "aku": "marah",
					"siapa": "nara", "ekspresi": "cemas", "balas": "Ayah…?",
					"ulasan": "Mendiamkan membuat anak bingung dan cemas. Lebih baik sampaikan perasaan dengan jujur dan tenang."},
			]},
			{"t": "latar", "id": "ruang_tamu"},
			{"t": "narasi", "teks": "Setelah makan, Ayah dan Nara duduk bersama di ruang tamu."},
			{"t": "bicara", "siapa": "nara", "ekspresi": "netral", "teks": "Yah, aku tahu aku salah. Aku harus gimana?"},
			{"t": "pilih", "tanya": "Bagaimana Ayah menegakkan kesepakatan?", "opsi": [
				{"teks": "“Sesuai kesepakatan, besok kamu belum boleh main keluar dulu. Lain kali, pinjam HP teman untuk mengabari Ayah, ya.”", "nilai": 2, "aku": "senang",
					"siapa": "nara", "ekspresi": "netral", "balas": "Iya, Yah. Aku terima. Lain kali aku pasti kabari.",
					"ulasan": "Hebat! Konsekuensi dijalankan sesuai kesepakatan dengan tenang, disertai solusi agar tidak terulang."},
				{"teks": "“Ya sudah, lupakan saja. Yang penting kamu sudah pulang.”", "nilai": 1, "aku": "netral",
					"siapa": "nara", "ekspresi": "senang", "balas": "Wah, makasih, Yah!",
					"ulasan": "Hangat, tetapi kesepakatan jadi tidak berarti. Konsistensi membuat aturan dihargai."},
				{"teks": "“Pokoknya HP-mu Ayah sita sebulan!”", "nilai": 0, "aku": "marah",
					"siapa": "nara", "ekspresi": "marah", "balas": "Itu nggak adil, Yah!",
					"ulasan": "Konsekuensi yang tidak disepakati sebelumnya dan berlebihan terasa tidak adil, sehingga anak tidak belajar tanggung jawab."},
			]},
		],
		"pesan": "Saat kesepakatan dilanggar: tenangkan diri, dengarkan alasannya, lalu jalankan konsekuensi yang sudah disepakati.",
		"suara_hati": "Aku tahu aku salah. Untung Ayah mau dengar dulu, jadi aku tidak takut jujur.", "pemilik_hati": "nara",
	},
	# ---------------------------------------------------------------- peran remaja
	{
		"id": "r_hp", "peran": "remaja", "judul": "Waktunya Simpan HP", "tema": "Digital",
		"latar": "ruang_tamu", "pemain": "raka", "lawan": "bunda",
		"langkah": [
			{"t": "narasi", "teks": "Kamu berperan sebagai Raka. Kesepakatan di rumah: HP disimpan pukul 21.00. Padahal teman-teman masih ramai di grup."},
			{"t": "bicara", "siapa": "bunda", "ekspresi": "netral", "teks": "Raka, sudah jam sembilan. HP-nya ditaruh di ruang tengah, ya."},
			{"t": "pilih", "tanya": "Apa yang kamu lakukan?", "opsi": [
				{"teks": "Melempar HP ke sofa: “Bunda nggak asyik! Semua temanku masih main!”", "nilai": 0, "aku": "marah",
					"siapa": "bunda", "ekspresi": "sedih", "balas": "Bunda sedih kamu bicara seperti itu.",
					"ulasan": "Wajar merasa kesal, tetapi melempar barang dan berkata kasar membuat orang tua sedih dan suasana jadi tegang."},
				{"teks": "Pura-pura menaruh HP, lalu diam-diam main lagi di kamar.", "nilai": 1, "aku": "cemas",
					"siapa": "bunda", "ekspresi": "kaget", "balas": "Lho, kok HP-nya masih menyala?",
					"ulasan": "Melanggar diam-diam merusak kepercayaan. Kalau ketahuan, aturan bisa jadi makin ketat."},
				{"teks": "“Oke, Bun. Tapi boleh aku pamit dulu ke grup lima menit?”", "nilai": 2, "aku": "netral",
					"siapa": "bunda", "ekspresi": "senang", "balas": "Boleh, Nak. Terima kasih sudah mau mengerti.",
					"ulasan": "Hebat! Kamu menyampaikan kebutuhanmu dengan sopan dan tetap menghargai kesepakatan."},
			]},
			{"t": "narasi", "teks": "Besoknya, kamu ingin jam HP diundur karena ada tugas kelompok lewat video call."},
			{"t": "bicara", "siapa": "bunda", "ekspresi": "netral", "teks": "Ada apa, Nak? Kelihatannya mau ngomong sesuatu."},
			{"t": "pilih", "tanya": "Bagaimana caramu menyampaikannya?", "opsi": [
				{"teks": "“Bun, minggu ini ada tugas kelompok lewat video call sampai jam 21.30. Boleh jam HP-nya diundur khusus minggu ini?”", "nilai": 2, "aku": "netral",
					"siapa": "bunda", "ekspresi": "senang", "balas": "Terima kasih sudah jujur. Boleh, khusus minggu ini, ya.",
					"ulasan": "Tepat! Kamu menjelaskan alasan dengan jelas dan menawarkan batas waktu. Orang tua jadi lebih mudah percaya."},
				{"teks": "“Pokoknya aku mau pegang HP sampai malam!”", "nilai": 0, "aku": "marah",
					"siapa": "bunda", "ekspresi": "cemas", "balas": "Kalau begitu, Bunda belum bisa setuju.",
					"ulasan": "Menuntut tanpa alasan membuat orang tua sulit memahami kebutuhanmu."},
				{"teks": "Tidak bilang apa-apa dan memendam rasa kesal.", "nilai": 1, "aku": "sedih",
					"siapa": "bunda", "ekspresi": "cemas", "balas": "Raka kenapa, ya? Kok diam saja.",
					"ulasan": "Memendam perasaan membuat masalah tidak selesai. Orang tua tidak bisa membantu kalau tidak tahu."},
			]},
		],
		"pesan": "Kesepakatan bisa diubah kalau dibicarakan baik-baik dengan alasan yang jelas.",
		"suara_hati": "Bunda senang kalau Raka mau bicara. Bunda pun bisa menyesuaikan aturan.", "pemilik_hati": "bunda",
	},
	{
		"id": "r_nilai", "peran": "remaja", "judul": "Nilai Ulangan Jelek", "tema": "Keterbukaan",
		"latar": "ruang_makan", "pemain": "nara", "lawan": "ayah",
		"langkah": [
			{"t": "narasi", "teks": "Kamu berperan sebagai Nara. Nilai ulangan matematikamu 55. Kamu takut Ayah marah."},
			{"t": "bicara", "siapa": "ayah", "ekspresi": "senang", "teks": "Nara, gimana ulangan matematikanya? Sudah dibagikan?"},
			{"t": "pilih", "tanya": "Apa yang kamu katakan?", "opsi": [
				{"teks": "Berbohong: “Belum dibagikan, Yah.”", "nilai": 0, "aku": "cemas",
					"siapa": "ayah", "ekspresi": "netral", "balas": "Oh, ya sudah.",
					"ulasan": "Berbohong mungkin terasa aman sesaat, tetapi kalau ketahuan, kepercayaan Ayah bisa hilang."},
				{"teks": "Jujur: “Sudah, Yah. Nilaiku 55… Aku takut Ayah marah.”", "nilai": 2, "aku": "sedih",
					"siapa": "ayah", "ekspresi": "netral", "balas": "Terima kasih sudah jujur, Nak. Ayah tidak marah.",
					"ulasan": "Berani! Jujur sambil menyampaikan perasaanmu membantu Ayah memahami dan menanggapi dengan tenang."},
				{"teks": "“Kok tanya-tanya terus sih, Yah?”", "nilai": 1, "aku": "marah",
					"siapa": "ayah", "ekspresi": "kaget", "balas": "Lho, Ayah cuma ingin tahu.",
					"ulasan": "Menjawab ketus membuat obrolan jadi tegang, padahal Ayah ingin peduli."},
			]},
			{"t": "bicara", "siapa": "ayah", "ekspresi": "netral", "teks": "Menurutmu, bagian mana yang paling sulit?"},
			{"t": "pilih", "tanya": "Apa jawabanmu?", "opsi": [
				{"teks": "“Bagian pecahan, Yah. Boleh Ayah bantu ajari, atau kita cari video belajar bareng?”", "nilai": 2, "aku": "senang",
					"siapa": "ayah", "ekspresi": "senang", "balas": "Boleh! Malam ini kita belajar bersama, ya.",
					"ulasan": "Hebat! Kamu tahu kesulitanmu dan berani meminta bantuan. Itu tanda tanggung jawab."},
				{"teks": "“Nggak tahu, Yah. Semuanya susah.”", "nilai": 1, "aku": "sedih",
					"siapa": "ayah", "ekspresi": "cemas", "balas": "Hmm, coba kita lihat soalnya bareng, ya.",
					"ulasan": "Wajar merasa kewalahan. Coba sebutkan bagian yang paling sulit agar solusinya bisa dicari."},
				{"teks": "“Gurunya aja yang nggak jelas ngajarnya!”", "nilai": 0, "aku": "marah",
					"siapa": "ayah", "ekspresi": "netral", "balas": "Bisa jadi. Tapi apa yang bisa kamu lakukan?",
					"ulasan": "Menyalahkan orang lain tidak menyelesaikan masalah. Fokus pada apa yang bisa kamu lakukan."},
			]},
		],
		"pesan": "Jujur dan berani minta bantuan membuat orang tua lebih mudah mendukungmu.",
		"suara_hati": "Ayah lebih bangga pada kejujuranmu daripada sekadar angka di kertas ulangan.", "pemilik_hati": "ayah",
	},
	{
		"id": "r_pesan", "peran": "remaja", "judul": "Pesan dari Orang Asing", "tema": "Keamanan Digital",
		"latar": "kamar", "pemain": "nara", "lawan": "bunda",
		"langkah": [
			{"t": "narasi", "teks": "Kamu berperan sebagai Nara. Akun tak dikenal mengirim pesan: “Kamu cantik. Kirim fotomu dong, nanti kukasih pulsa.”"},
			{"t": "pilih", "tanya": "Apa yang kamu lakukan?", "opsi": [
				{"teks": "Membalas dan mengirim foto karena tergiur pulsa.", "nilai": 0, "aku": "cemas",
					"siapa": "", "ekspresi": "", "balas": "Akun itu terus meminta foto lain dan mulai mengancam.",
					"ulasan": "Berbahaya! Foto yang dikirim ke orang asing bisa disalahgunakan. Jangan pernah membagikan foto atau data pribadi kepada orang yang tidak dikenal."},
				{"teks": "Tidak membalas, menyimpan tangkapan layar sebagai bukti, lalu bercerita ke Bunda.", "nilai": 2, "aku": "cemas",
					"siapa": "bunda", "ekspresi": "kaget", "balas": "Ada apa, Nara? Coba Bunda lihat.",
					"ulasan": "Tepat! Jangan dibalas, simpan bukti, dan ceritakan kepada orang dewasa yang dipercaya."},
				{"teks": "Langsung menghapus pesannya dan diam saja.", "nilai": 1, "aku": "cemas",
					"siapa": "", "ekspresi": "", "balas": "Pesan terhapus, tetapi akun itu masih bisa mengirim pesan lagi.",
					"ulasan": "Tidak membalas itu bagus, tetapi lebih aman jika kamu memblokir akun dan bercerita kepada orang tua."},
			]},
			{"t": "bicara", "siapa": "bunda", "ekspresi": "netral", "teks": "Terima kasih sudah cerita, Nara. Kamu tidak salah. Yuk, kita bereskan bersama."},
			{"t": "pilih", "tanya": "Apa yang kamu lakukan bersama Bunda?", "opsi": [
				{"teks": "Memblokir dan melaporkan akun itu bersama Bunda, lalu mengatur akun menjadi privat.", "nilai": 2, "aku": "senang",
					"siapa": "bunda", "ekspresi": "senang", "balas": "Pintar! Sekarang akunmu lebih aman.",
					"ulasan": "Hebat! Blokir, laporkan, dan atur privasi akun adalah langkah aman di media sosial."},
				{"teks": "Membalas pesan itu dengan marah-marah.", "nilai": 1, "aku": "marah",
					"siapa": "bunda", "ekspresi": "cemas", "balas": "Sebaiknya jangan dibalas, Nak.",
					"ulasan": "Membalas justru membuka percakapan dengan orang asing. Lebih aman blokir dan laporkan."},
				{"teks": "Tetap berteman dengan akun itu karena merasa kasihan.", "nilai": 0, "aku": "cemas",
					"siapa": "bunda", "ekspresi": "cemas", "balas": "Hati-hati, Nak. Kita tidak tahu siapa dia sebenarnya.",
					"ulasan": "Orang asing di internet bisa berbohong tentang dirinya. Jaga jarak dan lindungi dirimu."},
			]},
		],
		"pesan": "Jangan bagikan foto dan data pribadi kepada orang asing. Simpan bukti, blokir, laporkan, dan ceritakan kepada orang tua.",
		"suara_hati": "Bunda lega Nara mau cerita. Bunda ada untuk melindungimu, bukan untuk memarahimu.", "pemilik_hati": "bunda",
	},
	{
		"id": "r_maaf", "peran": "remaja", "judul": "Berani Minta Maaf", "tema": "Kedekatan",
		"latar": "teras", "pemain": "raka", "lawan": "ayah",
		"langkah": [
			{"t": "narasi", "teks": "Kamu berperan sebagai Raka. Tadi siang kamu berkata kasar kepada Ayah karena tidak dibelikan sepatu baru. Sekarang kamu menyesal."},
			{"t": "bicara", "siapa": "ayah", "ekspresi": "sedih", "teks": "(Ayah duduk sendirian di teras dan tampak sedih.)"},
			{"t": "pilih", "tanya": "Apa yang kamu lakukan?", "opsi": [
				{"teks": "Mendekati Ayah: “Yah, maaf tadi aku bicara kasar. Aku kesal, tapi aku salah.”", "nilai": 2, "aku": "malu",
					"siapa": "ayah", "ekspresi": "senang", "balas": "Terima kasih, Nak. Ayah juga minta maaf belum sempat menjelaskan.",
					"ulasan": "Berani minta maaf adalah tanda dewasa. Hubungan yang retak bisa pulih dengan kata “maaf”."},
				{"teks": "Membuatkan teh untuk Ayah tanpa berkata apa-apa.", "nilai": 1, "aku": "malu",
					"siapa": "ayah", "ekspresi": "netral", "balas": "Wah, terima kasih tehnya, Raka.",
					"ulasan": "Perhatianmu manis, tetapi ucapan maaf secara langsung akan membuat masalahnya benar-benar selesai."},
				{"teks": "Diam saja dan menghindari Ayah sampai besok.", "nilai": 0, "aku": "sedih",
					"siapa": "ayah", "ekspresi": "sedih", "balas": "(Ayah menghela napas panjang.)",
					"ulasan": "Menghindar membuat jarak makin lebar. Masalah tidak akan selesai dengan sendirinya."},
			]},
			{"t": "bicara", "siapa": "ayah", "ekspresi": "netral", "teks": "Sebenarnya bulan ini uangnya dipakai untuk memperbaiki atap rumah. Ayah belum sempat bilang."},
			{"t": "pilih", "tanya": "Bagaimana tanggapanmu?", "opsi": [
				{"teks": "“Oh, aku ngerti, Yah. Kalau begitu aku menabung dulu, boleh?”", "nilai": 2, "aku": "senang",
					"siapa": "ayah", "ekspresi": "senang", "balas": "Ide bagus! Nanti Ayah bantu tambah kalau tabunganmu sudah setengah.",
					"ulasan": "Hebat! Kamu memahami keadaan keluarga dan menawarkan solusi. Ayah pun ikut mendukung."},
				{"teks": "“Ya sudah, deh.” (masih cemberut)", "nilai": 1, "aku": "sedih",
					"siapa": "ayah", "ekspresi": "cemas", "balas": "Ayah tahu kamu kecewa.",
					"ulasan": "Kecewa itu wajar. Coba ungkapkan perasaanmu dan cari jalan keluar bersama Ayah."},
				{"teks": "“Pokoknya teman-temanku semua punya sepatu baru!”", "nilai": 0, "aku": "marah",
					"siapa": "ayah", "ekspresi": "sedih", "balas": "Ayah belum bisa sekarang, Nak.",
					"ulasan": "Membandingkan dengan teman membuat orang tua merasa bersalah. Pahami keadaan keluarga dan diskusikan solusinya."},
			]},
		],
		"pesan": "Minta maaf dan saling memahami membuat hubungan keluarga makin dekat.",
		"suara_hati": "Ayah bangga punya anak yang berani minta maaf dan mau mengerti keadaan keluarga.", "pemilik_hati": "ayah",
	},
]

const MAX_POIN := 4


static func by_id(id: String) -> Dictionary:
	for c in CERITA:
		if c["id"] == id:
			return c
	return {}


static func list(peran: String) -> Array:
	var out: Array = []
	for c in CERITA:
		if c["peran"] == peran:
			out.append(c)
	return out


static func stars_for(points: int) -> int:
	if points >= 4:
		return 3
	if points >= 3:
		return 2
	if points >= 1:
		return 1
	return 0
