# uncomment to view creature in editor
#tool
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

export (NodePath) var eyes_path: NodePath

onready var _eyes: PackedSprite = get_node(eyes_path)
onready var _creature: Creature = $".."

# stores the previous mood so that we can apply mood transitions.
var _prev_mood: int

# stores the current mood. used to prevent sync issues when changing moods faster than 80 milliseconds.
var _mood: int

# list of sprites to reset when unemoting
onready var _emote_sprites := [
	$"../Sprites/Neck0/HeadBobber/EmoteBrain",
	$"../Sprites/Neck0/HeadBobber/EmoteHead",
	$"../Sprites/EmoteBody",
	$"../Sprites/Neck0/HeadBobber/EmoteGlow",
]

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		# avoid playing animations in editor. manually set frames instead
		_apply_default_eye_frames()
	
	if not Engine.is_editor_hint():
		if _creature.orientation in [Creature.SOUTHWEST, Creature.SOUTHEAST]:
			if not is_playing():
				play("ambient")
				advance(randf() * current_animation_length)
		else:
			if is_playing():
				stop()
			_eyes.json_frame = 0


"""
Randomly advances the current animation up to 2.0 seconds. Used to ensure all creatures don't blink synchronously.
"""
func advance_animation_randomly() -> void:
	advance(randf() * 2.0)


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
	$"../Sprites/Neck0/HeadBobber/EmoteArms".frame = 0
	$"../Sprites/Neck0/HeadBobber/EmoteEyes".frame = 0
	
	$ResetTween.remove_all()
	$ResetTween.interpolate_property($"../Sprites/Neck0/HeadBobber", "rotation_degrees",
			$"../Sprites/Neck0/HeadBobber".rotation_degrees, 0, UNEMOTE_DURATION)
	for emote_sprite in _emote_sprites:
		$ResetTween.interpolate_property(emote_sprite, "rotation_degrees", emote_sprite.rotation_degrees, 0,
				UNEMOTE_DURATION)
		$ResetTween.interpolate_property(emote_sprite, "modulate", emote_sprite.modulate,
				Utils.to_transparent(emote_sprite.modulate), UNEMOTE_DURATION)
	$"../Sprites/Neck0/HeadBobber".head_bob_mode = HeadBobber.BOB_BOB
	$"../Sprites/Neck0/HeadBobber".head_motion_pixels = HeadBobber.HEAD_BOB_PIXELS
	$"../Sprites/Neck0/HeadBobber".head_motion_seconds = HeadBobber.HEAD_BOB_SECONDS
	$ResetTween.start()
	_prev_mood = ChatEvent.Mood.DEFAULT


"""
Immediately resets the creature to a default neutral mood.

This takes place immediately, callers do not need to wait for $ResetTween.
"""
func unemote_immediate() -> void:
	stop()
	emit_signal("before_mood_switched")
	$"../Sprites/Neck0/HeadBobber/EmoteArms".frame = 0
	$"../Sprites/Neck0/HeadBobber/EmoteEyes".frame = 0
	$"../Sprites/Neck0/HeadBobber".rotation_degrees = 0
	for emote_sprite in _emote_sprites:
		emote_sprite.rotation_degrees = 0
		emote_sprite.modulate = Color.transparent
	$"../Sprites/Neck0/HeadBobber".head_bob_mode = HeadBobber.BOB_BOB
	$"../Sprites/Neck0/HeadBobber".head_motion_pixels = HeadBobber.HEAD_BOB_PIXELS
	$"../Sprites/Neck0/HeadBobber".head_motion_seconds = HeadBobber.HEAD_BOB_SECONDS
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
		emote_sprite.scale = Vector2(1.0, 1.0)
		emote_sprite.rotation_degrees = 0.0
		emote_sprite.modulate = Color.transparent
	$"../Sprites/EmoteBody".scale = Vector2(0.418, 0.418)
	$"../Sprites/Neck0/HeadBobber/EmoteGlow".material.blend_mode = SpatialMaterial.BLEND_MODE_MIX


"""
Transition function for moods which don't need a transition.
"""
func _transition_noop() -> void:
	pass


"""
Function for transitioning from laugh1 mood to laugh0 mood.
"""
func _transition_laugh1_laugh0() -> void:
	var emote_sprite := $"../Sprites/Neck0/HeadBobber/EmoteBrain"
	$"../Sprites/Neck0/HeadBobber".head_bob_mode = HeadBobber.BOB_BOB
	$ResetTween.remove_all()
	$ResetTween.interpolate_property(emote_sprite, "modulate", emote_sprite.modulate, Color.transparent,
			UNEMOTE_DURATION)
	$ResetTween.start()


"""
Function for transitioning from sweat1 mood to sweat0 mood.
"""
func _transition_sweat1_sweat0() -> void:
	$"../Sprites/NearArm".frame = 1
	var emote_sprite := $"../Sprites/Neck0/HeadBobber/EmoteHead"
	$ResetTween.remove_all()
	$ResetTween.interpolate_property(emote_sprite, "modulate", emote_sprite.modulate, Color.transparent,
			UNEMOTE_DURATION)
	$ResetTween.start()


"""
Function for transitioning from smile1 mood to smile0 mood.
"""
func _transition_smile1_smile0() -> void:
	$ResetTween.remove_all()
	for emote_sprite in [$"../Sprites/Neck0/HeadBobber/EmoteBrain", $"../Sprites/Neck0/HeadBobber/EmoteGlow"]:
		$ResetTween.interpolate_property(emote_sprite, "modulate", emote_sprite.modulate, Color("008c2261"),
				UNEMOTE_DURATION)
	$ResetTween.interpolate_property($"../Sprites/Neck0/HeadBobber", "rotation_degrees",
			$"../Sprites/Neck0/HeadBobber".rotation_degrees, 0.0, UNEMOTE_DURATION)
	$ResetTween.start()


"""
Updates the mouth and eye frames to an appropriate frame for the creature's orientation.

Usually the mouth and eyes are controlled by an animation. But when they're not, this method ensures they still look
reasonable.
"""
func _apply_default_eye_frames() -> void:
	if Engine.is_editor_hint():
		_apply_tool_script_workaround()
	if _creature.orientation in [Creature.SOUTHWEST, Creature.SOUTHEAST]:
		_eyes.json_frame = 1
	else:
		_eyes.json_frame = 0


"""
This function manually assigns fields which Godot would ideally assign automatically by calling _ready. It is a
workaround for Godot issue #16974 (https://github.com/godotengine/godot/issues/16974)

Tool scripts do not call _ready on reload, which means all onready fields will be null. This breaks this script's
functionality and throws errors when it is used as a tool. This function manually assigns those fields to avoid those
problems.
"""
func _apply_tool_script_workaround() -> void:
	if not _creature:
		_eyes = get_node(eyes_path)
		_creature = $".."


func _on_animation_finished(anim_name) -> void:
	if _prev_mood in EMOTE_ANIMS.keys():
		unemote()
		yield($ResetTween, "tween_all_completed")
		_post_unemote()


"""
Reset the eye frame when loading a new creature appearance.

If we don't reset the eye frame, we have one strange transition frame.
"""
func _on_Creature_before_creature_arrived() -> void:
	_apply_default_eye_frames()
