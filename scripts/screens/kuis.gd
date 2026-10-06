extends Screen
## Pre-test / post-test pilihan ganda. Pre-test tanpa pembahasan; post-test dengan pembahasan langsung.

var kind := "pre"
var order: Array = []
var qi := -1
var answers: Array = []
var correct := 0
var body: VBoxContainer
var scroll: ScrollContainer
var prow: HBoxContainer
var bar: MeterBar
var counter: Label
var in_test := false


func build() -> void:
	back_to = "evaluasi"
	kind = "post" if str(params.get("kind", "pre")) == "post" else "pre"
	make_top_bar("Pre-Test" if kind == "pre" else "Post-Test")
	prow = UI.hbox(14)
	bar = MeterBar.make(0.0, UI.SKY if kind == "pre" else UI.TEAL, 18)
	bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	prow.add_child(bar)
	counter = UI.label("", 20, UI.INK, UI.F_BLACK, HORIZONTAL_ALIGNMENT_RIGHT, false)
	prow.add_child(counter)
	prow.visible = false
	layout.add_child(prow)
	scroll = ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	layout.add_child(scroll)
	var m := UI.margin(2, 4, 2, 24)
	m.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(m)
	body = UI.vbox(14)
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	m.add_child(body)
	_intro()


func handle_back() -> bool:
	if has_modal():
		close_modal()
		return true
	if in_test:
		confirm("Keluar dari tes?", "Jawaban yang sudah dipilih tidak akan disimpan.", "Keluar",
			func(): Router.go("evaluasi"), "Lanjut tes", UI.CORAL, "oyen", "cemas")
		return true
	Router.go("evaluasi")
	return true


func _clear() -> void:
	for c in body.get_children():
		c.queue_free()
	scroll.scroll_vertical = 0


func _intro() -> void:
	_clear()
	var cv := CharacterView.make("bunda" if kind == "pre" else "ayah", "senang")
	cv.custom_minimum_size = Vector2(0, 250)
	body.add_child(cv)
	body.add_child(UI.title("Pre-Test" if kind == "pre" else "Post-Test", 40, UI.INK, HORIZONTAL_ALIGNMENT_CENTER))
	var row := UI.hbox(10)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_child(UI.pill("%d soal pilihan ganda" % KuisData.SOAL.size(), UI.SKY_L, UI.INK, 19, "ui_list"))
	row.add_child(UI.pill("Tanpa batas waktu", UI.SUN_L, UI.INK, 19, "ui_clock"))
	for p in row.get_children():
		var ic: TextureRect = (p.get_child(0) as HBoxContainer).get_child(0)
		ic.modulate = UI.INK
	body.add_child(row)
	var txt := "Jawab sesuai pemahamanmu saat ini, ya. Pembahasan soal tersedia setelah post-test." if kind == "pre" \
		else "Setiap jawaban langsung dibahas. Di akhir, nilaimu dibandingkan dengan pre-test."
	var p2 := UI.panel(UI.WHITE, 22, 3, UI.INK, 18)
	p2.add_child(UI.label(txt, 23, UI.INK, UI.F_BOLD, HORIZONTAL_ALIGNMENT_CENTER))
	body.add_child(p2)
	var nm := str(Game.profile("name"))
	if nm != "":
		body.add_child(UI.label("Peserta: " + nm, 21, UI.INK_SOFT, UI.F_BLACK, HORIZONTAL_ALIGNMENT_CENTER))
	var go := UI.button("Mulai tes", UI.CORAL, "ui_play", UI.WHITE, 28, 86)
	go.pressed.connect(_start)
	body.add_child(go)


func _start() -> void:
	order = range(KuisData.SOAL.size())
	order.shuffle()
	qi = -1
	answers.clear()
	correct = 0
	in_test = true
	prow.visible = true
	_show_q()


func _show_q() -> void:
	qi += 1
	if qi >= order.size():
		_result()
		return
	_clear()
	bar.animate_to(float(qi) / order.size(), 0.3)
	counter.text = "Soal %d/%d" % [qi + 1, order.size()]
	var q: Dictionary = KuisData.SOAL[order[qi]]
	var qp := UI.panel(UI.SKY_L if kind == "pre" else UI.TEAL_L, 24, 3, UI.INK, 20)
	var qv := UI.vbox(6)
	qv.add_child(UI.label("SOAL %d" % (qi + 1), 17, UI.INK_SOFT, UI.F_BLACK))
	qv.add_child(UI.label(q["soal"], 26, UI.INK, UI.F_BOLD))
	qp.add_child(qv)
	body.add_child(qp)
	UI.pop_in(qp, 0.0, 0.9)
	var opts: Array = q["opsi"]
	var opt_order: Array = range(opts.size())
	opt_order.shuffle()
	var buttons: Array[Chunky] = []
	var badges: Array[PanelContainer] = []
	var state := {"chosen": -1}
	var foot := UI.vbox(12)
	var next_btn := UI.button("Lanjut" if qi < order.size() - 1 else "Lihat hasil", UI.CORAL, "ui_next", UI.WHITE, 26, 82)
	next_btn.disabled = true
	for k in opt_order.size():
		var oi: int = opt_order[k]
		var b := UI.chunky(UI.WHITE, 22, 6.0, 3)
		b.set_pad(14, 12, 16, 12)
		b.accessibility_name = opts[oi]
		b.sound = ""
		var row := UI.hbox(14)
		var badge := UI.panel(UI.LINE, 22, 3, UI.INK, 0)
		badge.custom_minimum_size = Vector2(46, 46)
		badge.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		var bl := UI.label("ABCD"[k], 24, UI.INK, UI.F_TITLE, HORIZONTAL_ALIGNMENT_CENTER, false)
		bl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		badge.add_child(bl)
		row.add_child(badge)
		var l := UI.label(opts[oi], 23, UI.INK, UI.F_BOLD)
		l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		row.add_child(l)
		b.add_child(row)
		buttons.append(b)
		badges.append(badge)
		b.pressed.connect(func():
			if kind == "post" and state["chosen"] >= 0:
				return
			state["chosen"] = oi
			for j in buttons.size():
				buttons[j].set_face(UI.WHITE)
				(badges[j].get_theme_stylebox("panel") as StyleBoxFlat).bg_color = UI.LINE
			if kind == "pre":
				Sfx.play("pop")
				b.set_face(UI.SUN_L)
				(badge.get_theme_stylebox("panel") as StyleBoxFlat).bg_color = UI.SUN
				UI.bounce(b, 1.04)
				next_btn.disabled = false
			else:
				_reveal(q, oi, buttons, badges, opt_order, foot)
				next_btn.disabled = false
				for x in buttons:
					x.tappable = false)
		body.add_child(b)
		UI.slide_in(b, 0.04 + k * 0.05, Vector2(30, 0))
	body.add_child(foot)
	next_btn.pressed.connect(func():
		var chosen: int = state["chosen"]
		if chosen < 0:
			return
		var ok := chosen == int(q["jawaban"])
		if ok:
			correct += 1
		answers.append({"q": order[qi], "chosen": chosen, "ok": ok})
		_show_q())
	body.add_child(next_btn)


func _reveal(q: Dictionary, oi: int, buttons: Array[Chunky], badges: Array[PanelContainer], opt_order: Array, foot: VBoxContainer) -> void:
	var ans := int(q["jawaban"])
	var ok := oi == ans
	Sfx.play("correct" if ok else "wrong")
	for j in opt_order.size():
		if opt_order[j] == ans:
			buttons[j].set_face(UI.GOOD_L)
			(badges[j].get_theme_stylebox("panel") as StyleBoxFlat).bg_color = UI.GOOD
		elif opt_order[j] == oi:
			buttons[j].set_face(UI.BAD_L)
			(badges[j].get_theme_stylebox("panel") as StyleBoxFlat).bg_color = UI.BAD
			UI.shake(buttons[j])
	var p := UI.panel(UI.GOOD_L if ok else UI.BAD_L, 22, 3, UI.INK, 16)
	var r := UI.hbox(12)
	r.add_child(UI.icon("c_badge_ok" if ok else "c_badge_no", 48))
	var v := UI.vbox(2)
	v.add_child(UI.label("Benar!" if ok else "Kurang tepat", 25, UI.INK, UI.F_TITLE))
	v.add_child(UI.label(q["bahas"], 21, UI.INK, UI.F_BOLD))
	r.add_child(v)
	p.add_child(r)
	foot.add_child(p)
	UI.pop_in(p, 0.0, 0.85)


func _result() -> void:
	in_test = false
	_clear()
	prow.visible = false
	var total := order.size()
	var pre_before: Dictionary = Game.test_result("pre")
	Game.set_test_result(kind, correct, total, answers)
	var score := int(round(100.0 * correct / maxi(total, 1)))
	var good := score >= 80
	Sfx.play("win" if good else "star")
	if good:
		Confetti.burst(overlay)
	var cv := CharacterView.make("oyen", "senang" if good else "netral")
	cv.custom_minimum_size = Vector2(0, 200)
	body.add_child(cv)
	body.add_child(UI.title("Hasil " + ("Pre-Test" if kind == "pre" else "Post-Test"), 34, UI.INK, HORIZONTAL_ALIGNMENT_CENTER))
	var nm := str(Game.profile("name"))
	if nm != "":
		body.add_child(UI.label(nm, 22, UI.INK_SOFT, UI.F_BLACK, HORIZONTAL_ALIGNMENT_CENTER))
	var sl := UI.label(str(score), 96, UI.TEAL if good else (UI.SUN if score >= 60 else UI.CORAL), UI.F_TITLE, HORIZONTAL_ALIGNMENT_CENTER, false)
	UI.outline(sl, UI.INK, 12)
	body.add_child(sl)
	UI.pop_in(sl, 0.1, 0.4, 0.5)
	var cat := Game.category(score)
	var pill := UI.pill("Kategori: " + cat, UI.GOOD_L if good else (UI.SUN_L if score >= 60 else UI.BAD_L), UI.INK, 22)
	pill.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	body.add_child(pill)
	body.add_child(UI.label("%d dari %d jawaban benar" % [correct, total], 22, UI.INK_SOFT, UI.F_BOLD, HORIZONTAL_ALIGNMENT_CENTER))
	var msg := ""
	if kind == "pre":
		msg = "Nilai awal tersimpan. Sekarang pelajari Jelajah Materi dan Cerita Keluarga, lalu kerjakan post-test."
	elif not pre_before.is_empty():
		var diff := score - int(pre_before["score"])
		msg = "Pre-test %d, post-test %d. " % [int(pre_before["score"]), score]
		msg += ("Naik %d poin, luar biasa!" % diff) if diff > 0 else ("Nilainya sama. Terus semangat belajar!" if diff == 0 else "Coba ulangi materi yang belum dipahami, ya.")
	else:
		msg = "Kerjakan juga pre-test agar perkembanganmu terlihat."
	var mp := UI.panel(UI.WHITE, 22, 3, UI.INK, 16)
	mp.add_child(UI.label(msg, 22, UI.INK, UI.F_BOLD, HORIZONTAL_ALIGNMENT_CENTER))
	body.add_child(mp)
	if kind == "post":
		var rv := UI.button("Lihat pembahasan", UI.TEAL, "ui_list", UI.WHITE, 25, 80)
		rv.pressed.connect(_review)
		body.add_child(rv)
	else:
		var lm := UI.button("Mulai belajar", UI.TEAL, "ui_play", UI.WHITE, 25, 80)
		lm.pressed.connect(func(): Router.go("materi_list"))
		body.add_child(lm)
	var back := UI.button("Kembali ke Evaluasi", UI.WHITE, "ui_back", UI.INK, 24, 76)
	back.pressed.connect(func(): Router.go("evaluasi"))
	body.add_child(back)


func _review() -> void:
	_clear()
	body.add_child(UI.title("Pembahasan", 34))
	for i in answers.size():
		var a: Dictionary = answers[i]
		var q: Dictionary = KuisData.SOAL[a["q"]]
		var ok: bool = a["ok"]
		var p := UI.panel(UI.GOOD_L if ok else UI.BAD_L, 22, 3, UI.INK, 16)
		var v := UI.vbox(6)
		var head := UI.hbox(10)
		head.add_child(UI.icon("c_badge_ok" if ok else "c_badge_no", 34))
		head.add_child(UI.label("Soal %d" % (i + 1), 20, UI.INK, UI.F_BLACK, HORIZONTAL_ALIGNMENT_LEFT, false))
		v.add_child(head)
		v.add_child(UI.label(q["soal"], 22, UI.INK, UI.F_BOLD))
		if not ok:
			v.add_child(UI.label("Jawabanmu: " + str(q["opsi"][a["chosen"]]), 20, UI.BAD.darkened(0.2), UI.F_BOLD))
		v.add_child(UI.label("Jawaban tepat: " + str(q["opsi"][q["jawaban"]]), 20, UI.GOOD.darkened(0.3), UI.F_BLACK))
		v.add_child(UI.label(q["bahas"], 19, UI.INK_SOFT, UI.F_BOLD))
		p.add_child(v)
		body.add_child(p)
	var back := UI.button("Kembali ke Evaluasi", UI.CORAL, "ui_back", UI.WHITE, 24, 78)
	back.pressed.connect(func(): Router.go("evaluasi"))
	body.add_child(back)
