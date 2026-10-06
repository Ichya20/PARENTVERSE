extends Screen
## Permainan "Memori Kebersamaan": cocokkan pasangan kartu kegiatan keluarga.

const PAIRS := 6

var grid: GridContainer
var moves_pill: PanelContainer
var time_pill: PanelContainer
var tip_box: VBoxContainer
var opened: Array[MemoryCard] = []
var found := 0
var moves := 0
var elapsed := 0.0
var running := false
var matched_tips: Array = []


func build() -> void:
	back_to = "game_menu"
	make_top_bar("Memori Kebersamaan")
	var hud := UI.hbox(12)
	moves_pill = UI.pill("0 langkah", UI.WHITE, UI.INK, 22, "ui_hand")
	time_pill = UI.pill("0:00", UI.WHITE, UI.INK, 22, "ui_clock")
	for p in [moves_pill, time_pill]:
		(p.get_theme_stylebox("panel") as StyleBoxFlat).set_border_width_all(3)
		var ic: TextureRect = (p.get_child(0) as HBoxContainer).get_child(0)
		ic.modulate = UI.INK
	hud.add_child(moves_pill)
	hud.add_child(UI.expander())
	hud.add_child(time_pill)
	layout.add_child(hud)
	grid = GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 14)
	grid.add_theme_constant_override("v_separation", 14)
	grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	layout.add_child(grid)
	tip_box = UI.vbox(0)
	tip_box.custom_minimum_size = Vector2(0, 92)
	layout.add_child(tip_box)
	_start()


func _start() -> void:
	for c in grid.get_children():
		c.queue_free()
	opened.clear()
	found = 0
	moves = 0
	elapsed = 0.0
	matched_tips.clear()
	_update_hud()
	_set_tip("Ketuk dua kartu untuk mencari pasangan kegiatan yang sama.", "oyen", "senang")
	var acts: Array = GameData.KEGIATAN.duplicate()
	acts.shuffle()
	var deck: Array = []
	for i in PAIRS:
		deck.append(acts[i])
		deck.append(acts[i])
	deck.shuffle()
	for i in deck.size():
		var a: Dictionary = deck[i]
		var card := MemoryCard.new().setup(a["ikon"], a["nama"])
		card.set_meta("tips", a["tips"])
		card.tapped.connect(_on_tap)
		grid.add_child(card)
		UI.pop_in(card, 0.03 * i, 0.5, 0.35)
	running = true


func _process(delta: float) -> void:
	if running:
		elapsed += delta
		(time_pill.get_meta("label") as Label).text = "%d:%02d" % [int(elapsed) / 60, int(elapsed) % 60]


func _update_hud() -> void:
	(moves_pill.get_meta("label") as Label).text = "%d langkah" % moves


func _set_tip(text: String, char_id: String, expr: String) -> void:
	for c in tip_box.get_children():
		c.queue_free()
	var row := UI.hbox(10)
	var cv := CharacterView.make(char_id, expr)
	cv.custom_minimum_size = Vector2(72, 92)
	row.add_child(cv)
	var bub := Bubble.make(UI.WHITE, "left", 0.5, 12)
	bub.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bub.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	bub.add_child(UI.label(text, 20, UI.INK, UI.F_BOLD))
	row.add_child(bub)
	tip_box.add_child(row)
	UI.slide_in(row, 0.0, Vector2(0, 20), 0.25)


func _on_tap(card: MemoryCard) -> void:
	if not running or opened.size() >= 2:
		return
	card.flip(true)
	opened.append(card)
	if opened.size() < 2:
		return
	moves += 1
	_update_hud()
	var a := opened[0]
	var b := opened[1]
	if a.key == b.key:
		await get_tree().create_timer(0.3).timeout
		a.set_matched()
		b.set_matched()
		Sfx.play("chime")
		found += 1
		matched_tips.append(a.get_meta("tips"))
		_set_tip("%s: %s" % [a.title_text, a.get_meta("tips")], ["bunda", "ayah", "nara", "raka"].pick_random(), "senang")
		opened.clear()
		if found >= PAIRS:
			running = false
			await get_tree().create_timer(0.6).timeout
			_end()
	else:
		await get_tree().create_timer(0.85).timeout
		if is_instance_valid(a):
			a.flip(false)
		if is_instance_valid(b):
			b.flip(false)
		opened.clear()


func _end() -> void:
	if not is_inside_tree():
		return
	var stars := 3 if moves <= 9 else (2 if moves <= 13 else 1)
	var record := Game.set_game_result("game_memori", maxi(0, 100 - moves), stars)
	Sfx.play("win")
	Confetti.burst(overlay)
	var box := UI.vbox(14)
	var cv := CharacterView.make("oyen", "senang")
	cv.custom_minimum_size = Vector2(0, 170)
	box.add_child(cv)
	box.add_child(UI.title("Semua kartu cocok!", 34, UI.INK, HORIZONTAL_ALIGNMENT_CENTER))
	var st := UI.stars(stars, 3, 54, 8)
	st.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_child(st)
	var info := "%d langkah  •  %d:%02d" % [moves, int(elapsed) / 60, int(elapsed) % 60]
	if record:
		info += "  •  Rekor baru!"
	box.add_child(UI.label(info, 23, UI.INK_SOFT, UI.F_BOLD, HORIZONTAL_ALIGNMENT_CENTER))
	var p := UI.panel(UI.SUN_L, 20, 3, UI.INK, 14)
	var v := UI.vbox(4)
	v.add_child(UI.label("IDE KEGIATAN MINGGU INI", 16, UI.SUN_D.darkened(0.35), UI.F_BLACK))
	v.add_child(UI.label(str(matched_tips.pick_random()) if not matched_tips.is_empty() else "", 21, UI.INK, UI.F_BOLD))
	p.add_child(v)
	box.add_child(p)
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
