class_name Bubble
extends PanelContainer
## Balon percakapan dengan ekor (kiri / kanan / bawah / atas).

var color: Color = UI.WHITE
var tail_side := "left"
var tail_at := 0.5
var tail_size := 22.0


static func make(p_color: Color = UI.WHITE, side: String = "left", at: float = 0.5, pad: float = 18) -> Bubble:
	var b := Bubble.new()
	b.color = p_color
	b.tail_side = side
	b.tail_at = at
	var s := UI.sb(p_color, 24, 3, UI.INK, pad)
	b.add_theme_stylebox_override("panel", s)
	b.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return b


func _draw() -> void:
	var t := tail_size
	var a: Vector2
	var b: Vector2
	var tip: Vector2
	match tail_side:
		"left":
			var y := clampf(size.y * tail_at, 30, size.y - 30)
			a = Vector2(1.5, y - t * 0.6)
			b = Vector2(1.5, y + t * 0.6)
			tip = Vector2(-t, y + t * 0.2)
		"right":
			var y2 := clampf(size.y * tail_at, 30, size.y - 30)
			a = Vector2(size.x - 1.5, y2 - t * 0.6)
			b = Vector2(size.x - 1.5, y2 + t * 0.6)
			tip = Vector2(size.x + t, y2 + t * 0.2)
		"top":
			var x0 := clampf(size.x * tail_at, 30, size.x - 30)
			a = Vector2(x0 - t * 0.6, 1.5)
			b = Vector2(x0 + t * 0.6, 1.5)
			tip = Vector2(x0 - t * 0.2, -t)
		_:
			var x := clampf(size.x * tail_at, 30, size.x - 30)
			a = Vector2(x - t * 0.6, size.y - 1.5)
			b = Vector2(x + t * 0.6, size.y - 1.5)
			tip = Vector2(x - t * 0.2, size.y + t)
	draw_colored_polygon(PackedVector2Array([a, tip, b]), color)
	draw_line(a, tip, UI.INK, 3.0, true)
	draw_line(tip, b, UI.INK, 3.0, true)
	# tutup garis tepi di pangkal ekor
	var inset := (b - a).normalized() * 2.0
	var n := Vector2.ZERO
	match tail_side:
		"left":
			n = Vector2(1.5, 0)
		"right":
			n = Vector2(-1.5, 0)
		"top":
			n = Vector2(0, 1.5)
		_:
			n = Vector2(0, -1.5)
	draw_line(a + inset + n, b - inset + n, color, 4.0)
