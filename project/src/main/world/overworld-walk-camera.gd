extends Camera2D
"""
Overworld camera for the walking scene. Follows the two characters.
"""

# amount of empty space around characters
const CAMERA_BOUNDARY := 160

# speed of pan adjustments
const LERP_WEIGHT := 0.10

onready var _overworld_ui: OverworldUi = Global.get_overworld_ui()

func _process(_delta: float) -> void:
	var new_position := _calculate_position()
	position = lerp(position, new_position, LERP_WEIGHT)


"""
Returns a rectangle representing the area which should be captured by the camera.
"""
func _calculate_camera_bounding_box() -> Rect2:
	return _overworld_ui.get_chatter_bounding_box().grow(CAMERA_BOUNDARY)


"""
Returns a number in the range [0.0, 1.0] corresponding the fattest creature in the cutscene.

A value of 0.0 means all the characters are thin. A value of 1.0 means at least one character is very fat. This value
is used in making camera adjustments.
"""
func _max_fatness_weight() -> float:
	var max_visual_fatness := 1.0
	for creature in get_tree().get_nodes_in_group("creatures"):
		max_visual_fatness = max(max_visual_fatness, creature.get_visual_fatness())
	return inverse_lerp(1.0, 10.0, clamp(max_visual_fatness, 1.0, 10.0))


"""
Calculate the desired camera position based on the chatting creatures.

This method does not update the camera's zoom value. It returns a value which can be used in a lerp or tween.
"""
func _calculate_position() -> Vector2:
	var camera_bounding_box := _calculate_camera_bounding_box()
	var new_position := camera_bounding_box.position + camera_bounding_box.size * 0.5
	
	# Adjust the cutscene camera so the creature's faces are visible. We move
	# it down slightly for skinny creatures, otherwise they're hidden by dialog
	# bubbles. We move it up for exceptionally fat creatures, otherwise their
	# heads are out of frame.
	new_position.y += camera_bounding_box.size.y * lerp(0.1, -0.3, _max_fatness_weight())
	return new_position
