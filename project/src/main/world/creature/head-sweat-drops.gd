extends Particles2D
## Manages the sweat drops which slide down the creature's body.

export var creature_visuals_path: NodePath

onready var _creature_visuals: CreatureVisuals = get_node(creature_visuals_path)

func _ready() -> void:
	_creature_visuals.connect("comfort_changed", self, "_on_CreatureVisuals_comfort_changed")


func _on_CreatureVisuals_comfort_changed() -> void:
	emitting = _creature_visuals.comfort < -0.2
	if emitting:
		var sweat_amount := clamp(inverse_lerp(-0.2, -1.0, _creature_visuals.comfort), 0.0, 1.0)
		amount = lerp(2, 4, sweat_amount)
		lifetime = lerp(6.0, 3.0, sweat_amount)
