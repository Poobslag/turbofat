#tool #uncomment to view creature in editor
class_name Creature
extends KinematicBody2D
"""
Script for representing a creature in the 2D overworld.
"""

signal fatness_changed
signal visual_fatness_changed
signal creature_name_changed

signal dna_loaded

signal food_eaten

# The scale of the TextureRect the creature is rendered to
const TEXTURE_SCALE := 0.4

const IDLE = CreatureVisuals.IDLE

const SOUTHEAST = CreatureVisuals.SOUTHEAST
const SOUTHWEST = CreatureVisuals.SOUTHWEST
const NORTHWEST = CreatureVisuals.NORTHWEST
const NORTHEAST = CreatureVisuals.NORTHEAST

# Number from [0.0, 1.0] which determines how quickly the creature slows down
const FRICTION := 0.15

# How slow can the creature move before she stops
const MIN_RUN_SPEED := 150

# How fast can the creature move
const MAX_RUN_SPEED := 338

# How fast can the creature accelerate
const MAX_RUN_ACCELERATION := 2250

export (String) var creature_id: String setget set_creature_id
export (Dictionary) var dna: Dictionary setget set_dna
export (bool) var suppress_sfx: bool = false setget set_suppress_sfx

# how high the creature's torso is from the floor, such as when they're sitting on a stool or standing up
export (int) var elevation: int setget set_elevation

# virtual property; value is only exposed through getters/setters
var creature_def: CreatureDef setget set_creature_def, get_creature_def

# dictionaries containing metadata for which dialog sequences should be launched in which order
var chat_selectors: Array setget set_chat_selectors

# creature conversations which were embedded in the creature definition
#
# key: chat tree id (string)
# value: chat tree json for a conversation the creature can have
var dialog: Dictionary

var creature_name: String setget set_creature_name
var creature_short_name: String
var chat_theme_def: Dictionary setget set_chat_theme_def
var chat_extents: Vector2

# the direction the creature wants to move, in isometric and non-isometric coordinates
var iso_walk_direction := Vector2.ZERO
var non_iso_walk_direction := Vector2.ZERO setget set_non_iso_walk_direction

# 'true' if the creature is being slowed by friction while stopping or turning
var _friction := false

# the velocity the player is moving, in isometric and non-isometric coordinates
var _iso_velocity := Vector2.ZERO
var _non_iso_velocity := Vector2.ZERO

# a number from [0.0 - 1.0] based on how fast the creature can move with their current animation
var _run_anim_speed := 1.0

onready var creature_visuals: CreatureVisuals = $CreatureOutline/Viewport/Visuals

func _ready() -> void:
	$CreatureOutline/TextureRect.rect_scale = Vector2(TEXTURE_SCALE, TEXTURE_SCALE)
	if creature_id:
		_refresh_creature_id()
	else:
		refresh_dna()


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	_apply_friction()
	_apply_walk(delta)
	_update_animation()
	var old_non_iso_velocity := _non_iso_velocity
	set_iso_velocity(move_and_slide(_iso_velocity))
	_maybe_play_bonk_sound(old_non_iso_velocity)


func set_suppress_sfx(new_suppress_sfx: bool) -> void:
	suppress_sfx = new_suppress_sfx
	$CreatureSfx.suppress_sfx = new_suppress_sfx


func set_elevation(new_elevation: int) -> void:
	elevation = new_elevation
	$CreatureOutline.position.y = -new_elevation * $CreatureOutline/TextureRect.rect_scale.y


func set_comfort(new_comfort: float) -> void:
	creature_visuals.set_comfort(new_comfort)


func set_fatness(new_fatness: float) -> void:
	creature_visuals.set_fatness(new_fatness)


func get_fatness() -> float:
	return creature_visuals.get_fatness() if creature_visuals else 1.0


func set_visual_fatness(new_visual_fatness: float) -> void:
	creature_visuals.visual_fatness = new_visual_fatness


func get_visual_fatness() -> float:
	return creature_visuals.visual_fatness


func set_non_iso_walk_direction(new_direction: Vector2) -> void:
	non_iso_walk_direction = new_direction
	iso_walk_direction = Global.to_iso(new_direction)


func set_iso_velocity(new_velocity: Vector2) -> void:
	_iso_velocity = new_velocity
	_non_iso_velocity = Global.from_iso(new_velocity)


func set_non_iso_velocity(new_velocity: Vector2) -> void:
	_non_iso_velocity = new_velocity
	_iso_velocity = Global.to_iso(new_velocity)


func set_dna(new_dna: Dictionary) -> void:
	dna = new_dna
	set_meta("dna", dna)
	refresh_dna()


func set_chat_selectors(new_chat_selectors: Array) -> void:
	chat_selectors = new_chat_selectors
	set_meta("chat_selectors", chat_selectors)


func set_creature_id(new_creature_id: String) -> void:
	creature_id = new_creature_id
	_refresh_creature_id()


func set_creature_name(new_creature_name: String) -> void:
	creature_name = new_creature_name
	set_meta("chat_name", creature_name)
	emit_signal("creature_name_changed")


func set_chat_theme_def(new_chat_theme_def: Dictionary) -> void:
	chat_theme_def = new_chat_theme_def
	set_meta("chat_theme_def", chat_theme_def)


"""
Plays a movement animation with the specified prefix and direction, such as a 'run' animation going left.

Parameters:
	'animation_prefix': A partial name of an animation on Creature/MovementPlayer, omitting the directional suffix
	
	'movement_direction': A vector in the (X, Y) direction the creature is moving.
"""
func play_movement_animation(animation_prefix: String, movement_direction: Vector2 = Vector2.ZERO) -> void:
	creature_visuals.play_movement_animation(animation_prefix, movement_direction)


"""
Animates the creature's appearance according to the specified mood: happy, angry, etc...

Parameters:
	'mood': The creature's new mood from ChatEvent.Mood
"""
func play_mood(mood: int) -> void:
	creature_visuals.play_mood(mood)


"""
Orients this creature so they're facing the specified target.
"""
func orient_toward(target: Node2D) -> void:
	# calculate the relative direction of the object this creature should face
	var direction: Vector2 = Global.from_iso(position.direction_to(target.position))
	var direction_dot := 0.0
	if direction:
		direction_dot = direction.normalized().dot(Vector2.RIGHT)
		if direction_dot == 0.0:
			# if two characters are directly above/below each other, make them face opposite directions
			direction_dot = direction.normalized().dot(Vector2.DOWN)

	if direction_dot > 0:
		# the target is to the right; face right
		creature_visuals.set_orientation(SOUTHEAST)
	elif direction_dot < 0:
		# the target is to the left; face left
		creature_visuals.set_orientation(SOUTHWEST)


func set_orientation(orientation: int) -> void:
	creature_visuals.set_orientation(orientation)


func get_orientation() -> int:
	return creature_visuals.orientation


"""
Plays a 'hello!' voice sample, for when a creature enters the restaurant
"""
func play_hello_voice(force: bool = false) -> void:
	if not suppress_sfx:
		$CreatureSfx.play_hello_voice(force)


"""
Plays a 'mmm!' voice sample, for when a player builds a big combo.
"""
func play_combo_voice() -> void:
	if not suppress_sfx:
		$CreatureSfx.play_combo_voice()


"""
Plays a 'check please!' voice sample, for when a creature is ready to leave
"""
func play_goodbye_voice(force: bool = false) -> void:
	if not suppress_sfx:
		$CreatureSfx.play_goodbye_voice(force)


func feed(food_color: Color) -> void:
	creature_visuals.feed(food_color)


func restart_idle_timer() -> void:
	creature_visuals.restart_idle_timer()


func set_creature_def(new_creature_def: CreatureDef) -> void:
	creature_id = new_creature_def.creature_id
	set_dna(new_creature_def.dna)
	set_creature_name(new_creature_def.creature_name)
	creature_short_name = new_creature_def.creature_short_name
	set_chat_selectors(new_creature_def.chat_selectors)
	dialog = new_creature_def.dialog
	set_chat_theme_def(new_creature_def.chat_theme_def)
	set_fatness(new_creature_def.fatness)
	creature_visuals.set_visual_fatness(new_creature_def.fatness)


func get_creature_def() -> CreatureDef:
	var result := CreatureDef.new()
	result.creature_id = creature_id
	result.dna = DnaUtils.trim_dna(dna)
	result.creature_name = creature_name
	result.creature_short_name = creature_short_name
	result.dialog = dialog
	result.chat_theme_def = chat_theme_def
	result.fatness = get_fatness()
	return result


"""
Build a list of level ids from the creature's chat selectors.
"""
func get_level_ids() -> Array:
	var level_ids := []
	for chat_selector_obj in chat_selectors:
		var chat_selector: Dictionary = chat_selector_obj
		if chat_selector.has("level"):
			level_ids.append(chat_selector["level"])
	return level_ids


func refresh_dna() -> void:
	if is_inside_tree():
		if dna:
			dna = DnaUtils.fill_dna(dna)
		creature_visuals.dna = dna
		if dna.has("line_rgb"):
			$CreatureOutline/TextureRect.material.set_shader_param("black", Color(dna.line_rgb))


"""
Workaround for Godot #21789 to make get_class return class_name
"""
func get_class() -> String:
	return "Creature"


"""
Workaround for Godot #21789 to make is_class match class_name
"""
func is_class(name: String) -> bool:
	return name == "Creature" or .is_class(name)


func _refresh_creature_id() -> void:
	if is_inside_tree():
		set_creature_def(CreatureLoader.load_creature_def_by_id(creature_id))


func _apply_friction() -> void:
	if _iso_velocity and iso_walk_direction:
		_friction = _non_iso_velocity.normalized().dot(non_iso_walk_direction.normalized()) < 0.25
	else:
		_friction = true
	
	if _friction:
		set_non_iso_velocity(lerp(_non_iso_velocity, Vector2.ZERO, FRICTION))
		if _non_iso_velocity.length() < MIN_RUN_SPEED * _run_anim_speed:
			set_non_iso_velocity(Vector2.ZERO)


func _apply_walk(delta: float) -> void:
	if iso_walk_direction:
		_accelerate_xy(delta, non_iso_walk_direction, MAX_RUN_ACCELERATION, MAX_RUN_SPEED * _run_anim_speed)


"""
Accelerates the creature horizontally.

If the creature would be accelerated beyond the specified maximum speed, the creature's acceleration is reduced.
"""
func _accelerate_xy(delta: float, _non_iso_push_direction: Vector2,
		acceleration: float, max_speed: float) -> void:
	if _non_iso_push_direction.length() == 0:
		return

	var accel_vector := _non_iso_push_direction.normalized() * acceleration * delta
	var new_velocity := _non_iso_velocity + accel_vector
	if new_velocity.length() > _non_iso_velocity.length() and new_velocity.length() > max_speed:
		new_velocity = new_velocity.normalized() * max_speed
	set_non_iso_velocity(new_velocity)


"""
Plays a bonk sound if a creature bumps into a wall.
"""
func _maybe_play_bonk_sound(old_non_iso_velocity: Vector2) -> void:
	var velocity_diff := _non_iso_velocity - old_non_iso_velocity
	if velocity_diff.length() > MAX_RUN_SPEED * _run_anim_speed * 0.9:
		if not suppress_sfx:
			$BonkSound.play()


"""
Updates the movement animation and run speed.

The run speed varies based on how fat the creature is.
"""
func _update_animation() -> void:
	if non_iso_walk_direction.length() > 0:
		var animation_prefix: String
		_run_anim_speed = creature_visuals.scale.y
		if creature_visuals.fatness >= 3.5:
			animation_prefix = "wiggle"
			_run_anim_speed *= 0.200
		elif creature_visuals.fatness >= 2.2:
			animation_prefix = "walk"
			_run_anim_speed *= 0.400
		elif creature_visuals.fatness >= 1.1:
			animation_prefix = "run"
			_run_anim_speed *= 0.700
		else:
			animation_prefix = "sprint"
			_run_anim_speed *= 1.000
		
		play_movement_animation(animation_prefix, non_iso_walk_direction)
	elif creature_visuals.movement_mode != CreatureVisuals.IDLE:
		play_movement_animation("idle", _non_iso_velocity)


func get_movement_mode() -> int:
	return creature_visuals.movement_mode


func _on_CreatureVisuals_landed() -> void:
	if not suppress_sfx:
		$HopSound.play()


func _on_Creature_fatness_changed() -> void:
	emit_signal("fatness_changed")


func _on_CreatureVisuals_dna_loaded() -> void:
	visible = true
	emit_signal("dna_loaded")


func _on_CreatureVisuals_food_eaten() -> void:
	emit_signal("food_eaten")


func _on_CreatureVisuals_visual_fatness_changed() -> void:
	emit_signal("visual_fatness_changed")


func _on_CollisionShape2D_extents_changed(value: Vector2) -> void:
	chat_extents = value


func _on_CreatureVisuals_movement_mode_changed(_old_mode: int, new_mode: int) -> void:
	if new_mode in [CreatureVisuals.WALK, CreatureVisuals.RUN]:
		# when on two legs, the body is a little higher off the ground
		set_elevation(35)
	else:
		set_elevation(0)
