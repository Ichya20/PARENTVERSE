class_name CharacterView
extends Control
## Karakter berlapis (badan + mata + mulut + aksesori) dengan ekspresi, kedip, bicara, dan gerak idle.

const DIR := "res://assets/art/characters/"
const HUMAN_EYES := ["netral", "senang", "sedih", "marah", "cemas", "kaget", "malu", "kedip"]
const HUMAN_MOUTHS := ["netral", "senang", "sedih", "marah", "cemas", "kaget", "malu", "bicara"]
const CAT_MAP := {"marah": "sedih", "cemas": "kaget", "malu": "senang"}
const NAMES := {"bunda": "Bunda", "ayah": "Ayah", "raka": "Raka", "nara": "Nara", "oyen": "Oyen"}

var char_id := "bunda"
var expression := "netral"
var flip := false
var idle := true

var _rig: Control
var _body: TextureRect
var _eyes: TextureRect
var _mouth: TextureRect
var _overlay: TextureRect
var _talking := false
var _talk_open := false
var _talk_t := 0.0
var _blink_t := 3.0
var _blinking := 0.0
var _idle_tw: Tween


static func make(id: String, expr: String = "netral", p_flip: bool = false) -> CharacterView:
	var cv := CharacterView.new()
	cv.char_id = id
	cv.expression = expr
	cv.flip = p_flip
	return cv


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_rig = Control.new()
	_rig.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_rig)
	_body = _layer()
	_mouth = _layer()
	_eyes = _layer()
	_overlay = _layer()


func _layer() -> TextureRect:
	var t := TextureRect.new()
	t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	t.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_rig.add_child(t)
	return t


func _ready() -> void:
	resized.connect(_layout)
	_body.texture = UI.tex(DIR + char_id + "_body.svg")
	_overlay.texture = UI.tex(DIR + "ayah_overlay.svg") if char_id == "ayah" else null
	for t in [_body, _eyes, _mouth, _overlay]:
		t.flip_h = flip
	_apply_face()
	_layout()
	_blink_t = randf_range(1.5, 4.0)
	if idle:
		start_idle()


func _layout() -> void:
	_rig.size = size
	_rig.pivot_offset = Vector2(size.x / 2, size.y)
	for t in [_body, _eyes, _mouth, _overlay]:
		t.position = Vector2.ZERO
		t.size = size


func start_idle() -> void:
	if _idle_tw and _idle_tw.is_valid():
		_idle_tw.kill()
	_idle_tw = create_tween().set_loops()
	var p := randf_range(2.2, 3.0)
	_idle_tw.tween_property(_rig, "scale", Vector2(1.0, 1.025), p / 2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_idle_tw.tween_property(_rig, "scale", Vector2(1.0, 1.0), p / 2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func set_expression(expr: String, react: bool = true) -> void:
	if expr == "":
		return
	var changed := expr != expression
	expression = expr
	_apply_face()
	if react and changed:
		offset_transform_enabled = true
		offset_transform_pivot_ratio = Vector2(0.5, 1.0)
		var tw := create_tween()
		var sq := Vector2(1.06, 0.94) if expr in ["senang", "kaget"] else Vector2(0.97, 1.03)
		tw.tween_property(self, "offset_transform_scale", sq, 0.08)
		tw.tween_property(self, "offset_transform_scale", Vector2.ONE, 0.32).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		if expr == "senang":
			hop()


func hop(height: float = 18.0) -> void:
	var tw := create_tween()
	tw.tween_property(_rig, "position:y", -height, 0.14).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(_rig, "position:y", 0.0, 0.22).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)


func set_talking(on: bool) -> void:
	_talking = on
	_talk_t = 0.0
	if not on:
		_talk_open = false
		_apply_face()


func _eyes_key(expr: String) -> String:
	if char_id == "oyen":
		var e: String = CAT_MAP.get(expr, expr)
		return "cat_eyes_" + (e if e in ["netral", "senang", "sedih", "kaget", "kedip"] else "netral")
	return "eyes_" + (expr if expr in HUMAN_EYES else "netral")


func _mouth_key(expr: String) -> String:
	if char_id == "oyen":
		var m: String = CAT_MAP.get(expr, expr)
		return "cat_mouth_" + (m if m in ["netral", "senang", "sedih", "kaget", "bicara"] else "netral")
	return "mouth_" + (expr if expr in HUMAN_MOUTHS else "netral")


func _apply_face() -> void:
	if _eyes == null:
		return
	var e := "kedip" if _blinking > 0.0 else expression
	_eyes.texture = UI.tex(DIR + _eyes_key(e) + ".svg")
	var m := "bicara" if (_talking and _talk_open) else expression
	_mouth.texture = UI.tex(DIR + _mouth_key(m) + ".svg")


func _process(delta: float) -> void:
	# kedip mata acak
	if _blinking > 0.0:
		_blinking -= delta
		if _blinking <= 0.0:
			_apply_face()
	else:
		_blink_t -= delta
		if _blink_t <= 0.0 and expression in ["netral", "senang", "sedih", "cemas", "malu", "marah"]:
			if expression != "senang":
				_blinking = 0.12
				_apply_face()
			_blink_t = randf_range(2.2, 5.0)
	# mulut bergerak saat berbicara
	if _talking:
		_talk_t -= delta
		if _talk_t <= 0.0:
			_talk_open = not _talk_open
			_talk_t = randf_range(0.08, 0.15)
			_apply_face()
