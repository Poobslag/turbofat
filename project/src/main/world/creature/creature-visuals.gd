#tool #uncomment to view creature in editor
class_name CreatureVisuals
extends Node2D
"""
Handles animations and audio/visual effects for a creature.

To edit creatures in the Godot editor:
	1. Run the 'edit-creature.sh on' shell command to enable the necessary tool scripts
	2. Toggle the CreatureVisuals.random_creature property in the Godot editor
	3. Make your changes
	4. When you're finished, toggle the CreatureVisuals.reset_creature property in the Godot editor
	5. Lastly, run the 'edit-creature.sh off' shell command to disable the necessary tool scripts

Do not leave the tool scripts enabled. Doing so causes errors in the Godot console and impacts performance as
unnecessary textures are loaded.
"""

# emitted on the frame when the food is launched into the creature's mouth
signal food_eaten

# emitted before a creature arrives and sits down
signal before_creature_arrived

# emitted when a creature arrives and sits down
signal creature_arrived

# emitted when a movement animation starts (e.g Spira starts running in a direction)
signal movement_animation_started(anim_name)

# emitted during the 'run' animation when the creature touches the ground
# warning-ignore:unused_signal
signal landed

signal orientation_changed(old_orientation, new_orientation)
signal movement_mode_changed(movement_mode)
signal fatness_changed

# directions the creature can face
enum Orientation {
	SOUTHEAST,
	SOUTHWEST,
	NORTHWEST,
	NORTHEAST,
}

const SOUTHEAST = Orientation.SOUTHEAST
const SOUTHWEST = Orientation.SOUTHWEST
const NORTHWEST = Orientation.NORTHWEST
const NORTHEAST = Orientation.NORTHEAST

# toggle to assign default animation frames based on the creature's orientation
export (bool) var _reset_frames setget reset_frames

# toggle to remove the creature's textures
export (bool) var _reset_creature setget reset_creature

# toggle to generate a creature with a random appearance
export (bool) var _random_creature setget random_creature

# 'true' if the creature is walking. toggling this makes certain sprites visible/invisible.
export (bool) var movement_mode := false setget set_movement_mode

export (Vector2) var southeast_dir := Vector2(0.70710678118, 0.70710678118)

# the direction the creature is facing
export (Orientation) var orientation := SOUTHEAST setget set_orientation

# describes the colors and textures used to draw the creature
export (Dictionary) var dna: Dictionary setget set_dna

# used to temporarily suppress sfx signals. used when skipping to the middle of animations which play sfx
var _suppress_sfx_signal_timer := 0.0

# forces listeners to update their animation frame
var _force_orientation_change := false

onready var _mouth_animation_player := $Mouth0Anims

func _ready() -> void:
	# Update creature's appearance based on their behavior and orientation
	_update_movement_mode()
	set_orientation(orientation)
	_mouth_animation_player.set_process(true)


func _process(delta: float) -> void:
	if _suppress_sfx_signal_timer > 0.0:
		_suppress_sfx_signal_timer -= delta


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
func set_fatness(new_fatness: float) -> void:
	if not Engine.is_editor_hint():
		$FatPlayer.set_fatness(new_fatness)
		emit_signal("fatness_changed")


"""
This function manually assigns fields which Godot would ideally assign automatically by calling _ready. It is a
workaround for Godot issue #16974 (https://github.com/godotengine/godot/issues/16974)

Tool scripts do not call _ready on reload, which means all onready fields will be null. This breaks this script's
functionality and throws errors when it is used as a tool. This function manually assigns those fields to avoid those
problems.
"""
func _apply_tool_script_workaround() -> void:
	if not _mouth_animation_player:
		_mouth_animation_player = $Mouth0Anims
		_mouth_animation_player.set_process(true)


"""
Updates the frame to something appropriate for the creature's orientation.

Usually the frame is controlled by an animation. But when it's not, this ensures it still looks reasonable.
"""
func reset_frames(value: bool = true) -> void:
	if not value:
		return
	reset_eye_frames()
	$Viewport/Sprites/Neck0/HeadBobber/Mouth.frame = 1 if orientation in [SOUTHWEST, SOUTHEAST] else 2


func reset_eye_frames() -> void:
	$Viewport/Sprites/Neck0/HeadBobber/Eyes.update_orientation(orientation)


"""
Remove the creature's textures.
"""
func reset_creature(value: bool = true) -> void:
	if not value:
		return
	set_dna({})
	dna = {}


"""
Generates a creature with a random appearance.
"""
func random_creature(value: bool = true) -> void:
	if not value:
		return
	if Engine.is_editor_hint():
		_apply_tool_script_workaround()
	var new_dna := CreatureLoader.fill_dna(
			CreatureLoader.DEFINITIONS[randi() % CreatureLoader.DEFINITIONS.size()])
	set_dna(new_dna)


"""
Sets the creature's orientation, and alters their appearance appropriately.

If the creature swaps between facing left or right, certain sprites are flipped horizontally. If the creature swaps
between facing forward or backward, certain sprites play different animations or toggle between different frames.
"""
func set_orientation(new_orientation: int) -> void:
	var old_orientation := orientation
	orientation = new_orientation
	if not get_tree():
		# avoid 'node not found' errors when tree is null
		return
	
	if Engine.is_editor_hint():
		_apply_tool_script_workaround()
	
	if orientation in [SOUTHWEST, SOUTHEAST]:
		# facing south; initialize textures to forward-facing frames
		$Viewport/Sprites/Neck0.z_index = 0
	else:
		# facing north; initialize textures to backward-facing frames
		$Viewport/Sprites/Neck0.z_index = -1
	
	# sprites are drawn facing southeast/northwest, and are horizontally flipped for other directions
	scale = \
			Vector2(1, 1) if orientation in [SOUTHEAST, NORTHWEST] else Vector2(-1, 1)
	
	# Body is rendered facing southeast/northeast, and is horizontally flipped for other directions. Unfortunately
	# its parent object is already flipped in some cases, making the following line of code quite unintuitive.
	$Viewport/Sprites/Body.scale = \
			Vector2(1, 1) if orientation in [SOUTHEAST, SOUTHWEST] else Vector2(-1, 1)
	
	if _force_orientation_change:
		# some listeners try to distinguish between 'big orientation changes' and 'little orientation changes'. if
		# _force_orientation_change is true, we signal to everyone that they cannot transition from the old
		# orientation by making it something nonsensical
		old_orientation = -1
	
	emit_signal("orientation_changed", old_orientation, new_orientation)


"""
Launches the 'feed' animation, hurling a piece of food at the creature and having them catch it.
"""
func feed(food_color: Color) -> void:
	if not visible:
		# If no creature is visible, it could mean their resources haven't loaded yet. Don't play any animations or
		# sounds. ...Maybe as an easter egg some day, we can make the chef flinging food into empty air. Ha ha.
		return
	
	$Viewport/Sprites/Neck0/HeadBobber/Food.modulate = food_color
	$Viewport/Sprites/Neck0/HeadBobber/FoodLaser.modulate = food_color
	if _mouth_animation_player.current_animation in ["eat", "eat-again"]:
		_mouth_animation_player.stop()
		_mouth_animation_player.play("eat-again")
		$EmoteAnims.stop()
		$EmoteAnims.play("eat-again")
	else:
		_mouth_animation_player.play("eat")
		$EmoteAnims.play("eat")


"""
Recolors the creature according to the specified creature definition. This involves updating shaders and sprite
properties.
"""
func set_dna(new_dna: Dictionary) -> void:
	dna = new_dna
	if is_inside_tree():
		CreatureLoader.load_details(dna)
		_update_creature_properties()
		set_fatness(1)


"""
The 'feed' animation causes a few side-effects. The creature's head recoils and some sounds play. This method controls
all of those secondary visual effects of the creature being fed.
"""
func show_food_effects() -> void:
	$Tween.interpolate_property($Viewport/Sprites/Neck0/HeadBobber, "position:x",
			clamp($Viewport/Sprites/Neck0/HeadBobber.position.x - 6, -20, 0), 0, 0.5,
			Tween.TRANS_QUINT, Tween.EASE_IN_OUT)
	$Tween.start()
	emit_signal("food_eaten")


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
		if movement_mode != false:
			set_movement_mode(false)
	else:
		if movement_direction.length() > 0.1:
			# tiny movement vectors are often the result of a collision. we ignore these to avoid constantly flipping
			# their orientation if they're mashing themselves into a wall
			var new_orientation := _compute_orientation(movement_direction)
			if new_orientation != orientation:
				set_orientation(new_orientation)
		var suffix := "se" if orientation in [Orientation.SOUTHEAST, Orientation.SOUTHWEST] else "nw"
		animation_name = "%s-%s" % [animation_prefix, suffix]
		if movement_mode != true:
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
		return orientation
	
	# preserve the old orientation if it's close to the new orientation. this prevents us from flipping repeatedly
	# when our direction puts us between two orientations.
	var new_orientation: int = orientation
	# unrounded orientation is a float in the range [-2.0, 2.0]
	var unrounded_orientation := -2 * direction.angle_to(southeast_dir) / PI
	if abs(unrounded_orientation - orientation) >= 0.6 and abs(unrounded_orientation + 4 - orientation) >= 0.6:
		# convert the float orientation [-2.0, 2.0] to an int orientation [0, 3]
		new_orientation = wrapi(int(round(unrounded_orientation)), 0, 4)
	return new_orientation


func set_movement_mode(new_mode: bool) -> void:
	movement_mode = new_mode
	if is_inside_tree():
		_update_movement_mode()
		emit_signal("movement_mode_changed", movement_mode)


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
Updates the visibility/position of nodes based on whether this creature is sitting or walking.
"""
func _update_movement_mode() -> void:
	if not movement_mode:
		# reset position/size attributes that get altered during movement
		$Viewport/Sprites/Neck0.position = Vector2.ZERO
	
	# movement sprites are visible if movement_mode is true
	$Viewport/Sprites/FarMovement.visible = movement_mode


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
	emit_signal("before_creature_arrived")
	
	for packed_sprite_obj in [
		$Viewport/Sprites/FarMovement,
		$Viewport/Sprites/FarArm,
		$Viewport/Sprites/FarLeg,
		$Viewport/Sprites/Body/NeckBlend,
		$Viewport/Sprites/NearLeg,
		$Viewport/Sprites/NearArm,
		$Viewport/Sprites/Neck0/HeadBobber/EarZ0,
		$Viewport/Sprites/Neck0/HeadBobber/HornZ0,
		$Viewport/Sprites/Neck0/HeadBobber/Head,
		$Viewport/Sprites/Neck0/HeadBobber/EarZ1,
		$Viewport/Sprites/Neck0/HeadBobber/HornZ1,
		$Viewport/Sprites/Neck0/HeadBobber/EarZ2,
		$Viewport/Sprites/Neck0/HeadBobber/Mouth,
		$Viewport/Sprites/Neck0/HeadBobber/Eyes,
		$Viewport/Sprites/Neck0/HeadBobber/Food,
		$Viewport/Sprites/Neck0/HeadBobber/FoodLaser,
	]:
		var packed_sprite: PackedSprite = packed_sprite_obj
		packed_sprite.texture = null
		packed_sprite.frame_data = ""
	
	if dna.has("mouth"):
		# set the sprite's color/texture properties
		_mouth_animation_player.set_process(false)
		if dna.mouth == "1":
			_mouth_animation_player = $Mouth0Anims
		elif dna.mouth == "2":
			_mouth_animation_player = $Mouth1Anims
		else:
			print("Invalid mouth: %s", dna.mouth)
		_mouth_animation_player.set_process(true)
	
	if dna.has("line_rgb"):
		$TextureRect.material.set_shader_param("black", Color(dna.line_rgb))
	
	for key in dna.keys():
		if key.find("property:") == 0:
			var node_path: String = "Viewport/Sprites/" + key.split(":")[1]
			var property_name: String = key.split(":")[2]
			get_node(node_path).set(property_name, dna[key])
		if key.find("shader:") == 0:
			var node_path: String = "Viewport/Sprites/" + key.split(":")[1]
			var shader_param: String = key.split(":")[2]
			get_node(node_path).material.set_shader_param(shader_param, dna[key])
	$Viewport/Sprites/Body.update()
	visible = true
	emit_signal("creature_arrived")


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
	_force_orientation_change = true
	set_orientation(orientation)


func _on_MovementAnims_animation_started(anim_name: String) -> void:
	emit_signal("movement_animation_started", anim_name)
