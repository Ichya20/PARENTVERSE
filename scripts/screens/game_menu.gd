extends Screen
## Menu "Main Bareng": empat permainan/aktivitas untuk orang tua dan anak.


func build() -> void:
	back_to = "home"
	make_top_bar("Main Bareng")
	var box := make_scroll(16)
	var intro := UI.hbox(12)
	var cv := CharacterView.make("raka", "senang")
	cv.custom_minimum_size = Vector2(104, 136)
	intro.add_child(cv)
	var bub := Bubble.make(UI.WHITE, "left", 0.5, 16)
	bub.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bub.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	bub.add_child(UI.label("Ajak anggota keluarga bermain bersama, bergantian, atau berlomba skor!", 21, UI.INK, UI.F_BOLD))
	intro.add_child(bub)
	box.add_child(intro)
	for i in GameData.MENU.size():
		var g: Dictionary = GameData.MENU[i]
		var card := _card(g)
		box.add_child(card)
		UI.slide_in(card, 0.05 + i * 0.08)


func _card(g: Dictionary) -> Control:
	var col := GameData.color(g["warna"])
	var card := UI.chunky(UI.PAPER, 28, 8.0, 4)
	card.set_pad(0, 0, 0, 0)
	card.custom_minimum_size = Vector2(0, 170)
	card.accessibility_name = g["judul"]
	var row := UI.hbox(0)
	var side := PanelContainer.new()
	var ss := UI.sb(col, 26, 0, UI.INK, 0)
	ss.corner_radius_top_right = 0
	ss.corner_radius_bottom_right = 0
	side.add_theme_stylebox_override("panel", ss)
	side.custom_minimum_size = Vector2(170, 0)
	var cc := CenterContainer.new()
	var circle := UI.panel(Color(1, 1, 1, 0.92), 60, 3, UI.INK, 6)
	circle.custom_minimum_size = Vector2(118, 118)
	circle.add_child(UI.icon(g["ikon"], 100))
	cc.add_child(circle)
	side.add_child(cc)
	row.add_child(side)
	var line := ColorRect.new()
	line.color = UI.INK
	line.custom_minimum_size = Vector2(3, 0)
	row.add_child(line)
	var body := UI.margin(18, 14, 18, 14)
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var v := UI.vbox(6)
	v.add_child(UI.title(g["judul"], 28))
	v.add_child(UI.label(g["ket"], 20, UI.INK_SOFT, UI.F_BOLD))
	var foot := UI.hbox(8)
	var id: String = g["id"]
	if id == "kesepakatan":
		var made := not Game.agreement().is_empty()
		foot.add_child(UI.pill("Sudah dibuat" if made else "Belum dibuat", UI.GOOD_L if made else UI.LINE, UI.INK, 16))
	elif Game.game_played(id):
		foot.add_child(UI.pill("Rekor %d" % Game.game_best(id), UI.SUN_L, UI.INK, 16, "c_trophy"))
	else:
		foot.add_child(UI.pill("Baru", UI.CORAL, UI.WHITE, 16))
	foot.add_child(UI.expander())
	foot.add_child(UI.stars(Game.game_stars(id), 3, 26, 2))
	v.add_child(foot)
	body.add_child(v)
	row.add_child(body)
	card.add_child(row)
	card.pressed.connect(func(): Router.go(id))
	return card
