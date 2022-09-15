extends AnimationPlayer
## Moves the restaurant scene's camera as customers get fatter.
##
## While this is an AnimationPlayer, the animation is only used to calculate the camera position. It shouldn't ever be
## played as an animation.

export (NodePath) var restaurant_scene_path: NodePath
export (NodePath) var customer_camera_path: NodePath

## The amount of empty space over the creature's head.
export (float, 0, 1) var headroom := 1.0 setget set_headroom

## the position that the restaurant scene's camera lerps to
var _target_camera_position: Vector2

## fields which control the screen shake effect
var _shake_total_seconds := 0.0
var _shake_remaining_seconds := 0.0
var _shake_magnitude := 2.0
var _shake_position := Vector2.ZERO

## if 'true', the target camera position needs to be recalculated because something about the customer changed
var _target_camera_position_dirty := true

onready var _restaurant_scene: RestaurantPuzzleScene = get_node(restaurant_scene_path)
onready var _customer_camera: Camera2D = get_node(customer_camera_path)

func _ready() -> void:
	var customers := _restaurant_scene.get_customers()
	for i in range(customers.size()):
		customers[i].connect("visual_fatness_changed", self, "_on_Creature_visual_fatness_changed", [i])
	_refresh_zoom_and_headroom()
	_refresh_target_camera_position()
	_customer_camera.position = _target_camera_position


func _physics_process(delta: float) -> void:
	if _target_camera_position_dirty:
		_refresh_target_camera_position()
	
	_customer_camera.position = lerp(_customer_camera.position, _target_camera_position, 0.09)
	
	if _shake_remaining_seconds > 0:
		_shake_remaining_seconds -= delta
		if _shake_remaining_seconds <= 0:
			_shake_position = Vector2.ZERO
		else:
			var max_shake := _shake_magnitude * _shake_remaining_seconds / _shake_total_seconds
			_shake_position = Vector2(rand_range(-max_shake, max_shake), rand_range(-max_shake, max_shake))
		_customer_camera.position += _shake_position


func set_headroom(new_headroom: float) -> void:
	headroom = new_headroom
	_target_camera_position_dirty = true


## Updates the 'zoom' and 'headroom' properties used to position the camera.
##
## These properties are updated by advancing this AnimationPlayer.
func _refresh_zoom_and_headroom() -> void:
	var customer := _restaurant_scene.get_customer(_restaurant_scene.current_creature_index)
	play("fat-se")
	advance(customer.get_visual_fatness())
	stop()
	_target_camera_position_dirty = true


## Updates the target camera position based on the current customer's position and the 'headroom' property.
func _refresh_target_camera_position() -> void:
	var customer := _restaurant_scene.get_customer(_restaurant_scene.current_creature_index)
	# calculate the position within the restaurant scene
	var target_pos: Vector2 = customer.body_pos_from_head_pos(lerp(Vector2(0, 40), Vector2(0, -65), headroom))
	_target_camera_position = target_pos
	_target_camera_position_dirty = false


func _on_Creature_visual_fatness_changed(index: int) -> void:
	if index == _restaurant_scene.current_creature_index:
		# only adjust the camera if the current creature changes
		_refresh_zoom_and_headroom()


func _on_RestaurantPuzzleScene_current_creature_index_changed(_value: int) -> void:
	_refresh_zoom_and_headroom()


func _on_RestaurantPuzzleScene_food_eaten(_food_type: int) -> void:
	_shake_total_seconds = 0.20
	_shake_remaining_seconds = 0.20
