extends Screen
## Peta materi: 7 topik tersusun seperti jalur petualangan.


func build() -> void:
	back_to = "home"
	var done := Game.materi_done_count()
	var pill := UI.pill("%d/7" % done, UI.WHITE, UI.INK, 22, "c_star_full")
	(pill.get_theme_stylebox("panel") as StyleBoxFlat).set_border_width_all(3)
	make_top_bar("Jelajah Materi", pill)
	var box := make_scroll(10)
	var intro := UI.hbox(12)
	var cv := CharacterView.make("bunda", "senang")
	cv.custom_minimum_size = Vector2(110, 142)
	intro.add_child(cv)
	var bubble := UI.panel(UI.WHITE, 22, 3, UI.INK, 16)
	bubble.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bubble.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	bubble.add_child(UI.label("Pilih topik mana saja. Setiap topik berisi materi, contoh, latihan, dan cek pemahaman.", 21, UI.INK, UI.F_BOLD))
	intro.add_child(bubble)
	box.add_child(intro)
	UI.slide_in(intro)

	var col := PathColumn.new()
	col.add_theme_constant_override("separation", 26)
	col.mouse_filter = Control.MOUSE_FILTER_PASS
	box.add_child(col)
	var first_open := -1
	for i in MateriData.TOPIK.size():
		var t: Dictionary = MateriData.TOPIK[i]
		if first_open < 0 and not Game.materi_done(t["id"]):
			first_open = i
		var row := _topic_row(i, t, i == first_open)
		col.add_child(row)
		UI.slide_in(row, 0.08 + i * 0.06, Vector2(-40 if i % 2 == 0 else 40, 0))
	for row in col.get_children():
		col.nodes.append(row.get_meta("node"))


func _topic_row(i: int, t: Dictionary, highlight: bool) -> Control:
	var col := GameData.color(t["warna"])
	var row := UI.hbox(16)
	row.mouse_filter = Control.MOUSE_FILTER_PASS
	# simpul bulat
	var node_wrap := Control.new()
	node_wrap.custom_minimum_size = Vector2(136, 136)
	node_wrap.mouse_filter = Control.MOUSE_FILTER_PASS
	node_wrap.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var node := UI.chunky(col, 64, 8.0, 4)
	node.set_pad(0, 0, 0, 0)
	node.position = Vector2(4, 4)
	node.size = Vector2(128, 128)
	node.accessibility_name = t["judul"]
	var cc := CenterContainer.new()
	var inner := UI.panel(UI.WHITE, 46, 3, UI.INK, 4)
	inner.custom_minimum_size = Vector2(92, 92)
	inner.add_child(UI.icon(t["ikon"], 78))
	cc.add_child(inner)
	node.add_child(cc)
	node_wrap.add_child(node)
	var num := UI.panel(UI.INK, 20, 0, UI.INK, 0)
	num.custom_minimum_size = Vector2(40, 40)
	num.position = Vector2(0, 0)
	var nl := UI.label(str(i + 1), 22, UI.WHITE, UI.F_TITLE, HORIZONTAL_ALIGNMENT_CENTER, false)
	nl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	num.add_child(nl)
	node_wrap.add_child(num)
	var stars := Game.materi_stars(t["id"])
	if stars > 0:
		var badge := UI.icon("c_badge_ok", 44)
		badge.position = Vector2(94, 0)
		node_wrap.add_child(badge)
	if highlight:
		UI.pulse_loop(node, 1.07, 1.3)
	row.set_meta("node", node_wrap)
	# kartu info
	var card := UI.chunky(UI.PAPER, 24, 7.0, 3)
	card.set_pad(18, 14, 18, 14)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.accessibility_name = t["judul"]
	var v := UI.vbox(4)
	var top := UI.hbox(8)
	top.add_child(UI.label("TOPIK %d" % (i + 1), 17, col.darkened(0.25), UI.F_BLACK, HORIZONTAL_ALIGNMENT_LEFT, false))
	top.add_child(UI.expander())
	if highlight:
		top.add_child(UI.pill("Mulai di sini", UI.SUN, UI.INK, 15))
	elif stars > 0:
		top.add_child(UI.stars(stars, 3, 24, 2))
	v.add_child(top)
	v.add_child(UI.title(t["judul"], 27))
	v.add_child(UI.label(t["ringkas"], 19, UI.INK_SOFT, UI.F_BOLD))
	card.add_child(v)
	var open := func(): Router.go("materi", {"id": t["id"]})
	node.pressed.connect(open)
	card.pressed.connect(open)
	if i % 2 == 0:
		row.add_child(node_wrap)
		row.add_child(card)
	else:
		row.add_child(card)
		row.add_child(node_wrap)
	return row
