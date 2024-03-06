extends AnimationPlayer
## Moves the pinup's camera to accomodate creatures of different size.
##
## While this is an AnimationPlayer, the animation is only used to calculate the camera position. It shouldn't ever be
## played as an animation.

export (NodePath) var creature_path: NodePath
export (NodePath) var customer_camera_path: NodePath

## Amount of empty space over the creature's head.
export (float, 0, 1) var headroom := 1.0 setget set_headroom

## if 'true', the target camera position needs to be recalculated because something about the customer changed
var _position_dirty := true

onready var _creature := get_node(creature_path)
onready var _camera := get_node(customer_camera_path)

func _ready() -> void:
	_refresh_zoom_and_headroom()


func _physics_process(_delta: float) -> void:
	if _position_dirty:
		_refresh_position()


func set_headroom(new_headroom: float) -> void:
	headroom = new_headroom
	_position_dirty = true


## Updates the target camera position based on the creature's position and the 'headroom' property.
func _refresh_position() -> void:
	_camera.position = _creature.get_node("MouthHook").position
	_camera.position += lerp(Vector2(0, 0), Vector2(0, -45), headroom)
	_position_dirty = false


## Updates the 'zoom' and 'headroom' properties used to position the camera.
##
## These properties are updated by advancing this AnimationPlayer.
func _refresh_zoom_and_headroom() -> void:
	if not is_inside_tree() or not _creature:
		return
	
	play("fat-se")
	advance(_creature.visual_fatness)
	stop()
	_position_dirty = true


func _on_Creature_visual_fatness_changed() -> void:
	_refresh_zoom_and_headroom()
