#tool #uncomment to view creature in editor
extends Node
"""
Exposes properties which make it easier to animate the creature.

Toggling things like arm and eye emotes involves animating four sprites. It's tedious having four near-identical
animation tracks, so this class consolidates those four frame properties into one.
"""

export (int) var emote_eye_frame: int setget set_emote_eye_frame
export (int) var eye_frame: int setget set_eye_frame
export (int) var emote_arm_frame: int setget set_emote_arm_frame

export (NodePath) var creature_visuals_path: NodePath setget set_creature_visuals_path

var _creature_visuals: CreatureVisuals

var _near_arm: PackedSprite
var _far_arm: PackedSprite
var _eye_z0: PackedSprite
var _eye_z1: PackedSprite
var _emote_eye_z0: PackedSprite
var _emote_eye_z1: PackedSprite
var _emote_arm_z0: PackedSprite
var _emote_arm_z1: PackedSprite

func _ready() -> void:
	_refresh_creature_visuals_path()
	_refresh_emote_eye_frame()
	_refresh_eye_frame()
	_refresh_emote_arm_frame()


func set_creature_visuals_path(new_creature_visuals_path: NodePath) -> void:
	creature_visuals_path = new_creature_visuals_path
	_refresh_creature_visuals_path()


"""
Sets the frame for the emote eye sprites, resetting the non-emote sprites to a default frame.
"""
func set_emote_eye_frame(new_emote_eye_frame: int) -> void:
	emote_eye_frame = new_emote_eye_frame
	_refresh_emote_eye_frame()


func _refresh_emote_eye_frame() -> void:
	if not is_inside_tree():
		return

	_eye_z0.frame = 1 if emote_eye_frame == 0 else 0
	_eye_z1.frame = 1 if emote_eye_frame == 0 else 0
	_emote_eye_z0.frame = emote_eye_frame
	_emote_eye_z1.frame = emote_eye_frame


"""
Sets the frame for the eye sprites, resetting the emote sprites to a default frame.
"""
func set_eye_frame(new_eye_frame: int) -> void:
	eye_frame = new_eye_frame
	_refresh_eye_frame()


func _refresh_eye_frame() -> void:
	if not is_inside_tree():
		return

	_eye_z0.frame = eye_frame
	_eye_z1.frame = eye_frame
	_emote_eye_z0.frame = 0
	_emote_eye_z1.frame = 0


"""
Sets the frame for the emote arm sprites, resetting the non-emote sprites to a default frame.
"""
func set_emote_arm_frame(new_emote_arm_frame: int) -> void:
	emote_arm_frame = new_emote_arm_frame
	_refresh_emote_arm_frame()


func _refresh_emote_arm_frame() -> void:
	if not is_inside_tree():
		return
	
	# hide the arm sprites, except for certain emotes where that specific arm is still visible
	_near_arm.frame = 1 if emote_arm_frame in [0, 1, 4] else 0
	_far_arm.frame = 1 if emote_arm_frame in [0, 3] else 0
	
	_emote_arm_z0.frame = emote_arm_frame
	_emote_arm_z1.frame = emote_arm_frame


func _refresh_creature_visuals_path() -> void:
	if not (is_inside_tree() and creature_visuals_path):
		return
	
	_creature_visuals = get_node(creature_visuals_path)
	
	_near_arm = _creature_visuals.get_node("NearArm")
	_far_arm = _creature_visuals.get_node("FarArm")
	_eye_z0 = _creature_visuals.get_node("Neck0/HeadBobber/EyeZ0")
	_eye_z1 = _creature_visuals.get_node("Neck0/HeadBobber/EyeZ1")
	_emote_eye_z0 = _creature_visuals.get_node("Neck0/HeadBobber/EmoteEyeZ0")
	_emote_eye_z1 = _creature_visuals.get_node("Neck0/HeadBobber/EmoteEyeZ1")
	_emote_arm_z0 = _creature_visuals.get_node("Neck0/HeadBobber/EmoteArmZ0")
	_emote_arm_z1 = _creature_visuals.get_node("Neck0/HeadBobber/EmoteArmZ1")
