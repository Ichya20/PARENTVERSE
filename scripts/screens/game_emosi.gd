extends Screen
## Permainan "Tebak Perasaan": kenali emosi anggota keluarga dari wajah dan situasinya.

const ROUNDS := 8

var rounds: Array = []
var ri := -1
var correct := 0
var results: Array = []
var counter_pill: PanelContainer
var dots: HBoxContainer
var body: VBoxContainer


func build() -> void:
	back_to = "game_menu"
	counter_pill = UI.pill("1/%d" % ROUNDS, UI.WHITE, UI.INK, 22)
	(counter_pill.get_theme_stylebox("panel") as StyleBoxFlat).set_border_width_all(3)
	make_top_bar("Tebak Perasaan", counter_pill)
	dots = UI.hbox(8)
	dots.alignment = BoxContainer.ALIGNMENT_CENTER
	layout.add_child(dots)
	var sc := ScrollContainer.new()
	sc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	sc.size_flags_vertical = Control.SIZE_EXPAND_FILL
	layout.add_child(sc)
	var m := UI.margin(2, 4, 2, 20)
	m.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sc.add_child(m)
	body = UI.vbox(14)
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	m.add_child(body)
	_start()


func _start() -> void:
	var pool: Array = GameData.SITUASI.duplicate()
	pool.shuffle()
	rounds = pool.slice(0, ROUNDS)
	ri = -1
	correct = 0
	results.clear()
	_next_round()


func _draw_dots() -> void:
	for c in dots.get_children():
		c.queue_free()
	for i in ROUNDS:
		var col := UI.LINE
		if i < results.size():
			col = UI.GOOD if results[i] else UI.BAD
		elif i == ri:
			col = UI.SUN
		var d := UI.panel(col, 10, 3, UI.INK, 0)
		d.custom_minimum_size = Vector2(30 if i == ri else 20, 20)
		dots.add_child(d)


func _next_round() -> void:
	ri += 1
	if ri >= ROUNDS:
		_end()
		return
	(counter_pill.get_meta("label") as Label).text = "%d/%d" % [ri + 1, ROUNDS]
	_draw_dots()
	for c in body.get_children():
		c.queue_free()
	var r: Dictionary = rounds[ri]
	var stage := UI.frame(GameData.color_light(["sun", "sky", "teal", "coral", "berry"][ri % 5]), 30, 8.0, 4)
	stage.set_pad(16, 12, 16, 12)
	var sv := UI.vbox(6)
	var cv := CharacterView.make(r["tokoh"], r["emosi"])
	cv.custom_minimum_size = Vector2(0, 300)
	sv.add_child(cv)
	var sit := UI.panel(UI.WHITE, 20, 3, UI.INK, 14)
	sit.add_child(UI.label(r["teks"], 23, UI.INK, UI.F_BOLD, HORIZONTAL_ALIGNMENT_CENTER))
	sv.add_child(sit)
	stage.add_child(sv)
	body.add_child(stage)
	UI.pop_in(stage, 0.0, 0.85)
	var nama: String = CharacterView.NAMES.get(r["tokoh"], "")
	body.add_child(UI.title("Bagaimana perasaan %s?" % nama, 28, UI.INK, HORIZONTAL_ALIGNMENT_CENTER))
	var opts: Array = [r["emosi"]]
	var others: Array = GameData.EMOSI.keys()
	others.shuffle()
	for e in others:
		if opts.size() >= 4:
			break
		if e != r["emosi"] and not (e in r.get("bukan", [])):
			opts.append(e)
	opts.shuffle()
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 14)
	grid.add_theme_constant_override("v_separation", 14)
	var buttons: Array[Chunky] = []
	for i in opts.size():
		var e: String = opts[i]
		var b := UI.chunky(UI.WHITE, 24, 7.0, 3)
		b.set_pad(12, 10, 12, 10)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.custom_minimum_size = Vector2(0, 96)
		b.accessibility_name = GameData.EMOSI[e]
		b.sound = ""
		var row := UI.hbox(12)
		row.alignment = BoxContainer.ALIGNMENT_CENTER
		row.add_child(UI.icon("e_" + e, 60))
		var l := UI.label(GameData.EMOSI[e], 26, UI.INK, UI.F_TITLE, HORIZONTAL_ALIGNMENT_LEFT, false)
		l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		row.add_child(l)
		b.add_child(row)
		b.set_meta("emo", e)
		buttons.append(b)
		b.pressed.connect(func(): _answer(e, b, buttons, cv, r))
		grid.add_child(b)
		UI.pop_in(b, 0.1 + i * 0.06, 0.7)
	body.add_child(grid)


func _answer(e: String, b: Chunky, buttons: Array[Chunky], cv: CharacterView, r: Dictionary) -> void:
	for x in buttons:
		x.tappable = false
	var ok: bool = e == r["emosi"]
	results.append(ok)
	_draw_dots()
	if ok:
		correct += 1
		Sfx.play("correct")
		b.set_face(UI.GOOD_L)
		UI.bounce(b, 1.08)
		cv.hop(24)
	else:
		Sfx.play("wrong")
		b.set_face(UI.BAD_L)
		UI.shake(b)
		for x in buttons:
			if x.get_meta("emo") == r["emosi"]:
				x.set_face(UI.GOOD_L)
				UI.bounce(x, 1.06)
	var p := UI.panel(UI.GOOD_L if ok else UI.SUN_L, 22, 3, UI.INK, 16)
	var row := UI.hbox(12)
	var oy := CharacterView.make("oyen", "senang" if ok else "netral")
	oy.custom_minimum_size = Vector2(86, 110)
	row.add_child(oy)
	var v := UI.vbox(4)
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var title_text := "Tepat! " if ok else "Jawabannya: %s. " % GameData.EMOSI[r["emosi"]]
	v.add_child(UI.label(title_text, 25, UI.INK, UI.F_TITLE))
	v.add_child(UI.label(r["tips"], 21, UI.INK, UI.F_BOLD))
	row.add_child(v)
	p.add_child(row)
	body.add_child(p)
	UI.pop_in(p, 0.05, 0.85)
	var nb := UI.button("Lanjut" if ri < ROUNDS - 1 else "Lihat hasil", UI.CORAL, "ui_next", UI.WHITE, 26, 80)
	nb.pressed.connect(_next_round)
	body.add_child(nb)
	await get_tree().process_frame
	var sc := body.get_parent().get_parent() as ScrollContainer
	if sc:
		var tw := create_tween()
		tw.tween_property(sc, "scroll_vertical", int(sc.get_v_scroll_bar().max_value), 0.35)


func _end() -> void:
	_draw_dots()
	var stars := 3 if correct >= ROUNDS else (2 if correct >= 6 else (1 if correct >= 4 else 0))
	var record := Game.set_game_result("game_emosi", correct, stars)
	Sfx.play("win" if stars >= 2 else "star")
	if stars == 3:
		Confetti.burst(overlay)
	var box := UI.vbox(14)
	var fam := UI.hbox(0)
	fam.alignment = BoxContainer.ALIGNMENT_CENTER
	for id in ["bunda", "raka", "nara", "ayah"]:
		var cv := CharacterView.make(id, "senang" if correct >= 6 else "netral")
		cv.custom_minimum_size = Vector2(120, 156)
		fam.add_child(cv)
	box.add_child(fam)
	box.add_child(UI.title("Hasil Tebak Perasaan", 32, UI.INK, HORIZONTAL_ALIGNMENT_CENTER))
	var sl := UI.label("%d/%d" % [correct, ROUNDS], 66, UI.SKY, UI.F_TITLE, HORIZONTAL_ALIGNMENT_CENTER, false)
	UI.outline(sl, UI.INK, 10)
	box.add_child(sl)
	var st := UI.stars(stars, 3, 52, 8)
	st.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_child(st)
	var msg := "Kamu pandai membaca perasaan keluarga!" if correct >= 6 else "Terus berlatih mengenali perasaan, ya."
	if record:
		msg += " Rekor baru!"
	box.add_child(UI.label(msg, 22, UI.INK_SOFT, UI.F_BOLD, HORIZONTAL_ALIGNMENT_CENTER))
	box.add_child(UI.label("Mengenali dan menamai perasaan adalah langkah awal mengelola emosi.", 20, UI.TEAL_D, UI.F_BOLD, HORIZONTAL_ALIGNMENT_CENTER))
	var row := UI.hbox(12)
	var done := UI.button("Selesai", UI.WHITE, "ui_list", UI.INK, 24, 78)
	done.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	done.pressed.connect(func():
		close_modal(true)
		Router.go("game_menu"))
	var again := UI.button("Main lagi", UI.CORAL, "ui_replay", UI.WHITE, 24, 78)
	again.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	again.pressed.connect(func():
		close_modal()
		_start())
	row.add_child(done)
	row.add_child(again)
	box.add_child(row)
	show_modal(box, false)
