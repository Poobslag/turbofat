#tool
class_name Creature
extends Node2D
"""
Handles animations and audio/visual effects for a creature.

---
Notes:

If you make Creature a tool and play with the 'creature_preset' editor setting, you can view a creature in the editor.
After a creature is in the editor, make this 'not a tool' again or it has some negative consequences, such as forcing
certain animation frames.

Make sure to remove this creature eventually by setting the value back to '-1'. Otherwise the game will load a little
slower since the creature's assets will need to be loaded for the scene.
"""

# emitted on the frame when the food is launched into the creature's mouth
signal food_eaten

# emitted when a creature arrives and sits down
signal creature_arrived

# emitted when a creature stands up and leaves.
# creatures don't leave anymore, but they used to leave while new textures were loaded.
signal creature_left

# emitted when a movement animation starts (e.g Spira starts running in a direction)
signal movement_animation_started(anim_name)

# emitted during the 'run' animation when the creature touches the ground
signal landed

# emitted during the 'jump' animation when the creature leaves the ground
signal jumped

# directions the creature can face
enum Orientation {
	SOUTHEAST,
	SOUTHWEST,
	NORTHWEST,
	NORTHEAST,
}

# ways the creature's head can move ambiently
enum HeadBobMode {
	OFF, # no movement
	BOB, # nodding vertically
	BOUNCE, # bouncing vertically like a ball hitting the floor
	SHUDDER, # shaking left and right
}

# delays between when creature arrives and when door chime is played (in seconds)
const CHIME_DELAYS: Array = [0.2, 0.3, 0.5, 1.0, 1.5]

# maps creature orientations to appropriate (x, y) direction vectors
const ORIENTATION_VECTORS := {
	Orientation.SOUTHEAST: Vector2(1.0, 0.0),
	Orientation.SOUTHWEST: Vector2(0.0, 1.0),
	Orientation.NORTHWEST: Vector2(-1.0, 0.0),
	Orientation.NORTHEAST: Vector2(0.0, -1.0),
}

# in the editor, this rotates between a set of different creature appearances
export (int) var _creature_preset := -1 setget set_creature_preset

# 'true' if the creature is walking or jumping. toggling this makes certain sprites visible/invisible.
export (bool) var _movement_mode := false setget set_movement_mode

# the direction the creature is facing
export (Orientation) var _orientation := Orientation.SOUTHEAST setget set_orientation, get_orientation

# these three fields control the creature's head motion: how it's moving, as well as how much/how fast
export (HeadBobMode) var head_bob_mode := HeadBobMode.BOB setget set_head_bob_mode
export (float) var head_motion_pixels := 2.0
export (float) var head_motion_seconds := 6.5

# the creature's head bobs up and down slowly, these constants control how much it bobs
const HEAD_BOB_SECONDS := 6.5
const HEAD_BOB_PIXELS := 2.0

# the total number of seconds which have elapsed since the object was created
var _total_seconds := 0.0

# the index of the previously launched food color. stored to avoid showing the same color twice consecutively
var _food_color_index := 0

# the definition of the creature who was most recently summoned
var _creature_def: Dictionary

# we suppress the first door chime. we usually cheat and play the chime after the creature appears, but that doesn't
# work when we can see them appear
var _suppress_one_chime := true

# index of the most recent combo sound that was played
var _combo_voice_index := 0

# current voice stream player. we track this to prevent a creature from saying two things at once
var _current_voice_stream: AudioStreamPlayer2D

var _creature_loader := CreatureLoader.new()

# used to temporarily suppress sfx signals. used when skipping to the middle of animations which play sfx
var _suppress_sfx_signal_timer := 0.0

# sounds the creatures make when they enter the restaurant
onready var hello_voices := [$HelloVoice0, $HelloVoice1, $HelloVoice2, $HelloVoice3]

# sounds which get played when a creature shows up
onready var chime_sounds := [$DoorChime0, $DoorChime1, $DoorChime2, $DoorChime3, $DoorChime4]

# sounds which get played when the creature eats
onready var _munch_sounds := [$Munch0, $Munch1, $Munch2, $Munch3, $Munch4]

# satisfied sounds the creatures make when a player builds a big combo
onready var _combo_voices := [
	$ComboVoice00, $ComboVoice01, $ComboVoice02, $ComboVoice03,
	$ComboVoice04, $ComboVoice05, $ComboVoice06, $ComboVoice07,
	$ComboVoice08, $ComboVoice09, $ComboVoice10, $ComboVoice11,
	$ComboVoice12, $ComboVoice13, $ComboVoice14, $ComboVoice15,
	$ComboVoice16, $ComboVoice17, $ComboVoice18, $ComboVoice19,
]

# sounds the creatures make when they ask for their check
onready var _goodbye_voices := [$GoodbyeVoice0, $GoodbyeVoice1, $GoodbyeVoice2, $GoodbyeVoice3]

# sprites which toggle between a single 'toward the camera' and 'away from the camera' frame
onready var _rotatable_sprites := [
	$Sprites/FarArm,
	$Sprites/FarLeg,
	$Sprites/Body/NeckBlend,
	$Sprites/NearLeg,
	$Sprites/NearArm,
	$Sprites/Neck0/Neck1/EarZ0,
	$Sprites/Neck0/Neck1/HornZ0,
	$Sprites/Neck0/Neck1/Head,
	$Sprites/Neck0/Neck1/EarZ1,
	$Sprites/Neck0/Neck1/HornZ1,
	$Sprites/Neck0/Neck1/EarZ2,
]

onready var _mouth_animation_player := $Mouth0Anims

func _ready() -> void:
	# Update creature's appearance based on their behavior and orientation
	_update_movement_mode()
	set_orientation(_orientation)


func _process(delta: float) -> void:
	if _suppress_sfx_signal_timer > 0.0:
		_suppress_sfx_signal_timer -= delta
	
	if Engine.is_editor_hint():
		# avoid playing animations, bouncing head in editor. manually set frames instead
		_apply_default_mouth_and_eye_frames()
	else:
		if not _mouth_animation_player.is_playing():
			_play_mouth_ambient_animation()

		if _orientation in [Orientation.SOUTHWEST, Orientation.SOUTHEAST]:
			if not $EmoteAnims.is_playing():
				$EmoteAnims.play("ambient")
				$EmoteAnims.advance(randf() * $EmoteAnims.current_animation_length)
		else:
			if $EmoteAnims.is_playing():
				$EmoteAnims.stop()
			$Sprites/Neck0/Neck1/Eyes.frame = 0

		_total_seconds += delta
		if has_node("Sprites/Neck0/Neck1"):
			var head_phase := _total_seconds * PI / head_motion_seconds
			if head_bob_mode == HeadBobMode.BOB:
				var bob_amount := head_motion_pixels * sin(2 * head_phase)
				$Sprites/Neck0/Neck1.position.y = -100 + bob_amount
			elif head_bob_mode == HeadBobMode.BOUNCE:
				var bounce_amount := head_motion_pixels * (1 - 2 * abs(sin(head_phase)))
				$Sprites/Neck0/Neck1.position.y = -100 + bounce_amount
			elif head_bob_mode == HeadBobMode.SHUDDER:
				var shudder_amount := head_motion_pixels * clamp(2 * sin(2 * head_phase), -1.0, 1.0)
				$Sprites/Neck0/Neck1.position.x = shudder_amount
				$Sprites/Neck0/Neck1.position.y = -100


"""
Returns the creature's fatness, a float which determines how fat the creature
should be; 5.0 = 5x normal size

Parameters:
	'creature_index': (Optional) The creature to ask about. Defaults to the current creature.
"""
func get_fatness() -> float:
	return $FatPlayer.get_fatness()


"""
Increases/decreases the creature's fatness, a float which determines how fat
the creature should be; 5.0 = 5x normal size

Parameters:
	'fatness_percent': Controls how fat the creature should be; 5.0 = 5x normal size
	
	'creature_index': (Optional) The creature to be altered. Defaults to the current creature.
"""
func set_fatness(fatness: float) -> void:
	$FatPlayer.set_fatness(fatness)


func set_head_bob_mode(new_head_bob_mode: int) -> void:
	head_bob_mode = new_head_bob_mode
	# Some head bob animations like 'shudder' offset the x position; reset it back to the center
	$Sprites/Neck0/Neck1.position.x = 0


"""
This function manually assigns fields which Godot would ideally assign automatically by calling _ready. It is a
workaround for Godot issue #16974 (https://github.com/godotengine/godot/issues/16974)

Tool scripts do not call _ready on reload, which means all onready fields will be null. This breaks this script's
functionality and throws errors when it is used as a tool. This function manually assigns those fields to avoid those
problems.
"""
func _apply_tool_script_workaround() -> void:
	if not _rotatable_sprites:
		_rotatable_sprites = [
			$Sprites/FarArm,
			$Sprites/FarLeg,
			$Sprites/NearLeg,
			$Sprites/NearArm,
			$Sprites/Body/NeckBlend,
			$Sprites/Neck0/Neck1/EarZ0,
			$Sprites/Neck0/Neck1/HornZ0,
			$Sprites/Neck0/Neck1/Head,
			$Sprites/Neck0/Neck1/EarZ1,
			$Sprites/Neck0/Neck1/HornZ1,
			$Sprites/Neck0/Neck1/EarZ2,
		]
	if not _mouth_animation_player:
		_mouth_animation_player = $Mouth0Anims


"""
Sets the creature's orientation, and alters their appearance appropriately.

If the creature swaps between facing left or right, certain sprites are flipped horizontally. If the creature swaps
between facing forward or backward, certain sprites play different animations or toggle between different frames.
"""
func set_orientation(orientation: int) -> void:
	_orientation = orientation
	if not get_tree():
		# avoid 'node not found' errors when tree is null
		return
	
	if Engine.is_editor_hint():
		_apply_tool_script_workaround()
	
	if _orientation in [Orientation.SOUTHWEST, Orientation.SOUTHEAST]:
		# facing south; initialize textures to forward-facing frames
		$Sprites/Neck0.z_index = 0
		for sprite in _rotatable_sprites:
			sprite.frame = 1
	else:
		# facing north; initialize textures to backward-facing frames
		$Sprites/Neck0.z_index = -1
		for sprite in _rotatable_sprites:
			sprite.frame = 2
	
	_play_mouth_ambient_animation()
	
	# sprites are drawn facing southeast/northwest, and are horizontally flipped for other directions
	$Sprites.scale = \
			Vector2(1, 1) if _orientation in [Orientation.SOUTHEAST, Orientation.NORTHWEST] else Vector2(-1, 1)
	
	# Body is rendered facing southeast/northeast, and is horizontally flipped for other directions. Unfortunately
	# its parent object is already flipped in some cases, making the following line of code quite unintuitive.
	$Sprites/Body.scale = \
			Vector2(1, 1) if _orientation in [Orientation.SOUTHEAST, Orientation.SOUTHWEST] else Vector2(-1, 1)


func get_orientation() -> int:
	return _orientation


"""
If you make Creature a tool and play with the 'creature_preset' editor setting, you can view a creature in the editor.

Make sure to remove this creature eventually by setting the value back to '-1'. Otherwise the game will load a little
slower since the creature's assets will need to be loaded for the scene.
"""
func set_creature_preset(creature_preset: int) -> void:
	_creature_preset = creature_preset
	
	if _creature_preset == -1:
		summon({}, false)
	elif Engine.is_editor_hint():
		_apply_tool_script_workaround()
		# only summon in the editor; otherwise we get NPEs because our children are uninitialized
		summon(CreatureLoader.DEFINITIONS[clamp(creature_preset, 0, CreatureLoader.DEFINITIONS.size() - 1)])


"""
Plays a door chime sound effect, for when a creature enters the restaurant.

Parameter: 'delay' is the delay in seconds before the chime sound plays. The default value of '-1' results in a random
	delay.
"""
func play_door_chime(delay: float = -1) -> void:
	if Scenario.settings.other.tutorial:
		# suppress door chime for tutorials
		return
	
	if delay < 0:
		delay = CHIME_DELAYS[randi() % CHIME_DELAYS.size()]
	yield(get_tree().create_timer(delay), "timeout")
	chime_sounds[randi() % chime_sounds.size()].play()
	yield(get_tree().create_timer(0.5), "timeout")
	play_hello_voice()


"""
Launches the 'feed' animation, hurling a piece of food at the creature and having them catch it.
"""
func feed() -> void:
	if not visible:
		# If no creature is visible, it could mean their resources haven't loaded yet. Don't play any animations or
		# sounds. ...Maybe as an easter egg some day, we can make the chef flinging food into empty air. Ha ha.
		return
	
	if _mouth_animation_player.current_animation in ["eat", "eat-again"]:
		_mouth_animation_player.stop()
		_mouth_animation_player.play("eat-again")
		$EmoteAnims.stop()
		$EmoteAnims.play("eat-again")
		show_food_effects()
	else:
		_mouth_animation_player.play("eat")
		$EmoteAnims.play("eat")
		show_food_effects(0.066)


"""
If the specified key is not associated with a value, this method associates it with the given value.
"""
func put_if_absent(creature_def: Dictionary, key: String, value) -> void:
	if not creature_def.has(key):
		creature_def[key] = value


"""
Recolors the creature according to the specified creature definition. This involves updating shaders and sprite
properties.

Parameters:
	'creature_def': Describes the colors and textures used to draw the creature.
	
	'use_defaults': Can be set to true to fill in the creature's missing traits with random values. Otherwise,
		missing values will be left empty, leading to invisible body parts or strange colors.
"""
func summon(creature_def: Dictionary, use_defaults: bool = true) -> void:
	# duplicate the creature_def so that we don't modify the original
	_creature_def = creature_def.duplicate()
	
	if use_defaults:
		put_if_absent(_creature_def, "line_rgb", "6c4331")
		put_if_absent(_creature_def, "body_rgb", "b23823")
		put_if_absent(_creature_def, "eye_rgb", "282828 dedede")
		put_if_absent(_creature_def, "horn_rgb", "f1e398")
		
		if ResourceCache.minimal_resources:
			# avoid loading unnecessary resources for things like the level editor
			pass
		else:
			put_if_absent(_creature_def, "eye", ["1", "1", "1", "2", "3"][randi() % 5])
			put_if_absent(_creature_def, "ear", ["1", "1", "1", "2", "3"][randi() % 5])
			put_if_absent(_creature_def, "horn", ["0", "0", "0", "1", "2"][randi() % 5])
			put_if_absent(_creature_def, "mouth", ["1", "1", "2"][randi() % 3])
		put_if_absent(_creature_def, "body", "1")
	
	_creature_loader.load_details(_creature_def)
	_update_creature_properties()
	set_fatness(1)


"""
The 'feed' animation causes a few side-effects. The creature's head recoils and some sounds play. This method controls
all of those secondary visual effects of the creature being fed.

Parameters:
	'delay': (Optional) Causes the food effects to appear after the specified delay, in seconds. If omitted, there is
		no delay.
"""
func show_food_effects(delay := 0.0) -> void:
	var munch_sound: AudioStreamPlayer2D = _munch_sounds[randi() % _munch_sounds.size()]
	munch_sound.pitch_scale = rand_range(0.96, 1.04)

	# avoid using the same color twice consecutively
	_food_color_index = (_food_color_index + 1 + randi() % (Playfield.FOOD_COLORS.size() - 1)) \
			% Playfield.FOOD_COLORS.size()
	var food_color: Color = Playfield.FOOD_COLORS[_food_color_index]
	$Sprites/Neck0/Neck1/Food.modulate = food_color
	$Sprites/Neck0/Neck1/FoodLaser.modulate = food_color

	if delay >= 0.0:
		yield(get_tree().create_timer(delay), "timeout")
	play_voice(munch_sound)
	$Tween.interpolate_property($Sprites/Neck0/Neck1, "position:x",
			clamp($Sprites/Neck0/Neck1.position.x - 6, -20, 0), 0, 0.5,
			Tween.TRANS_QUINT, Tween.EASE_IN_OUT)
	$Tween.start()
	emit_signal("food_eaten")


"""
Plays a 'mmm!' voice sample, for when a player builds a big combo.
"""
func play_combo_voice() -> void:
	_combo_voice_index = (_combo_voice_index + 1 + randi() % (_combo_voices.size() - 1)) % _combo_voices.size()
	play_voice(_combo_voices[_combo_voice_index])


"""
Plays a 'hello!' voice sample, for when a creature enters the restaurant
"""
func play_hello_voice() -> void:
	if Global.should_chat():
		play_voice(hello_voices[randi() % hello_voices.size()])


"""
Plays a 'check please!' voice sample, for when a creature is ready to leave
"""
func play_goodbye_voice() -> void:
	if Global.should_chat():
		play_voice(_goodbye_voices[randi() % _goodbye_voices.size()])


"""
Plays a voice sample, interrupting any other voice samples which are currently playing for this specific creature.
"""
func play_voice(audio_stream: AudioStreamPlayer2D) -> void:
	if _current_voice_stream and _current_voice_stream.playing:
		_current_voice_stream.stop()
	audio_stream.play()
	_current_voice_stream = _combo_voices[_combo_voice_index]


"""
Plays a movement animation with the specified prefix and direction, such as a 'run' animation going left.

Parameters:
	'animation_prefix': A partial name of an animation on $Creature/MovementAnims, omitting the directional suffix
	
	'movement_direction': A vector in the (X, Y) direction the creature is moving.
"""
func play_movement_animation(animation_prefix: String, movement_direction: Vector2 = Vector2.ZERO) -> void:
	var animation_name: String
	if animation_prefix == "idle":
		animation_name = "idle"
		if _movement_mode != false:
			set_movement_mode(false)
	else:
		if movement_direction.length() > 1:
			# tiny movement vectors are often the result of a collision. we ignore these to avoid constantly flipping
			# their orientation if they're mashing themselves into a wall
			var new_orientation := _compute_orientation(movement_direction)
			if new_orientation != _orientation:
				set_orientation(new_orientation)
		var suffix := "se" if _orientation in [Orientation.SOUTHEAST, Orientation.SOUTHWEST] else "nw"
		animation_name = "%s-%s" % [animation_prefix, suffix]
		if _movement_mode != true:
			set_movement_mode(true)
	if $MovementAnims.current_animation != animation_name:
		if not $EmoteAnims.current_animation in ["ambient", "ambient-nw"] and animation_name != "idle":
			$EmoteAnims.unemote_immediate()
		if $MovementAnims.current_animation.begins_with(animation_prefix + "-"):
			var old_position: float = $MovementAnims.current_animation_position
			_suppress_sfx_signal_timer = 0.000000001
			$MovementAnims.play(animation_name)
			$MovementAnims.advance(old_position)
		else:
			$MovementAnims.play(animation_name)


"""
Computes the nearest orientation for the specified direction.

For example, a direction of (0.99, -0.13) is mostly pointing towards the x-axis, so it would result in an orientation
of 'southeast'.
"""
func _compute_orientation(direction: Vector2) -> int:
	if direction.length() == 0:
		# we default to the current orientation if given a zero-length vector
		return _orientation
	
	# in case of a near-tie, we preserve their current orientation. this prevents them from rapidly flipping back and
	# forth when moving horizontally or vertically
	var highest_dot := direction.normalized().dot(ORIENTATION_VECTORS[_orientation]) + 0.1
	var new_orientation := _orientation
	for orientation in Orientation.values():
		# calculate which potential orientation has the highest dot product
		if orientation == _orientation:
			continue
		else:
			var dot := direction.normalized().dot(ORIENTATION_VECTORS[orientation])
			if dot > highest_dot:
				new_orientation = orientation
				highest_dot = dot

	return new_orientation


func set_movement_mode(movement_mode: bool) -> void:
	_movement_mode = movement_mode
	if is_inside_tree():
		_update_movement_mode()


"""
Returns 'true' if the creature isn't doing anything important, and we can rotate their head or turn them around.
"""
func is_idle() -> bool:
	return not $MovementAnims.is_playing() or $MovementAnims.current_animation == "idle"


"""
Animates the creature's appearance according to the specified mood: happy, angry, etc...

Parameters:
	'mood': The creature's new mood from ChatEvent.Mood
"""
func play_mood(mood: int) -> void:
	if mood == ChatEvent.Mood.NONE:
		pass
	elif mood == ChatEvent.Mood.DEFAULT:
		$EmoteAnims.unemote()
	else:
		$EmoteAnims.emote(mood)


"""
Plays an appropriate mouth ambient animation for the creature's orientation.
"""
func _play_mouth_ambient_animation() -> void:
	if _orientation in [Orientation.SOUTHWEST, Orientation.SOUTHEAST]:
		_mouth_animation_player.play("ambient-se")
	else:
		_mouth_animation_player.play("ambient-nw")


"""
Updates the visibility/position of nodes based on whether this creature is sitting or walking.
"""
func _update_movement_mode() -> void:
	if _movement_mode == false:
		# reset position/size attributes that get altered during movement
		$Sprites/Neck0.position = Vector2.ZERO
	
	# movement sprites are visible if movement_mode is true
	$Sprites/FarMovement.visible = _movement_mode

	# most other sprites are not visible if movement_mode is true
	$Sprites/FarArm.visible = not _movement_mode
	$Sprites/FarLeg.visible = not _movement_mode
	$Sprites/Body.visible = not _movement_mode
	$Sprites/NearLeg.visible = not _movement_mode
	$Sprites/NearArm.visible = not _movement_mode


"""
Updates the mouth and eye frames to an appropriate frame for the creature's orientation.

Usually the mouth and eyes are controlled by an animation. But when they're not, this method ensures they still look
reasonable.
"""
func _apply_default_mouth_and_eye_frames() -> void:
	if _mouth_animation_player == $Mouth0Anims:
		$Sprites/Neck0/Neck1/Mouth.frame = 1 if _orientation in [Orientation.SOUTHWEST, Orientation.SOUTHEAST] else 12
	elif _mouth_animation_player == $Mouth1Anims:
		$Sprites/Neck0/Neck1/Mouth.frame = 1 if _orientation in [Orientation.SOUTHWEST, Orientation.SOUTHEAST] else 17
	
	if _orientation in [Orientation.SOUTHWEST, Orientation.SOUTHEAST]:
		$Sprites/Neck0/Neck1/Eyes.frame = 1
	else:
		$Sprites/Neck0/Neck1/Eyes.frame = 0


"""
Updates the properties of the various creature sprites and Node2D objects based on the contents of the creature
definition. This assumes the CreatureLoader has finished loading all of the appropriate textures and values.
"""
func _update_creature_properties() -> void:
	if Engine.is_editor_hint():
		_apply_tool_script_workaround()
	
	# stop any AnimationPlayers, otherwise two AnimationPlayers might fight over control of the sprite
	_mouth_animation_player.stop()
	$EmoteAnims.stop()
	
	# reset the mouth frame, otherwise we could have one strange transition frame
	_apply_default_mouth_and_eye_frames()
	
	if _creature_def.has("mouth"):
		# set the sprite's color/texture properties
		if _creature_def.mouth == "1":
			_mouth_animation_player = $Mouth0Anims
		elif _creature_def.mouth == "2":
			_mouth_animation_player = $Mouth1Anims
		else:
			print("Invalid mouth: %s", _creature_def.mouth)
	
	for key in _creature_def.keys():
		if key.find("property:") == 0:
			var node_path: String = "Sprites/" + key.split(":")[1]
			var property_name: String = key.split(":")[2]
			get_node(node_path).set(property_name, _creature_def[key])
		if key.find("shader:") == 0:
			var node_path: String = "Sprites/" + key.split(":")[1]
			var shader_param: String = key.split(":")[2]
			get_node(node_path).material.set_shader_param(shader_param, _creature_def[key])
	$Sprites/Body.update()
	visible = true
	emit_signal("creature_arrived")
	
	if Engine.is_editor_hint():
		# Skip the sound effects if we're using this as an editor tool
		pass
	else:
		if _suppress_one_chime:
			_suppress_one_chime = false
		else:
			play_door_chime()


"""
Emits a signal to play a sound effect.

We temporarily suppress sound effect signals when skipping forward in an animation which plays sound effects.
"""
func emit_sfx_signal(signal_name: String) -> void:
	if _suppress_sfx_signal_timer > 0.0:
		pass
	else:
		emit_signal(signal_name)


func _on_EmoteAnims_before_mood_switched() -> void:
	# some moods modify the sprites for our eyes and arms, so we reset them
	set_orientation(_orientation)


func _on_MovementAnims_animation_started(anim_name: String) -> void:
	emit_signal("movement_animation_started", anim_name)
