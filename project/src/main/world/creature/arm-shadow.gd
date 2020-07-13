extends CreatureCurve
"""
The shadow drawn below the creature's arm.
"""

export (NodePath) var near_arm_path: NodePath

onready var _near_arm: CreaturePackedSprite = get_node(near_arm_path)

func _ready() -> void:
	_near_arm.connect("frame_changed", self, "_on_NearArm_frame_changed")


"""
Updates the 'visible' property based on the arm's current frame.
"""
func refresh_visible() -> void:
	.refresh_visible()
	if _near_arm.frame == 0:
		visible = false


func _on_NearArm_frame_changed() -> void:
	refresh_visible()
