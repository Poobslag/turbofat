class_name HudFlash
extends ColorRect
## Flashes the screen briefly. Used to transition between tutorial sections.

## Flashes the screen briefly. Used to transition between tutorial sections.
func flash() -> void:
	modulate.a = 0.25
	$Tween.remove_all()
	$Tween.interpolate_property(self, "modulate:a", modulate.a, 0.0, 1.0)
	$Tween.start()
