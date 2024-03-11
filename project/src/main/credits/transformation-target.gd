extends Node2D
## Location where the orb should launch its pieces when targetting pinups to transform.

export (NodePath) var wallpaper_path: NodePath

onready var _wallpaper := get_node(wallpaper_path)
onready var _particles := $Particles

func _ready() -> void:
	_particles.modulate = _wallpaper.light_color.lightened(0.5)


func emit_particles() -> void:
	_particles.emitting = true
