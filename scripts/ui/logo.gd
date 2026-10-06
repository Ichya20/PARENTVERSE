class_name Logo
extends HBoxContainer
## Logo teks PARENTVERSE berwarna-warni dengan huruf yang bisa dianimasikan.

const COLORS := [Color("f2694b"), Color("ffc23c"), Color("1fa39a"), Color("4aa8f0"), Color("e8558c")]

var letters: Array[Label] = []


static func make(size: float = 64, animate: bool = false) -> Logo:
	var l := Logo.new()
	l.add_theme_constant_override("separation", int(-size * 0.04))
	l.alignment = BoxContainer.ALIGNMENT_CENTER
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var word := "PARENTVERSE"
	for i in word.length():
		var c := UI.label(word[i], size, COLORS[i % COLORS.size()], UI.F_TITLE, HORIZONTAL_ALIGNMENT_CENTER, false)
		UI.outline(c, UI.INK, int(size * 0.16))
		UI.shadow(c, UI.INK, Vector2(0, size * 0.09))
		c.add_theme_constant_override("shadow_outline_size", int(size * 0.16))
		l.add_child(c)
		l.letters.append(c)
	if animate:
		l.play_intro()
	return l


func play_intro(delay: float = 0.0) -> void:
	for i in letters.size():
		var c := letters[i]
		c.offset_transform_enabled = true
		c.offset_transform_position = Vector2(0, -70)
		c.modulate.a = 0.0
		var tw := c.create_tween().set_parallel(true)
		var d := delay + i * 0.06
		tw.tween_property(c, "offset_transform_position", Vector2.ZERO, 0.5).set_delay(d) \
			.set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
		tw.tween_property(c, "modulate:a", 1.0, 0.2).set_delay(d)


## Gelombang kecil berulang pada huruf.
func wave_loop() -> void:
	for i in letters.size():
		var c := letters[i]
		c.offset_transform_enabled = true
		var tw := c.create_tween().set_loops()
		tw.tween_interval(i * 0.08)
		tw.tween_property(c, "offset_transform_position", Vector2(0, -7), 0.25).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tw.tween_property(c, "offset_transform_position", Vector2.ZERO, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		tw.tween_interval(3.2 - i * 0.08)
