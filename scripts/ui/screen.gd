class_name Screen
extends Control
## Dasar setiap layar: latar bermotif kawung, area aman (notch), bilah judul, gulir, modal, dan toast.

const MAX_W := 760.0
const SIDE := 28.0

var params: Dictionary = {}
var back_to := "home"
var safe_top := 0.0
var safe_bottom := 0.0
var bg_color: Color = UI.CREAM

var frame: MarginContainer
var layout: VBoxContainer
var overlay: Control
var _modal: Control
var _toast: Control


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_compute_safe_area()
	_add_background()
	frame = UI.margin(SIDE, 12 + safe_top, SIDE, 12 + safe_bottom)
	UI.full(frame)
	add_child(frame)
	layout = UI.vbox(14)
	frame.add_child(layout)
	overlay = Control.new()
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	UI.full(overlay)
	add_child(overlay)
	resized.connect(_on_resized)
	build()
	_on_resized()


## Diisi oleh setiap layar.
func build() -> void:
	pass


func _compute_safe_area() -> void:
	if not OS.has_feature("mobile"):
		return
	var win := DisplayServer.window_get_size()
	var safe := DisplayServer.get_display_safe_area()
	var vis := get_viewport().get_visible_rect().size
	if win.y <= 0 or safe.size.y <= 0:
		return
	var k := vis.y / float(win.y)
	safe_top = clampf(safe.position.y * k, 0.0, 140.0)
	safe_bottom = clampf((win.y - safe.end.y) * k, 0.0, 120.0)


func _on_resized() -> void:
	if frame == null:
		return
	var side := maxf(SIDE, (size.x - MAX_W) / 2.0)
	frame.add_theme_constant_override("margin_left", int(side))
	frame.add_theme_constant_override("margin_right", int(side))


func _add_background() -> void:
	var bg := ColorRect.new()
	bg.color = bg_color
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	UI.full(bg)
	add_child(bg)
	var pat := TextureRect.new()
	pat.texture = UI.tex(UI.ART + "bg/pattern_kawung.svg")
	pat.stretch_mode = TextureRect.STRETCH_TILE
	pat.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	pat.mouse_filter = Control.MOUSE_FILTER_IGNORE
	UI.full(pat)
	add_child(pat)


## Bilah atas: tombol kembali + judul (+ kontrol kanan opsional).
func make_top_bar(title_text: String, right: Control = null, show_back: bool = true) -> HBoxContainer:
	var bar := UI.hbox(16)
	bar.custom_minimum_size = Vector2(0, 84)
	if show_back:
		var b := UI.round_button("ui_back", UI.WHITE, UI.INK, 76, "Kembali")
		b.pressed.connect(func(): Router.back())
		bar.add_child(b)
	var t := UI.title(title_text, 36, UI.INK)
	t.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	t.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	t.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	t.autowrap_mode = TextServer.AUTOWRAP_OFF
	t.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	bar.add_child(t)
	if right:
		right.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		bar.add_child(right)
	layout.add_child(bar)
	return bar


## Area gulir vertikal; mengembalikan VBox tempat konten ditaruh.
func make_scroll(sep: int = 18) -> VBoxContainer:
	var sc := ScrollContainer.new()
	sc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	sc.size_flags_vertical = Control.SIZE_EXPAND_FILL
	sc.follow_focus = true
	layout.add_child(sc)
	var m := UI.margin(4, 6, 4, 28)
	m.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sc.add_child(m)
	var box := UI.vbox(sep)
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	m.add_child(box)
	return box


func handle_back() -> bool:
	if _modal and is_instance_valid(_modal):
		close_modal()
		return true
	if back_to != "":
		Router.go(back_to)
		return true
	return false


# --- Modal ----------------------------------------------------------------------
func show_modal(content: Control, dismissable: bool = true, face: Color = UI.PAPER) -> Chunky:
	close_modal(true)
	var root := Control.new()
	UI.full(root)
	root.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.add_child(root)
	var dim := ColorRect.new()
	dim.color = Color(UI.INK, 0.62)
	UI.full(dim)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	root.add_child(dim)
	if dismissable:
		dim.gui_input.connect(func(e: InputEvent):
			if e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_LEFT:
				close_modal())
	var mc := UI.margin(SIDE, safe_top + 30, SIDE, safe_bottom + 30)
	UI.full(mc)
	root.add_child(mc)
	var cc := CenterContainer.new()
	cc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	mc.add_child(cc)
	var card := UI.chunky(face, 32, 9.0, 4)
	card.tappable = false
	card.mouse_filter = Control.MOUSE_FILTER_STOP
	card.set_pad(30, 28, 30, 28)
	card.custom_minimum_size = Vector2(minf(size.x - SIDE * 2, 640), 0)
	card.add_child(content)
	cc.add_child(card)
	# isi modal boleh punya tombol: aktifkan kembali input untuk turunan bertipe Chunky / LineEdit
	_restore_inputs(content)
	_modal = root
	root.modulate.a = 0.0
	var tw := root.create_tween()
	tw.tween_property(root, "modulate:a", 1.0, 0.16)
	UI.pop_in(card, 0.0, 0.8, 0.32)
	return card


func _restore_inputs(n: Node) -> void:
	for c in n.get_children():
		_restore_inputs(c)
	if n is Chunky:
		(n as Chunky).mouse_filter = Control.MOUSE_FILTER_PASS
	elif n is LineEdit or n is ScrollContainer:
		(n as Control).mouse_filter = Control.MOUSE_FILTER_STOP if n is LineEdit else Control.MOUSE_FILTER_PASS


func close_modal(instant: bool = false) -> void:
	if _modal == null or not is_instance_valid(_modal):
		_modal = null
		return
	var m := _modal
	_modal = null
	if instant:
		m.queue_free()
		return
	m.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var tw := m.create_tween()
	tw.tween_property(m, "modulate:a", 0.0, 0.14)
	tw.tween_callback(m.queue_free)


func has_modal() -> bool:
	return _modal != null and is_instance_valid(_modal)


## Dialog konfirmasi dua tombol.
func confirm(title_text: String, body: String, yes_text: String, on_yes: Callable,
		no_text: String = "Batal", yes_color: Color = UI.CORAL, char_id: String = "oyen", expr: String = "cemas") -> void:
	var box := UI.vbox(18)
	var top := UI.hbox(16)
	var cv := CharacterView.make(char_id, expr)
	cv.custom_minimum_size = Vector2(120, 156)
	top.add_child(cv)
	var tv := UI.vbox(6)
	tv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tv.add_child(UI.title(title_text, 32))
	tv.add_child(UI.label(body, 24, UI.INK_SOFT))
	top.add_child(tv)
	box.add_child(top)
	var row := UI.hbox(14)
	var no := UI.button(no_text, UI.WHITE, "", UI.INK, 26, 76)
	no.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	no.pressed.connect(func(): close_modal())
	var yes := UI.button(yes_text, yes_color, "", UI.WHITE, 26, 76)
	yes.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	yes.pressed.connect(func():
		close_modal()
		on_yes.call())
	row.add_child(no)
	row.add_child(yes)
	box.add_child(row)
	show_modal(box)


func ask_exit() -> void:
	if OS.get_name() == "iOS":
		return
	confirm("Sudah selesai?", "Progres belajarmu tersimpan otomatis. Sampai jumpa lagi!", "Keluar",
		func(): get_tree().quit(), "Lanjut main", UI.CORAL, "oyen", "sedih")


# --- Toast ----------------------------------------------------------------------
func toast(text: String, bg: Color = UI.INK, fg: Color = UI.WHITE, secs: float = 2.4) -> void:
	if _toast and is_instance_valid(_toast):
		_toast.queue_free()
	var p := UI.panel(bg, 26, 0, UI.INK, 18)
	var l := UI.label(text, 23, fg, UI.F_BOLD, HORIZONTAL_ALIGNMENT_CENTER)
	p.add_child(l)
	var wrap := UI.margin(SIDE + 10, 0, SIDE + 10, safe_bottom + 40)
	wrap.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	wrap.grow_vertical = Control.GROW_DIRECTION_BEGIN
	wrap.add_child(p)
	overlay.add_child(wrap)
	_toast = wrap
	UI.slide_in(p, 0.0, Vector2(0, 30), 0.3)
	var tw := wrap.create_tween()
	tw.tween_interval(secs)
	tw.tween_property(wrap, "modulate:a", 0.0, 0.3)
	tw.tween_callback(wrap.queue_free)
