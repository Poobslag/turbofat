#tool #uncomment to view creature in editor
class_name CreatureVisuals
extends Node2D
## Handles animations and audio/visual effects for a creature.
##
## To edit creatures in the Godot editor:
## 	1. Run the 'edit-creature.sh on' shell command to enable the necessary tool scripts
## 	2. Toggle the CreatureVisuals.random_creature property in the Godot editor
## 	3. Make your changes
## 	4. When you're finished, toggle the CreatureVisuals.reset_creature property in the Godot editor
## 	5. Lastly, run the 'edit-creature.sh off' shell command to disable the necessary tool scripts
##
## Do not leave the tool scripts enabled. Doing so causes errors in the Godot console and impacts performance as
## unnecessary textures are loaded.

## emitted on the frame when creature bites into some food
signal food_eaten(food_type)

## emitted when a creature's textures and animations are loaded
signal dna_loaded

## emitted when a creature is assigned new set of dna
signal dna_changed(dna)

## emitted during the 'run' animation when the creature touches the ground
# warning-ignore:unused_signal
signal landed

signal orientation_changed(old_orientation, new_orientation)
signal movement_mode_changed(old_mode, new_mode)
signal fatness_changed
signal visual_fatness_changed
signal comfort_changed
signal talking_changed

## emitted by FatSpriteMover when it moves the head by making the creature fatter
# warning-ignore:unused_signal
signal head_moved

const SOUTHEAST_DIR := Vector2(0.70710678118, 0.70710678118)

## toggle to assign default animation frames based on the creature's orientation
export (bool) var _reset_frames setget reset_frames

## toggle to remove the creature's textures
export (bool) var _reset_creature setget reset_creature

## toggle to generate a creature with a random appearance
export (bool) var _random_creature setget random_creature

## state of whether the creature is walking, running or idle
export (Creatures.MovementMode) var movement_mode := Creatures.IDLE setget set_movement_mode

## direction the creature is facing
export (Creatures.Orientation) var orientation := Creatures.SOUTHEAST setget set_orientation

## colors and textures used to draw the creature
export (Dictionary) var dna: Dictionary setget set_dna

## how fat the creature looks right now; gradually approaches the 'fatness' property
export (float, 1.0, 10.0) var visual_fatness := 1.0 setget set_visual_fatness

## how fat the creature should be; 5.0 = 5x normal size
var fatness := 1.0 setget set_fatness

## comfort improves as the creature eats, and degrades as they overeat. comfort is a number from [-1.0, 1.0]. -1.0 is
## very uncomfortable, 1.0 is very comfortable
var comfort := 0.0 setget set_comfort

## MouthPlayer instance which animates mouths
var mouth_player

var creature_sfx: CreatureSfx setget set_creature_sfx

## For bouncy feeding animation, allowing inertia and acceleration.
## (See: creature_visuals.update_fattening_animation)
var _fattening_inertia: float = 0

## Stores the normal scale for the creature (right now just 0.6 for squirrels)
## Changed upon creature_visuals.rescale(), used so we can squash and stretch based on this value
var _base_scale: Vector2 = Vector2.ONE

## forces listeners to update their animation frame
var _force_orientation_change := false

## food type the creature is eating
var _food_type: int

## CreatureAnimations instance which animates the creature's limbs, facial expressions and movement.
onready var _animations: Node = $Animations

func _ready() -> void:
	# Update creature's appearance based on their behavior and orientation
	set_orientation(orientation)
	
	if not Engine.editor_hint:
		# Don't connect IdleTimer signal in the editor; it is not a tool script and produces an error
		connect("dna_loaded", $Animations/IdleTimer, "_on_CreatureVisuals_dna_loaded")
	
	$DnaLoader.connect("dna_loaded", self, "_on_DnaLoader_dna_loaded")
	$TalkTimer.connect("timeout", self, "_on_TalkTimer_timeout")
	_refresh_creature_sfx()


func _physics_process(_delta: float) -> void:
	if Engine.editor_hint:
		# don't move stuff in the editor
		return
	update_fattening_animation()


func update_fattening_animation() -> void:
	# bouncy animation; acceleration and squash n' stretch
	if visual_fatness == fatness and _fattening_inertia < 0.05:
		_fattening_inertia = 0.0
		return
	# inertia/acceleration/fatness/etc:
	# as we make this value bigger, the amount of time to accelerate decreases:
	var lerp_speed: float = 0.05
	# as we make this value bigger, the acceleration rises (more jiggle):
	var inertia_this_frame_slope: float = (fatness - visual_fatness) / 1.0
	_fattening_inertia = lerp(_fattening_inertia, inertia_this_frame_slope, lerp_speed)
	visual_fatness += _fattening_inertia
	# bounce to prevent visual_fatness from going too small (avoid becoming negative or thin)
	if visual_fatness < 1.0 and _fattening_inertia < 0:
		_fattening_inertia = -_fattening_inertia
	# dampening (reduces jiggle)
	visual_fatness = lerp(visual_fatness, fatness, 0.04)
	# behavior for values outside the range [1.0, 10.0] is undefined and results in visual errors
	visual_fatness = clamp(visual_fatness, 1.0, 10.0)
	set_visual_fatness(visual_fatness)
	# squash n' stretch
	var squash_amount: float = 1.0
	var stretch_amount: float = 1.0
	if _fattening_inertia > 0:
		squash_amount = 1 + abs(_fattening_inertia)
	else:
		# we won't see _fattening_inertia <= 0 often as it's only a little bit of rubber-banding that get us there
		stretch_amount = 1 + abs(_fattening_inertia)
	var normalized_squash_stretch: Vector2 = Vector2(squash_amount, stretch_amount).normalized()
	var squash_stretch: Vector2 = normalized_squash_stretch / 0.7107 * _base_scale\
			* max(stretch_amount, squash_amount)
	self.rescale(squash_stretch.x, squash_stretch.y, false)


func set_creature_sfx(new_creature_sfx: CreatureSfx) -> void:
	creature_sfx = new_creature_sfx
	_refresh_creature_sfx()


func set_comfort(new_comfort: float) -> void:
	comfort = new_comfort
	emit_signal("comfort_changed")


func set_visual_fatness(new_visual_fatness: float) -> void:
	visual_fatness = new_visual_fatness
	emit_signal("visual_fatness_changed")


## Increases/decreases the creature's fatness, a float which determines how fat
## the creature should be; 5.0 = 5x normal size
##
## Parameters:
## 	'new_fatness': Controls how fat the creature should be; 5.0 = 5x normal size
func set_fatness(new_fatness: float) -> void:
	fatness = new_fatness
	emit_signal("fatness_changed")


## Updates the frame to something appropriate for the creature's orientation.
##
## Usually the frame is controlled by an animation. But when it's not, this ensures it still looks reasonable.
func reset_frames(value: bool = true) -> void:
	if not value:
		return
	
	reset_eye_frames()
	$Neck0/HeadBobber/Mouth.frame = 1 if oriented_south() else 2
	$Neck0/HeadBobber/Chin.frame = 1 if oriented_south() else 2
	$TailZ0.frame = 1 if oriented_south() else 2
	$TailZ1.frame = 1 if oriented_south() else 2
	emit_signal("orientation_changed", -1, orientation)


## Resets the eyes to a forward/backward facing frame.
##
## Because the eye frames also become visible/invisible during emotes, they don't react to normal orientation/movement
## changes and are instead reset manually.
func reset_eye_frames() -> void:
	$Neck0/HeadBobber/EyeZ0.frame = 1 if oriented_south() else 2
	$Neck0/HeadBobber/EyeZ1.frame = 1 if oriented_south() else 2


## Remove the creature's textures.
func reset_creature(value: bool = true) -> void:
	if not value:
		return
	set_dna({})


## Generates a creature with a random appearance.
func random_creature(value: bool = true) -> void:
	if not value:
		return
	var new_dna: Dictionary = DnaUtils.random_dna()
	set_dna(new_dna)


## Sets the creature's orientation, and alters their appearance appropriately.
##
## If the creature swaps between facing left or right, certain sprites are flipped horizontally. If the creature swaps
## between facing forward or backward, certain sprites play different animations or toggle between different frames.
func set_orientation(new_orientation: int) -> void:
	var old_orientation := orientation
	orientation = new_orientation
	if not is_inside_tree():
		# avoid 'node not found' errors when tree is null
		return
	
	if oriented_south() != Creatures.oriented_south(old_orientation):
		# creature changed from facing north to south or vice versa
		
		# update their eyes to a default frame to prevent them from having
		# eyes on the back of their head, or no eyes at all
		reset_eye_frames()
		
		# when facing north, the head goes behind the body
		$Neck0.z_index = 0 if oriented_south() else -1
	
	rescale(scale.x)
	
	if _force_orientation_change:
		# some listeners try to distinguish between 'big orientation changes' and 'little orientation changes'. if
		# _force_orientation_change is true, we signal to everyone that they cannot transition from the old
		# orientation by making it something nonsensical
		old_orientation = -1
	
	emit_signal("orientation_changed", old_orientation, new_orientation)


## Adjusts the creature's scale, flipping them horizontally based on their orientation.
##
## The sprite resources portray creatures facing southeast/northwest, and need to be horizontally flipped for other
## orientations.
##
## Parameters:
## 	'new_scale_x': The new scale.x and scale.y value. Negative values are OK, and will be normalized.
##  'new_scale_y': (Optional) Scale.y will be equal to this rather than equivalent to 'new_scale_x'
##  'is_base_scale': (Optional) Controls whether creature's _base_scale will be changed (good in temporary animation)
func rescale(new_scale_x: float, new_scale_y: float = -1, is_base_scale: bool = true) -> void:
	if new_scale_y == -1:
		new_scale_y = new_scale_x
	scale = Vector2(abs(new_scale_x), abs(new_scale_y))

	if is_base_scale:
		_base_scale = scale
	
	scale.x = abs(scale.x) if orientation in [Creatures.SOUTHEAST, Creatures.NORTHWEST] \
			else -abs(scale.x)
	
	# Body is rendered facing southeast/northeast, and is horizontally flipped for other directions. Unfortunately
	# its parent object is already flipped in some cases, making the following line of code quite unintuitive.
	$Body.scale.x = 1 if oriented_south() else -1


## Launches the 'feed' animation. The creature makes a biting motion and plays a munch sound.
##
## Parameters:
## 	'food_type': Enum from FoodType corresponding to the food to show
func feed(food_type: int) -> void:
	if not visible:
		# If no creature is visible, it could mean their resources haven't loaded yet. Don't play any animations or
		# sounds. ...Maybe as an easter egg some day, we can make the chef flinging food into empty air. Ha ha.
		return
	
	if not $TalkTimer.is_stopped():
		$TalkTimer.stop()
		emit_signal("talking_changed")
	_food_type = food_type
	_animations.eat()
	if mouth_player:
		mouth_player.eat()


## Updates the creature's appearance according to the specified creature definition.
func set_dna(new_dna: Dictionary) -> void:
	dna = new_dna
	if not is_inside_tree():
		return
	
	CreatureLoader.load_details(dna)
	# any AnimationPlayers are stopped, otherwise old players will continue controlling the sprites
	$DnaLoader.unload_dna()
	$DnaLoader.load_dna()
	emit_signal("dna_changed", dna)


## The 'feed' animation causes a few side-effects. The creature's head recoils and some sounds play. This method
## controls all of those secondary visual effects of the creature being fed.
func show_food_effects() -> void:
	_animations.show_food_effects()
	emit_signal("food_eaten", _food_type)


func oriented_south() -> bool:
	return Creatures.oriented_south(orientation)


func oriented_north() -> bool:
	return Creatures.oriented_north(orientation)


## Plays a movement animation with the specified prefix and direction, such as a 'run' animation going left.
##
## Parameters:
## 	'animation_prefix': A partial name of an animation on $Creature/Animations/MovementPlayer, omitting the directional
## 		suffix
##
## 	'movement_direction': A vector in the (X, Y) direction the creature is moving.
func play_movement_animation(animation_prefix: String, movement_direction: Vector2 = Vector2.ZERO) -> void:
	if movement_direction.length() > 0.1:
		# tiny movement vectors are often the result of a collision. we ignore these to avoid constantly flipping
		# their orientation if they're mashing themselves into a wall
		var new_orientation := _compute_orientation(movement_direction)
		if new_orientation != orientation:
			set_orientation(new_orientation)
	var suffix := "se" if oriented_south() else "nw"
	var animation_name := "%s-%s" % [animation_prefix, suffix]
	
	if animation_prefix == "idle" and movement_mode != Creatures.IDLE:
		set_movement_mode(Creatures.IDLE)
	elif animation_prefix == "sprint" and movement_mode != Creatures.SPRINT:
		set_movement_mode(Creatures.SPRINT)
	elif animation_prefix == "run" and movement_mode != Creatures.RUN:
		set_movement_mode(Creatures.RUN)
	elif animation_prefix == "walk" and movement_mode != Creatures.WALK:
		set_movement_mode(Creatures.WALK)
	elif animation_prefix == "wiggle" and movement_mode != Creatures.WIGGLE:
		set_movement_mode(Creatures.WIGGLE)
	
	_animations.play_movement_animation(animation_name)


func set_movement_mode(new_mode: int) -> void:
	var old_mode := movement_mode
	movement_mode = new_mode
	if is_inside_tree():
		emit_signal("movement_mode_changed", old_mode, new_mode)


## Animates the creature's appearance according to the specified mood: happy, angry, etc...
##
## Parameters:
## 	'mood': The creature's new mood from Creatures.Mood
func play_mood(mood: int) -> void:
	if oriented_south():
		# Only play moods for south-facing creatures. Creatures do not have north-facing emotes, and playing them
		# causes glitches (eyes on the back of the head, etc)
		_animations.play_mood(mood)


func restart_idle_timer() -> void:
	_animations.restart_idle_timer()


## Emits a signal to play a sound effect.
func emit_sfx_signal(signal_name: String) -> void:
	emit_signal(signal_name)


## Launches a talking animation, opening and closes the creature's mouth for a few seconds.
func talk() -> void:
	$TalkTimer.start()
	emit_signal("talking_changed")


## Returns 'true' of the creature's talk animation is playing.
func is_talking() -> bool:
	return not $TalkTimer.is_stopped()


## Returns the number of seconds between the beginning of the eating animation and the 'chomp' noise.
func get_eating_delay() -> float:
	return 0.033


func _refresh_creature_sfx() -> void:
	if not is_inside_tree():
		return
	
	_animations.creature_sfx = creature_sfx


## Computes the nearest orientation for the specified direction.
##
## For example, a direction of (0.99, -0.13) is mostly pointing towards the x-axis, so it would result in an
## orientation of 'southeast'.
func _compute_orientation(direction: Vector2) -> int:
	if direction.length() == 0:
		# we default to the current orientation if given a zero-length vector
		return orientation
	
	var adjusted_direction := direction
	
	# we adjust creatures facing directly west/east to face southwest/southeast so we can see their face
	if is_equal_approx(adjusted_direction.y, 0.0):
		adjusted_direction.y = 0.01
	
	var new_orientation: int = orientation
	# unrounded orientation is a float in the range [-2.0, 2.0]
	var unrounded_orientation := -2 * adjusted_direction.angle_to(SOUTHEAST_DIR) / PI
	if abs(unrounded_orientation - orientation) < 0.6 or abs(unrounded_orientation + 4 - orientation) < 0.6:
		# preserve the old orientation if it's close to the new orientation. this prevents us from flipping repeatedly
		# when our direction puts us between two orientations.
		pass
	else:
		# convert the float orientation [-2.0, 2.0] to an int orientation [0, 3]
		new_orientation = wrapi(int(round(unrounded_orientation)), 0, 4)
	return new_orientation


func _on_DnaLoader_dna_loaded() -> void:
	emit_signal("dna_loaded")


func _on_TalkTimer_timeout() -> void:
	emit_signal("talking_changed")
