extends Screen
## Aktivitas "Kartu Kesepakatan": menyusun aturan keluarga bersama lalu "menandatanganinya".

const MIN_ITEMS := 3

var selected: Array = []
var family_edit: LineEdit
var count_label: Label
var make_btn: Chunky
var stamps := {"ortu": false, "anak": false}


func build() -> void:
	back_to = "game_menu"
	var saved: Dictionary = Game.agreement()
	if saved.is_empty() or params.get("edit", false):
		selected = (saved.get("items", []) as Array).duplicate()
		_build_editor(str(saved.get("family", "")))
	else:
		_build_card(str(saved.get("family", "")), saved.get("items", []), str(saved.get("date", "")))


# --- Penyusun --------------------------------------------------------------------
func _build_editor(family: String) -> void:
	make_top_bar("Kartu Kesepakatan")
	var box := make_scroll(14)
	var intro := UI.hbox(12)
	var cv := CharacterView.make("ayah", "senang")
	cv.custom_minimum_size = Vector2(104, 136)
	intro.add_child(cv)
	var bub := Bubble.make(UI.WHITE, "left", 0.5, 16)
	bub.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bub.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	bub.add_child(UI.label("Diskusikan bersama, lalu pilih minimal 3 aturan. Orang tua juga ikut berjanji, ya!", 21, UI.INK, UI.F_BOLD))
	intro.add_child(bub)
	box.add_child(intro)
	box.add_child(UI.label("Nama keluarga (boleh dikosongkan)", 21, UI.INK, UI.F_BLACK))
	family_edit = LineEdit.new()
	family_edit.placeholder_text = "Contoh: Keluarga Budi"
	family_edit.text = family
	family_edit.max_length = 32
	family_edit.custom_minimum_size = Vector2(0, 74)
	family_edit.virtual_keyboard_type = LineEdit.KEYBOARD_TYPE_DEFAULT
	family_edit.accessibility_name = "Nama keluarga"
	box.add_child(family_edit)
	for cat in GameData.KESEPAKATAN:
		var col := GameData.color(cat["warna"])
		var head := UI.hbox(10)
		head.add_child(UI.icon(cat["ikon"], 44))
		var hl := UI.label(cat["judul"], 26, UI.INK, UI.F_TITLE, HORIZONTAL_ALIGNMENT_LEFT, false)
		hl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		head.add_child(hl)
		box.add_child(UI.spacer(4))
		box.add_child(head)
		for item in cat["butir"]:
			box.add_child(_item_row(item, col))
	box.add_child(UI.spacer(6))
	count_label = UI.label("", 21, UI.INK_SOFT, UI.F_BOLD, HORIZONTAL_ALIGNMENT_CENTER)
	box.add_child(count_label)
	make_btn = UI.button("Buat Kartu Kesepakatan", UI.CORAL, "ui_check", UI.WHITE, 25, 84)
	make_btn.pressed.connect(func():
		Game.set_agreement(family_edit.text.strip_edges(), selected)
		Router.go("kesepakatan", {}, false))
	box.add_child(make_btn)
	_update_count()


func _item_row(text: String, col: Color) -> Control:
	var row := UI.chunky(UI.WHITE, 20, 5.0, 3)
	row.set_pad(14, 12, 14, 12)
	row.accessibility_name = text
	row.sound = ""
	var h := UI.hbox(14)
	var on := text in selected
	var box := UI.panel(col if on else UI.WHITE, 12, 3, UI.INK, 0)
	box.custom_minimum_size = Vector2(44, 44)
	box.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var tick := UI.icon("ui_check", 32, UI.WHITE)
	tick.visible = on
	var tc := CenterContainer.new()
	tc.add_child(tick)
	box.add_child(tc)
	h.add_child(box)
	h.add_child(UI.label(text, 22, UI.INK, UI.F_BOLD))
	row.add_child(h)
	row.pressed.connect(func():
		if text in selected:
			selected.erase(text)
			Sfx.play("click")
		else:
			selected.append(text)
			Sfx.play("pop")
		var now := text in selected
		tick.visible = now
		(box.get_theme_stylebox("panel") as StyleBoxFlat).bg_color = col if now else UI.WHITE
		UI.bounce(box)
		_update_count())
	return row


func _update_count() -> void:
	var n := selected.size()
	count_label.text = "%d aturan dipilih" % n + ("" if n >= MIN_ITEMS else " — pilih minimal %d" % MIN_ITEMS)
	make_btn.disabled = n < MIN_ITEMS


# --- Kartu jadi --------------------------------------------------------------------
func _build_card(family: String, items: Array, date: String) -> void:
	var edit := UI.round_button("ui_list", UI.WHITE, UI.INK, 72, "Ubah kesepakatan")
	edit.pressed.connect(func(): Router.go("kesepakatan", {"edit": true}))
	make_top_bar("Kartu Kesepakatan", edit)
	var box := make_scroll(14)
	var card := UI.frame(UI.PAPER, 30, 9.0, 4)
	card.set_pad(0, 0, 0, 0)
	var v := UI.vbox(0)
	card.add_child(v)
	var head := PanelContainer.new()
	var hs := UI.sb(UI.TEAL, 28, 0, UI.INK, 18)
	hs.corner_radius_bottom_left = 0
	hs.corner_radius_bottom_right = 0
	head.add_theme_stylebox_override("panel", hs)
	var hv := UI.vbox(4)
	var fam := UI.hbox(0)
	fam.alignment = BoxContainer.ALIGNMENT_CENTER
	for id in ["ayah", "bunda", "nara", "raka"]:
		var cv := CharacterView.make(id, "senang")
		cv.custom_minimum_size = Vector2(96, 124)
		fam.add_child(cv)
	hv.add_child(fam)
	var t := UI.title("Kesepakatan Keluarga", 32, UI.WHITE, HORIZONTAL_ALIGNMENT_CENTER)
	UI.outline(t, UI.INK, 8)
	hv.add_child(t)
	if family != "":
		var fl := UI.label(family, 26, UI.SUN, UI.F_TITLE, HORIZONTAL_ALIGNMENT_CENTER)
		UI.outline(fl, UI.INK, 7)
		hv.add_child(fl)
	head.add_child(hv)
	v.add_child(head)
	var line := ColorRect.new()
	line.color = UI.INK
	line.custom_minimum_size = Vector2(0, 3)
	v.add_child(line)
	var body := UI.margin(22, 18, 22, 22)
	var bv := UI.vbox(12)
	bv.add_child(UI.label("Kami sepakat untuk:", 22, UI.INK_SOFT, UI.F_BLACK))
	for i in items.size():
		var r := UI.hbox(12)
		var num := UI.panel(UI.SUN, 18, 3, UI.INK, 0)
		num.custom_minimum_size = Vector2(38, 38)
		num.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
		var nl := UI.label(str(i + 1), 20, UI.INK, UI.F_TITLE, HORIZONTAL_ALIGNMENT_CENTER, false)
		nl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		num.add_child(nl)
		r.add_child(num)
		r.add_child(UI.label(str(items[i]), 22, UI.INK, UI.F_BOLD))
		bv.add_child(r)
	bv.add_child(UI.spacer(6))
	bv.add_child(UI.label("Ditetapkan pada " + date, 19, UI.INK_SOFT, UI.F_BOLD, HORIZONTAL_ALIGNMENT_CENTER))
	var sign := UI.hbox(14)
	for who in [["ortu", "Orang Tua"], ["anak", "Anak"]]:
		sign.add_child(_stamp_box(who[0], who[1]))
	bv.add_child(sign)
	bv.add_child(UI.label("Ketuk kotak untuk membubuhkan cap hati.", 18, UI.INK_SOFT, UI.F_BOLD, HORIZONTAL_ALIGNMENT_CENTER))
	body.add_child(bv)
	v.add_child(body)
	box.add_child(card)
	UI.pop_in(card, 0.05, 0.85)
	var note := UI.panel(UI.SUN_L, 20, 3, UI.INK, 14)
	note.add_child(UI.label("Simpan kartu ini dengan tangkapan layar (screenshot), lalu tempel di tempat yang mudah dilihat seluruh keluarga.", 20, UI.INK, UI.F_BOLD))
	box.add_child(note)
	var done := UI.button("Selesai", UI.CORAL, "ui_check", UI.WHITE, 26, 82)
	done.pressed.connect(func(): Router.go("game_menu"))
	box.add_child(done)


func _stamp_box(key: String, label_text: String) -> Control:
	var b := UI.chunky(UI.WHITE, 22, 6.0, 3)
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.custom_minimum_size = Vector2(0, 150)
	b.accessibility_name = "Cap " + label_text
	b.sound = ""
	var v := UI.vbox(4)
	v.alignment = BoxContainer.ALIGNMENT_CENTER
	var heart := UI.icon("c_heart_full", 70)
	heart.modulate.a = 0.0
	v.add_child(heart)
	var ln := ColorRect.new()
	ln.color = UI.INK
	ln.custom_minimum_size = Vector2(0, 3)
	v.add_child(ln)
	v.add_child(UI.label(label_text, 21, UI.INK, UI.F_BLACK, HORIZONTAL_ALIGNMENT_CENTER))
	b.add_child(v)
	b.pressed.connect(func():
		if stamps[key]:
			return
		stamps[key] = true
		Sfx.play("pop", 0.8)
		heart.offset_transform_enabled = true
		heart.offset_transform_scale = Vector2(2.2, 2.2)
		heart.offset_transform_rotation = -0.4
		var tw := heart.create_tween().set_parallel(true)
		tw.tween_property(heart, "modulate:a", 1.0, 0.15)
		tw.tween_property(heart, "offset_transform_scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.tween_property(heart, "offset_transform_rotation", -0.15, 0.3)
		if stamps["ortu"] and stamps["anak"]:
			_complete())
	return b


func _complete() -> void:
	var items: Array = Game.agreement().get("items", [])
	Game.set_game_result("kesepakatan", items.size(), 3)
	Sfx.play("win")
	Confetti.burst(overlay)
	toast("Kesepakatan resmi! Kamu mendapat 3 bintang.", UI.GOOD, UI.WHITE, 2.8)
