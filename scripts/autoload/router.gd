extends Node
## Navigasi antar layar, transisi, dan tombol kembali (Android / Esc).

const SCREENS := {
	"splash": "res://scripts/screens/splash.gd",
	"home": "res://scripts/screens/home.gd",
	"materi_list": "res://scripts/screens/materi_list.gd",
	"materi": "res://scripts/screens/materi_view.gd",
	"cerita_list": "res://scripts/screens/cerita_list.gd",
	"cerita": "res://scripts/screens/cerita_play.gd",
	"game_menu": "res://scripts/screens/game_menu.gd",
	"game_kata": "res://scripts/screens/game_kata.gd",
	"game_emosi": "res://scripts/screens/game_emosi.gd",
	"game_memori": "res://scripts/screens/game_memori.gd",
	"kesepakatan": "res://scripts/screens/kesepakatan.gd",
	"evaluasi": "res://scripts/screens/evaluasi.gd",
	"kuis": "res://scripts/screens/kuis.gd",
	"info": "res://scripts/screens/info.gd",
}

signal screen_changed(name: String)

var host: Control
var current: Screen
var current_name := ""
var busy := false
var _layer: CanvasLayer
var _veil: ColorRect
var _last_back_ms := -1000


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().root.theme = UI.build_theme()
	_layer = CanvasLayer.new()
	_layer.layer = 100
	add_child(_layer)
	_veil = ColorRect.new()
	_veil.color = UI.CREAM
	_veil.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_veil.mouse_filter = Control.MOUSE_FILTER_STOP
	_veil.visible = false
	_layer.add_child(_veil)


func attach(h: Control) -> void:
	host = h
	go(OS.get_environment("PV_START") if SCREENS.has(OS.get_environment("PV_START")) else "splash", {}, true)


func go(screen: String, params: Dictionary = {}, instant: bool = false) -> void:
	if busy or host == null:
		return
	if not SCREENS.has(screen):
		push_error("Layar tidak dikenal: " + screen)
		return
	busy = true
	Sfx.stop_speaking()
	if not instant and current:
		Sfx.play("whoosh", 1.0, -8.0)
		_veil.visible = true
		_veil.modulate.a = 0.0
		var tw := create_tween()
		tw.tween_property(_veil, "modulate:a", 1.0, 0.15)
		await tw.finished
	if current and is_instance_valid(current):
		current.queue_free()
	var script: GDScript = load(SCREENS[screen])
	var scr: Screen = script.new()
	scr.params = params
	scr.name = screen.capitalize().replace(" ", "")
	host.add_child(scr)
	current = scr
	current_name = screen
	screen_changed.emit(screen)
	if not instant:
		var tw2 := create_tween()
		tw2.tween_property(_veil, "modulate:a", 0.0, 0.22)
		await tw2.finished
		_veil.visible = false
	busy = false


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		back()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		get_viewport().set_input_as_handled()
		back()


func back() -> void:
	var now := Time.get_ticks_msec()
	if now - _last_back_ms < 300 or busy or current == null:
		return
	_last_back_ms = now
	if not current.handle_back():
		current.ask_exit()
