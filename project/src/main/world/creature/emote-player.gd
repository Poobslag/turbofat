#tool #uncomment to view creature in editor
extends AnimationPlayer
## Script for AnimationPlayers which animate moods: blinking, smiling, sweating, etc.

signal animation_stopped

## mapping from moods to animation names
const EMOTE_ANIMS := {
	Creatures.Mood.AWKWARD0: "awkward0",
	Creatures.Mood.AWKWARD1: "awkward1",
	Creatures.Mood.CRY0: "cry0",
	Creatures.Mood.CRY1: "cry1",
	Creatures.Mood.LAUGH0: "laugh0",
	Creatures.Mood.LAUGH1: "laugh1",
	Creatures.Mood.LOVE0: "love0",
	Creatures.Mood.LOVE1: "love1",
	Creatures.Mood.LOVE1_FOREVER: "love1...",
	Creatures.Mood.NO0: "no0",
	Creatures.Mood.NO1: "no1",
	Creatures.Mood.RAGE0: "rage0",
	Creatures.Mood.RAGE1: "rage1",
	Creatures.Mood.RAGE2: "rage2",
	Creatures.Mood.SIGH0: "sigh0",
	Creatures.Mood.SIGH1: "sigh1",
	Creatures.Mood.SMILE0: "smile0",
	Creatures.Mood.SMILE1: "smile1",
	Creatures.Mood.SWEAT0: "sweat0",
	Creatures.Mood.SWEAT1: "sweat1",
	Creatures.Mood.THINK0: "think0",
	Creatures.Mood.THINK1: "think1",
	Creatures.Mood.WAVE0: "wave0",
	Creatures.Mood.WAVE1: "wave1",
	Creatures.Mood.YES0: "yes0",
	Creatures.Mood.YES1: "yes1",
}

## animation names for eating while smiling; referenced for animation transitions
const EAT_SMILE_ANIMS := {
	"eat-smile0": "_",
	"eat-again-smile0": "_",
	"eat-smile1": "_",
	"eat-again-smile1": "_",
}

## animation names for eating while sweating; referenced for animation transitions
const EAT_SWEAT_ANIMS := {
	"eat-sweat0": "_",
	"eat-again-sweat0": "_",
	"eat-sweat1": "_",
	"eat-again-sweat1": "_",
	"eat-sweat2": "_",
	"eat-again-sweat2": "_"
}

## custom transition for cases where the default mood transition looks awkward
const TRANSITIONS := {
	[Creatures.Mood.AWKWARD0, Creatures.Mood.AWKWARD0]: "_transition_noop",
	[Creatures.Mood.AWKWARD0, Creatures.Mood.AWKWARD1]: "_transition_noop",
	[Creatures.Mood.AWKWARD1, Creatures.Mood.AWKWARD0]: "_transition_awkward1_awkward0",
	[Creatures.Mood.AWKWARD1, Creatures.Mood.AWKWARD1]: "_transition_noop",
	[Creatures.Mood.CRY0, Creatures.Mood.CRY0]: "_transition_noop",
	[Creatures.Mood.CRY1, Creatures.Mood.CRY1]: "_transition_noop",
	[Creatures.Mood.LAUGH0, Creatures.Mood.LAUGH0]: "_transition_noop",
	[Creatures.Mood.LAUGH0, Creatures.Mood.LAUGH1]: "_transition_noop",
	[Creatures.Mood.LAUGH1, Creatures.Mood.LAUGH0]: "_transition_laugh1_laugh0",
	[Creatures.Mood.LAUGH1, Creatures.Mood.LAUGH1]: "_transition_noop",
	[Creatures.Mood.LOVE0, Creatures.Mood.LOVE0]: "_transition_noop",
	[Creatures.Mood.LOVE0, Creatures.Mood.LOVE1]: "_transition_noop",
	[Creatures.Mood.LOVE0, Creatures.Mood.LOVE1_FOREVER]: "_transition_noop",
	[Creatures.Mood.LOVE1, Creatures.Mood.LOVE0]: "_transition_love1_love0",
	[Creatures.Mood.LOVE1, Creatures.Mood.LOVE1]: "_transition_noop",
	[Creatures.Mood.LOVE1, Creatures.Mood.LOVE1_FOREVER]: "_transition_noop",
	[Creatures.Mood.LOVE1_FOREVER, Creatures.Mood.LOVE0]: "_transition_love1_love0",
	[Creatures.Mood.LOVE1_FOREVER, Creatures.Mood.LOVE1]: "_transition_noop",
	[Creatures.Mood.LOVE1_FOREVER, Creatures.Mood.LOVE1_FOREVER]: "_transition_noop",
	[Creatures.Mood.NO0, Creatures.Mood.NO0]: "_transition_noop",
	[Creatures.Mood.NO0, Creatures.Mood.NO1]: "_transition_noop",
	[Creatures.Mood.NO1, Creatures.Mood.NO0]: "_transition_noop",
	[Creatures.Mood.NO1, Creatures.Mood.NO1]: "_transition_noop",
	[Creatures.Mood.RAGE0, Creatures.Mood.RAGE0]: "_transition_noop",
	[Creatures.Mood.RAGE0, Creatures.Mood.RAGE1]: "_transition_noop",
	[Creatures.Mood.RAGE1, Creatures.Mood.RAGE0]: "_transition_rage1_rage0",
	[Creatures.Mood.RAGE1, Creatures.Mood.RAGE1]: "_transition_noop",
	[Creatures.Mood.RAGE2, Creatures.Mood.RAGE2]: "_transition_noop",
	[Creatures.Mood.SIGH0, Creatures.Mood.SIGH0]: "_transition_noop",
	[Creatures.Mood.SIGH0, Creatures.Mood.SIGH1]: "_transition_noop",
	[Creatures.Mood.SIGH1, Creatures.Mood.SIGH0]: "_transition_sigh1_sigh0",
	[Creatures.Mood.SIGH1, Creatures.Mood.SIGH1]: "_transition_noop",
	[Creatures.Mood.SMILE0, Creatures.Mood.SMILE0]: "_transition_noop",
	[Creatures.Mood.SMILE0, Creatures.Mood.SMILE1]: "_transition_noop",
	[Creatures.Mood.SMILE1, Creatures.Mood.SMILE0]: "_transition_smile1_smile0",
	[Creatures.Mood.SMILE1, Creatures.Mood.SMILE1]: "_transition_noop",
	[Creatures.Mood.SWEAT0, Creatures.Mood.SWEAT0]: "_transition_noop",
	[Creatures.Mood.SWEAT0, Creatures.Mood.SWEAT1]: "_transition_noop",
	[Creatures.Mood.SWEAT1, Creatures.Mood.SWEAT0]: "_transition_sweat1_sweat0",
	[Creatures.Mood.SWEAT1, Creatures.Mood.SWEAT1]: "_transition_noop",
	[Creatures.Mood.THINK0, Creatures.Mood.THINK0]: "_transition_noop",
	[Creatures.Mood.THINK1, Creatures.Mood.THINK1]: "_transition_noop",
	[Creatures.Mood.WAVE0, Creatures.Mood.WAVE0]: "_transition_noop",
	[Creatures.Mood.WAVE0, Creatures.Mood.WAVE1]: "_transition_noop",
	[Creatures.Mood.WAVE1, Creatures.Mood.WAVE0]: "_transition_noop",
	[Creatures.Mood.WAVE1, Creatures.Mood.WAVE1]: "_transition_noop",
	[Creatures.Mood.YES0, Creatures.Mood.YES0]: "_transition_noop",
	[Creatures.Mood.YES0, Creatures.Mood.YES1]: "_transition_noop",
	[Creatures.Mood.YES1, Creatures.Mood.YES0]: "_transition_noop",
	[Creatures.Mood.YES1, Creatures.Mood.YES1]: "_transition_noop",
}

## Time spent resetting to a neutral emotion: fading out speech bubbles, untilting the head, etc...
const UNEMOTE_DURATION := 0.08

## volume to fade sfx out to
const MIN_VOLUME := -40.0

## volume to fade sfx in to
const MAX_VOLUME := 0.0

const FADE_SFX_DURATION := 0.08

export (NodePath) var creature_visuals_path: NodePath setget set_creature_visuals_path

## stores the previous mood so that we can apply mood transitions.
var _prev_mood: int

## stores the current mood. used to prevent sync issues when changing moods faster than 80 milliseconds.
var _mood: int

var _creature_visuals: CreatureVisuals

## specific sprites manipulated frequently when emoting
var _emote_eye_z0: PackedSprite
var _emote_eye_z1: PackedSprite
var _head_bobber: Sprite

## list of sprites to reset when unemoting
var _emote_sprites: Array

onready var _emote_sfx := $EmoteSfx
onready var _reset_tween := $ResetTween
onready var _volume_db_tween := $VolumeDbTween

func _ready() -> void:
	_refresh_creature_visuals_path()


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		# don't trigger animations in editor
		return
	
	if _creature_visuals.oriented_south():
		if not is_playing():
			play("ambient")
			advance(randf() * current_animation_length)
	if _creature_visuals.oriented_north():
		if is_playing():
			stop()
			_creature_visuals.reset_eye_frames()


## Unmutes all mood-related sound effects for this creature.
func fade_in_sfx() -> void:
	_tween_sfx_volume(MAX_VOLUME)


## Mutes all mood-related sound effects for this creature.
func fade_out_sfx() -> void:
	_tween_sfx_volume(MIN_VOLUME)


func set_creature_visuals_path(new_creature_visuals_path: NodePath) -> void:
	creature_visuals_path = new_creature_visuals_path
	_refresh_creature_visuals_path()


## Stops and emits an 'animation_stopped' signal.
func stop(reset: bool = true) -> void:
	var old_anim := current_animation
	.stop(reset)
	emit_signal("animation_stopped", old_anim)


## Randomly advances the current animation up to 2.0 seconds. Used to ensure all creatures don't blink synchronously.
func advance_animation_randomly() -> void:
	advance(randf() * 2.0)


## Plays an eating animation appropriate to the creature's comfort level.
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
	elif emote_anim_name.begins_with("eat-again"):
		# immediately update the animation to ensure the creature's eyes stay closed
		advance(0.00001)


## Animates the creature's appearance according to the specified mood: happy, angry, etc...
##
## Parameters:
## 	'mood': The creature's new mood from Creatures.Mood
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
			yield(_reset_tween, "tween_all_completed")
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


## Starts resetting the creature to a default neutral mood.
##
## This does not take place immediately, but fires off a tween. Callers should wait until $ResetTween completes before
## updating the creature's appearance.
##
## Parameters:
## 	'anim_name': (Optional) The animation which was previously playing.
func unemote(anim_name: String = "") -> void:
	stop()
	_unemote_non_tweened_properties()
	if anim_name in EAT_SMILE_ANIMS:
		_creature_visuals.get_node("Neck0/HeadBobber/EyeZ0").frame = 0
		_creature_visuals.get_node("Neck0/HeadBobber/EyeZ1").frame = 0
		_emote_eye_z0.frame = 1
		_emote_eye_z1.frame = 1
		play("ambient-smile")
	elif anim_name in EAT_SWEAT_ANIMS:
		_creature_visuals.get_node("Neck0/HeadBobber/EyeZ0").frame = 0
		_creature_visuals.get_node("Neck0/HeadBobber/EyeZ1").frame = 0
		_emote_eye_z0.frame = 2
		_emote_eye_z1.frame = 2
		play("ambient-sweat")
	
	_reset_tween.remove_all()
	_reset_tween.interpolate_property(_head_bobber, "rotation_degrees",
			_head_bobber.rotation_degrees, 0, UNEMOTE_DURATION)
	for emote_sprite in _emote_sprites:
		_reset_tween.interpolate_property(emote_sprite, "rotation_degrees", emote_sprite.rotation_degrees, 0,
				UNEMOTE_DURATION)
		_reset_tween.interpolate_property(emote_sprite, "modulate", emote_sprite.modulate,
				Utils.to_transparent(emote_sprite.modulate), UNEMOTE_DURATION)
	for eye_sprite in [_emote_eye_z0, _emote_eye_z1]:
		# some animations like the 'love' animation change the emote eye scale
		_reset_tween.interpolate_property(eye_sprite, "scale", eye_sprite.scale, Vector2(2.0, 2.0),
				UNEMOTE_DURATION)
	
	_head_bobber.reset_head_bob()
	_reset_tween.start()
	_prev_mood = Creatures.Mood.DEFAULT


## Adjusts the volume for all mood-related sound effects for this creature.
func _tween_sfx_volume(new_value: float) -> void:
	_volume_db_tween.remove_all()
	_volume_db_tween.interpolate_property(_emote_sfx, "volume_db", _emote_sfx.volume_db, new_value, FADE_SFX_DURATION)
	_volume_db_tween.start()


## Resets the position and rotation of nodes which shift around during emotes.
##
## This only includes 'non-tweened properties'; properties which snap back to their starting value without being
## tweened into place.
func _unemote_non_tweened_properties() -> void:
	# unflip the creature's head; the scale itself can be tweened later
	_creature_visuals.get_node("Neck0").scale = \
			Vector2(abs(_creature_visuals.get_node("Neck0").scale.x),
			abs(_creature_visuals.get_node("Neck0").scale.y))
	_creature_visuals.get_node("Neck0/HeadBobber/EmoteArmZ0").frame = 0
	_creature_visuals.get_node("Neck0/HeadBobber/EmoteArmZ1").frame = 0
	_creature_visuals.get_node("NearArm").update_orientation(_creature_visuals.orientation)
	_creature_visuals.get_node("NearArm").z_index = 0
	_creature_visuals.get_node("FarArm").update_orientation(_creature_visuals.orientation)
	for eye_sprite in [_emote_eye_z0, _emote_eye_z1]:
		eye_sprite.scale = Vector2(2, 2)
		eye_sprite.frame = 0
		eye_sprite.rotation_degrees = 0
		eye_sprite.position = Vector2(0, 256)


## Immediately resets the creature to a default neutral mood.
##
## This takes place immediately, callers do not need to wait for $ResetTween.
func unemote_immediate() -> void:
	stop()
	_unemote_non_tweened_properties()
	_creature_visuals.reset_eye_frames()
	_head_bobber.rotation_degrees = 0
	for emote_sprite in _emote_sprites:
		emote_sprite.rotation_degrees = 0
		emote_sprite.modulate = Color.transparent
	_head_bobber.reset_head_bob()
	_prev_mood = Creatures.Mood.DEFAULT
	_post_unemote()


## Updates the values for a set of animation keys.
##
## Parameters:
## 	'anim_name': The animation to update
##
## 	'track_path': The track to update
##
## 	'key_indexes': The key indexes to update
##
## 	'value': The new value to set the animation keys to
func _update_animation_keys(anim_name: String, track_path: String, key_indexes: Array, value) -> void:
	var track_index := get_animation(anim_name).find_track(NodePath(track_path))
	if track_index == -1:
		push_warning("Track not found: %s -> %s" % [anim_name, track_path])
		return
	
	for key_index in key_indexes:
		get_animation(anim_name).track_set_key_value(track_index, key_index, value)


## Finishes resetting the creature to a default neutral mood.
##
## The tweens reset most of the creature's appearance, but they don't adjust scale or blendmode. This is to avoid a
## jarring effect if a speech bubble gradually grows to a large side, or if a creature's pink blush swaps to a neon
## green.
func _post_unemote() -> void:
	for emote_sprite in _emote_sprites:
		emote_sprite.frame = 0
		emote_sprite.modulate = Color.transparent
		emote_sprite.rotation_degrees = 0.0
		emote_sprite.scale = Vector2(2.0, 2.0)
		emote_sprite.position = Vector2.ZERO
		if emote_sprite.material:
			if emote_sprite.material.get("blend_mode"):
				emote_sprite.material.blend_mode = SpatialMaterial.BLEND_MODE_MIX
			if emote_sprite.material.has_method("set_shader_param") and Engine.is_editor_hint():
				# In the editor, we reset shader parameters to known values to avoid unnecessary churn in our scene
				# files. At runtime, this behavior would be destructive since some of these values are only
				# initialized when the creature is first loaded.
				emote_sprite.material.set_shader_param("red", Color.black)
				emote_sprite.material.set_shader_param("green", Color.black)
				emote_sprite.material.set_shader_param("blue", Color.black)
				emote_sprite.material.set_shader_param("black", Color.black)
	_creature_visuals.get_node("Neck0/HeadBobber/EmoteBrain").material.set_shader_param("red", Color.white)
	_creature_visuals.get_node("EmoteBody").scale = Vector2(0.836, 0.836)
	_creature_visuals.get_node("Neck0/HeadBobber/EmoteHead").position = Vector2( 0, 256 )
	_creature_visuals.get_node("Neck0").scale = Vector2(1.0, 1.0)


## Transition function for moods which don't need a transition.
func _transition_noop() -> void:
	pass


## Transitions from 'awkward1' to 'awkward0', hiding the white sweat circles.
func _transition_awkward1_awkward0() -> void:
	_creature_visuals.get_node("Neck0").scale = Vector2(1.0, 1.0)
	_reset_tween.remove_all()
	_tween_nodes_to_transparent(["Neck0/HeadBobber/EmoteHead"])
	_reset_tween.start()


## Transitions from 'laugh1' to 'laugh0', hiding the yellow laugh lines.
func _transition_laugh1_laugh0() -> void:
	_head_bobber.reset_head_bob()
	_reset_tween.remove_all()
	_tween_nodes_to_transparent(["Neck0/HeadBobber/EmoteBrain"])
	_reset_tween.start()


## Transitions from 'love1' to 'love0', hiding the hearts and blush.
func _transition_love1_love0() -> void:
	for eye_sprite in [_emote_eye_z0, _emote_eye_z1]:
		eye_sprite.rotation_degrees = 0
		eye_sprite.position = Vector2(0, 256)
	_reset_tween.remove_all()
	_tween_nodes_to_transparent(["Neck0/HeadBobber/EmoteBrain", "Neck0/HeadBobber/EmoteGlow"])
	_reset_tween.start()


## Transitions from 'rage1' to 'rage0', hiding the red anger symbols.
func _transition_rage1_rage0() -> void:
	_head_bobber.reset_head_bob()
	_reset_tween.remove_all()
	_tween_nodes_to_transparent(["Neck0/HeadBobber/EmoteBrain", "Neck0/HeadBobber/EmoteGlow"])
	_reset_tween.start()


## Transitions from 'sigh1' to 'sigh0', turning the head forward again
func _transition_sigh1_sigh0() -> void:
	_creature_visuals.get_node("Neck0").scale = Vector2(1.0, 1.0)
	_reset_tween.remove_all()
	_reset_tween.interpolate_property(_head_bobber, "rotation_degrees",
			_head_bobber.rotation_degrees, 0.0, UNEMOTE_DURATION)
	_reset_tween.start()


## Transitions from 'smile1' to 'smile0', hiding the pink love bubble and blush.
func _transition_smile1_smile0() -> void:
	_reset_tween.remove_all()
	_tween_nodes_to_transparent(["Neck0/HeadBobber/EmoteBrain", "Neck0/HeadBobber/EmoteGlow"])
	_reset_tween.interpolate_property(_head_bobber, "rotation_degrees",
			_head_bobber.rotation_degrees, 0.0, UNEMOTE_DURATION)
	_reset_tween.start()


## Transitions from 'sweat1' to 'sweat0', hiding the white sweat circles.
func _transition_sweat1_sweat0() -> void:
	_head_bobber.reset_head_bob()
	_creature_visuals.get_node("NearArm").frame = 1
	_reset_tween.remove_all()
	_tween_nodes_to_transparent(["Neck0/HeadBobber/EmoteHead"])
	_reset_tween.start()


func _tween_nodes_to_transparent(paths: Array) -> void:
	for path in paths:
		var node: Node2D = _creature_visuals.get_node(path)
		_reset_tween.interpolate_property(node, "modulate", node.modulate, Color.transparent, UNEMOTE_DURATION)


## This function manually assigns fields which Godot would ideally assign automatically by calling _ready. It is a
## workaround for Godot issue #16974 (https://github.com/godotengine/godot/issues/16974)
##
## Tool scripts do not call _ready on reload, which means all onready fields will be null. This breaks this script's
## functionality and throws errors when it is used as a tool. This function manually assigns those fields to avoid
## those problems.
func _apply_tool_script_workaround() -> void:
	if not _creature_visuals:
		_creature_visuals = get_parent()


func _refresh_creature_visuals_path() -> void:
	if not (is_inside_tree() and creature_visuals_path):
		return
	
	if _creature_visuals:
		_creature_visuals.disconnect("orientation_changed", self, "_on_CreatureVisuals_orientation_changed")
	
	root_node = creature_visuals_path
	_creature_visuals = get_node(creature_visuals_path)
	
	_creature_visuals.connect("orientation_changed", self, "_on_CreatureVisuals_orientation_changed")
	_emote_eye_z0 = _creature_visuals.get_node("Neck0/HeadBobber/EmoteEyeZ0")
	_emote_eye_z1 = _creature_visuals.get_node("Neck0/HeadBobber/EmoteEyeZ1")
	_head_bobber = _creature_visuals.get_node("Neck0/HeadBobber")
	_emote_sprites = [
		_creature_visuals.get_node("Neck0/HeadBobber/EmoteBrain"),
		_creature_visuals.get_node("Neck0/HeadBobber/EmoteHead"),
		_creature_visuals.get_node("EmoteBody"),
		_creature_visuals.get_node("Neck0/HeadBobber/EmoteGlow"),
	]

func _on_animation_finished(anim_name: String) -> void:
	if anim_name.ends_with("..."):
		# endless animation; merge it into the looping version
		play("...%s..." % [anim_name.trim_suffix("...")])
	elif _prev_mood in EMOTE_ANIMS or anim_name in EAT_SMILE_ANIMS or anim_name in EAT_SWEAT_ANIMS:
		unemote(anim_name)
		yield(_reset_tween, "tween_all_completed")
		_post_unemote()


func _on_IdleTimer_idle_animation_started(anim_name: String) -> void:
	if is_processing() and anim_name in get_animation_list():
		unemote_immediate()
		play(anim_name)


func _on_CreatureVisuals_orientation_changed(_old_orientation: int, new_orientation: int) -> void:
	if is_processing() and not Creatures.oriented_south(new_orientation):
		unemote_immediate()


func _on_IdleTimer_idle_animation_stopped() -> void:
	if is_processing() and current_animation.begins_with("idle"):
		unemote_immediate()
