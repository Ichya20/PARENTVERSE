class_name Confetti
extends Control
## Hujan konfeti sederhana (digambar sendiri, ringan untuk ponsel).

const COLORS := [Color("f2694b"), Color("ffc23c"), Color("1fa39a"), Color("4aa8f0"), Color("e8558c"), Color("4cb85a")]

var _parts: Array = []
var _life := 3.2


static func burst(parent: Control, count: int = 70) -> Confetti:
	var c := Confetti.new()
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(c)
	UI.full(c)
	c._spawn(count)
	return c


func _spawn(count: int) -> void:
	var w := get_viewport_rect().size.x
	for i in count:
		_parts.append({
			"p": Vector2(randf_range(0, w), randf_range(-260, -10)),
			"v": Vector2(randf_range(-80, 80), randf_range(160, 420)),
			"r": randf_range(0, TAU),
			"w": randf_range(-7, 7),
			"s": Vector2(randf_range(10, 18), randf_range(6, 11)),
			"c": COLORS[i % COLORS.size()],
		})


func _process(delta: float) -> void:
	_life -= delta
	if _life <= 0:
		queue_free()
		return
	for p in _parts:
		p["v"].y += 260 * delta
		p["v"].x += sin(_life * 3 + p["r"]) * 20 * delta
		p["p"] += p["v"] * delta
		p["r"] += p["w"] * delta
	modulate.a = clampf(_life / 0.6, 0, 1)
	queue_redraw()


func _draw() -> void:
	for p in _parts:
		draw_set_transform(p["p"], p["r"], Vector2.ONE)
		var s: Vector2 = p["s"]
		draw_rect(Rect2(-s / 2, s), p["c"])
	draw_set_transform(Vector2.ZERO, 0, Vector2.ONE)
