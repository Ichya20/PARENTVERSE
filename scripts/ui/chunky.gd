class_name Chunky
extends Container
## Panel/tombol bergaya "timbul": muka berwarna, garis tepi gelap, dan bayangan padat di bawahnya.
## Aman dipakai di dalam ScrollContainer: geser jari tidak dianggap ketukan.

signal pressed

const TAP_SLOP := 18.0

var face: Color = Color.WHITE
var edge: Color = UI.INK
var shadow_color: Color = UI.INK
var radius: int = 26
var depth: float = 7.0
var border: int = 3
var pad := Vector4(18, 14, 18, 14) # kiri, atas, kanan, bawah
var tappable := true
## true: semua turunan dibuat tidak menerima input (isi tombol). false: untuk panel berisi kontrol interaktif.
var auto_ignore := true
var sound := "click"
var disabled := false: set = set_disabled

var _down := false
var _press_global := Vector2.ZERO
var _press := 0.0
var _tw: Tween
var _sb_face := StyleBoxFlat.new()
var _sb_shadow := StyleBoxFlat.new()


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_PASS
	focus_mode = Control.FOCUS_NONE
	child_entered_tree.connect(_on_child_entered)
	_refresh()


func setup(p_face: Color, p_radius: int = 26, p_depth: float = 7.0, p_border: int = 3) -> Chunky:
	face = p_face
	radius = p_radius
	depth = p_depth
	border = p_border
	_refresh()
	return self


func set_pad(l: float, t: float, r: float, b: float) -> Chunky:
	pad = Vector4(l, t, r, b)
	update_minimum_size()
	queue_sort()
	return self


func set_face(c: Color) -> void:
	face = c
	_refresh()


func set_disabled(v: bool) -> void:
	disabled = v
	modulate = Color(1, 1, 1, 0.55) if v else Color.WHITE
	_refresh()


func _refresh() -> void:
	_sb_face.bg_color = face
	_sb_face.set_corner_radius_all(radius)
	_sb_face.set_border_width_all(border)
	_sb_face.border_color = edge
	_sb_face.anti_aliasing = true
	_sb_face.corner_detail = 12
	_sb_shadow.bg_color = shadow_color
	_sb_shadow.set_corner_radius_all(radius)
	_sb_shadow.anti_aliasing = true
	_sb_shadow.corner_detail = 12
	queue_redraw()


func _on_child_entered(n: Node) -> void:
	if auto_ignore:
		UI.ignore_mouse(n)


func _get_minimum_size() -> Vector2:
	var m := Vector2.ZERO
	for c in get_children():
		var cc := c as Control
		if cc and cc.visible and not cc.top_level:
			m = m.max(cc.get_combined_minimum_size())
	return m + Vector2(pad.x + pad.z, pad.y + pad.w + depth)


func _notification(what: int) -> void:
	if what == NOTIFICATION_SORT_CHILDREN:
		var off := depth * _press * 0.8
		var r := Rect2(pad.x, pad.y + off, maxf(0, size.x - pad.x - pad.z), maxf(0, size.y - depth - pad.y - pad.w))
		for c in get_children():
			var cc := c as Control
			if cc and not cc.top_level:
				fit_child_in_rect(cc, r)
	elif what == NOTIFICATION_MOUSE_EXIT and _down and not OS.has_feature("mobile"):
		_cancel()


func _draw() -> void:
	var h := size.y - depth
	if h <= 0:
		return
	if depth > 0.0:
		draw_style_box(_sb_shadow, Rect2(0, depth, size.x, h))
	draw_style_box(_sb_face, Rect2(0, depth * _press * 0.8, size.x, h))


func _gui_input(event: InputEvent) -> void:
	if not tappable or disabled:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		var mb := event as InputEventMouseButton
		if mb.pressed:
			_down = true
			_press_global = mb.global_position
			_animate(1.0)
		elif _down:
			_down = false
			_animate(0.0)
			if Rect2(Vector2.ZERO, size).has_point(mb.position) \
					and mb.global_position.distance_to(_press_global) <= TAP_SLOP:
				accept_event()
				_fire()
	elif event is InputEventMouseMotion and _down:
		if (event as InputEventMouseMotion).global_position.distance_to(_press_global) > TAP_SLOP:
			_cancel()


func _cancel() -> void:
	_down = false
	_animate(0.0)


## Memicu tombol dari kode (dipakai juga untuk pengujian otomatis).
func activate() -> void:
	if not disabled:
		_fire()


func _fire() -> void:
	if sound != "":
		Sfx.play(sound)
	pressed.emit()


func _animate(target: float) -> void:
	if _tw and _tw.is_valid():
		_tw.kill()
	_tw = create_tween()
	_tw.tween_method(_set_press, _press, target, 0.06 if target > 0.0 else 0.14)


func _set_press(v: float) -> void:
	_press = v
	queue_sort()
	queue_redraw()
