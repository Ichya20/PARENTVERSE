extends Screen
## Beranda: logo, ilustrasi keluarga, tips harian, dan 4 kartu menu utama.

const SAPA := {
	"ayah": "Halo! Aku Ayah Budi.", "bunda": "Hai! Aku Bunda Sari.", "nara": "Hai, aku Nara!",
	"raka": "Yo! Aku Raka.", "oyen": "Meong! Aku Oyen.",
}

var _hero: Control
var _bubble: Control
var _star_pill: PanelContainer


func build() -> void:
	back_to = ""
	_build_top()
	var box := make_scroll(18)
	box.add_child(_build_hero())
	box.add_child(_build_tip())
	box.add_child(_build_grid())
	var foot := UI.label("Telkom University  ×  PKK Desa Muntang  •  v" + AppInfo.VERSI, 19, UI.INK_SOFT,
		UI.F_BOLD, HORIZONTAL_ALIGNMENT_CENTER)
	box.add_child(foot)
	if not Game.profile("onboarded"):
		create_tween().tween_callback(show_guide.bind(0)).set_delay(0.6)


func _build_top() -> void:
	var bar := UI.hbox(12)
	bar.custom_minimum_size = Vector2(0, 84)
	var gear := UI.round_button("ui_gear", UI.WHITE, UI.INK, 72, "Pengaturan")
	gear.pressed.connect(_show_settings)
	bar.add_child(gear)
	var logo := Logo.make(40)
	logo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.add_child(logo)
	logo.wave_loop()
	_star_pill = UI.pill(str(Game.total_stars()), UI.WHITE, UI.INK, 24, "c_star_full")
	(_star_pill.get_theme_stylebox("panel") as StyleBoxFlat).set_border_width_all(3)
	_star_pill.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	bar.add_child(_star_pill)
	var info := UI.round_button("ui_info", UI.SUN, UI.INK, 72, "Info aplikasi")
	info.pressed.connect(func(): Router.go("info"))
	bar.add_child(info)
	layout.add_child(bar)


func _build_hero() -> Control:
	var outer := UI.chunky(UI.SKY_L, 30, 8.0, 4)
	outer.tappable = false
	outer.mouse_filter = Control.MOUSE_FILTER_PASS
	outer.set_pad(0, 0, 0, 0)
	outer.custom_minimum_size = Vector2(0, 392)
	var hero := Panel.new()
	hero.add_theme_stylebox_override("panel", UI.sb(UI.SKY_L, 30))
	hero.clip_children = CanvasItem.CLIP_CHILDREN_AND_DRAW
	hero.mouse_filter = Control.MOUSE_FILTER_PASS
	outer.add_child(hero)
	_hero = hero
	var pic := UI.picture(UI.ART + "bg/home.svg")
	UI.full(pic)
	hero.add_child(pic)
	# sapaan
	var bubble := UI.panel(UI.WHITE, 22, 3, UI.INK, 14)
	bubble.position = Vector2(20, 18)
	var bv := UI.vbox(2)
	bv.add_child(UI.label(Game.greeting() + "!", 26, UI.CORAL, UI.F_TITLE, HORIZONTAL_ALIGNMENT_LEFT, false))
	bv.add_child(UI.label("Yuk belajar & bermain bersama keluarga.", 19, UI.INK, UI.F_BOLD, HORIZONTAL_ALIGNMENT_LEFT, false))
	bubble.add_child(bv)
	hero.add_child(bubble)
	UI.pop_in(bubble, 0.25, 0.7)
	# keluarga
	var fam := UI.hbox(-6)
	fam.alignment = BoxContainer.ALIGNMENT_CENTER
	fam.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	fam.offset_top = -196
	fam.offset_bottom = 26
	fam.mouse_filter = Control.MOUSE_FILTER_PASS
	hero.add_child(fam)
	var ids := ["ayah", "bunda", "nara", "raka", "oyen"]
	for i in ids.size():
		var holder := Control.new()
		holder.custom_minimum_size = Vector2(128, 222) if ids[i] != "oyen" else Vector2(104, 180)
		holder.size_flags_vertical = Control.SIZE_SHRINK_END
		holder.mouse_filter = Control.MOUSE_FILTER_PASS
		var cv := CharacterView.make(ids[i], "senang" if ids[i] in ["bunda", "oyen"] else "netral")
		UI.full(cv)
		holder.add_child(cv)
		holder.gui_input.connect(_on_char_input.bind(holder, cv, ids[i]))
		fam.add_child(holder)
		UI.slide_in(holder, 0.15 + i * 0.08, Vector2(0, 60))
	var border := Panel.new()
	border.add_theme_stylebox_override("panel", UI.sb(Color(0, 0, 0, 0), 30, 4, UI.INK))
	border.mouse_filter = Control.MOUSE_FILTER_IGNORE
	UI.full(border)
	hero.add_child(border)
	return outer


func _on_char_input(event: InputEvent, holder: Control, cv: CharacterView, id: String) -> void:
	if not (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		return
	Sfx.play("pop", randf_range(0.9, 1.2))
	cv.hop(26)
	var old := cv.expression
	cv.set_expression("senang", false)
	cv.create_tween().tween_callback(cv.set_expression.bind(old, false)).set_delay(1.4)
	if _bubble and is_instance_valid(_bubble):
		_bubble.queue_free()
	var b := UI.panel(UI.WHITE, 18, 3, UI.INK, 10)
	b.add_child(UI.label(SAPA.get(id, "Halo!"), 20, UI.INK, UI.F_BOLD, HORIZONTAL_ALIGNMENT_CENTER, false))
	_hero.add_child(b)
	b.reset_size()
	var p := holder.global_position - _hero.global_position
	b.position = Vector2(clampf(p.x + holder.size.x / 2 - b.size.x / 2, 10, _hero.size.x - b.size.x - 10), p.y + 10)
	_bubble = b
	UI.pop_in(b, 0.0, 0.5, 0.3)
	var tw := b.create_tween()
	tw.tween_interval(1.6)
	tw.tween_property(b, "modulate:a", 0.0, 0.25)
	tw.tween_callback(b.queue_free)


func _build_tip() -> Control:
	var row := UI.hbox(10)
	var cv := CharacterView.make("oyen", "senang")
	cv.custom_minimum_size = Vector2(104, 132)
	row.add_child(cv)
	var bubble := UI.panel(UI.WHITE, 24, 3, UI.INK, 16)
	bubble.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bubble.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var v := UI.vbox(4)
	v.add_child(UI.label("Tips Oyen hari ini", 21, UI.TEAL_D, UI.F_TITLE))
	var day := int(Time.get_unix_time_from_system() / 86400.0)
	v.add_child(UI.label(GameData.TIPS[day % GameData.TIPS.size()], 22, UI.INK, UI.F_BOLD))
	bubble.add_child(v)
	row.add_child(bubble)
	UI.slide_in(row, 0.3)
	return row


func _build_grid() -> Control:
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 18)
	grid.add_theme_constant_override("v_separation", 18)
	grid.mouse_filter = Control.MOUSE_FILTER_PASS
	var n_materi := Game.materi_done_count()
	var n_cerita := Game.kasus_played_count()
	var n_game := 0
	for g in GameData.MENU:
		if g["id"] == "kesepakatan":
			n_game += 1 if not Game.agreement().is_empty() else 0
		elif Game.game_played(g["id"]):
			n_game += 1
	var pre: Dictionary = Game.test_result("pre")
	var post: Dictionary = Game.test_result("post")
	var ev := "Pre %s • Post %s" % [str(pre.get("score", "–")), str(post.get("score", "–"))]
	var cards := [
		["Jelajah Materi", "7 topik parenting remaja bergambar", "menu_materi", UI.TEAL, "%d/7 topik" % n_materi, "materi_list", float(n_materi) / 7.0],
		["Cerita Keluarga", "Pilih respons terbaik di situasi sehari-hari", "menu_cerita", UI.CORAL, "%d/%d cerita" % [n_cerita, CeritaData.CERITA.size()], "cerita_list", float(n_cerita) / CeritaData.CERITA.size()],
		["Main Bareng", "Permainan seru untuk orang tua & anak", "menu_game", UI.SUN, "%d/4 permainan" % n_game, "game_menu", n_game / 4.0],
		["Evaluasi", "Pre-test & post-test pemahaman", "menu_evaluasi", UI.SKY, ev, "evaluasi", (0.5 if not pre.is_empty() else 0.0) + (0.5 if not post.is_empty() else 0.0)],
	]
	for i in cards.size():
		var c: Array = cards[i]
		var card := _menu_card(c[0], c[1], c[2], c[3], c[4], c[6])
		var target: String = c[5]
		card.pressed.connect(func(): Router.go(target))
		grid.add_child(card)
		UI.pop_in(card, 0.35 + i * 0.08, 0.7)
	return grid


func _menu_card(title_text: String, sub: String, icon_name: String, col: Color, progress: String, ratio: float) -> Chunky:
	var card := UI.chunky(UI.PAPER, 28, 8.0, 4)
	card.set_pad(0, 0, 0, 0)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.custom_minimum_size = Vector2(0, 286)
	card.accessibility_name = title_text
	var v := UI.vbox(0)
	card.add_child(v)
	var head := PanelContainer.new()
	var hs := UI.sb(col, 26, 0, UI.INK, 0)
	hs.corner_radius_bottom_left = 0
	hs.corner_radius_bottom_right = 0
	hs.content_margin_top = 14
	hs.content_margin_bottom = 10
	head.add_theme_stylebox_override("panel", hs)
	var hv := UI.vbox(4)
	var ic_wrap := CenterContainer.new()
	var circle := UI.panel(Color(1, 1, 1, 0.9), 50, 3, UI.INK, 6)
	circle.custom_minimum_size = Vector2(100, 100)
	circle.add_child(UI.icon(icon_name, 84))
	ic_wrap.add_child(circle)
	hv.add_child(ic_wrap)
	var t := UI.title(title_text, 29, UI.WHITE if col != UI.SUN else UI.INK, HORIZONTAL_ALIGNMENT_CENTER)
	if col != UI.SUN:
		UI.outline(t, UI.INK, 8)
	hv.add_child(t)
	head.add_child(hv)
	v.add_child(head)
	var line := ColorRect.new()
	line.color = UI.INK
	line.custom_minimum_size = Vector2(0, 3)
	v.add_child(line)
	var body := UI.margin(16, 10, 16, 12)
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var bv := UI.vbox(8)
	var s := UI.label(sub, 19, UI.INK_SOFT, UI.F_BOLD, HORIZONTAL_ALIGNMENT_CENTER)
	s.size_flags_vertical = Control.SIZE_EXPAND_FILL
	bv.add_child(s)
	bv.add_child(ProgressBadge.make(progress, ratio, col))
	body.add_child(bv)
	v.add_child(body)
	return card


# --- Pengaturan ----------------------------------------------------------------
func _show_settings() -> void:
	var box := UI.vbox(14)
	box.add_child(UI.title("Pengaturan", 34))
	box.add_child(_toggle_row("Musik latar", "music", "ui_music_on"))
	box.add_child(_toggle_row("Efek suara", "sfx", "ui_sound_on"))
	box.add_child(_toggle_row("Teks lebih besar", "big_text", "ui_list"))
	var guide := UI.button("Panduan aplikasi", UI.TEAL, "ui_question", UI.WHITE, 24, 72)
	guide.pressed.connect(func():
		close_modal(true)
		show_guide())
	box.add_child(guide)
	var reset := UI.button("Hapus semua progres", UI.WHITE, "ui_replay", UI.BAD, 22, 66)
	reset.pressed.connect(func():
		close_modal(true)
		confirm("Hapus progres?", "Bintang, nilai tes, dan riwayat belajar di perangkat ini akan dihapus.", "Hapus",
			func():
				Game.reset_progress()
				Router.go("home", {}, true), "Batal", UI.BAD, "oyen", "kaget"))
	box.add_child(reset)
	var close := UI.button("Tutup", UI.CORAL, "", UI.WHITE, 26, 76)
	close.pressed.connect(func(): close_modal())
	box.add_child(close)
	show_modal(box)


func _toggle_row(text: String, key: String, icon_name: String) -> Control:
	var row := UI.chunky(UI.WHITE, 22, 5.0, 3)
	row.set_pad(18, 10, 14, 10)
	row.custom_minimum_size = Vector2(0, 76)
	row.accessibility_name = text
	var h := UI.hbox(14)
	h.add_child(UI.icon(icon_name, 34, UI.INK))
	var l := UI.label(text, 25, UI.INK, UI.F_BOLD)
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	h.add_child(l)
	var sw := Switch.make(bool(Game.setting(key)))
	h.add_child(sw)
	row.add_child(h)
	row.pressed.connect(func():
		var v := not bool(Game.setting(key))
		Game.set_setting(key, v)
		sw.set_on(v)
		if key == "big_text":
			toast("Ukuran teks diterapkan saat membuka layar berikutnya."))
	return row


# --- Panduan / pengenalan -------------------------------------------------------
func show_guide(page: int = 0) -> void:
	var box := UI.vbox(16)
	match page:
		0:
			var cv := CharacterView.make("oyen", "senang")
			cv.custom_minimum_size = Vector2(0, 230)
			box.add_child(cv)
			box.add_child(UI.title("Halo! Aku Oyen", 36, UI.INK, HORIZONTAL_ALIGNMENT_CENTER))
			box.add_child(UI.label("Aku kucing keluarga Ayah Budi dan Bunda Sari. Aku akan menemanimu belajar parenting remaja sambil bermain!", 24, UI.INK_SOFT, UI.F_BOLD, HORIZONTAL_ALIGNMENT_CENTER))
		1:
			box.add_child(UI.title("Kenalan dengan keluarga", 32, UI.INK, HORIZONTAL_ALIGNMENT_CENTER))
			var grid := GridContainer.new()
			grid.columns = 2
			grid.add_theme_constant_override("h_separation", 12)
			grid.add_theme_constant_override("v_separation", 10)
			for t in AppInfo.TOKOH:
				if t["id"] == "oyen":
					continue
				var cell := UI.vbox(0)
				cell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				var cv := CharacterView.make(t["id"], "senang")
				cv.custom_minimum_size = Vector2(0, 150)
				cell.add_child(cv)
				cell.add_child(UI.label(t["nama"], 23, UI.INK, UI.F_TITLE, HORIZONTAL_ALIGNMENT_CENTER))
				cell.add_child(UI.label(t["ket"], 17, UI.INK_SOFT, UI.F_BOLD, HORIZONTAL_ALIGNMENT_CENTER))
				grid.add_child(cell)
			box.add_child(grid)
		_:
			box.add_child(UI.title("4 menu utama", 34, UI.INK, HORIZONTAL_ALIGNMENT_CENTER))
			var items := [
				["menu_materi", "Jelajah Materi", "7 topik bergambar, bisa dibacakan."],
				["menu_cerita", "Cerita Keluarga", "Latihan memilih respons terbaik."],
				["menu_game", "Main Bareng", "Permainan seru orang tua & anak."],
				["menu_evaluasi", "Evaluasi", "Pre-test & post-test pemahaman."],
			]
			for it in items:
				var r := UI.hbox(14)
				r.add_child(UI.icon(it[0], 64))
				var tv := UI.vbox(0)
				tv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				tv.add_child(UI.label(it[1], 24, UI.INK, UI.F_TITLE))
				tv.add_child(UI.label(it[2], 20, UI.INK_SOFT, UI.F_BOLD))
				r.add_child(tv)
				box.add_child(r)
			box.add_child(UI.label("Kumpulkan bintang dari setiap kegiatan, ya!", 21, UI.TEAL_D, UI.F_BOLD, HORIZONTAL_ALIGNMENT_CENTER))
	var dots := UI.hbox(8)
	dots.alignment = BoxContainer.ALIGNMENT_CENTER
	for i in 3:
		var d := UI.panel(UI.CORAL if i == page else UI.LINE, 8, 0, UI.INK, 0)
		d.custom_minimum_size = Vector2(36 if i == page else 16, 16)
		dots.add_child(d)
	box.add_child(dots)
	var next := UI.button("Lanjut" if page < 2 else "Mulai!", UI.CORAL, "ui_next" if page < 2 else "ui_play", UI.WHITE, 28, 82)
	next.pressed.connect(func():
		if page < 2:
			show_guide(page + 1)
		else:
			Game.set_profile("onboarded", true)
			close_modal()
			Sfx.play("star"))
	box.add_child(next)
	show_modal(box, false)
