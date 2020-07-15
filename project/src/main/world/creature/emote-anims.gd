#tool #uncomment to view creature in editor
extends AnimationPlayer
"""
Script for AnimationPlayers which animate moods: blinking, smiling, sweating, etc.
"""

# fired before we switch to a new mood; arms/legs/etc should be reset to default
signal before_mood_switched

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

# custom transition for cases where the default mood transition looks awkward
const TRANSITIONS := {
	[ChatEvent.Mood.LAUGH0, ChatEvent.Mood.LAUGH1]: "_transition_noop",
	[ChatEvent.Mood.LAUGH1, ChatEvent.Mood.LAUGH0]: "_transition_laugh1_laugh0",
	[ChatEvent.Mood.SWEAT0, ChatEvent.Mood.SWEAT1]: "_transition_noop",
	[ChatEvent.Mood.SWEAT1, ChatEvent.Mood.SWEAT0]: "_transition_sweat1_sweat0",
	[ChatEvent.Mood.SMILE0, ChatEvent.Mood.SMILE1]: "_transition_noop",
	[ChatEvent.Mood.SMILE1, ChatEvent.Mood.SMILE0]: "_transition_smile1_smile0",
}

# Time spent resetting to a neutral emotion: fading out speech bubbles, untilting the head, etc...
const UNEMOTE_DURATION := 0.08

onready var _creature_visuals: CreatureVisuals = $".."

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

func _process(_delta: float) -> void:
	if not Engine.is_editor_hint():
		if _creature_visuals.orientation in [CreatureVisuals.SOUTHWEST, CreatureVisuals.SOUTHEAST]:
			if not is_playing():
				play("ambient")
				advance(randf() * current_animation_length)
		else:
			if is_playing():
				stop()
			_creature_visuals.reset_eye_frames()


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
	
	if _creature_visuals.comfort > 0.5:
		# creature is very comfortable; they have a heart balloon and they're blushing
		emote_anim_name = "eat-smile1"
		
		if current_animation in ["eat-smile1", "eat-again-smile1"]:
			emote_anim_name = "eat-again-smile1"
		elif current_animation in ["eat-smile0", "eat-again-smile0"]:
			emote_anim_name = "eat-smile1"
			# Their eyes are already closed, but the heart balloon isn't visible. Advance
			# the animation so the heart balloon pops up, but they don't reopen their eyes
			emote_advance_amount = 0.0667
	elif _creature_visuals.comfort > 0.0:
		# creature is comfortable; they're smiling and bouncing their head
		emote_anim_name = "eat-smile0"
		
		if current_animation in ["eat-smile0", "eat-again-smile0", "eat-smile1", "eat-again-smile1"]:
			emote_anim_name = "eat-again-smile0"
	
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
	if _prev_mood in EMOTE_ANIMS.keys():
		if TRANSITIONS.has([_prev_mood, mood]):
			# call the custom transition instead of interrupting the animation
			call(TRANSITIONS.get([_prev_mood, mood]))
		else:
			# reset to the default mood, and wait for the tween to complete
			unemote()
			yield($ResetTween, "tween_all_completed")
			_post_unemote()
	
	if _mood == mood and mood in EMOTE_ANIMS.keys():
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
"""
func unemote() -> void:
	stop()
	emit_signal("before_mood_switched")
	$"../Neck0/HeadBobber/EmoteArms".frame = 0
	$"../Neck0/HeadBobber/EmoteEyes".frame = 0
	
	$ResetTween.remove_all()
	$ResetTween.interpolate_property($"../Neck0/HeadBobber", "rotation_degrees",
			$"../Neck0/HeadBobber".rotation_degrees, 0, UNEMOTE_DURATION)
	for emote_sprite in _emote_sprites:
		$ResetTween.interpolate_property(emote_sprite, "rotation_degrees", emote_sprite.rotation_degrees, 0,
				UNEMOTE_DURATION)
		$ResetTween.interpolate_property(emote_sprite, "modulate", emote_sprite.modulate,
				Utils.to_transparent(emote_sprite.modulate), UNEMOTE_DURATION)
	$"../Neck0/HeadBobber".reset_head_bob()
	$ResetTween.start()
	_prev_mood = ChatEvent.Mood.DEFAULT


"""
Immediately resets the creature to a default neutral mood.

This takes place immediately, callers do not need to wait for $ResetTween.
"""
func unemote_immediate() -> void:
	stop()
	emit_signal("before_mood_switched")
	$"../Neck0/HeadBobber/EmoteArms".frame = 0
	$"../Neck0/HeadBobber/EmoteEyes".frame = 0
	$"../Neck0/HeadBobber".rotation_degrees = 0
	for emote_sprite in _emote_sprites:
		emote_sprite.rotation_degrees = 0
		emote_sprite.modulate = Color.transparent
	$"../Neck0/HeadBobber".reset_head_bob()
	_prev_mood = ChatEvent.Mood.DEFAULT
	_post_unemote()


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
	$"../Neck0/HeadBobber".reset_head_bob()
	$ResetTween.remove_all()
	$ResetTween.interpolate_property($"../Neck0/HeadBobber/EmoteBrain", "modulate",
			$"../Neck0/HeadBobber/EmoteBrain".modulate, Color.transparent, UNEMOTE_DURATION)
	$ResetTween.start()


"""
Function for transitioning from sweat1 mood to sweat0 mood.
"""
func _transition_sweat1_sweat0() -> void:
	$"../Neck0/HeadBobber".reset_head_bob()
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
	$ResetTween.interpolate_property($"../Neck0/HeadBobber", "rotation_degrees",
			$"../Neck0/HeadBobber".rotation_degrees, 0.0, UNEMOTE_DURATION)
	$ResetTween.start()


"""
Updates the mouth and eye frames to an appropriate frame for the creature's orientation.

Usually the mouth and eyes are controlled by an animation. But when they're not, this method ensures they still look
reasonable.
"""
func _apply_default_eye_frames() -> void:
	if Engine.is_editor_hint():
		_apply_tool_script_workaround()
	_creature_visuals.reset_eye_frames()


"""
This function manually assigns fields which Godot would ideally assign automatically by calling _ready. It is a
workaround for Godot issue #16974 (https://github.com/godotengine/godot/issues/16974)

Tool scripts do not call _ready on reload, which means all onready fields will be null. This breaks this script's
functionality and throws errors when it is used as a tool. This function manually assigns those fields to avoid those
problems.
"""
func _apply_tool_script_workaround() -> void:
	if not _creature_visuals:
		_creature_visuals = $".."


func _on_animation_finished(anim_name: String) -> void:
	if _prev_mood in EMOTE_ANIMS.keys() \
			or anim_name in ["eat-smile0", "eat-again-smile0", "eat-smile1", "eat-again-smile1"]:
		unemote()
		yield($ResetTween, "tween_all_completed")
		_post_unemote()


"""
Reset the eye frame when loading a new creature appearance.

If we don't reset the eye frame, we have one strange transition frame.
"""
func _on_CreatureVisuals_before_creature_arrived() -> void:
	_apply_default_eye_frames()
