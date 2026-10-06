extends Screen
## Layar pembuka: logo melompat, keluarga muncul, lalu otomatis ke beranda.

var _done := false


func build() -> void:
	back_to = ""
	var center := UI.vbox(18)
	center.alignment = BoxContainer.ALIGNMENT_CENTER
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	layout.add_child(center)

	var icon_box := CenterContainer.new()
	icon_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var ic := UI.icon("res://icon.svg", 210)
	icon_box.add_child(ic)
	center.add_child(icon_box)
	UI.pop_in(ic, 0.05, 0.3, 0.6)

	var logo := Logo.make(66)
	center.add_child(logo)
	logo.play_intro(0.35)

	var tag := UI.label(AppInfo.TAGLINE, 24, UI.INK_SOFT, UI.F_BOLD, HORIZONTAL_ALIGNMENT_CENTER)
	center.add_child(tag)
	UI.slide_in(tag, 1.0, Vector2(0, 20))

	var fam := UI.hbox(0)
	fam.alignment = BoxContainer.ALIGNMENT_CENTER
	fam.custom_minimum_size = Vector2(0, 230)
	var ids := ["ayah", "bunda", "nara", "raka", "oyen"]
	for i in ids.size():
		var cv := CharacterView.make(ids[i], "senang" if i % 2 == 0 else "netral")
		cv.custom_minimum_size = Vector2(130, 170) if ids[i] != "oyen" else Vector2(110, 140)
		cv.size_flags_vertical = Control.SIZE_SHRINK_END
		fam.add_child(cv)
		UI.slide_in(cv, 0.6 + i * 0.1, Vector2(0, 80), 0.55)
	center.add_child(fam)

	var foot := UI.vbox(10)
	foot.add_child(UI.label("Telkom University  ×  PKK Desa Muntang", 21, UI.INK_SOFT, UI.F_BOLD, HORIZONTAL_ALIGNMENT_CENTER))
	foot.add_child(UI.label("Ketuk layar untuk mulai", 19, Color(UI.INK_SOFT, 0.75), UI.F_BODY, HORIZONTAL_ALIGNMENT_CENTER))
	layout.add_child(foot)

	Sfx.play("star", 1.0, -4.0)
	get_tree().create_timer(3.2).timeout.connect(_finish)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_finish()


func _finish() -> void:
	if _done or not is_inside_tree():
		return
	_done = true
	Router.go("home")


func handle_back() -> bool:
	return true
