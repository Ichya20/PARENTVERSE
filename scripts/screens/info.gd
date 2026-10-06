extends Screen
## Info aplikasi: tentang PARENTVERSE, ketua, anggota tim, anggota mahasiswa, mitra, dan program.


func build() -> void:
	back_to = "home"
	make_top_bar("Info Aplikasi")
	var box := make_scroll(16)
	# kepala
	var head := UI.frame(UI.TEAL, 30, 8.0, 4)
	head.set_pad(22, 22, 22, 22)
	var hv := UI.vbox(10)
	var ic_wrap := CenterContainer.new()
	ic_wrap.add_child(UI.icon("res://icon.svg", 132))
	hv.add_child(ic_wrap)
	var logo := Logo.make(48)
	hv.add_child(logo)
	var tag := UI.label(AppInfo.TAGLINE, 22, UI.WHITE, UI.F_BLACK, HORIZONTAL_ALIGNMENT_CENTER)
	hv.add_child(tag)
	var vp := UI.pill("Versi " + AppInfo.VERSI, UI.WHITE, UI.INK, 18)
	vp.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	hv.add_child(vp)
	head.add_child(hv)
	box.add_child(head)
	UI.pop_in(head, 0.0, 0.9)
	# tentang
	box.add_child(_section("Tentang Aplikasi", "t_komunikasi", UI.label(AppInfo.TENTANG, 22, UI.INK, UI.F_BOLD)))
	# tim
	box.add_child(_heading("Tim Pengabdian", "ui_person"))
	box.add_child(_role_label("Ketua Tim"))
	box.add_child(_person(AppInfo.KETUA["nama"], "Ketua Tim", AppInfo.KETUA["inisial"], UI.CORAL, true))
	box.add_child(_role_label("Anggota Tim"))
	for a in AppInfo.ANGGOTA:
		box.add_child(_person(a["nama"], "Anggota Tim", a["inisial"], UI.TEAL))
	box.add_child(_role_label("Anggota Mahasiswa"))
	var cols := [UI.SKY, UI.BERRY, UI.SUN_D, UI.SKY_D]
	for i in AppInfo.MAHASISWA.size():
		var m: Dictionary = AppInfo.MAHASISWA[i]
		box.add_child(_person(m["nama"], "NIM " + str(m["nim"]), m["inisial"], cols[i % cols.size()]))
	# mitra
	var mv := UI.vbox(4)
	mv.add_child(UI.title(AppInfo.MITRA["nama"], 26))
	mv.add_child(UI.label(AppInfo.MITRA["alamat"], 20, UI.INK_SOFT, UI.F_BOLD))
	box.add_child(_section("Mitra Sasaran", "t_kedekatan", mv))
	# program
	var pv := UI.vbox(8)
	for item in AppInfo.PROGRAM:
		var r := UI.hbox(10)
		var dot := UI.panel(UI.SUN, 8, 2, UI.INK, 0)
		dot.custom_minimum_size = Vector2(16, 16)
		dot.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		r.add_child(dot)
		r.add_child(UI.label(item, 21, UI.INK, UI.F_BOLD))
		pv.add_child(r)
	box.add_child(_section("Program", "menu_evaluasi", pv))
	# tokoh
	var tv := UI.vbox(10)
	for t in AppInfo.TOKOH:
		var r2 := UI.hbox(12)
		var cv := CharacterView.make(t["id"], "senang")
		cv.custom_minimum_size = Vector2(84, 108)
		r2.add_child(cv)
		var v2 := UI.vbox(0)
		v2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		v2.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		v2.add_child(UI.title(t["nama"], 23))
		v2.add_child(UI.label(t["ket"], 19, UI.INK_SOFT, UI.F_BOLD))
		r2.add_child(v2)
		tv.add_child(r2)
	box.add_child(_section("Kenalan dengan Tokoh", "g_emosi", tv))
	box.add_child(_section("Kredit", "c_sparkle", UI.label(AppInfo.KREDIT, 19, UI.INK_SOFT, UI.F_BOLD)))
	box.add_child(UI.label("© 2026 Tim PARENTVERSE — Telkom University", 18, UI.INK_SOFT, UI.F_BOLD, HORIZONTAL_ALIGNMENT_CENTER))


func _heading(text: String, icon_name: String) -> Control:
	var r := UI.hbox(10)
	r.add_child(UI.icon(icon_name, 36, UI.CORAL))
	var l := UI.label(text, 30, UI.INK, UI.F_TITLE, HORIZONTAL_ALIGNMENT_LEFT, false)
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	r.add_child(l)
	return r


func _role_label(text: String) -> Control:
	return UI.label(text.to_upper(), 18, UI.INK_SOFT, UI.F_BLACK)


func _person(nama: String, ket: String, initials: String, col: Color, big: bool = false) -> Control:
	var p := UI.frame(UI.WHITE, 24, 6.0, 3)
	p.set_pad(16, 14, 16, 14)
	var r := UI.hbox(14)
	r.add_child(UI.avatar(initials, col, 88 if big else 72))
	var v := UI.vbox(2)
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	v.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	v.add_child(UI.title(nama, 25 if big else 23))
	v.add_child(UI.label(ket, 19, UI.INK_SOFT, UI.F_BOLD))
	r.add_child(v)
	p.add_child(r)
	return p


func _section(title_text: String, icon_name: String, content: Control) -> Control:
	var p := UI.frame(UI.PAPER, 26, 7.0, 3)
	p.set_pad(20, 16, 20, 18)
	var v := UI.vbox(10)
	var h := UI.hbox(10)
	h.add_child(UI.icon(icon_name, 40))
	var l := UI.label(title_text, 26, UI.INK, UI.F_TITLE, HORIZONTAL_ALIGNMENT_LEFT, false)
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	h.add_child(l)
	v.add_child(h)
	v.add_child(content)
	p.add_child(v)
	return p
