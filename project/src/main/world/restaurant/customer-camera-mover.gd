extends AnimationPlayer
"""
Moves the restaurant scene's camera as customers get fatter.

While this is an AnimationPlayer, the animation is only used to calculate the camera position. It shouldn't ever be
played as an animation.
"""

export (NodePath) var restaurant_scene_path: NodePath
export (NodePath) var customer_camera_path: NodePath

# the position that the restaurant scene's camera lerps to
export (Vector2) var target_camera_position: Vector2

# fields which control the screen shake effect
var _shake_total_seconds := 0.0
var _shake_remaining_seconds := 0.0
var _shake_magnitude := 8.0
var _shake_position := Vector2.ZERO

onready var _restaurant_scene: RestaurantScene = get_node(restaurant_scene_path)
onready var _customer_camera: Camera2D = get_node(customer_camera_path)

func _ready() -> void:
	var customers := _restaurant_scene.get_customers()
	for i in range(0, customers.size()):
		customers[i].connect("visual_fatness_changed", self, "_on_Creature_visual_fatness_changed", [0])
	_refresh_target_camera_position()
	_customer_camera.position = target_camera_position


func _physics_process(delta: float) -> void:
	_customer_camera.position = lerp(_customer_camera.position, target_camera_position, 0.12)
	
	if _shake_remaining_seconds > 0:
		_shake_remaining_seconds -= delta
		if _shake_remaining_seconds <= 0:
			_shake_position = Vector2.ZERO
		else:
			var max_shake := _shake_magnitude * _shake_remaining_seconds / _shake_total_seconds
			_shake_position = Vector2(rand_range(-max_shake, max_shake), rand_range(-max_shake, max_shake))
		_customer_camera.position += _shake_position


func _refresh_target_camera_position() -> void:
	play("fat-se")
	var customer := _restaurant_scene.get_customer(_restaurant_scene.current_creature_index)
	if customer.dna.get("body") == "2":
		# small creatures (squirrels) don't advance the camera as far
		advance(customer.get_visual_fatness() * customer.creature_visuals.scale.y)
	else:
		advance(customer.get_visual_fatness())
	stop()
	target_camera_position.x += 2000 * _restaurant_scene.current_creature_index


func _on_Creature_visual_fatness_changed(index: int) -> void:
	if index == _restaurant_scene.current_creature_index:
		# only adjust the camera if the current creature changes
		_refresh_target_camera_position()


func _on_RestaurantScene_current_creature_index_changed(_value: int) -> void:
	_refresh_target_camera_position()


func _on_RestaurantScene_food_eaten() -> void:
	_shake_total_seconds = 0.20
	_shake_remaining_seconds = 0.20
