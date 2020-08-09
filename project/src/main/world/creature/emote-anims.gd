#tool #uncomment to view creature in editor
extends AnimationPlayer
"""
Script for AnimationPlayers which animate moods: blinking, smiling, sweating, etc.
"""

signal animation_stopped

# mapping from moods to animation names
const EMOTE_ANIMS := {
	ChatEvent.Mood.SMILE0: "smile0",
	ChatEvent.Mood.SMILE1: "smile1",
	ChatEvent.Mood.LAUGH0: "laugh0",
	ChatEvent.Mood.LAUGH1: "laugh1",
	ChatEvent.Mood.THINK0: "think0",
	ChatEvent.Mood.THINK1: "think1",
	ChatEvent.Mood.CRY0: "cry0",
	ChatEvent.Mood.CRY1: "cry1",
	ChatEvent.Mood.SWEAT0: "sweat0",
	ChatEvent.Mood.SWEAT1: "sweat1",
	ChatEvent.Mood.RAGE0: "rage0",
	ChatEvent.Mood.RAGE1: "rage1",
}

# animation names for eating while smiling; referenced for animation transitions
const EAT_SMILE_ANIMS := {
	"eat-smile0": "_",
	"eat-again-smile0": "_",
	"eat-smile1": "_",
	"eat-again-smile1": "_",
}

# animation names for eating while sweating; referenced for animation transitions
const EAT_SWEAT_ANIMS := {
	"eat-sweat0": "_",
	"eat-again-sweat0": "_",
	"eat-sweat1": "_",
	"eat-again-sweat1": "_",
	"eat-sweat2": "_",
	"eat-again-sweat2": "_"
}

# custom transition for cases where the default mood transition looks awkward
const TRANSITIONS := {
	[ChatEvent.Mood.SMILE0, ChatEvent.Mood.SMILE0]: "_transition_noop",
	[ChatEvent.Mood.SMILE0, ChatEvent.Mood.SMILE1]: "_transition_noop",
	[ChatEvent.Mood.SMILE1, ChatEvent.Mood.SMILE1]: "_transition_noop",
	[ChatEvent.Mood.SMILE1, ChatEvent.Mood.SMILE0]: "_transition_smile1_smile0",
	[ChatEvent.Mood.LAUGH0, ChatEvent.Mood.LAUGH0]: "_transition_noop",
	[ChatEvent.Mood.LAUGH0, ChatEvent.Mood.LAUGH1]: "_transition_noop",
	[ChatEvent.Mood.LAUGH1, ChatEvent.Mood.LAUGH0]: "_transition_laugh1_laugh0",
	[ChatEvent.Mood.LAUGH1, ChatEvent.Mood.LAUGH1]: "_transition_noop",
	[ChatEvent.Mood.THINK0, ChatEvent.Mood.THINK0]: "_transition_noop",
	[ChatEvent.Mood.THINK1, ChatEvent.Mood.THINK1]: "_transition_noop",
	[ChatEvent.Mood.CRY0, ChatEvent.Mood.CRY0]: "_transition_noop",
	[ChatEvent.Mood.CRY1, ChatEvent.Mood.CRY1]: "_transition_noop",
	[ChatEvent.Mood.SWEAT0, ChatEvent.Mood.SWEAT1]: "_transition_noop",
	[ChatEvent.Mood.SWEAT0, ChatEvent.Mood.SWEAT0]: "_transition_noop",
	[ChatEvent.Mood.SWEAT1, ChatEvent.Mood.SWEAT0]: "_transition_sweat1_sweat0",
	[ChatEvent.Mood.SWEAT1, ChatEvent.Mood.SWEAT1]: "_transition_noop",
	[ChatEvent.Mood.RAGE0, ChatEvent.Mood.RAGE0]: "_transition_noop",
	[ChatEvent.Mood.RAGE1, ChatEvent.Mood.RAGE1]: "_transition_noop",
}

# Time spent resetting to a neutral emotion: fading out speech bubbles, untilting the head, etc...
const UNEMOTE_DURATION := 0.08

onready var _creature_visuals: CreatureVisuals = get_parent()

# stores the previous mood so that we can apply mood transitions.
var _prev_mood: int

# stores the current mood. used to prevent sync issues when changing moods faster than 80 milliseconds.
var _mood: int

# list of sprites to reset when unemoting
onready var _emote_sprites := [
	$"../Neck0/HeadBobber/EmoteBrain",
	$"../Neck0/HeadBobber/EmoteHead",
	$"../EmoteBody",
	$"../Neck0/HeadBobber/EmoteGlow",
]

# specific sprites manipulated frequently when emoting
onready var _emote_eye_z0: PackedSprite = $"../Neck0/HeadBobber/EmoteEyeZ0"
onready var _emote_eye_z1: PackedSprite = $"../Neck0/HeadBobber/EmoteEyeZ1"
onready var _head_bobber: Sprite = $"../Neck0/HeadBobber"

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		# don't trigger animations in editor
		return
	
	if _creature_visuals.orientation in [CreatureVisuals.SOUTHWEST, CreatureVisuals.SOUTHEAST]:
		if not is_playing():
			play("ambient")
			advance(randf() * current_animation_length)
	if _creature_visuals.orientation in [CreatureVisuals.NORTHWEST, CreatureVisuals.NORTHEAST]:
		if is_playing():
			stop()
			_creature_visuals.reset_eye_frames()


"""
Stops and emits an 'animation_stopped' signal.
"""
func stop(reset: bool = true) -> void:
	var old_anim := current_animation
	.stop(reset)
	emit_signal("animation_stopped", old_anim)


"""
Randomly advances the current animation up to 2.0 seconds. Used to ensure all creatures don't blink synchronously.
"""
func advance_animation_randomly() -> void:
	advance(randf() * 2.0)


"""
Plays an eating animation appropriate to the creature's comfort level.
"""
func eat() -> void:
	# default eating animation
	var emote_anim_name := "eat-again"
	var emote_advance_amount := 0.0
	
	if _creature_visuals.comfort > 0.60:
		# creature is very comfortable (0.6, 1.0]; they have a heart balloon and they're blushing
		emote_anim_name = "eat-smile1"
		
		if current_animation in ["eat-smile1", "eat-again-smile1"]:
			emote_anim_name = "eat-again-smile1"
		elif _emote_eye_z0.frame != 0:
			emote_anim_name = "eat-smile1"
			# Their eyes are already closed, but the heart balloon isn't visible. Advance
			# the animation so the heart balloon pops up, but they don't reopen their eyes
			emote_advance_amount = 0.0667
	elif _creature_visuals.comfort > 0.20:
		# creature is comfortable (0.2, 0.6]; they're smiling and bouncing their head
		emote_anim_name = "eat-smile0"
		
		if _emote_eye_z0.frame != 0:
			emote_anim_name = "eat-again-smile0"
	elif _creature_visuals.comfort > -0.20:
		# creature is so-so (-0.2, 0.2]
		pass
	elif _creature_visuals.comfort > -0.60:
		# creature is uncomfortable (-0.6, -0.2]
		emote_anim_name = "eat-sweat0"
		
		if current_animation in ["eat-sweat0", "eat-again-sweat0"]:
			# wavy lines are already visible; keep them visible
			emote_anim_name = "eat-again-sweat0"
		elif _emote_eye_z0.frame != 0:
			# Their eyes are already closed, but the wavy lines aren't visible. Advance
			# the animation so the wavy lines appear, but they don't reopen their eyes
			emote_advance_amount = 0.0667
		
		# discomfort_amount increases from 0.0 to 1.0 and controls the visual effects
		var discomfort_amount := inverse_lerp(-0.2, -0.6, _creature_visuals.comfort)
		
		# wavy lines become more pronounced
		var brain_color := Utils.to_transparent(Color.white, lerp(0.5, 1.0, discomfort_amount))
		_update_animation_keys("eat-sweat0", "Neck0/HeadBobber/EmoteBrain:modulate", [1, 2], brain_color)
		_update_animation_keys("eat-again-sweat0", "Neck0/HeadBobber/EmoteBrain:modulate", [0, 1], brain_color)
		
		# gradually become bluer and bluer
		var glow_color := Utils.to_transparent(Color("800000bc"), lerp(0.25, 0.50, discomfort_amount))
		_update_animation_keys("eat-sweat0", "Neck0/HeadBobber/EmoteGlow:modulate", [1, 2], glow_color)
		_update_animation_keys("eat-again-sweat0", "Neck0/HeadBobber/EmoteGlow:modulate", [0, 1], glow_color)
	elif _creature_visuals.comfort > -1.00:
		# creature is very uncomfortable (-1.0, -0.6]
		emote_anim_name = "eat-sweat1"
		
		if current_animation in ["eat-sweat1", "eat-again-sweat1", "eat-sweat2", "eat-again-sweat2"]:
			# black glow is already visible; keep it visible
			emote_anim_name = "eat-again-sweat1"
		elif _emote_eye_z0.frame != 0:
			# Their eyes are already closed, but the black glow isn't visible. Advance
			# the animation so the black glow appears, but they don't reopen their eyes
			emote_advance_amount = 0.0667
	else:
		# creature is going to die [-1.0]
		emote_anim_name = "eat-sweat2"
		
		if current_animation in ["eat-sweat1", "eat-again-sweat1", "eat-sweat2", "eat-again-sweat2"]:
			# black glow is already visible; keep it visible
			emote_anim_name = "eat-again-sweat2"
		elif _emote_eye_z0.frame != 0:
			# Their eyes are already closed, but the black glow isn't visible. Advance
			# the animation so the black glow appears, but they don't reopen their eyes
			emote_advance_amount = 0.0667
	
	unemote_immediate()
	play(emote_anim_name)
	if emote_advance_amount > 0:
		advance(emote_advance_amount)


"""
Animates the creature's appearance according to the specified mood: happy, angry, etc...

Parameters:
	'mood': The creature's new mood from ChatEvent.Mood
"""
func emote(mood: int) -> void:
	_mood = mood
	if _prev_mood in EMOTE_ANIMS:
		if TRANSITIONS.has([_prev_mood, mood]):
			# call the custom transition instead of interrupting the animation
			call(TRANSITIONS.get([_prev_mood, mood]))
			stop()
		else:
			# reset to the default mood, and wait for the tween to complete
			unemote()
			yield($ResetTween, "tween_all_completed")
			_post_unemote()
	else:
		# initialize eye frames in case the eyes were previously invisible, such as for north-facing creatures
		_creature_visuals.reset_eye_frames()

	if _mood == mood and mood in EMOTE_ANIMS:
		# we double-check that the mood we were passed is still the current mood. this invariant can be violated
		# if we're called multiple times in quick succession. in those cases, we want the newest mood to 'win'.
		
		play(EMOTE_ANIMS[mood])
		
		if TRANSITIONS.has([_prev_mood, mood]):
			# skip ahead in the animation; we played a custom transition
			advance(0.1)
		_prev_mood = mood


"""
Starts resetting the creature to a default neutral mood.

This does not take place immediately, but fires off a tween. Callers should wait until $ResetTween completes before
updating the creature's appearance.

Parameters:
	'anim_name': (Optional) The animation which was previously playing.
"""
func unemote(anim_name: String = "") -> void:
	stop()
	$"../Neck0/HeadBobber/EmoteArmZ0".frame = 0
	$"../Neck0/HeadBobber/EmoteArmZ1".frame = 0
	$"../NearArm".update_orientation(_creature_visuals.orientation)
	$"../FarArm".update_orientation(_creature_visuals.orientation)
	_emote_eye_z0.frame = 0
	_emote_eye_z1.frame = 0
	if anim_name in EAT_SMILE_ANIMS:
		$"../Neck0/HeadBobber/EyeZ0".frame = 0
		$"../Neck0/HeadBobber/EyeZ1".frame = 0
		_emote_eye_z0.frame = 1
		_emote_eye_z1.frame = 1
		play("ambient-smile")
	elif anim_name in EAT_SWEAT_ANIMS:
		$"../Neck0/HeadBobber/EyeZ0".frame = 0
		$"../Neck0/HeadBobber/EyeZ1".frame = 0
		_emote_eye_z0.frame = 2
		_emote_eye_z1.frame = 2
		play("ambient-sweat")
	
	$ResetTween.remove_all()
	$ResetTween.interpolate_property(_head_bobber, "rotation_degrees",
			_head_bobber.rotation_degrees, 0, UNEMOTE_DURATION)
	for emote_sprite in _emote_sprites:
		$ResetTween.interpolate_property(emote_sprite, "rotation_degrees", emote_sprite.rotation_degrees, 0,
				UNEMOTE_DURATION)
		$ResetTween.interpolate_property(emote_sprite, "modulate", emote_sprite.modulate,
				Utils.to_transparent(emote_sprite.modulate), UNEMOTE_DURATION)
	_head_bobber.reset_head_bob()
	$ResetTween.start()
	_prev_mood = ChatEvent.Mood.DEFAULT


"""
Immediately resets the creature to a default neutral mood.

This takes place immediately, callers do not need to wait for $ResetTween.
"""
func unemote_immediate() -> void:
	stop()
	$"../Neck0/HeadBobber/EmoteArmZ0".frame = 0
	$"../Neck0/HeadBobber/EmoteArmZ1".frame = 0
	$"../NearArm".update_orientation(_creature_visuals.orientation)
	$"../FarArm".update_orientation(_creature_visuals.orientation)
	_emote_eye_z0.frame = 0
	_emote_eye_z1.frame = 0
	_head_bobber.rotation_degrees = 0
	for emote_sprite in _emote_sprites:
		emote_sprite.rotation_degrees = 0
		emote_sprite.modulate = Color.transparent
	_head_bobber.reset_head_bob()
	_prev_mood = ChatEvent.Mood.DEFAULT
	_post_unemote()


"""
Updates the values for a set of animation keys.

Parameters:
	'anim_name': The animation to update
	
	'track_path': The track to update
	
	'key_indexes': The key indexes to update
	
	'value': The new value to set the animation keys to
"""
func _update_animation_keys(anim_name: String, track_path: String, key_indexes: Array, value) -> void:
	var track_index := get_animation(anim_name).find_track(NodePath(track_path))
	if track_index == -1:
		push_warning("Track not found: %s -> %s" % [anim_name, track_path])
		return
	
	for key_index in key_indexes:
		get_animation(anim_name).track_set_key_value(track_index, key_index, value)


"""
Finishes resetting the creature to a default neutral mood.

The tweens reset most of the creature's appearance, but they don't adjust scale or blendmode. This is to avoid a
jarring effect if a speech bubble gradually grows to a large side, or if a creature's pink blush swaps to a neon
green.
"""
func _post_unemote() -> void:
	for emote_sprite in _emote_sprites:
		emote_sprite.scale = Vector2(2.0, 2.0)
		emote_sprite.rotation_degrees = 0.0
		emote_sprite.modulate = Color.transparent
	$"../EmoteBody".scale = Vector2(0.836, 0.836)
	$"../Neck0".scale = Vector2(1.0, 1.0)
	$"../Neck0/HeadBobber/EmoteGlow".material.blend_mode = SpatialMaterial.BLEND_MODE_MIX


"""
Transition function for moods which don't need a transition.
"""
func _transition_noop() -> void:
	pass


"""
Function for transitioning from laugh1 mood to laugh0 mood.
"""
func _transition_laugh1_laugh0() -> void:
	_head_bobber.reset_head_bob()
	$ResetTween.remove_all()
	$ResetTween.interpolate_property($"../Neck0/HeadBobber/EmoteBrain", "modulate",
			$"../Neck0/HeadBobber/EmoteBrain".modulate, Color.transparent, UNEMOTE_DURATION)
	$ResetTween.start()


"""
Function for transitioning from sweat1 mood to sweat0 mood.
"""
func _transition_sweat1_sweat0() -> void:
	_head_bobber.reset_head_bob()
	$"../NearArm".frame = 1
	$ResetTween.remove_all()
	$ResetTween.interpolate_property($"../Neck0/HeadBobber/EmoteHead", "modulate",
			$"../Neck0/HeadBobber/EmoteHead".modulate, Color.transparent, UNEMOTE_DURATION)
	$ResetTween.start()


"""
Function for transitioning from smile1 mood to smile0 mood.
"""
func _transition_smile1_smile0() -> void:
	$ResetTween.remove_all()
	$ResetTween.interpolate_property($"../Neck0/HeadBobber/EmoteBrain", "modulate",
			$"../Neck0/HeadBobber/EmoteBrain".modulate, Color("008c2261"), UNEMOTE_DURATION)
	$ResetTween.interpolate_property($"../Neck0/HeadBobber/EmoteGlow", "modulate",
			$"../Neck0/HeadBobber/EmoteGlow".modulate, Color("008c2261"), UNEMOTE_DURATION)
	$ResetTween.interpolate_property(_head_bobber, "rotation_degrees",
			_head_bobber.rotation_degrees, 0.0, UNEMOTE_DURATION)
	$ResetTween.start()


"""
This function manually assigns fields which Godot would ideally assign automatically by calling _ready. It is a
workaround for Godot issue #16974 (https://github.com/godotengine/godot/issues/16974)

Tool scripts do not call _ready on reload, which means all onready fields will be null. This breaks this script's
functionality and throws errors when it is used as a tool. This function manually assigns those fields to avoid those
problems.
"""
func _apply_tool_script_workaround() -> void:
	if not _creature_visuals:
		_creature_visuals = get_parent()


func _on_animation_finished(anim_name: String) -> void:
	if _prev_mood in EMOTE_ANIMS or anim_name in EAT_SMILE_ANIMS or anim_name in EAT_SWEAT_ANIMS:
		unemote(anim_name)
		yield($ResetTween, "tween_all_completed")
		_post_unemote()


func _on_IdleTimer_start_idle_animation(anim_name: String) -> void:
	if is_processing() and anim_name in get_animation_list():
		play(anim_name)


func _on_CreatureVisuals_orientation_changed(_old_orientation: int, new_orientation: int) -> void:
	if is_processing() and not new_orientation in [CreatureVisuals.SOUTHWEST, CreatureVisuals.SOUTHEAST]:
		unemote_immediate()
