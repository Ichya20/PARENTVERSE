class_name MeterBar
extends Control
## Bilah kemajuan membulat dengan garis tepi tinta.

var ratio := 0.0: set = set_ratio
var fill: Color = UI.TEAL
var track: Color = UI.LINE
var border := 3


static func make(p_ratio: float, p_fill: Color, height: float = 16) -> MeterBar:
	var m := MeterBar.new()
	m.ratio = p_ratio
	m.fill = p_fill
	m.custom_minimum_size = Vector2(0, height)
	m.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return m


func set_ratio(v: float) -> void:
	ratio = clampf(v, 0.0, 1.0)
	queue_redraw()


func animate_to(v: float, dur: float = 0.6) -> void:
	var tw := create_tween()
	tw.tween_property(self, "ratio", clampf(v, 0.0, 1.0), dur).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


func _draw() -> void:
	var r := int(size.y / 2)
	draw_style_box(UI.sb(track, r, border, UI.INK), Rect2(Vector2.ZERO, size))
	if ratio > 0.001:
		var w := maxf(size.y, size.x * ratio)
		draw_style_box(UI.sb(fill, r, border, UI.INK), Rect2(Vector2.ZERO, Vector2(w, size.y)))
