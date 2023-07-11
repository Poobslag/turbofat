#tool #uncomment to view creature in editor
class_name CreatureAnimations
extends Node
## Animates the creature's limbs, facial expressions and movement.
##
## Contains AnimationPlayers to handle things like idle emotes, movement and idle animations.
##
## Exposes properties which manipulate multiple sprites simultaneously. Toggling things like arm and eye emotes
## involves animating four sprites. It's tedious having four near-identical animation tracks, so this class
## consolidates those four frame properties into one.

export (int) var emote_eye_frame: int setget set_emote_eye_frame
export (int) var eye_frame: int setget set_eye_frame
export (int) var emote_arm_frame: int setget set_emote_arm_frame

export (NodePath) var creature_visuals_path: NodePath setget set_creature_visuals_path

var creature_sfx: CreatureSfx setget set_creature_sfx

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

## IdleTimer which launches idle animations periodically
onready var _idle_timer: Timer = $IdleTimer

## recoils the creature's head
onready var _tween: SceneTreeTween

## EmotePlayer which animates moods: blinking, smiling, sweating, etc.
onready var _emote_player: AnimationPlayer = $EmotePlayer

## AnimationPlayer which animates movement: running, walking, etc.
onready var _movement_player: AnimationPlayer = $MovementPlayer

func _ready() -> void:
	_refresh_creature_visuals_path()
	_refresh_emote_eye_frame()
	_refresh_eye_frame()
	_refresh_emote_arm_frame()
	_refresh_creature_sfx()
	_refresh_should_play_sfx()


func set_creature_sfx(new_creature_sfx: CreatureSfx) -> void:
	creature_sfx = new_creature_sfx
	_refresh_creature_sfx()
	_refresh_should_play_sfx()


func set_creature_visuals_path(new_creature_visuals_path: NodePath) -> void:
	creature_visuals_path = new_creature_visuals_path
	_refresh_creature_visuals_path()


## Sets the frame for the emote eye sprites, resetting the non-emote sprites to a default frame.
func set_emote_eye_frame(new_emote_eye_frame: int) -> void:
	emote_eye_frame = new_emote_eye_frame
	_refresh_emote_eye_frame()


## Resets the eye/arm frames to default values.
##
## This is used during development to ensure the .tscn file doesn't include unnecessary changes when we play animations
## in the Godot editor. It is not used during the game.
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


## Animates the creature's appearance according to the specified mood: happy, angry, etc...
##
## Parameters:
## 	'mood': The creature's new mood from Creatures.Mood
func play_mood(mood: int) -> void:
	_idle_timer.stop_idle_animation()
	
	match mood:
		Creatures.Mood.NONE:
			pass
		Creatures.Mood.DEFAULT:
			_emote_player.unemote()
		_:
			_emote_player.emote(mood)


## The 'feed' animation causes a few side-effects. The creature's head recoils and some sounds play. This method
## controls all of those secondary visual effects of the creature being fed.
func show_food_effects() -> void:
	_head_bobber.position.x = clamp(_head_bobber.position.x - 6, -20, 0)
	_tween = Utils.recreate_tween(self, _tween).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN_OUT)
	_tween.tween_property(_head_bobber, "position:x", 0.0, 0.5)


## Plays a movement animation with the specified animation name, such as 'run-sw'.
##
## Parameters:
## 	'animation_prefix': The name of an animation on $Creature/Animations/MovementPlayer
func play_movement_animation(animation_name: String) -> void:
	# The first chunk of the animation name such as 'sprint', 'run' or 'idle'
	var animation_prefix := StringUtils.substring_before_last(animation_name, "-")
	
	if _movement_player.current_animation != animation_name:
		# prevent emotes from conflicting with movement animations
		if not _emote_player.current_animation.begins_with("ambient") \
				and not animation_name.begins_with("idle"):
			# don't unemote during sitting-still animations; only when changing movement stances
			_emote_player.unemote_immediate()
		
		# play the animation
		if _movement_player.current_animation.begins_with(animation_prefix):
			# preserve the position in the animation timeline when changing direction
			var old_animation_position: float = _movement_player.current_animation_position
			if creature_sfx:
				creature_sfx.briefly_suppress_sfx(0.000000001)
			
			_movement_player.play(animation_name)
			_movement_player.advance(old_animation_position)
		else:
			_movement_player.play(animation_name)
		
		# update the creature's tail
		if not animation_name.begins_with("sprint"):
			_tail_z0.frame = 1 if _creature_visuals.oriented_south() else 2
			_tail_z1.frame = 1 if _creature_visuals.oriented_south() else 2


## Sets the frame for the eye sprites, resetting the emote sprites to a default frame.
func set_eye_frame(new_eye_frame: int) -> void:
	eye_frame = new_eye_frame
	_refresh_eye_frame()


## Sets the frame for the emote arm sprites, resetting the non-emote sprites to a default frame.
func set_emote_arm_frame(new_emote_arm_frame: int) -> void:
	emote_arm_frame = new_emote_arm_frame
	_refresh_emote_arm_frame()


func _refresh_creature_sfx() -> void:
	if not creature_sfx:
		return
	
	creature_sfx.connect("should_play_sfx_changed", self, "_on_CreatureSfx_should_play_sfx_changed")


func _refresh_emote_eye_frame() -> void:
	if not is_inside_tree():
		return

	_eye_z0.frame = 1 if emote_eye_frame == 0 else 0
	_eye_z1.frame = 1 if emote_eye_frame == 0 else 0
	_emote_eye_z0.frame = emote_eye_frame
	_emote_eye_z1.frame = emote_eye_frame


func _refresh_eye_frame() -> void:
	if not is_inside_tree():
		return

	_eye_z0.frame = eye_frame
	_eye_z1.frame = eye_frame
	_emote_eye_z0.frame = 0
	_emote_eye_z1.frame = 0


func _refresh_emote_arm_frame() -> void:
	if not is_inside_tree():
		return
	
	if not _movement_player.current_animation.empty() and not _movement_player.current_animation.begins_with("idle"):
		# if the creature is walking, they can't emote with their arms
		return
	
	# hide the arm sprites, except for certain emotes where that specific arm is still visible
	_near_arm.frame = 1 if emote_arm_frame in [0, 1, 4] else 0
	_far_arm.frame = 1 if emote_arm_frame in [0, 3] else 0
	
	_emote_arm_z0.frame = emote_arm_frame
	_emote_arm_z1.frame = emote_arm_frame


func _refresh_creature_visuals_path() -> void:
	if not (is_inside_tree() and not creature_visuals_path.is_empty()):
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


func _refresh_should_play_sfx() -> void:
	if not creature_sfx:
		return
	
	if creature_sfx.should_play_sfx:
		_emote_player.fade_in_sfx()
	else:
		_emote_player.fade_out_sfx()


func _on_CreatureVisuals_orientation_changed(_old_orientation: int, new_orientation: int) -> void:
	if not _movement_player:
		return
	
	if _movement_player.current_animation == "idle-nw" and Creatures.oriented_south(new_orientation):
		_movement_player.play("idle-se")
	elif _movement_player.current_animation == "idle-se" and Creatures.oriented_north(new_orientation):
		_movement_player.play("idle-nw")


func _on_CreatureSfx_should_play_sfx_changed() -> void:
	_refresh_should_play_sfx()
