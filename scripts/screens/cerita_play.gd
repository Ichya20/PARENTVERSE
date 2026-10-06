extends Screen
## Simulasi cerita keluarga: dialog bertahap, pilihan respons, reaksi tokoh, umpan balik, dan meter kedekatan.

const MAX_HEARTS := 5

var story: Dictionary
var steps: Array
var si := -1
var points := 0
var hearts := 3
var first := {}
var stage_bg: TextureRect
var me: CharacterView
var other: CharacterView
var heart_row: HBoxContainer
var dlg: VBoxContainer
var dlg_scroll: ScrollContainer
var _type_tw: Tween
var _type_label: Label
var _type_cv: CharacterView
var _advance := Callable()
var _pre_expr := {}
var _last_delta := 0


func build() -> void:
	back_to = "cerita_list"
	story = CeritaData.by_id(str(params.get("id", "pendiam")))
	if story.is_empty():
		story = CeritaData.CERITA[0]
	steps = story["langkah"]
	heart_row = UI.hbox(2)
	make_top_bar(story["judul"], heart_row)
	_set_hearts(3, false)
	_build_stage()
	_build_dialog()
	_next()


func handle_back() -> bool:
	if has_modal():
		close_modal()
		return true
	confirm("Keluar dari cerita?", "Hasil cerita ini belum tersimpan kalau keluar sekarang.", "Keluar",
		func(): Router.go("cerita_list"), "Lanjut cerita", UI.CORAL, "oyen", "cemas")
	return true


# --- Panggung ----------------------------------------------------------------------
func _build_stage() -> void:
	var outer := UI.frame(UI.SKY_L, 30, 8.0, 4)
	outer.set_pad(0, 0, 0, 0)
	outer.custom_minimum_size = Vector2(0, 420)
	resized.connect(func():
		outer.custom_minimum_size.y = clampf(size.y * 0.41, 380.0, 640.0))
	var clip := Panel.new()
	clip.add_theme_stylebox_override("panel", UI.sb(UI.SKY_L, 30))
	clip.clip_children = CanvasItem.CLIP_CHILDREN_AND_DRAW
	clip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	outer.add_child(clip)
	stage_bg = UI.picture(UI.ART + "bg/%s.svg" % story["latar"])
	UI.full(stage_bg)
	clip.add_child(stage_bg)
	var row := UI.hbox(0)
	row.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	row.offset_top = 34
	row.offset_bottom = 40
	clip.add_child(row)
	me = CharacterView.make(story["pemain"], "netral")
	other = CharacterView.make(story["lawan"], "netral")
	for cv in [me, other]:
		cv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(cv)
	UI.slide_in(me, 0.1, Vector2(-80, 0))
	UI.slide_in(other, 0.2, Vector2(80, 0))
	var tag_me := UI.pill("Kamu · " + CharacterView.NAMES.get(story["pemain"], ""), UI.CORAL, UI.WHITE, 19)
	tag_me.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	tag_me.position = Vector2(16, 0)
	var tag_other := UI.pill(CharacterView.NAMES.get(story["lawan"], ""), UI.WHITE, UI.INK, 19)
	tag_other.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	for tg in [tag_me, tag_other]:
		(tg.get_theme_stylebox("panel") as StyleBoxFlat).set_border_width_all(3)
		clip.add_child(tg)
	clip.resized.connect(func():
		tag_me.position = Vector2(16, clip.size.y - tag_me.size.y - 14)
		tag_other.position = Vector2(clip.size.x - tag_other.size.x - 16, clip.size.y - tag_other.size.y - 14))
	var border := Panel.new()
	border.add_theme_stylebox_override("panel", UI.sb(Color(0, 0, 0, 0), 30, 4, UI.INK))
	border.mouse_filter = Control.MOUSE_FILTER_IGNORE
	UI.full(border)
	clip.add_child(border)
	layout.add_child(outer)


func _build_dialog() -> void:
	var panel := UI.frame(UI.PAPER, 28, 8.0, 4)
	panel.set_pad(20, 16, 20, 16)
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	panel.gui_input.connect(_on_panel_input)
	dlg_scroll = ScrollContainer.new()
	dlg_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	dlg_scroll.mouse_filter = Control.MOUSE_FILTER_PASS
	dlg = UI.vbox(12)
	dlg.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	dlg.mouse_filter = Control.MOUSE_FILTER_PASS
	dlg_scroll.add_child(dlg)
	panel.add_child(dlg_scroll)
	layout.add_child(panel)


var _panel_press := Vector2(-999, -999)


func _on_panel_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		var mb := event as InputEventMouseButton
		if mb.pressed:
			_panel_press = mb.global_position
		elif mb.global_position.distance_to(_panel_press) < 18.0:
			_tap_continue()


func _tap_continue() -> void:
	if _type_tw and _type_tw.is_valid() and _type_tw.is_running():
		_finish_typing()
		return
	if _advance.is_valid():
		var f := _advance
		_advance = Callable()
		Sfx.play("click")
		f.call()


# --- Alur langkah --------------------------------------------------------------------
func _next() -> void:
	si += 1
	if si >= steps.size():
		_finish()
		return
	var st: Dictionary = steps[si]
	match st["t"]:
		"narasi":
			_show_line("", st["teks"], "", _next)
		"bicara":
			_show_line(st["siapa"], st["teks"], st.get("ekspresi", ""), _next)
		"latar":
			_change_bg(st["id"])
			_next()
		"pilih":
			_show_choice(st)
		_:
			_next()


func _cv_for(who: String) -> CharacterView:
	if who == story["pemain"]:
		return me
	if who == story["lawan"]:
		return other
	return null


func _focus(cv: CharacterView) -> void:
	for c in [me, other]:
		var target := Color.WHITE if (cv == null or c == cv) else Color(0.78, 0.78, 0.84)
		c.create_tween().tween_property(c, "modulate", target, 0.2)


func _clear_dlg() -> void:
	for c in dlg.get_children():
		c.queue_free()
	dlg_scroll.scroll_vertical = 0


func _show_line(who: String, text: String, expr: String, on_next: Callable) -> void:
	_clear_dlg()
	var cv := _cv_for(who)
	if cv and expr != "":
		cv.set_expression(expr)
	_focus(cv)
	var head := UI.hbox(10)
	if who == "":
		head.add_child(UI.pill("Narasi", UI.SUN_L, UI.INK, 18, "ui_list"))
	else:
		var mine := cv == me
		var name_text: String = CharacterView.NAMES.get(who, who) + (" (kamu)" if mine else "")
		head.add_child(UI.pill(name_text, UI.CORAL if mine else UI.SKY, UI.WHITE, 19))
	head.add_child(UI.expander())
	if Sfx.can_speak():
		var sp := UI.round_button("ui_speaker", UI.WHITE, UI.INK, 58, "Bacakan")
		sp.pressed.connect(func(): Sfx.speak(text))
		head.add_child(sp)
	dlg.add_child(head)
	var l := UI.label(text, 26 if who != "" else 24, UI.INK if who != "" else UI.INK_SOFT, UI.F_BOLD)
	dlg.add_child(l)
	var foot := UI.hbox(10)
	foot.add_child(UI.expander())
	var hint := UI.label("Ketuk untuk lanjut", 18, UI.INK_SOFT, UI.F_BOLD, HORIZONTAL_ALIGNMENT_RIGHT, false)
	hint.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	foot.add_child(hint)
	var nb := UI.round_button("ui_next", UI.CORAL, UI.WHITE, 64, "Lanjut")
	nb.sound = ""
	nb.pressed.connect(_tap_continue)
	foot.add_child(nb)
	dlg.add_child(foot)
	_type(l, cv)
	_advance = on_next


func _type(l: Label, cv: CharacterView) -> void:
	l.visible_ratio = 0.0
	_type_label = l
	_type_cv = cv
	if cv:
		cv.set_talking(true)
	var dur := clampf(l.text.length() * 0.022, 0.35, 2.4)
	_type_tw = create_tween()
	_type_tw.tween_property(l, "visible_ratio", 1.0, dur)
	_type_tw.tween_callback(func():
		if is_instance_valid(cv):
			cv.set_talking(false))


func _finish_typing() -> void:
	if _type_tw:
		_type_tw.kill()
	if is_instance_valid(_type_label):
		_type_label.visible_ratio = 1.0
	if is_instance_valid(_type_cv):
		_type_cv.set_talking(false)


func _change_bg(id: String) -> void:
	var tw := create_tween()
	tw.tween_property(stage_bg, "modulate:a", 0.0, 0.18)
	tw.tween_callback(func(): stage_bg.texture = UI.tex(UI.ART + "bg/%s.svg" % id))
	tw.tween_property(stage_bg, "modulate:a", 1.0, 0.25)


func _show_choice(st: Dictionary) -> void:
	_clear_dlg()
	_focus(me)
	_advance = Callable()
	var q := UI.label(st["tanya"], 26, UI.INK, UI.F_TITLE)
	dlg.add_child(q)
	var opts: Array = st["opsi"]
	var order: Array = range(opts.size())
	order.shuffle()
	for k in order.size():
		var opt: Dictionary = opts[order[k]]
		var b := UI.chunky(UI.WHITE, 22, 6.0, 3)
		b.set_pad(14, 12, 16, 12)
		b.accessibility_name = opt["teks"]
		var row := UI.hbox(14)
		var badge := UI.panel(UI.SUN, 23, 3, UI.INK, 0)
		badge.custom_minimum_size = Vector2(46, 46)
		badge.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		var bl := UI.label("ABC"[k], 24, UI.INK, UI.F_TITLE, HORIZONTAL_ALIGNMENT_CENTER, false)
		bl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		badge.add_child(bl)
		row.add_child(badge)
		var l := UI.label(opt["teks"], 23, UI.INK, UI.F_BOLD)
		l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		row.add_child(l)
		b.add_child(row)
		b.pressed.connect(_on_pick.bind(opt))
		dlg.add_child(b)
		UI.slide_in(b, 0.05 + k * 0.07, Vector2(36, 0))


func _on_pick(opt: Dictionary) -> void:
	var nilai := int(opt["nilai"])
	if not first.has(si):
		first[si] = nilai
		points += nilai
	_pre_expr = {"me": me.expression, "other": other.expression}
	_last_delta = 1 if nilai == 2 else (0 if nilai == 1 else -1)
	me.set_expression(str(opt.get("aku", "netral")))
	_show_line(story["pemain"], opt["teks"], "", func():
		var who: String = opt.get("siapa", "")
		if who != "":
			_show_line(who, opt["balas"], str(opt.get("ekspresi", "")), func(): _show_feedback(opt))
		else:
			_show_line("", opt["balas"], "", func(): _show_feedback(opt)))


func _show_feedback(opt: Dictionary) -> void:
	_clear_dlg()
	_focus(null)
	var nilai := int(opt["nilai"])
	_set_hearts(hearts + _last_delta)
	var info := {
		2: ["Respons terbaik!", UI.GOOD_L, "c_badge_ok", "correct", "+1 kedekatan"],
		1: ["Cukup baik", UI.SUN_L, "c_badge_mid", "pop", "Kedekatan tetap"],
		0: ["Kurang tepat", UI.BAD_L, "c_badge_no", "wrong", "−1 kedekatan"],
	}
	var inf: Array = info[nilai]
	Sfx.play(inf[3])
	if nilai == 2:
		other.hop(22)
	var p := UI.panel(inf[1], 22, 3, UI.INK, 16)
	var v := UI.vbox(8)
	var head := UI.hbox(10)
	head.add_child(UI.icon(inf[2], 46))
	var ht := UI.label(inf[0], 28, UI.INK, UI.F_TITLE, HORIZONTAL_ALIGNMENT_LEFT, false)
	ht.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	head.add_child(ht)
	head.add_child(UI.expander())
	head.add_child(UI.pill(inf[4], UI.WHITE, UI.INK, 17, "c_heart_full"))
	v.add_child(head)
	v.add_child(UI.label(opt["ulasan"], 23, UI.INK, UI.F_BOLD))
	p.add_child(v)
	dlg.add_child(p)
	UI.pop_in(p, 0.0, 0.85)
	var row := UI.hbox(12)
	if nilai < 2:
		var again := UI.button("Coba lagi", UI.WHITE, "ui_replay", UI.INK, 23, 74)
		again.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		again.pressed.connect(_retry)
		row.add_child(again)
	var go := UI.button("Lanjut", UI.CORAL, "ui_next", UI.WHITE, 24, 74)
	go.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	go.pressed.connect(_next)
	row.add_child(go)
	dlg.add_child(row)


func _retry() -> void:
	_set_hearts(hearts - _last_delta, false)
	me.set_expression(_pre_expr.get("me", "netral"), false)
	other.set_expression(_pre_expr.get("other", "netral"), false)
	_show_choice(steps[si])


func _set_hearts(v: int, animate: bool = true) -> void:
	var old := hearts
	hearts = clampi(v, 0, MAX_HEARTS)
	for c in heart_row.get_children():
		c.queue_free()
	for i in MAX_HEARTS:
		var h := UI.icon("c_heart_full" if i < hearts else "c_heart_empty", 34)
		heart_row.add_child(h)
		if animate and i == hearts - 1 and hearts > old:
			UI.bounce(h, 1.4)
	if animate and hearts < old:
		UI.shake(heart_row, 8)


# --- Selesai -------------------------------------------------------------------
func _finish() -> void:
	var stars := CeritaData.stars_for(points)
	Game.set_kasus_result(story["id"], stars, points, CeritaData.MAX_POIN)
	Sfx.play("win" if stars >= 2 else "star")
	if stars == 3:
		Confetti.burst(overlay)
	var box := UI.vbox(14)
	box.add_child(UI.title("Cerita selesai!", 34, UI.INK, HORIZONTAL_ALIGNMENT_CENTER))
	var st := UI.stars(stars, 3, 60, 10)
	st.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_child(st)
	for i in st.get_child_count():
		UI.pop_in(st.get_child(i), 0.2 + i * 0.16, 0.2, 0.5)
	var hr := UI.hbox(2)
	hr.alignment = BoxContainer.ALIGNMENT_CENTER
	for i in MAX_HEARTS:
		hr.add_child(UI.icon("c_heart_full" if i < hearts else "c_heart_empty", 30))
	box.add_child(hr)
	box.add_child(UI.label("Poin respons: %d dari %d" % [points, CeritaData.MAX_POIN], 22, UI.INK_SOFT, UI.F_BOLD, HORIZONTAL_ALIGNMENT_CENTER))
	var msg := UI.panel(UI.SUN_L, 20, 3, UI.INK, 16)
	var mv := UI.vbox(4)
	mv.add_child(UI.label("PESAN CERITA", 16, UI.SUN_D.darkened(0.35), UI.F_BLACK))
	mv.add_child(UI.label(story["pesan"], 22, UI.INK, UI.F_BOLD))
	msg.add_child(mv)
	box.add_child(msg)
	var heart := UI.hbox(10)
	var owner_id: String = story.get("pemilik_hati", story["lawan"])
	var cv := CharacterView.make(owner_id, "senang")
	cv.custom_minimum_size = Vector2(100, 130)
	heart.add_child(cv)
	var bub := Bubble.make(UI.WHITE, "left", 0.5, 14)
	bub.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bub.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var bv := UI.vbox(2)
	bv.add_child(UI.label("Suara hati " + CharacterView.NAMES.get(owner_id, ""), 18, UI.BERRY, UI.F_BLACK))
	bv.add_child(UI.label(story["suara_hati"], 21, UI.INK, UI.F_BOLD))
	bub.add_child(bv)
	heart.add_child(bub)
	box.add_child(heart)
	var row := UI.hbox(12)
	var again := UI.button("Main lagi", UI.WHITE, "ui_replay", UI.INK, 23, 76)
	again.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var sid: String = story["id"]
	again.pressed.connect(func():
		close_modal(true)
		Router.go("cerita", {"id": sid}))
	row.add_child(again)
	var other_b := UI.button("Cerita lain", UI.CORAL, "ui_list", UI.WHITE, 23, 76)
	other_b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	other_b.pressed.connect(func():
		close_modal(true)
		Router.go("cerita_list"))
	row.add_child(other_b)
	box.add_child(row)
	show_modal(box, false)
