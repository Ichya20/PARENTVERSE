class_name MemoryCard
extends Control
## Kartu bolak-balik untuk permainan Memori Kebersamaan.

signal tapped(card: MemoryCard)

var key := ""
var title_text := ""
var face_up := false
var matched := false
var _front: PanelContainer
var _back: PanelContainer
var _flipping := false


func setup(p_key: String, p_title: String) -> MemoryCard:
	key = p_key
	title_text = p_title
	mouse_filter = Control.MOUSE_FILTER_STOP
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	custom_minimum_size = Vector2(0, 150)
	accessibility_name = "Kartu tertutup"
	# sisi belakang
	_back = PanelContainer.new()
	_back.add_theme_stylebox_override("panel", UI.sb(UI.CORAL, 22, 4, UI.INK, 0))
	_back.mouse_filter = Control.MOUSE_FILTER_IGNORE
	UI.full(_back)
	var tile := TextureRect.new()
	tile.texture = UI.tex(UI.ART + "bg/card_back.svg")
	tile.stretch_mode = TextureRect.STRETCH_TILE
	tile.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tile.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var tm := UI.margin(8, 8, 8, 8)
	tm.add_child(tile)
	_back.add_child(tm)
	var cc := CenterContainer.new()
	cc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var circ := UI.panel(UI.WHITE, 34, 3, UI.INK, 0)
	circ.custom_minimum_size = Vector2(68, 68)
	circ.add_child(UI.icon("c_heart_full", 44))
	cc.add_child(circ)
	_back.add_child(cc)
	add_child(_back)
	# sisi depan
	_front = PanelContainer.new()
	_front.add_theme_stylebox_override("panel", UI.sb(UI.WHITE, 22, 4, UI.INK, 8))
	_front.mouse_filter = Control.MOUSE_FILTER_IGNORE
	UI.full(_front)
	var v := UI.vbox(2)
	v.alignment = BoxContainer.ALIGNMENT_CENTER
	var ic := UI.icon(p_key, 92)
	ic.size_flags_vertical = Control.SIZE_EXPAND_FILL
	v.add_child(ic)
	v.add_child(UI.label(p_title, 17, UI.INK, UI.F_BLACK, HORIZONTAL_ALIGNMENT_CENTER))
	_front.add_child(v)
	_front.visible = false
	add_child(_front)
	return self


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		accept_event()
		if not face_up and not matched and not _flipping:
			tapped.emit(self)


func flip(up: bool) -> void:
	if face_up == up:
		return
	face_up = up
	_flipping = true
	Sfx.play("flip")
	offset_transform_enabled = true
	var tw := create_tween()
	tw.tween_property(self, "offset_transform_scale", Vector2(0.0, 1.04), 0.11).set_trans(Tween.TRANS_SINE)
	tw.tween_callback(func():
		_front.visible = up
		_back.visible = not up
		accessibility_name = title_text if up else "Kartu tertutup")
	tw.tween_property(self, "offset_transform_scale", Vector2.ONE, 0.13).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_callback(func(): _flipping = false)


func set_matched() -> void:
	matched = true
	var s := UI.sb(UI.GOOD_L, 22, 4, UI.GOOD.darkened(0.2), 8)
	_front.add_theme_stylebox_override("panel", s)
	UI.bounce(self, 1.1)
