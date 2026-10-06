extends Control
## Titik masuk aplikasi: menyerahkan wadah layar ke Router.


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	Router.attach(self)
