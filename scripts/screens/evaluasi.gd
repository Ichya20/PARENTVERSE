extends Screen
## Evaluasi: pre-test, post-test, dan rapor belajar (pengetahuan, keterampilan, pemanfaatan).


func build() -> void:
	back_to = "home"
	make_top_bar("Evaluasi")
	var box := make_scroll(16)
	var intro := UI.hbox(12)
	var cv := CharacterView.make("ayah", "senang")
	cv.custom_minimum_size = Vector2(104, 136)
	intro.add_child(cv)
	var bub := Bubble.make(UI.WHITE, "left", 0.5, 16)
	bub.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bub.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	bub.add_child(UI.label("Kerjakan pre-test sebelum belajar dan post-test setelah mempelajari semua materi. Bandingkan hasilnya!", 21, UI.INK, UI.F_BOLD))
	intro.add_child(bub)
	box.add_child(intro)
	# nama peserta
	box.add_child(UI.label("Nama peserta (opsional)", 21, UI.INK, UI.F_BLACK))
	var name_edit := LineEdit.new()
	name_edit.placeholder_text = "Tulis nama agar tercantum di hasil tes"
	name_edit.text = str(Game.profile("name"))
	name_edit.max_length = 40
	name_edit.custom_minimum_size = Vector2(0, 74)
	name_edit.accessibility_name = "Nama peserta"
	name_edit.text_changed.connect(func(t: String): Game.set_profile("name", t.strip_edges()))
	box.add_child(name_edit)
	var row := UI.hbox(16)
	row.add_child(_test_card("pre", "Pre-Test", "Sebelum belajar", UI.SKY))
	row.add_child(_test_card("post", "Post-Test", "Sesudah belajar", UI.TEAL))
	box.add_child(row)
	box.add_child(_report())


func _test_card(kind: String, title_text: String, sub: String, col: Color) -> Control:
	var res: Dictionary = Game.test_result(kind)
	var card := UI.chunky(UI.PAPER, 26, 8.0, 4)
	card.set_pad(0, 0, 0, 0)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.accessibility_name = title_text
	var v := UI.vbox(0)
	var head := PanelContainer.new()
	var hs := UI.sb(col, 24, 0, UI.INK, 14)
	hs.corner_radius_bottom_left = 0
	hs.corner_radius_bottom_right = 0
	head.add_theme_stylebox_override("panel", hs)
	var hv := UI.vbox(0)
	var t := UI.title(title_text, 30, UI.WHITE, HORIZONTAL_ALIGNMENT_CENTER)
	UI.outline(t, UI.INK, 8)
	hv.add_child(t)
	hv.add_child(UI.label(sub, 18, UI.WHITE, UI.F_BLACK, HORIZONTAL_ALIGNMENT_CENTER))
	head.add_child(hv)
	v.add_child(head)
	var line := ColorRect.new()
	line.color = UI.INK
	line.custom_minimum_size = Vector2(0, 3)
	v.add_child(line)
	var body := UI.margin(12, 12, 12, 14)
	var bv := UI.vbox(8)
	if res.is_empty():
		bv.add_child(UI.label("–", 52, UI.LINE.darkened(0.2), UI.F_TITLE, HORIZONTAL_ALIGNMENT_CENTER))
		bv.add_child(UI.label("Belum dikerjakan", 18, UI.INK_SOFT, UI.F_BOLD, HORIZONTAL_ALIGNMENT_CENTER))
	else:
		var score := int(res["score"])
		var sl := UI.label(str(score), 52, col.darkened(0.15), UI.F_TITLE, HORIZONTAL_ALIGNMENT_CENTER)
		bv.add_child(sl)
		var cat := Game.category(score)
		bv.add_child(UI.pill(cat, UI.GOOD_L if score >= 80 else (UI.SUN_L if score >= 60 else UI.BAD_L), UI.INK, 16))
		bv.add_child(UI.label(str(res.get("date", "")), 16, UI.INK_SOFT, UI.F_BOLD, HORIZONTAL_ALIGNMENT_CENTER))
	var go := UI.pill("Mulai" if res.is_empty() else "Ulangi", UI.CORAL, UI.WHITE, 19, "ui_play")
	go.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	bv.add_child(go)
	for c in bv.get_children():
		if c is PanelContainer:
			c.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	body.add_child(bv)
	v.add_child(body)
	card.add_child(v)
	card.pressed.connect(func(): Router.go("kuis", {"kind": kind}))
	return card


func _report() -> Control:
	var p := UI.frame(UI.WHITE, 26, 8.0, 4)
	p.set_pad(22, 18, 22, 20)
	var v := UI.vbox(14)
	var head := UI.hbox(10)
	head.add_child(UI.icon("c_trophy", 44))
	var hl := UI.label("Rapor Belajar", 30, UI.INK, UI.F_TITLE, HORIZONTAL_ALIGNMENT_LEFT, false)
	hl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	head.add_child(hl)
	v.add_child(head)
	# pengetahuan
	var pre: Dictionary = Game.test_result("pre")
	var post: Dictionary = Game.test_result("post")
	v.add_child(UI.label("1. Pengetahuan (pre-test vs post-test)", 21, UI.INK, UI.F_BLACK))
	v.add_child(_bar_row("Pre", pre.get("score", -1), UI.SKY))
	v.add_child(_bar_row("Post", post.get("score", -1), UI.TEAL))
	if not pre.is_empty() and not post.is_empty():
		var diff := int(post["score"]) - int(pre["score"])
		var txt := "Naik %d poin. Hebat!" % diff if diff > 0 else ("Nilai tetap. Coba pelajari lagi materinya." if diff == 0 else "Turun %d poin. Yuk ulangi materinya." % -diff)
		v.add_child(UI.pill(txt, UI.GOOD_L if diff > 0 else UI.SUN_L, UI.INK, 18))
	v.add_child(_sep())
	# keterampilan
	v.add_child(UI.label("2. Keterampilan merespons kasus", 21, UI.INK, UI.F_BLACK))
	var sk := Game.skill_percent()
	v.add_child(_bar_row("Cerita", sk, UI.CORAL))
	v.add_child(UI.label("Dihitung dari pilihan respons terakhir di menu Cerita Keluarga.", 18, UI.INK_SOFT, UI.F_BOLD))
	v.add_child(_sep())
	# pemanfaatan
	v.add_child(UI.label("3. Pemanfaatan PARENTVERSE", 21, UI.INK, UI.F_BLACK))
	var n_game := 0
	for g in GameData.MENU:
		if g["id"] == "kesepakatan":
			n_game += 0 if Game.agreement().is_empty() else 1
		elif Game.game_played(g["id"]):
			n_game += 1
	var use := [
		["Materi", Game.materi_done_count(), MateriData.TOPIK.size(), UI.TEAL],
		["Cerita", Game.kasus_played_count(), CeritaData.CERITA.size(), UI.CORAL],
		["Main", n_game, GameData.MENU.size(), UI.SUN],
	]
	for u in use:
		v.add_child(_count_row(u[0], u[1], u[2], u[3]))
	var total_stars := Game.total_stars()
	v.add_child(UI.pill("Total bintang: %d" % total_stars, UI.SUN_L, UI.INK, 19, "c_star_full"))
	for c in v.get_children():
		if c is PanelContainer:
			c.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	p.add_child(v)
	return p


func _sep() -> Control:
	var c := ColorRect.new()
	c.color = UI.LINE
	c.custom_minimum_size = Vector2(0, 3)
	return c


func _bar_row(name_text: String, score: Variant, col: Color) -> Control:
	var r := UI.hbox(12)
	var l := UI.label(name_text, 20, UI.INK, UI.F_BOLD, HORIZONTAL_ALIGNMENT_LEFT, false)
	l.custom_minimum_size = Vector2(80, 0)
	r.add_child(l)
	var s := int(score)
	var bar := MeterBar.make(0.0, col, 22)
	bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	r.add_child(bar)
	if s >= 0:
		bar.animate_to(s / 100.0, 0.8)
	var vl := UI.label(str(s) if s >= 0 else "–", 22, UI.INK, UI.F_TITLE, HORIZONTAL_ALIGNMENT_RIGHT, false)
	vl.custom_minimum_size = Vector2(56, 0)
	r.add_child(vl)
	return r


func _count_row(name_text: String, n: int, total: int, col: Color) -> Control:
	var r := UI.hbox(12)
	var l := UI.label(name_text, 20, UI.INK, UI.F_BOLD, HORIZONTAL_ALIGNMENT_LEFT, false)
	l.custom_minimum_size = Vector2(80, 0)
	r.add_child(l)
	var bar := MeterBar.make(0.0, col, 22)
	bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	bar.animate_to(float(n) / maxi(total, 1), 0.8)
	r.add_child(bar)
	var vl := UI.label("%d/%d" % [n, total], 20, UI.INK, UI.F_TITLE, HORIZONTAL_ALIGNMENT_RIGHT, false)
	vl.custom_minimum_size = Vector2(56, 0)
	r.add_child(vl)
	return r
