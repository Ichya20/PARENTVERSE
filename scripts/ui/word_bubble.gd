class_name WordBubble
extends Control
## Gelembung kalimat untuk permainan Tangkap Kata Baik.

signal tapped(bubble: WordBubble)

var good := true
var phrase := ""
var fill: Color = UI.WHITE
var base_x := 0.0
var phase := 0.0
var sway := 26.0
var speed := 100.0
var t := 0.0
var done := false
var bad_info: Dictionary = {}


func setup(p_text: String, p_good: bool, p_fill: Color, w: float) -> WordBubble:
	phrase = p_text
	good = p_good
	fill = p_fill
	size = Vector2(w, 104)
	custom_minimum_size = size
	mouse_filter = Control.MOUSE_FILTER_STOP
	var m := UI.margin(18, 8, 18, 18)
	UI.full(m)
	add_child(m)
	var l := UI.label(p_text, 22, UI.INK, UI.F_BLACK, HORIZONTAL_ALIGNMENT_CENTER)
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.size_flags_vertical = Control.SIZE_EXPAND_FILL
	m.add_child(l)
	accessibility_name = p_text
	return self


func _draw() -> void:
	var h := size.y - 12
	draw_style_box(UI.sb(fill, int(h / 2), 3, UI.INK), Rect2(0, 0, size.x, h))
	var a := Vector2(34, h - 2)
	var b := Vector2(62, h - 2)
	var tip := Vector2(30, size.y)
	draw_colored_polygon(PackedVector2Array([a, tip, b]), fill)
	draw_line(a, tip, UI.INK, 3.0, true)
	draw_line(tip, b, UI.INK, 3.0, true)
	draw_line(a + Vector2(2, -1.5), b + Vector2(-2, -1.5), fill, 4.0)
	draw_set_transform(Vector2(30, 18), -0.3, Vector2(1.0, 0.45))
	draw_circle(Vector2.ZERO, 14, Color(1, 1, 1, 0.75), true, -1.0, true)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _gui_input(event: InputEvent) -> void:
	if done:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		accept_event()
		tapped.emit(self)
