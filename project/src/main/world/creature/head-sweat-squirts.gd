extends Particles2D
"""
Manages the sweat drops which leap from the creature's head.
"""

export var creature_visuals_path: NodePath

onready var _creature_visuals: CreatureVisuals = get_node(creature_visuals_path)

func _ready() -> void:
	_creature_visuals.connect("comfort_changed", self, "_on_CreatureVisuals_comfort_changed")


func _on_CreatureVisuals_comfort_changed() -> void:
	emitting = _creature_visuals.comfort < -0.6
	if emitting:
		var sweat_amount := clamp(inverse_lerp(-0.6, -1.0, _creature_visuals.comfort), 0.0, 1.0)
		amount = lerp(3, 8, sweat_amount)
