extends Spatial
"""
Target which the camera attaches to while Spira is talking to someone.

The camera target tries to keep all speaking characters in frame. If Spira runs
too far away, the target emits a signal to zoom out.
"""

# emitted when the camera should zoom out because Spira ran too far away
signal left_zoom_radius

# how far from the camera target Spira can be before the camera zooms out
const ZOOM_OUT_DISTANCE := 50.0

# the position of the camera target relative to the midpoint
const RELATIVE_TRANSLATION := Vector3(325, 250, 325)

# 'true' if the camera should currently be zoomed into this target
var zoomed_in := false

onready var _overworld_ui: OverworldUi3D = $"../OverworldUi"

func _physics_process(delta: float) -> void:
	if not zoomed_in:
		# camera is not zoomed in; don't worry about updating the target position
		return
	
	# calculate a bounding box containing Spira and all chat participants
	var bounding_box: AABB
	var spira_point := _overworld_ui.spira.translation
	bounding_box = AABB(spira_point, Vector3(0, 0, 0))
	for chatter in _overworld_ui.chatters:
		if not bounding_box:
			bounding_box = AABB(chatter.translation, Vector3(0, 0, 0))
		else:
			bounding_box = bounding_box.expand(chatter.translation)
	
	# zoom in on the midpoint of the bounding box
	var midpoint := bounding_box.position + bounding_box.size * 0.5
	translation = RELATIVE_TRANSLATION + midpoint

	if _overworld_ui.spira.translation.distance_to(midpoint) > ZOOM_OUT_DISTANCE:
		# Spira ran too far from the midpoint; zoom out
		emit_signal("left_zoom_radius")
		zoomed_in = false
