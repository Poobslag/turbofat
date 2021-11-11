extends Particles2D
## Manages the sweat drops which slide down the creature's body.

export var creature_visuals_path: NodePath

onready var _creature_visuals: CreatureVisuals = get_node(creature_visuals_path)

func _ready() -> void:
	_creature_visuals.connect("comfort_changed", self, "_on_CreatureVisuals_comfort_changed")
	_creature_visuals.connect("visual_fatness_changed", self, "_on_CreatureVisuals_visual_fatness_changed")


func _refresh_sweat() -> void:
	emitting = _creature_visuals.comfort < -0.4
	if emitting:
		var sweat_amount := clamp(inverse_lerp(-0.4, -1.0, _creature_visuals.comfort), 0.0, 1.0)
		var new_amount: float = _creature_visuals.get_fatness() * lerp(1.5, 4, sweat_amount)
		var new_lifetime: float = lerp(6.0, 3.0, sweat_amount)
		if abs(amount - new_amount) / max(amount, 1) > 0.33 \
				or abs(lifetime - new_lifetime) / max(lifetime, 1) > 0.33:
			# changing amount/lifetime resets all particles, so we try not to do it too often
			amount = new_amount
			lifetime = new_lifetime


func _on_CreatureVisuals_comfort_changed() -> void:
	_refresh_sweat()


func _on_CreatureVisuals_visual_fatness_changed() -> void:
	_refresh_sweat()
