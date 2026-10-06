class_name Switch
extends Control
## Sakelar aktif/mati (tampilan saja; diketuk lewat baris induknya).

var on := false
var _k := 0.0


static func make(p_on: bool) -> Switch:
	var s := Switch.new()
	s.on = p_on
	s._k = 1.0 if p_on else 0.0
	s.custom_minimum_size = Vector2(84, 46)
	s.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	s.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return s


func set_on(v: bool) -> void:
	on = v
	var tw := create_tween()
	tw.tween_method(func(x: float):
		_k = x
		queue_redraw(), _k, 1.0 if v else 0.0, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _draw() -> void:
	var col := UI.LINE.lerp(UI.TEAL, clampf(_k, 0, 1))
	draw_style_box(UI.sb(col, int(size.y / 2), 3, UI.INK), Rect2(Vector2.ZERO, size))
	var d := size.y - 12
	var x := lerpf(6, size.x - 6 - d, _k)
	draw_style_box(UI.sb(UI.WHITE, int(d / 2), 3, UI.INK), Rect2(x, 6, d, d))
