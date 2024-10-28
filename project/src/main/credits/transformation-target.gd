extends Node2D
## Location where the orb should launch its pieces when targetting pinups to transform.

onready var _particles := $Particles

func _ready() -> void:
	_particles.modulate = Wallpaper.light_color.lightened(0.5)


func emit_particles() -> void:
	_particles.emitting = true
