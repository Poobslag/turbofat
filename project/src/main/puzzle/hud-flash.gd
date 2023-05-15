class_name HudFlash
extends ColorRect
## Flashes the screen briefly. Used to transition between tutorial sections.

var _tween: Tween

## Flashes the screen briefly. Used to transition between tutorial sections.
func flash() -> void:
	modulate.a = 0.25
	
	_tween = Utils.recreate_tween(self, _tween)
	_tween.tween_property(self, "modulate:a", 0.0, 1.0)
