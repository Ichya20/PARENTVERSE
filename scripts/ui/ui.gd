class_name UI
extends RefCounted
## Token desain (warna, huruf, ukuran) dan fungsi pembuat elemen antarmuka PARENTVERSE.

# --- Palet warna -------------------------------------------------------------
const INK := Color("2d2440")
const INK_SOFT := Color("5e5672")
const CREAM := Color("fff4e2")
const PAPER := Color("fffbf4")
const LINE := Color("eadfcd")
const CORAL := Color("f2694b")
const CORAL_D := Color("c94a2f")
const CORAL_L := Color("ffe1d8")
const SUN := Color("ffc23c")
const SUN_D := Color("d99a12")
const SUN_L := Color("fff0c7")
const TEAL := Color("1fa39a")
const TEAL_D := Color("13786f")
const TEAL_L := Color("d4f3ef")
const SKY := Color("4aa8f0")
const SKY_D := Color("2a7fc4")
const SKY_L := Color("dceeff")
const BERRY := Color("e8558c")
const BERRY_L := Color("ffe0ec")
const LEAF := Color("4cb85a")
const GOOD := Color("2fb36d")
const GOOD_L := Color("dcf5e6")
const BAD := Color("e5484d")
const BAD_L := Color("ffe2e2")
const WHITE := Color(1, 1, 1)

# --- Huruf ------------------------------------------------------------------
const F_TITLE := preload("res://assets/fonts/Fredoka-Bold.ttf")
const F_HEAD := preload("res://assets/fonts/Fredoka-SemiBold.ttf")
const F_BODY := preload("res://assets/fonts/Nunito-SemiBold.ttf")
const F_BOLD := preload("res://assets/fonts/Nunito-ExtraBold.ttf")
const F_BLACK := preload("res://assets/fonts/Nunito-Black.ttf")

const ICON := "res://assets/art/icons/"
const ART := "res://assets/art/"

static var text_scale := 1.0
static var _tex_cache := {}


static func fs(size: float) -> int:
	return int(round(size * text_scale))


static func tex(path: String) -> Texture2D:
	if not _tex_cache.has(path):
		_tex_cache[path] = load(path) if ResourceLoader.exists(path) else null
	return _tex_cache[path]


# --- Teks ---------------------------------------------------------------------
static func label(text: String, size: float = 26, color: Color = INK, font: Font = F_BODY,
		align: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT, wrap: bool = true) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_override("font", font)
	l.add_theme_font_size_override("font_size", fs(size))
	l.add_theme_color_override("font_color", color)
	l.horizontal_alignment = align
	if wrap:
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		# label yang bisa terlipat harus mendapat lebar; tanpa ini, di dalam HBox teks tersusun per huruf
		l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l


static func title(text: String, size: float = 40, color: Color = INK,
		align: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	return label(text, size, color, F_TITLE, align)


static func outline(l: Label, color: Color = INK, size: int = 8) -> Label:
	l.add_theme_color_override("font_outline_color", color)
	l.add_theme_constant_override("outline_size", size)
	return l


static func shadow(l: Label, color: Color = INK, offset: Vector2 = Vector2(0, 4)) -> Label:
	l.add_theme_color_override("font_shadow_color", color)
	l.add_theme_constant_override("shadow_offset_x", int(offset.x))
	l.add_theme_constant_override("shadow_offset_y", int(offset.y))
	l.add_theme_constant_override("shadow_outline_size", 8)
	return l


static func rich(bbcode: String, size: float = 26, color: Color = INK) -> RichTextLabel:
	var r := RichTextLabel.new()
	r.bbcode_enabled = true
	r.fit_content = true
	r.scroll_active = false
	r.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	r.add_theme_font_override("normal_font", F_BODY)
	r.add_theme_font_override("bold_font", F_BLACK)
	r.add_theme_font_override("italics_font", F_BOLD)
	r.add_theme_font_size_override("normal_font_size", fs(size))
	r.add_theme_font_size_override("bold_font_size", fs(size))
	r.add_theme_font_size_override("italics_font_size", fs(size))
	r.add_theme_color_override("default_color", color)
	r.add_theme_constant_override("line_separation", 4)
	r.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	r.text = bbcode
	return r


## Mengubah **teks** menjadi [b]teks[/b] agar data konten mudah ditulis.
static func md(text: String) -> String:
	var out := ""
	var parts := text.split("**")
	for i in parts.size():
		out += ("[b]%s[/b]" % parts[i]) if i % 2 == 1 else parts[i]
	return out


static func plain(text: String) -> String:
	return text.replace("**", "")


# --- Gambar & ikon -------------------------------------------------------------
static func icon(path: String, size: float, modulate: Color = Color.WHITE) -> TextureRect:
	var t := TextureRect.new()
	t.texture = tex(path if path.begins_with("res://") else ICON + path + ".svg")
	t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	t.custom_minimum_size = Vector2(size, size)
	t.modulate = modulate
	t.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return t


static func picture(path: String, cover: bool = true) -> TextureRect:
	var t := TextureRect.new()
	t.texture = tex(path)
	t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED if cover else TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	t.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return t


# --- Kotak & tata letak ---------------------------------------------------------
static func sb(bg: Color, radius: int = 24, border: int = 0, border_color: Color = INK, pad: float = 0) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.set_corner_radius_all(radius)
	s.set_border_width_all(border)
	s.border_color = border_color
	s.set_content_margin_all(pad)
	s.anti_aliasing = true
	s.corner_detail = 12
	return s


static func panel(bg: Color, radius: int = 24, border: int = 0, border_color: Color = INK, pad: float = 20) -> PanelContainer:
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", sb(bg, radius, border, border_color, pad))
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return p


static func vbox(sep: int = 16) -> VBoxContainer:
	var b := VBoxContainer.new()
	b.add_theme_constant_override("separation", sep)
	b.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return b


static func hbox(sep: int = 16) -> HBoxContainer:
	var b := HBoxContainer.new()
	b.add_theme_constant_override("separation", sep)
	b.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return b


static func margin(l: float, t: float, r: float, b: float) -> MarginContainer:
	var m := MarginContainer.new()
	m.add_theme_constant_override("margin_left", int(l))
	m.add_theme_constant_override("margin_top", int(t))
	m.add_theme_constant_override("margin_right", int(r))
	m.add_theme_constant_override("margin_bottom", int(b))
	m.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return m


static func spacer(h: float = 0, w: float = 0) -> Control:
	var c := Control.new()
	c.custom_minimum_size = Vector2(w, h)
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return c


static func expander() -> Control:
	var c := spacer()
	c.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return c


static func full(c: Control) -> Control:
	c.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	return c


static func ignore_mouse(n: Node) -> void:
	if n is Control:
		(n as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE
	for c in n.get_children():
		ignore_mouse(c)


# --- Tombol -------------------------------------------------------------------
static func chunky(face: Color, radius: int = 26, depth: float = 7.0, border: int = 3) -> Chunky:
	return Chunky.new().setup(face, radius, depth, border)


## Panel timbul (tidak bisa diketuk) yang boleh berisi tombol/gulir.
static func frame(face: Color = PAPER, radius: int = 28, depth: float = 8.0, border: int = 4) -> Chunky:
	var c := Chunky.new()
	c.auto_ignore = false
	c.tappable = false
	c.setup(face, radius, depth, border)
	return c


## Tombol besar berteks (dengan ikon opsional).
static func button(text: String, face: Color = CORAL, icon_name: String = "", text_color: Color = WHITE,
		size: float = 28, min_h: float = 84) -> Chunky:
	var c := chunky(face, 26, 7.0)
	c.custom_minimum_size = Vector2(0, min_h)
	c.set_pad(22, 10, 22, 10)
	var row := hbox(12)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	if icon_name != "":
		row.add_child(icon(icon_name, size * 1.15, text_color))
	var l := label(text, size, text_color, F_TITLE, HORIZONTAL_ALIGNMENT_CENTER, false)
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(l)
	c.add_child(row)
	c.set_meta("label", l)
	c.accessibility_name = text
	return c


## Tombol bulat berisi ikon glyph (ui_*).
static func round_button(icon_name: String, face: Color = WHITE, icon_color: Color = INK, d: float = 78,
		access_name: String = "") -> Chunky:
	var c := chunky(face, int(d / 2), 6.0)
	c.custom_minimum_size = Vector2(d, d)
	c.set_pad(0, 0, 0, 0)
	var cc := CenterContainer.new()
	cc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cc.add_child(icon(icon_name, d * 0.46, icon_color))
	c.add_child(cc)
	c.accessibility_name = access_name
	return c


static func pill(text: String, bg: Color, fg: Color = INK, size: float = 20, icon_name: String = "") -> PanelContainer:
	var p := PanelContainer.new()
	var s := sb(bg, 40, 0, INK, 0)
	s.content_margin_left = 16
	s.content_margin_right = 16
	s.content_margin_top = 5
	s.content_margin_bottom = 6
	p.add_theme_stylebox_override("panel", s)
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var row := hbox(8)
	if icon_name != "":
		row.add_child(icon(icon_name, size * 1.2))
	var l := label(text, size, fg, F_BOLD, HORIZONTAL_ALIGNMENT_CENTER, false)
	row.add_child(l)
	p.add_child(row)
	p.set_meta("label", l)
	return p


## Deretan bintang 0..max.
static func stars(n: int, max_n: int = 3, size: float = 36, sep: int = 4) -> HBoxContainer:
	var row := hbox(sep)
	for i in max_n:
		row.add_child(icon("c_star_full" if i < n else "c_star_empty", size))
	return row


static func avatar(initials: String, bg: Color, d: float = 84) -> PanelContainer:
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", sb(bg, int(d / 2), 3, INK, 0))
	p.custom_minimum_size = Vector2(d, d)
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var l := label(initials, d * 0.36, WHITE, F_TITLE, HORIZONTAL_ALIGNMENT_CENTER, false)
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	outline(l, INK, 6)
	p.add_child(l)
	return p


# --- Animasi ------------------------------------------------------------------
static func _ot(c: Control) -> void:
	c.offset_transform_enabled = true


static func pop_in(c: Control, delay: float = 0.0, from: float = 0.6, dur: float = 0.42) -> void:
	_ot(c)
	c.offset_transform_scale = Vector2(from, from)
	c.modulate.a = 0.0
	var tw := c.create_tween().set_parallel(true)
	tw.tween_property(c, "offset_transform_scale", Vector2.ONE, dur).set_delay(delay) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(c, "modulate:a", 1.0, dur * 0.6).set_delay(delay)


static func slide_in(c: Control, delay: float = 0.0, from: Vector2 = Vector2(0, 46), dur: float = 0.45) -> void:
	_ot(c)
	c.offset_transform_position = from
	c.modulate.a = 0.0
	var tw := c.create_tween().set_parallel(true)
	tw.tween_property(c, "offset_transform_position", Vector2.ZERO, dur).set_delay(delay) \
		.set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	tw.tween_property(c, "modulate:a", 1.0, dur * 0.7).set_delay(delay)


static func bounce(c: Control, amount: float = 1.12) -> void:
	_ot(c)
	var tw := c.create_tween()
	tw.tween_property(c, "offset_transform_scale", Vector2(amount, amount), 0.09)
	tw.tween_property(c, "offset_transform_scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


static func shake(c: Control, strength: float = 14.0) -> void:
	_ot(c)
	var tw := c.create_tween()
	for i in 5:
		var s := strength * (1.0 - i / 5.0) * (1 if i % 2 == 0 else -1)
		tw.tween_property(c, "offset_transform_position", Vector2(s, 0), 0.045)
	tw.tween_property(c, "offset_transform_position", Vector2.ZERO, 0.05)


static func float_loop(c: Control, amp: float = 8.0, period: float = 2.6, delay: float = 0.0) -> void:
	_ot(c)
	var tw := c.create_tween().set_loops()
	if delay > 0:
		tw.tween_interval(delay)
	tw.tween_property(c, "offset_transform_position", Vector2(0, -amp), period / 2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(c, "offset_transform_position", Vector2(0, 0), period / 2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


static func pulse_loop(c: Control, amount: float = 1.06, period: float = 1.4) -> void:
	_ot(c)
	var tw := c.create_tween().set_loops()
	tw.tween_property(c, "offset_transform_scale", Vector2(amount, amount), period / 2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(c, "offset_transform_scale", Vector2.ONE, period / 2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


## Teks melayang (mis. "+10") di dalam parent pada posisi lokal.
static func float_text(parent: Control, text: String, pos: Vector2, color: Color = GOOD, size: float = 34) -> void:
	var l := label(text, size, color, F_TITLE, HORIZONTAL_ALIGNMENT_CENTER, false)
	outline(l, WHITE, 8)
	parent.add_child(l)
	l.position = pos - Vector2(60, 24)
	l.size = Vector2(120, 48)
	var tw := l.create_tween().set_parallel(true)
	tw.tween_property(l, "position:y", l.position.y - 90, 0.8).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(l, "modulate:a", 0.0, 0.8).set_delay(0.25)
	tw.chain().tween_callback(l.queue_free)


# --- Tema dasar ---------------------------------------------------------------
static func build_theme() -> Theme:
	var th := Theme.new()
	th.default_font = F_BODY
	th.default_font_size = 26
	th.set_color("font_color", "Label", INK)
	var le := sb(WHITE, 20, 3, INK, 18)
	le.content_margin_top = 14
	le.content_margin_bottom = 14
	var lef := sb(WHITE, 20, 4, TEAL, 18)
	lef.content_margin_top = 14
	lef.content_margin_bottom = 14
	th.set_stylebox("normal", "LineEdit", le)
	th.set_stylebox("focus", "LineEdit", lef)
	th.set_stylebox("read_only", "LineEdit", le)
	th.set_color("font_color", "LineEdit", INK)
	th.set_color("font_placeholder_color", "LineEdit", Color(INK_SOFT, 0.7))
	th.set_color("caret_color", "LineEdit", CORAL)
	th.set_color("selection_color", "LineEdit", Color(SUN, 0.5))
	th.set_font("font", "LineEdit", F_BOLD)
	th.set_font_size("font_size", "LineEdit", 28)
	var empty := StyleBoxEmpty.new()
	var bar := StyleBoxEmpty.new()
	bar.content_margin_left = 3
	bar.content_margin_right = 3
	th.set_stylebox("scroll", "VScrollBar", bar)
	th.set_stylebox("scroll_focus", "VScrollBar", bar)
	var grab := sb(Color(INK, 0.16), 4, 0, INK, 0)
	grab.content_margin_left = 3
	grab.content_margin_right = 3
	th.set_stylebox("grabber", "VScrollBar", grab)
	th.set_stylebox("grabber_highlight", "VScrollBar", grab)
	th.set_stylebox("grabber_pressed", "VScrollBar", grab)
	th.set_stylebox("panel", "ScrollContainer", empty)
	th.set_stylebox("focus", "ScrollContainer", empty)
	th.set_stylebox("panel", "PanelContainer", empty)
	return th
