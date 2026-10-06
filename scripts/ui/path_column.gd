class_name PathColumn
extends VBoxContainer
## Kolom yang menggambar jalur titik-titik berkelok di belakang simpul-simpulnya (peta materi).

var nodes: Array[Control] = []
var dot_color := Color(UI.INK, 0.28)


func _ready() -> void:
	sort_children.connect(queue_redraw)
	resized.connect(queue_redraw)


func _process(_d: float) -> void:
	# simpul bisa bergerak saat animasi masuk; gambar ulang sesekali
	if Engine.get_process_frames() % 4 == 0:
		queue_redraw()


func _center(c: Control) -> Vector2:
	return c.get_global_rect().get_center() - global_position


func _draw() -> void:
	if nodes.size() < 2:
		return
	for i in nodes.size() - 1:
		var a := _center(nodes[i])
		var b := _center(nodes[i + 1])
		var dy := (b.y - a.y) * 0.55
		var c1 := a + Vector2(0, dy)
		var c2 := b - Vector2(0, dy)
		var steps := 60
		var last := a
		var acc := 0.0
		for s in range(1, steps + 1):
			var t := float(s) / steps
			var p := a.bezier_interpolate(c1, c2, b, t)
			acc += p.distance_to(last)
			last = p
			if acc >= 22.0:
				acc = 0.0
				draw_circle(p, 6.0, dot_color, true, -1.0, true)
