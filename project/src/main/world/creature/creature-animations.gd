#tool #uncomment to view creature in editor
extends Node
"""
Exposes properties which make it easier to animate the creature.

Toggling things like arm and eye emotes involves animating four sprites. It's tedious having four near-identical
animation tracks, so this class consolidates those four frame properties into one.
"""

# Virtual properties; value is only exposed through getters/setters
export (int) var emote_eye_frame: int setget set_emote_eye_frame
export (int) var eye_frame: int setget set_eye_frame
export (int) var emote_arm_frame: int setget set_emote_arm_frame

export (NodePath) var creature_visuals_path: NodePath setget set_creature_visuals_path

var _creature_visuals: CreatureVisuals

func _ready() -> void:
	_refresh_creature_visuals_path()


func set_creature_visuals_path(new_creature_visuals_path: NodePath) -> void:
	creature_visuals_path = new_creature_visuals_path
	_refresh_creature_visuals_path()


"""
Sets the frame for the emote eye sprites, resetting the non-emote sprites to a default frame.
"""
func set_emote_eye_frame(new_emote_eye_frame: int) -> void:
	if not is_inside_tree():
		return
	_creature_visuals.get_node("Neck0/HeadBobber/EyeZ0").frame = 1 if new_emote_eye_frame == 0 else 0
	_creature_visuals.get_node("Neck0/HeadBobber/EyeZ1").frame = 1 if new_emote_eye_frame == 0 else 0
	_creature_visuals.get_node("Neck0/HeadBobber/EmoteEyeZ0").frame = new_emote_eye_frame
	_creature_visuals.get_node("Neck0/HeadBobber/EmoteEyeZ1").frame = new_emote_eye_frame


"""
Sets the frame for the eye sprites, resetting the emote sprites to a default frame.
"""
func set_eye_frame(new_eye_frame: int) -> void:
	if not is_inside_tree():
		return
	_creature_visuals.get_node("Neck0/HeadBobber/EyeZ0").frame = new_eye_frame
	_creature_visuals.get_node("Neck0/HeadBobber/EyeZ1").frame = new_eye_frame
	_creature_visuals.get_node("Neck0/HeadBobber/EmoteEyeZ0").frame = 0
	_creature_visuals.get_node("Neck0/HeadBobber/EmoteEyeZ1").frame = 0


"""
Sets the frame for the emote arm sprites, resetting the non-emote sprites to a default frame.
"""
func set_emote_arm_frame(new_emote_arm_frame: int) -> void:
	if not is_inside_tree():
		return
	
	# hide the arm sprites, except for certain emotes where that specific arm is still visible
	_creature_visuals.get_node("NearArm").frame = 1 if new_emote_arm_frame in [0, 1, 4] else 0
	_creature_visuals.get_node("FarArm").frame = 1 if new_emote_arm_frame in [0, 3] else 0
	
	_creature_visuals.get_node("Neck0/HeadBobber/EmoteArmZ0").frame = new_emote_arm_frame
	_creature_visuals.get_node("Neck0/HeadBobber/EmoteArmZ1").frame = new_emote_arm_frame


func _refresh_creature_visuals_path() -> void:
	if not (is_inside_tree() and creature_visuals_path):
		return
	
	_creature_visuals = get_node(creature_visuals_path)
