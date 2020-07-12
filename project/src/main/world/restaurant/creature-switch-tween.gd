extends Tween
"""
Pans the camera from one creature to another.
"""

# the amount of time spent panning the camera to a new creature
const PAN_DURATION_SECONDS := 0.4

onready var _creature_switcher: Node2D = get_parent()

func _on_RestaurantScene_current_creature_index_changed(value: int) -> void:
	interpolate_property(
			_creature_switcher, "position:x",
			_creature_switcher.position.x, -1000 * value, PAN_DURATION_SECONDS,
			Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	start()
