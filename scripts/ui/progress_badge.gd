class_name ProgressBadge
extends HBoxContainer
## Bilah kemajuan kecil + teks (dipakai di kartu menu).


static func make(text: String, ratio: float, col: Color) -> ProgressBadge:
	var p := ProgressBadge.new()
	p.add_theme_constant_override("separation", 10)
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var bar := MeterBar.make(ratio, col, 16)
	bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	p.add_child(bar)
	var l := UI.label(text, 17, UI.INK, UI.F_BLACK, HORIZONTAL_ALIGNMENT_RIGHT, false)
	p.add_child(l)
	return p
