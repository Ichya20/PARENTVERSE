class_name Breather
extends Control
## Latihan napas tenang: lingkaran membesar (tarik napas), tahan, lalu mengecil (hembuskan).

signal finished

const PHASES := [["Tarik napas…", 4.0, 0.0, 1.0], ["Tahan…", 2.0, 1.0, 1.0], ["Hembuskan…", 4.0, 1.0, 0.0]]

var running := false
var _k := 0.0
var _label: Label
var _count: Label
var _cycle := 0
var cycles := 3


func _init() -> void:
	custom_minimum_size = Vector2(0, 330)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var v := UI.vbox(0)
	v.alignment = BoxContainer.ALIGNMENT_CENTER
	UI.full(v)
	add_child(v)
	_label = UI.label("Siap?", 32, UI.INK, UI.F_TITLE, HORIZONTAL_ALIGNMENT_CENTER, false)
	v.add_child(_label)
	_count = UI.label("3 putaran", 22, UI.INK_SOFT, UI.F_BOLD, HORIZONTAL_ALIGNMENT_CENTER, false)
	v.add_child(_count)


func start() -> void:
	if running:
		return
	running = true
	_cycle = 0
	_run_cycle()


func _run_cycle() -> void:
	if not is_inside_tree():
		return
	if _cycle >= cycles:
		running = false
		_label.text = "Hebat!"
		_count.text = "Rasanya lebih tenang, kan?"
		Sfx.play("star")
		finished.emit()
		return
	_count.text = "Putaran %d dari %d" % [_cycle + 1, cycles]
	var tw := create_tween()
	for ph in PHASES:
		tw.tween_callback(func():
			_label.text = ph[0]
			Sfx.play("tick", 0.8, -10.0))
		tw.tween_method(_set_k, ph[2], ph[3], ph[1]) \
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_callback(func():
		_cycle += 1
		_run_cycle())


func _set_k(v: float) -> void:
	_k = v
	queue_redraw()


func _draw() -> void:
	var c := size / 2
	var base := minf(size.x, size.y) * 0.24
	var r := base + base * 0.85 * _k
	draw_circle(c, r + 26, Color(UI.TEAL, 0.12), true, -1.0, true)
	draw_circle(c, r + 12, Color(UI.TEAL, 0.22), true, -1.0, true)
	draw_circle(c, r, UI.TEAL_L, true, -1.0, true)
	draw_circle(c, r, UI.INK, false, 4.0, true)
