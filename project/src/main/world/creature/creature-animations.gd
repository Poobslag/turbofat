#tool #uncomment to view creature in editor
class_name CreatureAnimations
extends Node
"""
Animates the creature's limbs, facial expressions and movement.

Contains AnimationPlayers to handle things like idle emotes, movement and idle animations.

Exposes properties which manipulate multiple sprites simultaneously. Toggling things like arm and eye emotes involves
animating four sprites. It's tedious having four near-identical animation tracks, so this class consolidates those four
frame properties into one.
"""

export (int) var emote_eye_frame: int setget set_emote_eye_frame
export (int) var eye_frame: int setget set_eye_frame
export (int) var emote_arm_frame: int setget set_emote_arm_frame

export (NodePath) var creature_visuals_path: NodePath setget set_creature_visuals_path

var _creature_visuals: CreatureVisuals

var _emote_arm_z0: PackedSprite
var _emote_arm_z1: PackedSprite
var _emote_eye_z0: PackedSprite
var _emote_eye_z1: PackedSprite
var _eye_z0: PackedSprite
var _eye_z1: PackedSprite
var _far_arm: PackedSprite
var _head_bobber: HeadBobber
var _near_arm: PackedSprite
var _tail_z0: PackedSprite
var _tail_z1: PackedSprite

# IdleTimer which launches idle animations periodically
onready var _idle_timer: Timer = $IdleTimer

# recoils the creature's head
onready var _tween: Tween = $Tween

# EmotePlayer which animates moods: blinking, smiling, sweating, etc.
onready var _emote_player: AnimationPlayer = $EmotePlayer

# AnimationPlayer which animates movement: running, walking, etc.
onready var _movement_player: AnimationPlayer = $MovementPlayer

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


"""
Resets the eye/arm frames to default values.

This is used during development to ensure the .tscn file doesn't include unnecessary changes when we play animations
in the Godot editor. It is not used during the game.
"""
func reset() -> void:
	set_emote_eye_frame(0)
	set_eye_frame(0)
	set_emote_arm_frame(0)


func play_idle_animation(idle_anim: String) -> void:
	_idle_timer.play_idle_animation(idle_anim)


func restart_idle_timer() -> void:
	_idle_timer.restart()


func eat() -> void:
	_emote_player.eat()


"""
Animates the creature's appearance according to the specified mood: happy, angry, etc...

Parameters:
	'mood': The creature's new mood from ChatEvent.Mood
"""
func play_mood(mood: int) -> void:
	_idle_timer.stop_idle_animation()
	
	if mood == ChatEvent.Mood.NONE:
		pass
	elif mood == ChatEvent.Mood.DEFAULT:
		_emote_player.unemote()
	else:
		_emote_player.emote(mood)


"""
The 'feed' animation causes a few side-effects. The creature's head recoils and some sounds play. This method controls
all of those secondary visual effects of the creature being fed.
"""
func show_food_effects() -> void:
	_tween.interpolate_property(_head_bobber, "position:x",
			clamp(_head_bobber.position.x - 6, -20, 0), 0, 0.5,
			Tween.TRANS_QUINT, Tween.EASE_IN_OUT)
	_tween.start()


func play_movement_animation(animation_prefix: String, animation_name: String) -> void:
	if _movement_player.current_animation != animation_name:
		if not _emote_player.current_animation.begins_with("ambient") \
				and not animation_name.begins_with("idle"):
			# don't unemote during sitting-still animations; only when changing movement stances
			_emote_player.unemote_immediate()
		if _movement_player.current_animation.begins_with(animation_prefix):
			var old_position: float = _movement_player.current_animation_position
			_creature_visuals.briefly_suppress_sfx_signal()
			_movement_player.play(animation_name)
			_movement_player.advance(old_position)
		else:
			_movement_player.play(animation_name)
		if not animation_name.begins_with("sprint"):
			_tail_z0.frame = 1 if _creature_visuals.oriented_south() else 2
			_tail_z1.frame = 1 if _creature_visuals.oriented_south() else 2


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
	
	if _movement_player.current_animation and not _movement_player.current_animation.begins_with("idle"):
		# if the creature is walking, they can't emote with their arms
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
	
	_emote_arm_z0 = _creature_visuals.get_node("Neck0/HeadBobber/EmoteArmZ0")
	_emote_arm_z1 = _creature_visuals.get_node("Neck0/HeadBobber/EmoteArmZ1")
	_emote_eye_z0 = _creature_visuals.get_node("Neck0/HeadBobber/EmoteEyeZ0")
	_emote_eye_z1 = _creature_visuals.get_node("Neck0/HeadBobber/EmoteEyeZ1")
	_eye_z0 = _creature_visuals.get_node("Neck0/HeadBobber/EyeZ0")
	_eye_z1 = _creature_visuals.get_node("Neck0/HeadBobber/EyeZ1")
	_far_arm = _creature_visuals.get_node("FarArm")
	_head_bobber = _creature_visuals.get_node("Neck0/HeadBobber")
	_near_arm = _creature_visuals.get_node("NearArm")
	_tail_z0 = _creature_visuals.get_node("TailZ0")
	_tail_z1 = _creature_visuals.get_node("TailZ1")


func _on_CreatureVisuals_orientation_changed(_old_orientation: int, new_orientation: int) -> void:
	if not _movement_player:
		return
	
	if _movement_player.current_animation == "idle-nw" and CreatureOrientation.oriented_south(new_orientation):
		_movement_player.play("idle-se")
	elif _movement_player.current_animation == "idle-se" and CreatureOrientation.oriented_north(new_orientation):
		_movement_player.play("idle-nw")
