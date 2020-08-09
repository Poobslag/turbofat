extends Tween
"""
Pans the camera from one creature to another.
"""

# the amount of time spent panning the camera to a new creature
const PAN_DURATION_SECONDS := 0.4

export (NodePath) var customer_camera_path: NodePath

onready var _customer_camera: Camera2D = get_node(customer_camera_path)

func _on_RestaurantScene_current_creature_index_changed(value: int) -> void:
	interpolate_property(
			_customer_camera, "position:x",
			_customer_camera.position.x, 2000 * value, PAN_DURATION_SECONDS,
			Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	start()
