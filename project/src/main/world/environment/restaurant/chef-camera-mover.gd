extends AnimationPlayer
## Moves the restaurant scene's camera to keep fat chefs in frame.
##
## While this is an AnimationPlayer, the animation is only used to calculate the camera position. It shouldn't ever be
## played as an animation.

export (NodePath) var restaurant_scene_path: NodePath
export (NodePath) var chef_camera_path: NodePath

## The amount of empty space over the creature's head.
export (float, 0, 1) var headroom := 1.0 setget set_headroom

## the position that the restaurant scene's camera lerps to
var _target_camera_position: Vector2

var _target_camera_position_dirty := true

onready var _restaurant_scene: RestaurantPuzzleScene = get_node(restaurant_scene_path)
onready var _chef_camera: Camera2D = get_node(chef_camera_path)

func _ready() -> void:
	_refresh_zoom_and_headroom()
	_refresh_target_camera_position()
	_chef_camera.position = _target_camera_position


func _physics_process(_delta: float) -> void:
	if _target_camera_position_dirty:
		_refresh_target_camera_position()
	
	_chef_camera.position = lerp(_chef_camera.position, _target_camera_position, 0.09)


func set_headroom(new_headroom: float) -> void:
	headroom = new_headroom
	_target_camera_position_dirty = true


## Updates the 'zoom' and 'headroom' properties used to position the camera.
##
## These properties are updated by advancing this AnimationPlayer.
func _refresh_zoom_and_headroom() -> void:
	var customer := _restaurant_scene.get_chef()
	play("fat-se")
	advance(customer.get_visual_fatness())
	stop()
	_target_camera_position_dirty = true


## Updates the target camera position based on the chef's position and the 'headroom' property.
func _refresh_target_camera_position() -> void:
	var chef := _restaurant_scene.get_chef()
	# calculate the position within the restaurant scene
	var target_pos: Vector2 = chef.body_pos_from_head_pos(lerp(Vector2(-50, 0), Vector2(0, -50), headroom))
	_target_camera_position = target_pos
	_target_camera_position_dirty = false
