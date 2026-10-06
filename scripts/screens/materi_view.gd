extends Screen
## Pemutar materi: slide bergambar (intro, poin, napas, banding, tips, cek) dengan navigasi & geser.

var topic: Dictionary
var slides: Array
var idx := 0
var color: Color = UI.TEAL
var holder: Control
var current: Control
var bar: MeterBar
var counter: Label
var prev_btn: Chunky
var next_btn: Chunky
var answered := false
var wrong_tries := 0
var revealed := {}
var _touch_start := Vector2.ZERO
var _touching := false
var _busy := false


func build() -> void:
	back_to = "materi_list"
	topic = MateriData.by_id(str(params.get("id", "remaja")))
	if topic.is_empty():
		topic = MateriData.TOPIK[0]
	slides = topic["slides"]
	color = GameData.color(topic["warna"])
	var right: Control = null
	if Sfx.can_speak():
		var sp := UI.round_button("ui_speaker", UI.WHITE, UI.INK, 72, "Bacakan materi")
		sp.pressed.connect(_speak)
		right = sp
	make_top_bar(topic["judul"], right)
	var prow := UI.hbox(14)
	bar = MeterBar.make(0.0, color, 18)
	bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	prow.add_child(bar)
	counter = UI.label("1/%d" % slides.size(), 20, UI.INK, UI.F_BLACK, HORIZONTAL_ALIGNMENT_RIGHT, false)
	prow.add_child(counter)
	layout.add_child(prow)
	holder = Control.new()
	holder.size_flags_vertical = Control.SIZE_EXPAND_FILL
	holder.clip_contents = true
	holder.mouse_filter = Control.MOUSE_FILTER_PASS
	layout.add_child(holder)
	var nav := UI.hbox(14)
	prev_btn = UI.button("Kembali", UI.WHITE, "ui_back", UI.INK, 25, 80)
	prev_btn.custom_minimum_size.x = 200
	prev_btn.pressed.connect(func(): go_to(idx - 1))
	nav.add_child(prev_btn)
	next_btn = UI.button("Lanjut", color if color != UI.SUN else UI.CORAL, "ui_next", UI.WHITE, 26, 80)
	next_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	next_btn.pressed.connect(_on_next)
	nav.add_child(next_btn)
	layout.add_child(nav)
	go_to(0, true)


func _on_next() -> void:
	if idx < slides.size() - 1:
		go_to(idx + 1)
	elif answered:
		_finish()
	else:
		toast("Jawab pertanyaannya dulu, ya!", UI.INK)


func go_to(i: int, instant: bool = false) -> void:
	if i < 0 or i >= slides.size() or _busy:
		return
	Sfx.stop_speaking()
	var dir := 1 if i >= idx else -1
	idx = i
	var old := current
	current = _build_slide(slides[i])
	holder.add_child(current)
	_update_nav()
	if instant or old == null:
		if old:
			old.queue_free()
		return
	_busy = true
	var w := holder.size.x
	current.offset_transform_enabled = true
	current.offset_transform_position = Vector2(w * dir, 0)
	old.offset_transform_enabled = true
	var tw := create_tween().set_parallel(true)
	tw.tween_property(current, "offset_transform_position", Vector2.ZERO, 0.32).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.tween_property(old, "offset_transform_position", Vector2(-w * dir, 0), 0.32).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.tween_property(old, "modulate:a", 0.0, 0.3)
	tw.chain().tween_callback(func():
		old.queue_free()
		_busy = false)


func _update_nav() -> void:
	bar.animate_to(float(idx + 1) / slides.size(), 0.35)
	counter.text = "%d/%d" % [idx + 1, slides.size()]
	prev_btn.disabled = idx == 0
	var last := idx == slides.size() - 1
	var l: Label = next_btn.get_meta("label")
	l.text = "Selesai" if last else "Lanjut"
	next_btn.disabled = last and not answered


func _input(event: InputEvent) -> void:
	if has_modal() or _busy:
		return
	if event is InputEventScreenTouch:
		var st := event as InputEventScreenTouch
		if st.pressed and holder.get_global_rect().has_point(st.position):
			_touching = true
			_touch_start = st.position
		elif not st.pressed and _touching:
			_touching = false
			var d := st.position - _touch_start
			if absf(d.x) > 120 and absf(d.y) < 90:
				if d.x < 0:
					if idx < slides.size() - 1:
						go_to(idx + 1)
				else:
					go_to(idx - 1)


# --- Pembuat slide ---------------------------------------------------------------
func _wrap(content: Control) -> Control:
	var sc := ScrollContainer.new()
	sc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	UI.full(sc)
	var m := UI.margin(4, 8, 4, 16)
	m.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	m.add_child(content)
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sc.add_child(m)
	return sc


func _build_slide(s: Dictionary) -> Control:
	match s["tipe"]:
		"intro":
			return _wrap(_slide_intro(s))
		"poin":
			return _wrap(_slide_poin(s))
		"napas":
			return _wrap(_slide_napas(s))
		"banding":
			return _wrap(_slide_banding(s))
		"tips":
			return _wrap(_slide_tips(s))
		"cek":
			return _wrap(_slide_cek(s))
	return _wrap(UI.label("?"))


func _slide_intro(s: Dictionary) -> Control:
	var v := UI.vbox(18)
	var stage := UI.hbox(18)
	var cv := CharacterView.make(s["tokoh"], s["ekspresi"])
	cv.custom_minimum_size = Vector2(220, 286)
	cv.size_flags_vertical = Control.SIZE_SHRINK_END
	stage.add_child(cv)
	var bub := Bubble.make(UI.WHITE, "left", 0.55, 18)
	bub.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bub.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var bv := UI.vbox(6)
	bv.add_child(UI.label(CharacterView.NAMES.get(s["tokoh"], ""), 20, color.darkened(0.2), UI.F_BLACK))
	bv.add_child(UI.label(s["ucapan"], 24, UI.INK, UI.F_BOLD))
	bub.add_child(bv)
	stage.add_child(bub)
	v.add_child(stage)
	UI.pop_in(bub, 0.15, 0.7)
	cv.set_talking(true)
	cv.create_tween().tween_callback(cv.set_talking.bind(false)).set_delay(1.8)
	var card := UI.panel(UI.PAPER, 26, 3, UI.INK, 24)
	var cvb := UI.vbox(10)
	var head := UI.hbox(10)
	head.add_child(UI.icon("c_sparkle", 34))
	head.add_child(UI.label("Kata Oyen", 22, UI.TEAL_D, UI.F_TITLE, HORIZONTAL_ALIGNMENT_LEFT, false))
	cvb.add_child(head)
	cvb.add_child(UI.rich(UI.md(s["teks"]), 25, UI.INK))
	card.add_child(cvb)
	v.add_child(card)
	UI.slide_in(card, 0.3)
	return v


func _slide_poin(s: Dictionary) -> Control:
	var v := UI.vbox(14)
	v.add_child(UI.title(s["judul"], 32))
	var pts: Array = s["poin"]
	for i in pts.size():
		var p: Dictionary = pts[i]
		var card := UI.chunky(UI.WHITE, 22, 6.0, 3)
		card.tappable = false
		card.mouse_filter = Control.MOUSE_FILTER_PASS
		card.set_pad(16, 14, 18, 14)
		var row := UI.hbox(16)
		var badge := UI.panel(color, 30, 3, UI.INK, 0)
		badge.custom_minimum_size = Vector2(60, 60)
		badge.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
		var bl := UI.label(str(p.get("huruf", str(i + 1))), 30, UI.WHITE, UI.F_TITLE, HORIZONTAL_ALIGNMENT_CENTER, false)
		bl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		UI.outline(bl, UI.INK, 7)
		badge.add_child(bl)
		row.add_child(badge)
		var tv := UI.vbox(2)
		tv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		tv.add_child(UI.title(p["judul"], 26))
		tv.add_child(UI.label(p["teks"], 22, UI.INK_SOFT, UI.F_BOLD))
		row.add_child(tv)
		card.add_child(row)
		v.add_child(card)
		UI.slide_in(card, 0.08 + i * 0.08, Vector2(40, 0))
	return v


func _slide_napas(s: Dictionary) -> Control:
	var v := UI.vbox(16)
	v.add_child(UI.title(s["judul"], 32))
	v.add_child(UI.label(s["teks"], 23, UI.INK_SOFT, UI.F_BOLD))
	var br := Breather.new()
	v.add_child(br)
	var row := UI.hbox(12)
	var cv := CharacterView.make("oyen", "netral")
	cv.custom_minimum_size = Vector2(110, 140)
	row.add_child(cv)
	var btn := UI.button("Mulai latihan", UI.TEAL, "ui_play", UI.WHITE, 26, 84)
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	btn.pressed.connect(func():
		btn.disabled = true
		cv.set_expression("kedip")
		br.start())
	br.finished.connect(func():
		cv.set_expression("senang")
		btn.disabled = false
		(btn.get_meta("label") as Label).text = "Ulangi latihan")
	row.add_child(btn)
	v.add_child(row)
	return v


func _quote_card(kind: String, text: String) -> Control:
	var good := kind == "baik"
	var p := UI.panel(UI.GOOD_L if good else UI.BAD_L, 24, 3, UI.INK, 18)
	var v := UI.vbox(8)
	var head := UI.hbox(10)
	head.add_child(UI.icon("c_badge_ok" if good else "c_badge_no", 40))
	var hl := UI.label("Lebih baik" if good else "Kurang tepat", 24, UI.GOOD.darkened(0.25) if good else UI.BAD.darkened(0.2), UI.F_TITLE, HORIZONTAL_ALIGNMENT_LEFT, false)
	hl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	head.add_child(hl)
	v.add_child(head)
	v.add_child(UI.label(text, 24, UI.INK, UI.F_BOLD))
	p.add_child(v)
	return p


func _slide_banding(s: Dictionary) -> Control:
	var v := UI.vbox(14)
	v.add_child(UI.title("Coba Bandingkan", 32))
	var sit := UI.panel(UI.SUN_L, 22, 3, UI.INK, 18)
	var sv := UI.vbox(4)
	sv.add_child(UI.label("SITUASI", 17, UI.SUN_D.darkened(0.35), UI.F_BLACK))
	sv.add_child(UI.label(s["situasi"], 24, UI.INK, UI.F_BOLD))
	sit.add_child(sv)
	v.add_child(sit)
	v.add_child(_quote_card("kurang", s["kurang"]))
	var slot := UI.vbox(14)
	v.add_child(slot)
	var key := "%s_%d" % [topic["id"], idx]
	var show_good := func():
		for c in slot.get_children():
			c.queue_free()
		var q := _quote_card("baik", s["baik"])
		slot.add_child(q)
		UI.pop_in(q, 0.0, 0.85)
		var why := UI.hbox(12)
		var cv := CharacterView.make("oyen", "senang")
		cv.custom_minimum_size = Vector2(96, 124)
		why.add_child(cv)
		var bub := Bubble.make(UI.WHITE, "left", 0.5, 16)
		bub.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		bub.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		bub.add_child(UI.label(s["alasan"], 22, UI.INK, UI.F_BOLD))
		why.add_child(bub)
		slot.add_child(why)
		UI.slide_in(why, 0.2)
	if revealed.get(key, false):
		show_good.call()
	else:
		var cover := UI.chunky(UI.GOOD, 24, 7.0, 3)
		cover.set_pad(18, 18, 18, 18)
		cover.custom_minimum_size = Vector2(0, 120)
		cover.accessibility_name = "Lihat respons yang lebih baik"
		var row := UI.hbox(14)
		row.alignment = BoxContainer.ALIGNMENT_CENTER
		row.add_child(UI.icon("ui_hand", 46, UI.WHITE))
		var cl := UI.label("Ketuk untuk melihat respons yang lebih baik", 24, UI.WHITE, UI.F_TITLE, HORIZONTAL_ALIGNMENT_CENTER)
		UI.outline(cl, UI.INK, 6)
		cl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(cl)
		cover.add_child(row)
		cover.sound = "chime"
		cover.pressed.connect(func():
			revealed[key] = true
			show_good.call())
		slot.add_child(cover)
		UI.pulse_loop(cover, 1.03, 1.6)
	return v


func _slide_tips(s: Dictionary) -> Control:
	var v := UI.vbox(14)
	v.add_child(UI.title(s["judul"], 32))
	var avoid: bool = s.get("hindari", false)
	var warn: bool = s.get("waspada", false)
	var tips: Array = s["tips"]
	if not avoid and not warn:
		v.add_child(UI.label("Tandai yang ingin dicoba bersama keluarga minggu ini.", 21, UI.INK_SOFT, UI.F_BOLD))
	var checked: Array = Game.checklist(topic["id"]).duplicate()
	for i in tips.size():
		var t: String = tips[i]
		if avoid or warn:
			var p := UI.panel(UI.BAD_L if avoid else UI.SUN_L, 22, 3, UI.INK, 16)
			var r := UI.hbox(14)
			r.add_child(UI.icon("c_badge_no" if avoid else "c_badge_mid", 40))
			var l := UI.label(t, 23, UI.INK, UI.F_BOLD)
			l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			r.add_child(l)
			p.add_child(r)
			v.add_child(p)
			UI.slide_in(p, 0.06 * i, Vector2(30, 0))
		else:
			var row := UI.chunky(UI.WHITE, 22, 6.0, 3)
			row.set_pad(16, 14, 16, 14)
			row.accessibility_name = t
			var h := UI.hbox(14)
			var box := UI.panel(UI.GOOD if i in checked else UI.WHITE, 12, 3, UI.INK, 0)
			box.custom_minimum_size = Vector2(46, 46)
			box.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			var tick := UI.icon("ui_check", 34, UI.WHITE)
			tick.visible = i in checked
			var tc := CenterContainer.new()
			tc.add_child(tick)
			box.add_child(tc)
			h.add_child(box)
			var l2 := UI.label(t, 23, UI.INK, UI.F_BOLD)
			l2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			h.add_child(l2)
			row.add_child(h)
			row.pressed.connect(func():
				if i in checked:
					checked.erase(i)
				else:
					checked.append(i)
					Sfx.play("pop")
				var on := i in checked
				tick.visible = on
				(box.get_theme_stylebox("panel") as StyleBoxFlat).bg_color = UI.GOOD if on else UI.WHITE
				UI.bounce(box)
				Game.set_checklist(topic["id"], checked))
			v.add_child(row)
			UI.slide_in(row, 0.06 * i, Vector2(30, 0))
	if s.has("aksi"):
		var target: String = s["aksi"]
		var b := UI.button(s.get("aksi_teks", "Buka"), UI.SUN, "ui_play", UI.INK, 25, 80)
		b.pressed.connect(func(): Router.go(target))
		v.add_child(UI.spacer(4))
		v.add_child(b)
	return v


func _slide_cek(s: Dictionary) -> Control:
	var v := UI.vbox(14)
	var head := UI.hbox(12)
	head.add_child(UI.icon("menu_evaluasi", 54))
	var ht := UI.label("Cek Pemahaman", 32, UI.INK, UI.F_TITLE, HORIZONTAL_ALIGNMENT_LEFT, false)
	ht.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	head.add_child(ht)
	v.add_child(head)
	var q := UI.panel(UI.SKY_L, 24, 3, UI.INK, 20)
	q.add_child(UI.label(s["soal"], 25, UI.INK, UI.F_BOLD))
	v.add_child(q)
	var feedback := UI.vbox(10)
	var opts: Array = s["opsi"]
	var order: Array = range(opts.size())
	order.shuffle()
	var buttons: Array[Chunky] = []
	for k in order.size():
		var oi: int = order[k]
		var b := UI.chunky(UI.WHITE, 22, 6.0, 3)
		b.set_pad(14, 12, 16, 12)
		b.accessibility_name = opts[oi]
		var row := UI.hbox(14)
		var badge := UI.panel(UI.LINE, 22, 3, UI.INK, 0)
		badge.custom_minimum_size = Vector2(46, 46)
		badge.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		var bl := UI.label("ABC"[k], 24, UI.INK, UI.F_TITLE, HORIZONTAL_ALIGNMENT_CENTER, false)
		bl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		badge.add_child(bl)
		row.add_child(badge)
		var l := UI.label(opts[oi], 23, UI.INK, UI.F_BOLD)
		l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		row.add_child(l)
		b.add_child(row)
		b.sound = ""
		buttons.append(b)
		b.pressed.connect(func():
			if answered:
				return
			for c in feedback.get_children():
				c.queue_free()
			if oi == int(s["jawaban"]):
				answered = true
				Sfx.play("correct")
				b.set_face(UI.GOOD_L)
				(badge.get_theme_stylebox("panel") as StyleBoxFlat).bg_color = UI.GOOD
				bl.add_theme_color_override("font_color", UI.WHITE)
				UI.bounce(b, 1.05)
				for other in buttons:
					if other != b:
						other.disabled = true
				var fb := _quote_feedback(true, s["bahas"])
				feedback.add_child(fb)
				UI.pop_in(fb, 0.0, 0.85)
				_update_nav()
				UI.pulse_loop(next_btn, 1.05, 1.2)
			else:
				wrong_tries += 1
				Sfx.play("wrong")
				b.set_face(UI.BAD_L)
				b.disabled = true
				UI.shake(b)
				var fb2 := _quote_feedback(false, "Belum tepat. Coba pilih jawaban lain, ya!")
				feedback.add_child(fb2)
				UI.pop_in(fb2, 0.0, 0.9))
		v.add_child(b)
		UI.slide_in(b, 0.05 + 0.06 * k, Vector2(30, 0))
	v.add_child(feedback)
	return v


func _quote_feedback(ok: bool, text: String) -> Control:
	var p := UI.panel(UI.GOOD_L if ok else UI.BAD_L, 22, 3, UI.INK, 16)
	var r := UI.hbox(12)
	var cv := CharacterView.make("oyen", "senang" if ok else "sedih")
	cv.custom_minimum_size = Vector2(84, 108)
	r.add_child(cv)
	var tv := UI.vbox(4)
	tv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tv.add_child(UI.label("Benar!" if ok else "Ups!", 26, UI.GOOD.darkened(0.25) if ok else UI.BAD.darkened(0.15), UI.F_TITLE))
	tv.add_child(UI.label(text, 22, UI.INK, UI.F_BOLD))
	r.add_child(tv)
	p.add_child(r)
	return p


# --- Selesai -----------------------------------------------------------------
func _finish() -> void:
	var stars := 3 if wrong_tries == 0 else (2 if wrong_tries == 1 else 1)
	var had := Game.materi_stars(topic["id"])
	Game.set_materi_result(topic["id"], stars)
	Sfx.play("win")
	Confetti.burst(overlay)
	var box := UI.vbox(16)
	var cv := CharacterView.make("oyen", "senang")
	cv.custom_minimum_size = Vector2(0, 190)
	box.add_child(cv)
	box.add_child(UI.title("Topik selesai!", 36, UI.INK, HORIZONTAL_ALIGNMENT_CENTER))
	var st := UI.stars(stars, 3, 64, 10)
	st.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_child(st)
	for i in st.get_child_count():
		UI.pop_in(st.get_child(i), 0.25 + i * 0.18, 0.2, 0.5)
	var msg := "Hebat, kamu menjawab dengan tepat!" if stars == 3 else "Bagus! Kamu sudah memahami topik ini."
	if had > stars:
		msg += " Bintang terbaikmu tetap tersimpan."
	box.add_child(UI.label(msg, 23, UI.INK_SOFT, UI.F_BOLD, HORIZONTAL_ALIGNMENT_CENTER))
	var ni := MateriData.index_of(topic["id"]) + 1
	if ni < MateriData.TOPIK.size():
		var nb := UI.button("Topik berikutnya", UI.CORAL, "ui_next", UI.WHITE, 26, 80)
		var nid: String = MateriData.TOPIK[ni]["id"]
		nb.pressed.connect(func():
			close_modal(true)
			Router.go("materi", {"id": nid}))
		box.add_child(nb)
	var back := UI.button("Kembali ke peta materi", UI.WHITE, "ui_list", UI.INK, 24, 76)
	back.pressed.connect(func():
		close_modal(true)
		Router.go("materi_list"))
	box.add_child(back)
	show_modal(box, false)


func _speak() -> void:
	if Sfx.is_speaking():
		Sfx.stop_speaking()
		return
	var s: Dictionary = slides[idx]
	var parts := PackedStringArray()
	match s["tipe"]:
		"intro":
			parts.append(s["ucapan"])
			parts.append(s["teks"])
		"poin":
			parts.append(s["judul"])
			for p in s["poin"]:
				parts.append("%s. %s" % [p["judul"], p["teks"]])
		"napas":
			parts.append(s["judul"])
			parts.append(s["teks"])
		"banding":
			parts.append("Situasi. " + str(s["situasi"]))
			parts.append("Kurang tepat. " + str(s["kurang"]))
			parts.append("Lebih baik. " + str(s["baik"]))
			parts.append(s["alasan"])
		"tips":
			parts.append(s["judul"])
			for t in s["tips"]:
				parts.append(t)
		"cek":
			parts.append(s["soal"])
			for o in s["opsi"]:
				parts.append(o)
	if not Sfx.speak(". ".join(parts)):
		toast("Suara bacaan belum tersedia di perangkat ini.")
