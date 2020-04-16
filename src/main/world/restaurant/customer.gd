#tool
extends Node2D
"""
Handles animations and audio/visual effects for a customer.

---
Notes:

If you make Customer a tool and play with the 'customer_preset' editor setting, you can view a customer in the editor.

Make sure to remove this customer eventually by setting the value back to '-1'. Otherwise the game will load a little
slower since the customer's assets will need to be loaded for the scene.
"""

# signal emitted on the frame when the food is launched into the customer's mouth
signal food_eaten

# signal emitted when a customer arrives and sits down
signal customer_arrived

# signal emitted when a stands up and customer leaves
signal customer_left

# directions the customer can face
enum Orientation {
	SOUTHEAST,
	SOUTHWEST,
	NORTHWEST,
	NORTHEAST
}

# food colors for the food which gets hurled into the customer's mouth
const FOOD_COLORS: Array = [
	Color("a4470b"), # brown
	Color("ff5d68"), # pink
	Color("ffa357"), # bread
	Color("fff6eb") # white
]

# delays between when customer arrives and when door chime is played (in seconds)
const CHIME_DELAYS: Array = [0.1, 0.2, 0.3, 0.5, 1.0, 1.5, 2.0]

# maps customer orientations to appropriate (x, y) direction vectors
const ORIENTATION_VECTORS := {
	Orientation.SOUTHEAST: Vector2(1.0, 0.0),
	Orientation.SOUTHWEST: Vector2(0.0, 1.0),
	Orientation.NORTHWEST: Vector2(-1.0, 0.0),
	Orientation.NORTHEAST: Vector2(0.0, -1.0),
}

# in the editor, this rotates between a set of different customer appearances
export (int) var _customer_preset := -1 setget set_customer_preset

# 'true' if the customer is walking or jumping. toggling this makes certain sprites visible/invisible.
export (bool) var _movement_mode := false setget set_movement_mode

# the direction the customer is facing
export (Orientation) var _orientation: int = Orientation.SOUTHEAST setget set_orientation

# the total number of seconds which have elapsed since the object was created
var _total_seconds := 0.0

# the creature's head bobs up and down slowly, these fields control how much it bobs
var _head_bob_seconds := 6.5
var _head_bob_pixels := 2.0

# the index of the previously launched food color. stored to avoid showing the same color twice consecutively
var _food_color_index := 0

# true if we're in the process of 'summoning a customer' -- loading all of their assets and waiting for them to render
var _summoning := false

# the definition of the customer who was most recently summoned
var _customer_def: Dictionary

# we suppress the first door chime. we usually cheat and play the chime after the customer appears, but that doesn't
# work when we can see them appear
var _suppress_one_chime := true

# index of the most recent combo sound that was played
var _combo_voice_index := 0

# current voice stream player. we track this to prevent a customer from saying two things at once
var _current_voice_stream: AudioStreamPlayer2D

# sounds the customers make when they enter the restaurant
onready var hello_voices:Array = [
	$HelloVoice0, $HelloVoice1, $HelloVoice2, $HelloVoice3
]

# sounds which get played when a customer shows up
onready var chime_sounds:Array = [
	$DoorChime0,
	$DoorChime1,
	$DoorChime2,
	$DoorChime3,
	$DoorChime4
]

# sounds which get played when the customer eats
onready var _munch_sounds:Array = [
	$Munch0,
	$Munch1,
	$Munch2,
	$Munch3,
	$Munch4
]

# satisfied sounds the customers make when a player builds a big combo
onready var _combo_voices:Array = [
	$ComboVoice00, $ComboVoice01, $ComboVoice02, $ComboVoice03,
	$ComboVoice04, $ComboVoice05, $ComboVoice06, $ComboVoice07,
	$ComboVoice08, $ComboVoice09, $ComboVoice10, $ComboVoice11,
	$ComboVoice12, $ComboVoice13, $ComboVoice14, $ComboVoice15,
	$ComboVoice16, $ComboVoice17, $ComboVoice18, $ComboVoice19
]

# sounds the customers make when they ask for their check
onready var _goodbye_voices:Array = [
	$GoodbyeVoice0, $GoodbyeVoice1, $GoodbyeVoice2, $GoodbyeVoice3
]

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
	$Sprites/Neck0/Neck1/EarZ2
]

onready var _mouth_animation_player := $Mouth0Anims

func _ready() -> void:
	# Update customer's appearance based on their behavior and orientation
	_update_movement_mode()
	set_orientation(_orientation)


func _process(delta: float) -> void:
	if _summoning and CustomerLoader.is_customer_ready(_customer_def):
		_update_customer_properties()
		_summoning = false

	if Engine.is_editor_hint():
		# avoid playing animations, bouncing head in editor. manually set frames instead
		_apply_default_mouth_and_eye_frames()
	else:
		if not _mouth_animation_player.is_playing():
			_play_mouth_ambient_animation()
		
		if _orientation in [Orientation.SOUTHWEST, Orientation.SOUTHEAST]:
			if not $Eye0Anims.is_playing():
				$Eye0Anims.play("ambient")
				$Eye0Anims.advance(randf() * $Eye0Anims.current_animation_length)
		else:
			if $Eye0Anims.is_playing():
				$Eye0Anims.stop()
			$Sprites/Neck0/Neck1/Eyes.frame = 0
		
		_total_seconds += delta
		if has_node("Sprites/Neck0/Neck1"):
			var bob_amount = _head_bob_pixels * sin((_total_seconds * 2 * PI) / _head_bob_seconds)
			$Sprites/Neck0/Neck1.position.y = -100 + bob_amount


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
Sets the customer's orientation, and alters their appearance appropriately.

If the customer swaps between facing left or right, certain sprites are flipped horizontally. If the customer swaps
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
	$Sprites.scale = Vector2(1, 1) if _orientation in [Orientation.SOUTHEAST, Orientation.NORTHWEST] else Vector2(-1, 1)
	
	# Body is rendered facing southeast/northeast, and is horizontally flipped for other directions. Unfortunately
	# its parent object is already flipped in some cases, making the following line of code quite unintuitive.
	$Sprites/Body.scale = Vector2(1, 1) if _orientation in [Orientation.SOUTHEAST, Orientation.SOUTHWEST] else Vector2(-1, 1)


"""
If you make Customer a tool and play with the 'customer_preset' editor setting, you can view a customer in the editor.

Make sure to remove this customer eventually by setting the value back to '-1'. Otherwise the game will load a little
slower since the customer's assets will need to be loaded for the scene.
"""
func set_customer_preset(customer_preset: int) -> void:
	_customer_preset = customer_preset
	
	if _customer_preset == -1:
		summon({}, false)
	else:
		summon(CustomerLoader.DEFINITIONS[clamp(customer_preset, 0, CustomerLoader.DEFINITIONS.size() - 1)])


"""
Plays a door chime sound effect, for when a customer enters the restaurant.

Parameter: 'delay' is the delay in seconds before the chime sound plays. The default value of '-1' results in a random
	delay.
"""
func play_door_chime(delay: float = -1):
	if delay < 0:
		delay = CHIME_DELAYS[randi() % CHIME_DELAYS.size()]
	yield(get_tree().create_timer(delay), "timeout")
	chime_sounds[randi() % chime_sounds.size()].play()
	yield(get_tree().create_timer(0.5), "timeout")
	play_hello_voice()


"""
Launches the 'feed' animation, hurling a piece of food at the customer and having them catch it.
"""
func feed() -> void:
	if not visible:
		# If no customer is visible, it could mean their resources haven't loaded yet. Don't play any animations or
		# sounds. ...Maybe as an easter egg some day, we can make the chef flinging food into empty air. Ha ha.
		return
	
	if _mouth_animation_player.current_animation in ["eat", "eat-again"]:
		_mouth_animation_player.stop()
		_mouth_animation_player.play("eat-again")
		$Eye0Anims.stop()
		$Eye0Anims.play("eat-again")
		show_food_effects()
	else:
		_mouth_animation_player.play("eat")
		$Eye0Anims.play("eat")
		show_food_effects(0.066)


"""
If the specified key is not associated with a value, this method associates it with the given value.
"""
func put_if_absent(customer_def: Dictionary, key: String, value) -> void:
	if not customer_def.has(key):
		customer_def[key] = value


"""
Recolors the customer according to the specified customer definition. This involves updating shaders and sprite
properties.

Parameter: 'customer_def' describes the colors and textures used to draw the customer.
Parameter: 'use_defaults' can be set to true to fill in the customer's missing traits with random values. Otherwise,
	missing values will be left empty, leading to invisible body parts or strange colors.
"""
func summon(customer_def: Dictionary, use_defaults: bool = true) -> void:
	# duplicate the customer_def so that we don't modify the original
	_customer_def = customer_def.duplicate()
	
	if use_defaults:
		put_if_absent(_customer_def, "line_rgb", "6c4331")
		put_if_absent(_customer_def, "body_rgb", "b23823")
		put_if_absent(_customer_def, "eye_rgb", "282828 dedede")
		put_if_absent(_customer_def, "horn_rgb", "f1e398")
		
		put_if_absent(_customer_def, "eye", ["0", "0", "0", "1", "2"][randi() % 5])
		put_if_absent(_customer_def, "ear", ["0", "0", "0", "1", "2"][randi() % 5])
		put_if_absent(_customer_def, "horn", ["0", "0", "0", "1", "2"][randi() % 5])
		put_if_absent(_customer_def, "mouth", ["0", "0", "1"][randi() % 3])
		put_if_absent(_customer_def, "body", "0")
	
	_summoning = true
	CustomerLoader.summon_customer(_customer_def)
	visible = false
	emit_signal("customer_left")


"""
The 'feed' animation causes a few side-effects. The customer's head recoils and some sounds play. This method controls
all of those secondary visual effects of the customer being fed.

Parameters:
	'delay': (Optional) Causes the food effects to appear after the specified delay, in seconds. If omitted, there is
		no delay.
"""
func show_food_effects(delay := 0.0) -> void:
	var munch_sound: AudioStreamPlayer2D = _munch_sounds[randi() % _munch_sounds.size()]
	munch_sound.pitch_scale = rand_range(0.96, 1.04)

	# avoid using the same color twice consecutively
	_food_color_index = (_food_color_index + 1 + randi() % (FOOD_COLORS.size() - 1)) % FOOD_COLORS.size()
	var food_color: Color = FOOD_COLORS[_food_color_index]
	$Sprites/Neck0/Neck1/Food.modulate = food_color
	$Sprites/Neck0/Neck1/FoodLaser.modulate = food_color

	if delay >= 0.0:
		yield(get_tree().create_timer(delay), "timeout")
	play_voice(munch_sound)
	$Tween.interpolate_property($Sprites/Neck0/Neck1, "position:x", clamp($Sprites/Neck0/Neck1.position.x - 6, -20, 0), 0, 0.5,
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
Plays a 'hello!' voice sample, for when a customer enters the restaurant
"""
func play_hello_voice() -> void:
	if Global.should_chat():
		play_voice(hello_voices[randi() % hello_voices.size()])


"""
Plays a 'check please!' voice sample, for when a customer is ready to leave
"""
func play_goodbye_voice() -> void:
	if Global.should_chat():
		play_voice(_goodbye_voices[randi() % _goodbye_voices.size()])


"""
Plays a voice sample, interrupting any other voice samples which are currently playing for this specific customer.
"""
func play_voice(audio_stream: AudioStreamPlayer2D) -> void:
	if _current_voice_stream and _current_voice_stream.playing:
		_current_voice_stream.stop()
	audio_stream.play()
	_current_voice_stream = _combo_voices[_combo_voice_index]


"""
Plays a movement animation with the specified prefix and direction, such as a 'run' animation going left.

Parameters:
	'animation_prefix': A partial name of an animation on $Customer/MovementAnims, omitting the directional suffix
	
	'movement_direction': A vector in the (X, Y) direction the customer is moving.
"""
func play_movement_animation(animation_prefix: String, movement_direction: Vector2 = Vector2.ZERO) -> void:
	var animation_name: String
	if animation_prefix == "idle":
		animation_name = "idle"
		if _movement_mode != false:
			set_movement_mode(false)
	else:
		if movement_direction.length() > 0:
			var new_orientation = _compute_orientation(movement_direction)
			if new_orientation != _orientation:
				set_orientation(new_orientation)
		var suffix = "se" if _orientation in [Orientation.SOUTHEAST, Orientation.SOUTHWEST] else "nw"
		animation_name = "%s-%s" % [animation_prefix, suffix]
		if _movement_mode != true:
			set_movement_mode(true)
	if $MovementAnims.current_animation != animation_name:
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
	
	var highest_dot = direction.normalized().dot(ORIENTATION_VECTORS[_orientation])
	var new_orientation = _orientation
	for orientation in Orientation.values():
		# iterate over the possible orientations and calculate which one has the highest dot product. in the case of a
		# tie, we prefer the customer's current orientation.
		if orientation == _orientation:
			continue
		else:
			var dot = direction.normalized().dot(ORIENTATION_VECTORS[orientation])
			if dot > highest_dot:
				new_orientation = orientation
				highest_dot = dot

	return new_orientation


func set_movement_mode(movement_mode: bool) -> void:
	_movement_mode = movement_mode
	if is_inside_tree():
		_update_movement_mode()


"""
Plays an appropriate mouth ambient animation for the customer's orientation.
"""
func _play_mouth_ambient_animation() -> void:
	if _orientation in [Orientation.SOUTHWEST, Orientation.SOUTHEAST]:
		_mouth_animation_player.play("ambient-se")
	else:
		_mouth_animation_player.play("ambient-nw")


"""
Updates the visibility/position of nodes based on whether this customer is sitting or walking.
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
Updates the mouth and eye frames to an appropriate frame for the customer's orientation.

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
Updates the properties of the various customer sprites and Node2D objects based on the contents of the customer
definition. This assumes the CustomerLoader has finished loading all of the appropriate textures and values.
"""
func _update_customer_properties() -> void:
	if Engine.is_editor_hint():
		_apply_tool_script_workaround()
	
	# stop any AnimationPlayers, otherwise two AnimationPlayers might fight over control of the sprite
	_mouth_animation_player.stop()
	$Eye0Anims.stop()
	
	# reset the mouth frame, otherwise we could have one strange transition frame
	_apply_default_mouth_and_eye_frames()
	
	if _customer_def.has("mouth"):
		# set the sprite's color/texture properties
		if _customer_def.mouth == "0":
			_mouth_animation_player = $Mouth0Anims
		elif _customer_def.mouth == "1":
			_mouth_animation_player = $Mouth1Anims
		else:
			print("Invalid mouth: %s", _customer_def.mouth)
	
	for key in _customer_def.keys():
		if key.find("property:") == 0:
			var node_path: String = "Sprites/" + key.split(":")[1]
			var property_name: String = key.split(":")[2]
			get_node(node_path).set(property_name, _customer_def[key])
			if property_name == "texture" and _customer_def[key]:
				get_node(node_path).vframes = max(1, int(round(_customer_def[key].get_height() / 1025)))
				get_node(node_path).hframes = max(1, int(round(_customer_def[key].get_width() / 1025)))
		if key.find("shader:") == 0:
			var node_path: String = "Sprites/" + key.split(":")[1]
			var shader_param: String = key.split(":")[2]
			get_node(node_path).material.set_shader_param(shader_param, _customer_def[key])
	$Sprites/Body.update()
	visible = true
	emit_signal("customer_arrived")
	
	if Engine.is_editor_hint():
		# Skip the sound effects if we're using this as an editor tool
		pass
	else:
		if _suppress_one_chime:
			_suppress_one_chime = false
		else:
			play_door_chime()
