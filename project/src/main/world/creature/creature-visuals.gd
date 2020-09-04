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

# emitted when a creature's textures and animations are loaded
signal dna_loaded

# emitted during the 'run' animation when the creature touches the ground
# warning-ignore:unused_signal
signal landed

signal orientation_changed(old_orientation, new_orientation)
signal movement_mode_changed(old_mode, new_mode)
signal fatness_changed
signal visual_fatness_changed
signal comfort_changed

# emitted by FatSpriteMover when it moves the head by making the creature fatter
# warning-ignore:unused_signal
signal head_moved

# directions the creature can face
enum Orientation {
	SOUTHEAST,
	SOUTHWEST,
	NORTHWEST,
	NORTHEAST,
}

enum MovementMode {
	IDLE, # not walking/running
	SPRINT, # quadrapedal run
	RUN, # bipedal run
	WALK, # bipedal walk
	WIGGLE, # flailing their arms and legs helplessly
}

const IDLE := MovementMode.IDLE
const SPRINT := MovementMode.SPRINT
const RUN := MovementMode.RUN
const WALK := MovementMode.WALK
const WIGGLE := MovementMode.WIGGLE

const SOUTHEAST := Orientation.SOUTHEAST
const SOUTHWEST := Orientation.SOUTHWEST
const NORTHWEST := Orientation.NORTHWEST
const NORTHEAST := Orientation.NORTHEAST

# toggle to assign default animation frames based on the creature's orientation
export (bool) var _reset_frames setget reset_frames

# toggle to remove the creature's textures
export (bool) var _reset_creature setget reset_creature

# toggle to generate a creature with a random appearance
export (bool) var _random_creature setget random_creature

# the state of whether the creature is walking, running or idle
export (MovementMode) var movement_mode := MovementMode.IDLE setget set_movement_mode

export (Vector2) var southeast_dir := Vector2(0.70710678118, 0.70710678118)

# the direction the creature is facing
export (Orientation) var orientation := SOUTHEAST setget set_orientation

# describes the colors and textures used to draw the creature
export (Dictionary) var dna: Dictionary setget set_dna

# how fat the creature looks right now; gradually approaches the 'fatness' property
export (float) var visual_fatness := 1.0 setget set_visual_fatness

# how fat the creature will become eventually; visual_fatness gradually approaches this value
var fatness := 1.0 setget set_fatness, get_fatness

# comfort improves as the creature eats, and degrades as they overeat. comfort is a number from [-1.0, 1.0]. -1.0 is
# very uncomfortable, 1.0 is very comfortable
var comfort := 0.0 setget set_comfort

# used to temporarily suppress sfx signals. used when skipping to the middle of animations which play sfx
var _suppress_sfx_signal_timer := 0.0

# forces listeners to update their animation frame
var _force_orientation_change := false

var _mouth_player

func _ready() -> void:
	# Update creature's appearance based on their behavior and orientation
	set_orientation(orientation)


func _process(delta: float) -> void:
	if _suppress_sfx_signal_timer > 0.0:
		_suppress_sfx_signal_timer -= delta


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		# don't move stuff in the editor
		return
	
	# lerp plus a little extra
	if visual_fatness != fatness:
		if visual_fatness < fatness:
			visual_fatness = min(visual_fatness + 4 * delta, fatness)
		elif visual_fatness > fatness:
			visual_fatness = max(visual_fatness - 4 * delta, fatness)
		set_visual_fatness(lerp(visual_fatness, fatness, 0.008))


func set_comfort(new_comfort: float) -> void:
	comfort = new_comfort
	emit_signal("comfort_changed")


func set_visual_fatness(new_visual_fatness: float) -> void:
	visual_fatness = new_visual_fatness
	emit_signal("visual_fatness_changed")


"""
Returns the creature's fatness, a float which determines how fat the creature
should be; 5.0 = 5x normal size

Parameters:
	'creature_index': (Optional) The creature to ask about. Defaults to the current creature.
"""
func get_fatness() -> float:
	return fatness


"""
Increases/decreases the creature's fatness, a float which determines how fat
the creature should be; 5.0 = 5x normal size

Parameters:
	'fatness_percent': Controls how fat the creature should be; 5.0 = 5x normal size
	
	'creature_index': (Optional) The creature to be altered. Defaults to the current creature.
"""
func set_fatness(new_fatness: float) -> void:
	fatness = new_fatness
	emit_signal("fatness_changed")


func play_idle_animation(idle_anim: String) -> void:
	$IdleTimer.play_idle_animation(idle_anim)


"""
Updates the frame to something appropriate for the creature's orientation.

Usually the frame is controlled by an animation. But when it's not, this ensures it still looks reasonable.
"""
func reset_frames(value: bool = true) -> void:
	if not value:
		return
	
	reset_eye_frames()
	$Neck0/HeadBobber/Mouth.frame = 1 if orientation in [SOUTHWEST, SOUTHEAST] else 2
	$Neck0/HeadBobber/Chin.frame = 1 if orientation in [SOUTHWEST, SOUTHEAST] else 2
	$TailZ0.frame = 1 if orientation in [SOUTHWEST, SOUTHEAST] else 2
	$TailZ1.frame = 1 if orientation in [SOUTHWEST, SOUTHEAST] else 2
	emit_signal("orientation_changed", -1, orientation)


"""
Resets the eyes to a forward/backward facing frame.

Because the eye frames also become visible/invisible during emotes, they don't react to normal orientation/movement
changes and are instead reset manually.
"""
func reset_eye_frames() -> void:
	$Neck0/HeadBobber/EyeZ0.frame = 1 if orientation in [SOUTHWEST, SOUTHEAST] else 2
	$Neck0/HeadBobber/EyeZ1.frame = 1 if orientation in [SOUTHWEST, SOUTHEAST] else 2


"""
Remove the creature's textures.
"""
func reset_creature(value: bool = true) -> void:
	if not value:
		return
	set_dna({})


"""
Generates a creature with a random appearance.
"""
func random_creature(value: bool = true) -> void:
	if not value:
		return
	var new_dna: Dictionary = DnaUtils.fill_dna(DnaUtils.random_creature_palette())
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
	
	if (orientation in [SOUTHEAST, SOUTHWEST]) != (old_orientation in [SOUTHEAST, SOUTHWEST]):
		# creature changed from facing north to south or vice versa
		
		# update their eyes to a default frame to prevent them from having
		# eyes on the back of their head, or no eyes at all
		reset_eye_frames()
		
		# when facing north, the head goes behind the body
		$Neck0.z_index = 0 if orientation in [SOUTHWEST, SOUTHEAST] else -1
	
	# sprites are drawn facing southeast/northwest, and are horizontally flipped for other directions
	scale.x = abs(scale.x) if orientation in [SOUTHEAST, NORTHWEST] else -abs(scale.x)
	
	# Body is rendered facing southeast/northeast, and is horizontally flipped for other directions. Unfortunately
	# its parent object is already flipped in some cases, making the following line of code quite unintuitive.
	if has_node("Body/Viewport/Body"):
		$Body/Viewport/Body.scale.x = 1 if orientation in [SOUTHEAST, SOUTHWEST] else -1
	if has_node("BodyShadows/Viewport/Body"):
		$BodyShadows/Viewport/Body.scale.x = 1 if orientation in [SOUTHEAST, SOUTHWEST] else -1
	
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
	
	$Neck0/HeadBobber/Food.modulate = food_color
	$Neck0/HeadBobber/FoodLaser.modulate = food_color
	$EmotePlayer.eat()
	if _mouth_player:
		_mouth_player.eat()


"""
Recolors the creature according to the specified creature definition. This involves updating shaders and sprite
properties.
"""
func set_dna(new_dna: Dictionary) -> void:
	dna = new_dna
	if is_inside_tree():
		CreatureLoader.load_details(dna)
		# any AnimationPlayers are stopped, otherwise old players will continue controlling the sprites
		_unload_dna()
		_load_dna()


"""
The 'feed' animation causes a few side-effects. The creature's head recoils and some sounds play. This method controls
all of those secondary visual effects of the creature being fed.
"""
func show_food_effects() -> void:
	$Tween.interpolate_property($Neck0/HeadBobber, "position:x",
			clamp($Neck0/HeadBobber.position.x - 6, -20, 0), 0, 0.5,
			Tween.TRANS_QUINT, Tween.EASE_IN_OUT)
	$Tween.start()
	emit_signal("food_eaten")


"""
Returns an AnimationPlayer which animates moods: blinking, smiling, sweating, etc.
"""
func get_emote_player() -> AnimationPlayer:
	return $EmotePlayer as AnimationPlayer


"""
Returns a Timer which launches idle animations periodically.
"""
func get_idle_timer() -> Timer:
	return $IdleTimer as Timer


"""
Plays a movement animation with the specified prefix and direction, such as a 'run' animation going left.

Parameters:
	'animation_prefix': A partial name of an animation on $Creature/MovementPlayer, omitting the directional suffix
	
	'movement_direction': A vector in the (X, Y) direction the creature is moving.
"""
func play_movement_animation(animation_prefix: String, movement_direction: Vector2 = Vector2.ZERO) -> void:
	if movement_direction.length() > 0.1:
		# tiny movement vectors are often the result of a collision. we ignore these to avoid constantly flipping
		# their orientation if they're mashing themselves into a wall
		var new_orientation := _compute_orientation(movement_direction)
		if new_orientation != orientation:
			set_orientation(new_orientation)
	var suffix := "se" if orientation in [Orientation.SOUTHEAST, Orientation.SOUTHWEST] else "nw"
	var animation_name := "%s-%s" % [animation_prefix, suffix]
	
	if animation_prefix == "idle" and movement_mode != IDLE:
		set_movement_mode(IDLE)
	elif animation_prefix == "sprint" and movement_mode != SPRINT:
		set_movement_mode(SPRINT)
	elif animation_prefix == "run" and movement_mode != RUN:
		set_movement_mode(RUN)
	elif animation_prefix == "walk" and movement_mode != WALK:
		set_movement_mode(WALK)
	elif animation_prefix == "wiggle" and movement_mode != WIGGLE:
		set_movement_mode(WIGGLE)
	
	if $MovementPlayer.current_animation != animation_name:
		if not $EmotePlayer.current_animation.begins_with("ambient") and not animation_name.begins_with("idle"):
			# don't unemote during sitting-still animations; only when changing movement stances
			$EmotePlayer.unemote_immediate()
		if $MovementPlayer.current_animation.begins_with(animation_prefix):
			var old_position: float = $MovementPlayer.current_animation_position
			_suppress_sfx_signal_timer = 0.000000001
			$MovementPlayer.play(animation_name)
			$MovementPlayer.advance(old_position)
		else:
			$MovementPlayer.play(animation_name)
		if not animation_name.begins_with("sprint"):
			$TailZ0.frame = 1 if orientation in [SOUTHWEST, SOUTHEAST] else 2
			$TailZ1.frame = 1 if orientation in [SOUTHWEST, SOUTHEAST] else 2


func set_movement_mode(new_mode: int) -> void:
	var old_mode := movement_mode
	movement_mode = new_mode
	if is_inside_tree():
		emit_signal("movement_mode_changed", old_mode, new_mode)


"""
Returns 'true' if the creature isn't doing anything important, and we can rotate their head or turn them around.
"""
func is_idle() -> bool:
	return not $MovementPlayer.is_playing() or $MovementPlayer.current_animation.begins_with("idle")


"""
Animates the creature's appearance according to the specified mood: happy, angry, etc...

Parameters:
	'mood': The creature's new mood from ChatEvent.Mood
"""
func play_mood(mood: int) -> void:
	$IdleTimer.stop_idle_animation()
	
	if mood == ChatEvent.Mood.NONE:
		pass
	elif mood == ChatEvent.Mood.DEFAULT:
		$EmotePlayer.unemote()
	else:
		$EmotePlayer.emote(mood)


func restart_idle_timer() -> void:
	$IdleTimer.restart()


"""
Emits a signal to play a sound effect.

We temporarily suppress sound effect signals when skipping forward in an animation which plays sound effects.
"""
func emit_sfx_signal(signal_name: String) -> void:
	if _suppress_sfx_signal_timer > 0.0:
		pass
	else:
		emit_signal(signal_name)


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


"""
Removes a 'dna node', one which swaps out based on the creature's DNA.
"""
func _remove_dna_node(path: NodePath) -> void:
	if not has_node(path):
		return
	
	var node := get_node(path)
	# These nodes must be immediately removed to avoid name conflicts with the nodes which replace them.
	node.get_parent().remove_child(node)
	node.queue_free()


"""
Adds a 'dna node', one which swaps out based on the creature's DNA.
"""
func _add_dna_node(node: Node, key_message: String, value_message: String, parent: Node = self) -> void:
	if not node:
		push_warning("Invalid %s: %s" % [key_message, value_message])
		return
	
	parent.add_child(node)
	node.owner = self
	node.creature_visuals_path = node.get_path_to(self)


"""
Unassigns the sprites and animations for the creature.

Different body parts have different animations and textures. Before changing the creature's appearance, any old
textures and animations need to be stopped and removed, and any signals disconnected. This method handles all of that.
"""
func _unload_dna() -> void:
	$EmotePlayer.unemote_immediate()
	for packed_sprite_obj in [
		$Collar,
		$FarArm,
		$FarLeg,
		$NearArm,
		$NearLeg,
		$Sprint,
		$TailZ0,
		$TailZ1,
		$Neck0/HeadBobber/CheekZ0,
		$Neck0/HeadBobber/CheekZ1,
		$Neck0/HeadBobber/CheekZ2,
		$Neck0/HeadBobber/Chin,
		$Neck0/HeadBobber/EarZ0,
		$Neck0/HeadBobber/EarZ1,
		$Neck0/HeadBobber/EarZ2,
		$Neck0/HeadBobber/EyeZ0,
		$Neck0/HeadBobber/EyeZ1,
		$Neck0/HeadBobber/Food,
		$Neck0/HeadBobber/FoodLaser,
		$Neck0/HeadBobber/HairZ0,
		$Neck0/HeadBobber/HairZ1,
		$Neck0/HeadBobber/HairZ2,
		$Neck0/HeadBobber/Head,
		$Neck0/HeadBobber/HornZ0,
		$Neck0/HeadBobber/HornZ1,
		$Neck0/HeadBobber/Mouth,
		$Neck0/HeadBobber/Nose,
	]:
		var packed_sprite: PackedSprite = packed_sprite_obj
		if packed_sprite:
			packed_sprite.texture = null
			packed_sprite.frame_data = ""
	$Body.rect_position = Vector2(-580, -850)
	$Neck0/HeadBobber.position = Vector2(0, -100)
	scale = Vector2(1.00, 1.00)
	
	_remove_dna_node("MouthPlayer")
	_remove_dna_node("EarPlayer")
	_remove_dna_node("Body/Viewport/Body")
	_remove_dna_node("BellyColors/Viewport/Body")
	_remove_dna_node("BodyShadows/Viewport/Body")
	_remove_dna_node("FatSpriteMover")


"""
Assigns the sprites and animations based on the creature's dna.

This method assumes that any existing animations and connections have been disconnected.
"""
func _load_dna() -> void:
	if dna.has("mouth"):
		_add_dna_node(CreatureLoader.new_mouth_player(dna.mouth), "mouth", dna.mouth)
	
	if dna.has("ear"):
		_add_dna_node(CreatureLoader.new_ear_player(dna.ear), "ear", dna.ear)
	
	if dna.has("body"):
		_add_dna_node(CreatureLoader.new_body(dna.body), "body", dna.body, $Body/Viewport)
		_add_dna_node(CreatureLoader.new_body_colors(dna.body), "body colors", dna.body, $BellyColors/Viewport)
		_add_dna_node(CreatureLoader.new_body_shadows(dna.body), "body shadows", dna.body, $BodyShadows/Viewport)
		_add_dna_node(CreatureLoader.new_fat_sprite_mover(dna.body), "fat sprite mover", dna.body)
	
	if has_node("EarPlayer"):
		move_child(get_node("EarPlayer"), $IdleTimer.get_position_in_parent() + 1)
	if has_node("MouthPlayer"):
		_mouth_player = get_node("MouthPlayer")
		move_child(get_node("MouthPlayer"), $IdleTimer.get_position_in_parent() + 1)
	
	for key in dna.keys():
		if key.find("property:") == 0:
			var node_path: String = key.split(":")[1]
			var property_name: String = key.split(":")[2]
			var property_value = dna[key]
			if node_path == "BellyColors/Viewport/Body" and property_name == "belly":
				# set_belly requires an int, not a string
				property_value = int(property_value)
			if has_node(node_path):
				get_node(node_path).set(property_name, property_value)
		if key.find("shader:") == 0:
			var node_path: String = key.split(":")[1]
			var shader_param: String = key.split(":")[2]
			var shader_value = dna[key]
			if has_node(node_path):
				get_node(node_path).material.set_shader_param(shader_param, shader_value)
	
	scale = Vector2(0.60, 0.60) if dna.get("body") == "2" else Vector2(1.00, 1.00)
	visible = true
	
	# initialize creature curves, and reset the mouth/eye frame to avoid a strange transition frame
	reset_frames()
	emit_signal("dna_loaded")
