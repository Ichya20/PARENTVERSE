extends Screen
## Daftar cerita keluarga dengan dua peran: orang tua & remaja.

static var tab := "ortu"


func build() -> void:
	back_to = "home"
	if params.has("tab"):
		tab = str(params["tab"])
	var pill := UI.pill("%d/%d" % [Game.kasus_played_count(), CeritaData.CERITA.size()], UI.WHITE, UI.INK, 22, "c_star_full")
	(pill.get_theme_stylebox("panel") as StyleBoxFlat).set_border_width_all(3)
	make_top_bar("Cerita Keluarga", pill)
	var tabs := UI.hbox(12)
	for t in [["ortu", "Aku Orang Tua", "ui_person"], ["remaja", "Aku Remaja", "ui_heart"]]:
		var sel: bool = t[0] == tab
		var b := UI.button(t[1], UI.CORAL if sel else UI.WHITE, t[2], UI.WHITE if sel else UI.INK, 24, 76)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var key: String = t[0]
		b.pressed.connect(func():
			if key != tab:
				tab = key
				Router.go("cerita_list", {"tab": key}, true))
		tabs.add_child(b)
	layout.add_child(tabs)
	var box := make_scroll(16)
	var info := UI.hbox(12)
	var cv := CharacterView.make("bunda" if tab == "ortu" else "raka", "senang")
	cv.custom_minimum_size = Vector2(100, 130)
	info.add_child(cv)
	var bub := Bubble.make(UI.WHITE, "left", 0.5, 16)
	bub.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bub.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var msg := "Jadilah Ayah atau Bunda. Pilih respons terbaik saat menghadapi remaja di situasi sehari-hari." \
		if tab == "ortu" else "Jadilah Raka atau Nara. Latih cara menyampaikan perasaan kepada orang tua."
	bub.add_child(UI.label(msg, 21, UI.INK, UI.F_BOLD))
	info.add_child(bub)
	box.add_child(info)
	var list := CeritaData.list(tab)
	for i in list.size():
		var card := _card(list[i])
		box.add_child(card)
		UI.slide_in(card, 0.05 + i * 0.07)


func _card(c: Dictionary) -> Control:
	var card := UI.chunky(UI.PAPER, 26, 7.0, 3)
	card.set_pad(0, 0, 0, 0)
	card.custom_minimum_size = Vector2(0, 176)
	card.accessibility_name = c["judul"]
	var row := UI.hbox(0)
	var thumb := Panel.new()
	var ts := UI.sb(UI.SKY_L, 24)
	ts.corner_radius_top_right = 0
	ts.corner_radius_bottom_right = 0
	thumb.add_theme_stylebox_override("panel", ts)
	thumb.clip_children = CanvasItem.CLIP_CHILDREN_AND_DRAW
	thumb.custom_minimum_size = Vector2(172, 168)
	var pic := UI.picture(UI.ART + "bg/%s.svg" % c["latar"])
	UI.full(pic)
	thumb.add_child(pic)
	var cv := CharacterView.make(c["lawan"], "netral")
	cv.idle = false
	cv.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	cv.offset_top = 14
	cv.offset_bottom = 30
	thumb.add_child(cv)
	row.add_child(thumb)
	var line := ColorRect.new()
	line.color = UI.INK
	line.custom_minimum_size = Vector2(3, 0)
	row.add_child(line)
	var body := UI.margin(18, 14, 16, 14)
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var v := UI.vbox(6)
	var top := UI.hbox(8)
	top.add_child(UI.pill(c["tema"], UI.SUN_L, UI.INK, 16))
	top.add_child(UI.expander())
	var stars := Game.kasus_stars(c["id"])
	if Game.kasus_played(c["id"]):
		top.add_child(UI.stars(stars, 3, 26, 2))
	else:
		top.add_child(UI.pill("Baru", UI.CORAL, UI.WHITE, 15))
	v.add_child(top)
	v.add_child(UI.title(c["judul"], 27))
	var who := "Kamu jadi %s" % CharacterView.NAMES.get(c["pemain"], "")
	v.add_child(UI.label(who, 19, UI.INK_SOFT, UI.F_BOLD))
	body.add_child(v)
	row.add_child(body)
	card.add_child(row)
	var id: String = c["id"]
	card.pressed.connect(func(): Router.go("cerita", {"id": id}))
	return card
