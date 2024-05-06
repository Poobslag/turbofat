extends Camera2D
## Camera for a unique cutscene where the player and Fat Sensei walk through a cheering crowd.

## if the camera needs to move further than this, it will not bother lerping
const CAMERA_LERP_THRESHOLD := 500

## amount of empty space around characters
const CAMERA_BOUNDARY := 160

## speed of pan adjustments
const LERP_WEIGHT := 0.10

## zoom amount when zoomed in or out
const ZOOM_AMOUNT_NEAR := Vector2(0.18750, 0.18750)
const ZOOM_AMOUNT_FAR := Vector2(0.3750, 0.3750)

export (NodePath) var overworld_environment_path: NodePath setget set_overworld_environment_path

var _overworld_environment: OverworldEnvironment

func _ready() -> void:
	_refresh_overworld_environment_path()
	position = _calculate_position()
	zoom = _calculate_zoom()


func _process(_delta: float) -> void:
	var new_position := _calculate_position()
	if ((new_position - position).length() > CAMERA_LERP_THRESHOLD):
		# immediately snap to the new position when preparing the cutscene
		position = new_position
	else:
		# smoothly lerp to the new position when playing the cutscene
		position = lerp(position, new_position, LERP_WEIGHT)

	var new_zoom := _calculate_zoom()
	zoom = lerp(zoom, new_zoom, LERP_WEIGHT)


func set_overworld_environment_path(new_overworld_environment_path: NodePath) -> void:
	overworld_environment_path = new_overworld_environment_path
	_refresh_overworld_environment_path()


func _refresh_overworld_environment_path() -> void:
	if not is_inside_tree():
		return
	
	_overworld_environment = get_node(overworld_environment_path) if overworld_environment_path else null


## Returns a rectangle representing the area which should be captured by the camera.
func _calculate_camera_bounding_box() -> Rect2:
	var bounding_box: Rect2
	for creature in _overworld_environment.get_creatures():
		var adjusted_creature_position: Vector2 = creature.position
		if "elevation" in creature:
			adjusted_creature_position += creature.elevation * Vector2.UP * Global.CREATURE_SCALE
		
		if bounding_box:
			var chat_extents: Vector2 = creature.chat_extents if "chat_extents" in creature else Vector2.ZERO
			var creature_box := Rect2(adjusted_creature_position - chat_extents / 2, chat_extents)
			bounding_box = bounding_box.merge(creature_box)
		else:
			bounding_box = Rect2(adjusted_creature_position, Vector2.ZERO)
	
	return bounding_box.grow(CAMERA_BOUNDARY)


## Calculate the desired camera position based on the player and Fat Sensei.
##
## This method does not update the camera's position. It returns a value which can be used in a lerp or tween.
func _calculate_position() -> Vector2:
	var camera_bounding_box := _calculate_camera_bounding_box()
	var new_position := camera_bounding_box.position + camera_bounding_box.size * 0.5
	return new_position


## Calculate the desired camera zoom based on the player and Fat Sensei.
##
## This method does not update the camera's zoom value. It returns a value which can be used in a lerp or tween.
func _calculate_zoom() -> Vector2:
	var camera_bounding_box := _calculate_camera_bounding_box()
	var new_zoom := Vector2.ZERO
	new_zoom.x = max(camera_bounding_box.size.x / Global.window_size.x, \
			camera_bounding_box.size.y / Global.window_size.y)
	new_zoom.x = clamp(new_zoom.x, ZOOM_AMOUNT_NEAR.x, ZOOM_AMOUNT_FAR.x)
	
	# If any exceptionally fat creatures are in frame, we keep the camera zoomed out.
	new_zoom.x = max(new_zoom.x, lerp(ZOOM_AMOUNT_NEAR.x, ZOOM_AMOUNT_FAR.x, _max_fatness_weight()))
	
	new_zoom.y = new_zoom.x
	
	return new_zoom


## Returns a number in the range [0.0, 1.0] corresponding the fattest creature in the cutscene.
##
## A value of 0.0 means all the characters are thin. A value of 1.0 means at least one character is very fat. This
## value is used in making camera adjustments.
func _max_fatness_weight() -> float:
	var max_visual_fatness := 1.0
	for creature in _overworld_environment.get_creatures():
		max_visual_fatness = max(max_visual_fatness, creature.visual_fatness)
	return inverse_lerp(1.0, 10.0, clamp(max_visual_fatness, 1.0, 10.0))
