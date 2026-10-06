extends Screen
## Permainan "Tangkap Kata Baik": ketuk gelembung kalimat positif, hindari kalimat yang menyakiti.

const DURATION := 60.0
const LIVES := 3
const FILLS := [Color("fff0c7"), Color("dceeff"), Color("d4f3ef"), Color("ffe1d8"), Color("ffe0ec"), Color("ffffff")]

var field: Control
var score_pill: PanelContainer
var timer_bar: MeterBar
var heart_row: HBoxContainer
var banner: PanelContainer
var running := false
var time_left := DURATION
var lives := LIVES
var score := 0
var caught := 0
var spawn_t := 0.0
var ouch: Array = []
var _good_bag: Array = []
var _bad_bag: Array = []
var _last_tick := -1
var _lane := 0


func build() -> void:
	back_to = "game_menu"
	make_top_bar("Tangkap Kata Baik")
	var hud := UI.hbox(12)
	score_pill = UI.pill("0", UI.WHITE, UI.INK, 26, "c_trophy")
	(score_pill.get_theme_stylebox("panel") as StyleBoxFlat).set_border_width_all(3)
	hud.add_child(score_pill)
	var tv := UI.hbox(8)
	tv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tv.add_child(UI.icon("ui_clock", 32, UI.INK))
	timer_bar = MeterBar.make(1.0, UI.SUN, 20)
	timer_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	timer_bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	tv.add_child(timer_bar)
	hud.add_child(tv)
	heart_row = UI.hbox(2)
	hud.add_child(heart_row)
	layout.add_child(hud)
	_draw_hearts()
	var outer := UI.frame(UI.SKY_L, 30, 8.0, 4)
	outer.set_pad(0, 0, 0, 0)
	outer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	layout.add_child(outer)
	var clip := Panel.new()
	clip.add_theme_stylebox_override("panel", UI.sb(UI.SKY_L, 30))
	clip.clip_children = CanvasItem.CLIP_CHILDREN_AND_DRAW
	clip.mouse_filter = Control.MOUSE_FILTER_PASS
	outer.add_child(clip)
	var pat := TextureRect.new()
	pat.texture = UI.tex(UI.ART + "bg/pattern_kawung.svg")
	pat.stretch_mode = TextureRect.STRETCH_TILE
	pat.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	pat.mouse_filter = Control.MOUSE_FILTER_IGNORE
	UI.full(pat)
	clip.add_child(pat)
	field = Control.new()
	field.mouse_filter = Control.MOUSE_FILTER_PASS
	UI.full(field)
	clip.add_child(field)
	var border := Panel.new()
	border.add_theme_stylebox_override("panel", UI.sb(Color(0, 0, 0, 0), 30, 4, UI.INK))
	border.mouse_filter = Control.MOUSE_FILTER_IGNORE
	UI.full(border)
	clip.add_child(border)
	_show_intro()


func _draw_hearts() -> void:
	for c in heart_row.get_children():
		c.queue_free()
	for i in LIVES:
		heart_row.add_child(UI.icon("c_heart_full" if i < lives else "c_heart_empty", 38))


func _show_intro() -> void:
	var box := UI.vbox(16)
	var cv := CharacterView.make("nara", "senang")
	cv.custom_minimum_size = Vector2(0, 200)
	box.add_child(cv)
	box.add_child(UI.title("Tangkap Kata Baik", 34, UI.INK, HORIZONTAL_ALIGNMENT_CENTER))
	box.add_child(UI.rich("[center]Ketuk gelembung berisi [b]kalimat baik[/b] yang menguatkan hati. Hindari [b]kalimat yang menyakiti[/b]! Waktumu 60 detik dan ada 3 nyawa.[/center]", 23, UI.INK))
	var row := UI.hbox(10)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_child(UI.pill("+10 kalimat baik", UI.GOOD_L, UI.INK, 18, "c_badge_ok"))
	row.add_child(UI.pill("−1 nyawa", UI.BAD_L, UI.INK, 18, "c_badge_no"))
	box.add_child(row)
	var go := UI.button("Mulai main", UI.CORAL, "ui_play", UI.WHITE, 28, 84)
	go.pressed.connect(func():
		close_modal()
		_start())
	box.add_child(go)
	show_modal(box, false)


func _start() -> void:
	for c in field.get_children():
		c.queue_free()
	time_left = DURATION
	lives = LIVES
	score = 0
	caught = 0
	ouch.clear()
	spawn_t = 0.3
	_draw_hearts()
	_set_score(0)
	running = true


func _set_score(v: int) -> void:
	score = v
	(score_pill.get_meta("label") as Label).text = str(score)


func _pick_good() -> String:
	if _good_bag.is_empty():
		_good_bag = GameData.KATA_BAIK.duplicate()
		_good_bag.shuffle()
	return _good_bag.pop_back()


func _pick_bad() -> Dictionary:
	if _bad_bag.is_empty():
		_bad_bag = GameData.KATA_BURUK.duplicate()
		_bad_bag.shuffle()
	return _bad_bag.pop_back()


func _process(delta: float) -> void:
	if not running:
		return
	time_left -= delta
	timer_bar.ratio = time_left / DURATION
	var secs := int(ceil(time_left))
	if secs <= 5 and secs != _last_tick and secs > 0:
		_last_tick = secs
		Sfx.play("tick")
	if time_left <= 0.0:
		_end("Waktu habis!")
		return
	var f := 1.0 - time_left / DURATION
	spawn_t -= delta
	if spawn_t <= 0.0:
		spawn_t = lerpf(1.25, 0.8, f)
		_spawn(lerpf(92.0, 160.0, f))
	for c in field.get_children():
		var b := c as WordBubble
		if b == null or b.done:
			continue
		b.t += delta
		b.position.y -= b.speed * delta
		b.position.x = b.base_x + sin(b.t * 1.6 + b.phase) * b.sway
		if b.position.y < -b.size.y:
			b.queue_free()


func _spawn(speed: float) -> void:
	var w := minf(300.0, field.size.x * 0.46)
	var good := randf() < 0.6
	var b := WordBubble.new()
	if good:
		b.setup(_pick_good(), true, FILLS.pick_random(), w)
	else:
		var info := _pick_bad()
		b.setup(info["kata"], false, FILLS.pick_random(), w)
		b.bad_info = info
	b.speed = speed * randf_range(0.97, 1.03)
	b.phase = randf() * TAU
	b.sway = randf_range(6.0, 12.0)
	# dua jalur bergantian (kiri/kanan) agar gelembung tidak saling menimpa
	_lane = 1 - _lane if randf() < 0.85 else _lane
	var gap := maxf(14.0, (field.size.x - 2.0 * w) / 4.0)
	b.base_x = gap + randf_range(0.0, gap * 0.6) if _lane == 0 else field.size.x - w - gap - randf_range(0.0, gap * 0.6)
	b.position = Vector2(b.base_x, field.size.y + 6)
	b.tapped.connect(_on_tap)
	field.add_child(b)


func _on_tap(b: WordBubble) -> void:
	if not running or b.done:
		return
	b.done = true
	b.offset_transform_enabled = true
	var center := b.position + b.size / 2
	if b.good:
		caught += 1
		_set_score(score + 10)
		Sfx.play("chime", randf_range(0.95, 1.15))
		UI.float_text(field, "+10", center, UI.GOOD)
		var tw := b.create_tween().set_parallel(true)
		tw.tween_property(b, "offset_transform_scale", Vector2(1.25, 1.25), 0.16)
		tw.tween_property(b, "modulate:a", 0.0, 0.18)
		tw.chain().tween_callback(b.queue_free)
		UI.bounce(score_pill, 1.15)
	else:
		lives -= 1
		_draw_hearts()
		Sfx.play("bonk")
		UI.float_text(field, "Aduh!", center, UI.BAD)
		UI.shake(field, 12)
		if not b.bad_info.is_empty() and not ouch.has(b.bad_info):
			ouch.append(b.bad_info)
		_show_banner(b.bad_info)
		b.fill = Color("d9d3dd")
		b.queue_redraw()
		var tw2 := b.create_tween()
		tw2.tween_property(b, "modulate:a", 0.0, 0.4)
		tw2.tween_callback(b.queue_free)
		if lives <= 0:
			_end("Nyawa habis!")


func _show_banner(info: Dictionary) -> void:
	if info.is_empty():
		return
	if banner and is_instance_valid(banner):
		banner.queue_free()
	banner = UI.panel(UI.WHITE, 20, 3, UI.INK, 14)
	var v := UI.vbox(2)
	v.add_child(UI.label("“%s” menyakiti hati." % info["kata"], 19, UI.BAD.darkened(0.2), UI.F_BLACK))
	v.add_child(UI.label("Coba: “%s”" % info["ganti"], 19, UI.INK, UI.F_BOLD))
	banner.add_child(v)
	banner.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	banner.offset_left = 18
	banner.offset_right = -18
	banner.offset_top = 16
	field.get_parent().add_child(banner)
	UI.slide_in(banner, 0.0, Vector2(0, -30), 0.25)
	var b := banner
	var tw := b.create_tween()
	tw.tween_interval(2.2)
	tw.tween_property(b, "modulate:a", 0.0, 0.3)
	tw.tween_callback(b.queue_free)


func _end(reason: String) -> void:
	running = false
	for c in field.get_children():
		if c is WordBubble:
			c.done = true
	var stars := 3 if score >= 150 else (2 if score >= 90 else (1 if score >= 40 else 0))
	var prev_best := Game.game_best("game_kata")
	var record := Game.set_game_result("game_kata", score, stars)
	Sfx.play("win" if stars >= 2 else "star")
	if record and score > 0:
		Confetti.burst(overlay)
	var box := UI.vbox(14)
	box.add_child(UI.title(reason, 34, UI.INK, HORIZONTAL_ALIGNMENT_CENTER))
	var sl := UI.label(str(score), 72, UI.CORAL, UI.F_TITLE, HORIZONTAL_ALIGNMENT_CENTER, false)
	UI.outline(sl, UI.INK, 10)
	box.add_child(sl)
	var st := UI.stars(stars, 3, 54, 8)
	st.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_child(st)
	var info := "%d kalimat baik tertangkap. " % caught
	info += "Rekor baru!" if record and score > 0 else "Rekormu: %d" % maxi(prev_best, score)
	box.add_child(UI.label(info, 22, UI.INK_SOFT, UI.F_BOLD, HORIZONTAL_ALIGNMENT_CENTER))
	if not ouch.is_empty():
		var p := UI.panel(UI.SUN_L, 20, 3, UI.INK, 14)
		var v := UI.vbox(8)
		v.add_child(UI.label("YUK GANTI KALIMATNYA", 16, UI.SUN_D.darkened(0.35), UI.F_BLACK))
		for i in mini(ouch.size(), 3):
			var o: Dictionary = ouch[i]
			for pair in [["c_badge_no", o["kata"], UI.BAD.darkened(0.2)], ["c_badge_ok", o["ganti"], UI.GOOD.darkened(0.3)]]:
				var r := UI.hbox(8)
				r.add_child(UI.icon(pair[0], 26))
				r.add_child(UI.label("“%s”" % pair[1], 19, pair[2], UI.F_BLACK))
				v.add_child(r)
		p.add_child(v)
		box.add_child(p)
	var row := UI.hbox(12)
	var again := UI.button("Main lagi", UI.CORAL, "ui_replay", UI.WHITE, 24, 78)
	again.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	again.pressed.connect(func():
		close_modal()
		_start())
	var done := UI.button("Selesai", UI.WHITE, "ui_list", UI.INK, 24, 78)
	done.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	done.pressed.connect(func():
		close_modal(true)
		Router.go("game_menu"))
	row.add_child(done)
	row.add_child(again)
	box.add_child(row)
	show_modal(box, false)


func handle_back() -> bool:
	if has_modal():
		if running:
			close_modal()
		else:
			close_modal(true)
			Router.go("game_menu")
		return true
	if running:
		running = false
		confirm("Berhenti bermain?", "Skor permainan ini tidak akan disimpan.", "Berhenti",
			func(): Router.go("game_menu"), "Lanjut main", UI.CORAL, "oyen", "cemas")
		# lanjutkan permainan bila dialog ditutup tanpa berhenti
		_resume_when_closed()
		return true
	Router.go("game_menu")
	return true


func _resume_when_closed() -> void:
	while is_inside_tree() and has_modal():
		await get_tree().process_frame
	if is_inside_tree() and Router.current == self and not Router.busy and time_left > 0 and lives > 0:
		running = true
