extends Node
## Progres belajar & pengaturan pemain, disimpan lokal di perangkat (user://).

signal progress_changed
signal settings_changed

const SAVE_PATH := "user://parentverse_save.cfg"
const BULAN := ["Januari", "Februari", "Maret", "April", "Mei", "Juni", "Juli", "Agustus",
	"September", "Oktober", "November", "Desember"]

var data: Dictionary = {}


func _ready() -> void:
	_reset_data()
	load_data()
	UI.text_scale = 1.12 if setting("big_text") else 1.0


func _reset_data() -> void:
	data = {
		"materi": {},
		"kasus": {},
		"games": {},
		"tests": {},
		"agreement": {},
		"checklist": {},
		"settings": {"music": true, "sfx": true, "big_text": false},
		"profile": {"name": "", "onboarded": false},
	}


func load_data() -> void:
	var cf := ConfigFile.new()
	if cf.load(SAVE_PATH) != OK:
		return
	for section in data.keys():
		var v: Variant = cf.get_value("save", section, null)
		if v is Dictionary:
			(data[section] as Dictionary).merge(v, true)


func save_data() -> void:
	var cf := ConfigFile.new()
	for section in data.keys():
		cf.set_value("save", section, data[section])
	cf.save(SAVE_PATH)


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_data()


# --- pengaturan ---------------------------------------------------------------
func setting(key: String) -> Variant:
	return (data["settings"] as Dictionary).get(key, false)


func set_setting(key: String, value: Variant) -> void:
	data["settings"][key] = value
	if key == "big_text":
		UI.text_scale = 1.12 if value else 1.0
	save_data()
	settings_changed.emit()


func profile(key: String) -> Variant:
	return (data["profile"] as Dictionary).get(key, "")


func set_profile(key: String, value: Variant) -> void:
	data["profile"][key] = value
	save_data()


# --- materi -------------------------------------------------------------------
func materi_stars(id: String) -> int:
	return int((data["materi"] as Dictionary).get(id, {}).get("stars", 0))


func materi_done(id: String) -> bool:
	return materi_stars(id) > 0


func set_materi_result(id: String, stars: int) -> void:
	var prev := materi_stars(id)
	data["materi"][id] = {"stars": maxi(prev, stars), "date": today()}
	save_data()
	progress_changed.emit()


func materi_done_count() -> int:
	var n := 0
	for id in (data["materi"] as Dictionary).keys():
		if materi_done(id):
			n += 1
	return n


func checklist(id: String) -> Array:
	return (data["checklist"] as Dictionary).get(id, [])


func set_checklist(id: String, items: Array) -> void:
	data["checklist"][id] = items
	save_data()


# --- cerita / kasus ---------------------------------------------------------------
func kasus_stars(id: String) -> int:
	return int((data["kasus"] as Dictionary).get(id, {}).get("stars", 0))


func kasus_played(id: String) -> bool:
	return (data["kasus"] as Dictionary).has(id)


func set_kasus_result(id: String, stars: int, points: int, max_points: int) -> void:
	var prev: Dictionary = (data["kasus"] as Dictionary).get(id, {})
	data["kasus"][id] = {
		"stars": maxi(int(prev.get("stars", 0)), stars),
		"best": maxi(int(prev.get("best", 0)), points),
		"last": points,
		"max": max_points,
		"plays": int(prev.get("plays", 0)) + 1,
	}
	save_data()
	progress_changed.emit()


## Persentase keterampilan dari skor terakhir setiap cerita yang pernah dimainkan.
func skill_percent() -> int:
	var got := 0
	var total := 0
	for v in (data["kasus"] as Dictionary).values():
		got += int(v.get("last", 0))
		total += int(v.get("max", 0))
	return int(round(100.0 * got / total)) if total > 0 else -1


func kasus_played_count() -> int:
	return (data["kasus"] as Dictionary).size()


# --- permainan ------------------------------------------------------------------
func game_best(id: String) -> int:
	return int((data["games"] as Dictionary).get(id, {}).get("best", 0))


func game_stars(id: String) -> int:
	return int((data["games"] as Dictionary).get(id, {}).get("stars", 0))


func game_played(id: String) -> bool:
	return (data["games"] as Dictionary).has(id)


## Mengembalikan true bila skor ini rekor baru.
func set_game_result(id: String, score: int, stars: int) -> bool:
	var prev: Dictionary = (data["games"] as Dictionary).get(id, {})
	var best := int(prev.get("best", 0))
	data["games"][id] = {
		"best": maxi(best, score),
		"stars": maxi(int(prev.get("stars", 0)), stars),
		"plays": int(prev.get("plays", 0)) + 1,
	}
	save_data()
	progress_changed.emit()
	return score > best


func games_played_count() -> int:
	return (data["games"] as Dictionary).size()


# --- evaluasi ---------------------------------------------------------------------
func test_result(kind: String) -> Dictionary:
	return (data["tests"] as Dictionary).get(kind, {})


func set_test_result(kind: String, correct: int, total: int, answers: Array) -> void:
	var score := int(round(100.0 * correct / maxi(total, 1)))
	var prev: Dictionary = test_result(kind)
	data["tests"][kind] = {
		"score": score,
		"correct": correct,
		"total": total,
		"date": today(),
		"best": maxi(int(prev.get("best", 0)), score),
		"attempts": int(prev.get("attempts", 0)) + 1,
		"answers": answers,
		"name": str(profile("name")),
	}
	save_data()
	progress_changed.emit()


static func category(score: int) -> String:
	if score >= 80:
		return "Baik"
	if score >= 60:
		return "Cukup"
	return "Perlu Belajar Lagi"


# --- kesepakatan keluarga --------------------------------------------------------
func agreement() -> Dictionary:
	return data["agreement"]


func set_agreement(family: String, items: Array) -> void:
	data["agreement"] = {"family": family, "items": items, "date": today()}
	save_data()
	progress_changed.emit()


# --- bintang ------------------------------------------------------------------
func total_stars() -> int:
	var n := 0
	for k in ["materi", "kasus", "games"]:
		for v in (data[k] as Dictionary).values():
			n += int(v.get("stars", 0))
	return n


func reset_progress() -> void:
	var keep_settings: Dictionary = data["settings"].duplicate()
	var keep_profile: Dictionary = data["profile"].duplicate()
	_reset_data()
	data["settings"] = keep_settings
	data["profile"] = keep_profile
	save_data()
	progress_changed.emit()


# --- tanggal ------------------------------------------------------------------
static func today() -> String:
	var d := Time.get_date_dict_from_system()
	return "%d %s %d" % [d.day, BULAN[d.month - 1], d.year]


static func greeting() -> String:
	var h: int = Time.get_time_dict_from_system().hour
	if h >= 4 and h < 11:
		return "Selamat pagi"
	if h >= 11 and h < 15:
		return "Selamat siang"
	if h >= 15 and h < 18:
		return "Selamat sore"
	return "Selamat malam"
