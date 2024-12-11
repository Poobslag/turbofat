#tool #uncomment to view creature in editor
class_name Creature
extends KinematicBody2D
## Script for representing a creature in the 2D overworld.

signal fatness_changed
signal visual_fatness_changed
signal creature_name_changed
signal talking_changed

signal dna_loaded

## emitted on the frame when creature bites into some food
signal food_eaten(food_type)

## emitted during the 'run' animation when the creature touches the ground
signal landed

## emitted after a creature finishes fading in/out and their visible/modulate values are finalized
signal fade_in_finished
signal fade_out_finished

const IDLE := Creatures.IDLE

## Number from [0.0, 1.0] which determines how quickly the creature slows down
const FRICTION := 0.15

## How slow can the creature move before she stops
const MIN_RUN_SPEED := 150

## How fast can the creature move
const MAX_RUN_SPEED := 338

## How fast can the creature accelerate
const MAX_RUN_ACCELERATION := 2250

const CREATURE_FADE_IN_DURATION := 0.6
const CREATURE_FADE_OUT_DURATION := 0.3

export (String) var creature_id: String setget set_creature_id
export (Dictionary) var dna: Dictionary setget set_dna

## 'true' if the creature should not make any sounds when walking/loading. Used for the creature editor.
export (bool) var suppress_sfx: bool = false setget set_suppress_sfx

## if 'true' the creature will only use the fatness in the creature definition,
## ignoring any accrued fatness from puzzles
export (bool) var suppress_fatness: bool = false

## how high the creature's torso is from the floor, such as when they're sitting on a stool or standing up
export (float) var elevation: float setget set_elevation

## virtual property; value is not kept up-to-date and should only be accessed through getters/setters
export (Creatures.Orientation) var orientation: int setget set_orientation, get_orientation

## virtual property; value is only exposed through getters/setters
var creature_def: CreatureDef setget set_creature_def, get_creature_def

## dictionaries containing metadata for which chat sequences should be launched in which order
var chat_selectors: Array setget set_chat_selectors

var creature_name: String setget set_creature_name
var creature_short_name: String
var chat_theme := ChatTheme.new() setget set_chat_theme
var chat_extents: Vector2 setget ,get_chat_extents

## direction the creature wants to move, in isometric and non-isometric coordinates
var iso_walk_direction := Vector2.ZERO
var non_iso_walk_direction := Vector2.ZERO setget set_non_iso_walk_direction

## number of times the creature was fed during this puzzle
var feed_count := 0
var box_feed_count := 0

## minimum fatness; some creatures never get very thin
var min_fatness := 1.0

## how fast the creature should gain weight during a puzzle. 4.0x = four times faster than normal.
## 0.0 = creature does not gain weight
var weight_gain_scale := 1.0

## how fast the creature should lose weight between puzzles. 0.25x = four times slower than normal.
var metabolism_scale := 1.0

## base fatness when the creature enters the restaurant
## player score is added to this to determine their new fatness
var base_fatness := 1.0

var creature_visuals: CreatureVisuals

## Virtual property; value is only exposed through getters/setters
var fatness: float setget set_fatness, get_fatness

## Virtual property; value is only exposed through getters/setters
var visual_fatness: float setget set_visual_fatness, get_visual_fatness

## 'true' if the creature is being slowed by friction while stopping or turning
var _friction := false

## velocity the player is moving, in isometric and non-isometric coordinates
var _iso_velocity := Vector2.ZERO
var _non_iso_velocity := Vector2.ZERO

## handles animations and audio/visual effects for a creature
var _creature_outline: CreatureOutline

var _fade_tween: SceneTreeTween

onready var _creature_sfx: CreatureSfx = $CreatureSfx
onready var _collision_shape: CollisionShape2D = $CollisionShape2D
onready var _mouth_hook: Node2D = $MouthHook

func _ready() -> void:
	var creature_outline_scene_path := "res://src/main/world/creature/ViewportCreatureOutline.tscn"
	if not Engine.editor_hint \
			and SystemData.graphics_settings.creature_detail == GraphicsSettings.CreatureDetail.LOW:
		creature_outline_scene_path = "res://src/main/world/creature/FastCreatureOutline.tscn"
	var creature_outline_scene: PackedScene
	if Engine.editor_hint:
		# ResourceCache is not available in tool scripts
		creature_outline_scene = load(creature_outline_scene_path)
	else:
		creature_outline_scene = ResourceCache.get_resource(creature_outline_scene_path)
	_creature_outline = creature_outline_scene.instance()
	add_child(_creature_outline)
	
	creature_visuals = _creature_outline.creature_visuals
	if not Engine.editor_hint:
		_mouth_hook.creature_visuals = creature_visuals
		_collision_shape.creature_visuals = creature_visuals
	creature_visuals.creature_sfx = _creature_sfx
	
	creature_visuals.connect("dna_loaded", self, "_on_CreatureVisuals_dna_loaded")
	creature_visuals.connect("fatness_changed", self, "_on_CreatureVisuals_fatness_changed")
	creature_visuals.connect("food_eaten", self, "_on_CreatureVisuals_food_eaten")
	creature_visuals.connect("landed", self, "_on_CreatureVisuals_landed")
	creature_visuals.connect("movement_mode_changed", self, "_on_CreatureVisuals_movement_mode_changed")
	creature_visuals.connect("talking_changed", self, "_on_CreatureVisuals_talking_changed")
	creature_visuals.connect("visual_fatness_changed", self, "_on_CreatureVisuals_visual_fatness_changed")
	
	SceneTransition.connect("fade_in_started", self, "_on_SceneTransition_fade_in_started")
	
	if creature_id:
		_refresh_creature_id()
	else:
		refresh_dna()
	creature_visuals.orientation = orientation
	_refresh_elevation()


func _physics_process(delta: float) -> void:
	if Engine.editor_hint:
		return
	
	_apply_friction()
	_apply_walk(delta)
	_update_animation()
	var old_non_iso_velocity := _non_iso_velocity
	set_iso_velocity(move_and_slide(_iso_velocity))
	_maybe_play_bonk_sound(old_non_iso_velocity)


## Increases the collision shape size for fatter creatures.
##
## This is not done on all creatures, because having fatter creatures collide with chairs/tables differently as they
## gain weight introduces problems. It's easier to leave their collision shapes consistent and just have a few visual
## bugs here and there.
func refresh_collision_extents() -> void:
	_collision_shape.refresh_extents()


func set_collision_disabled(new_collision_disabled: bool) -> void:
	_collision_shape.disabled = new_collision_disabled


func set_suppress_sfx(new_suppress_sfx: bool) -> void:
	suppress_sfx = new_suppress_sfx
	$CreatureSfx.suppress_sfx = new_suppress_sfx


func set_elevation(new_elevation: float) -> void:
	elevation = new_elevation
	_refresh_elevation()


func set_comfort(new_comfort: float) -> void:
	creature_visuals.set_comfort(new_comfort)


func set_fatness(new_fatness: float) -> void:
	creature_visuals.fatness = new_fatness


func get_fatness() -> float:
	return creature_visuals.fatness if creature_visuals else 1.0


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
	feed_count = 0
	box_feed_count = 0


func set_chat_selectors(new_chat_selectors: Array) -> void:
	chat_selectors = new_chat_selectors
	set_meta("chat_selectors", chat_selectors)


func set_creature_id(new_creature_id: String) -> void:
	creature_id = new_creature_id
	set_meta("chat_id", creature_id)
	_refresh_creature_id()


func set_creature_name(new_creature_name: String) -> void:
	creature_name = new_creature_name
	emit_signal("creature_name_changed")


func set_chat_theme(new_chat_theme: ChatTheme) -> void:
	chat_theme = new_chat_theme
	set_meta("chat_theme", chat_theme)


## Plays a movement animation with the specified prefix and direction, such as a 'run' animation going left.
##
## Parameters:
## 	'animation_prefix': The partial name of an animation on Creature/MovementPlayer, omitting the directional
## 		suffix
##
## 	'movement_direction': A vector in the (X, Y) direction the creature is moving.
func play_movement_animation(animation_prefix: String, movement_direction: Vector2 = Vector2.ZERO) -> void:
	creature_visuals.play_movement_animation(animation_prefix, movement_direction)


## Animates the creature's appearance according to the specified mood: happy, angry, etc...
##
## Parameters:
## 	'mood': The creature's new mood from Creatures.Mood
func play_mood(mood: int) -> void:
	creature_visuals.play_mood(mood)


## Orients this creature so they're facing the specified target.
func orient_toward(target_position: Vector2) -> void:
	# calculate the relative direction of the object this creature should face
	var direction: Vector2 = Global.from_iso(position.direction_to(target_position))
	var direction_dot := 0.0
	if direction:
		direction_dot = direction.normalized().dot(Vector2.RIGHT)
		if direction_dot == 0.0:
			# if two characters are directly above/below each other, make them face opposite directions
			direction_dot = direction.normalized().dot(Vector2.DOWN)
	
	# orient this creature based on the calculated direction
	set_orientation(Creatures.SOUTHEAST if direction_dot > 0 else Creatures.SOUTHWEST)


func set_orientation(new_orientation: int) -> void:
	orientation = new_orientation
	if creature_visuals:
		creature_visuals.orientation = new_orientation


func get_orientation() -> int:
	return creature_visuals.orientation if creature_visuals else orientation


## Stores this creature's fatness in the CreatureLibrary.
##
## This allows the creature to maintain their fatness if we see them again. They lose a little weight in between.
##
## Parameters:
## 	'stored_fatness': The fatness to save in the creature library. This can be higher than the creature's current
## 		fatness if they're still eating.
func save_fatness(stored_fatness: float) -> void:
	if creature_id.empty():
		# randomly-generated creatures have no creature id; their fatness isn't stored
		return
	
	# weight decreases by 10% if they ate normally; 25% if they ate only vegetables
	var metabolism := 0.9 if box_feed_count > 0 else 0.75
	# apply metabolism scale; a value of 4.0x means their weight decays 4x as fast
	metabolism = pow(metabolism, metabolism_scale)
	stored_fatness *= metabolism
	stored_fatness = clamp(stored_fatness, min_fatness, Creatures.MAX_FATNESS)
	PlayerData.creature_library.set_fatness(creature_id, stored_fatness)


## Plays a 'hello!' voice sample for when a creature enters the restaurant.
func play_hello_voice() -> void:
	_creature_sfx.play_hello_voice()


## Plays a 'mmm!' voice sample for when a player builds a big combo.
func play_combo_voice() -> void:
	_creature_sfx.play_combo_voice()


## Plays a 'check please!' voice sample for when a creature is ready to leave.
func play_goodbye_voice() -> void:
	_creature_sfx.play_goodbye_voice()


## Parameters:
## 	'food_type': Enum from FoodType corresponding to the food to show
func feed(food_type: int) -> void:
	feed_count += 1
	box_feed_count += 1
	creature_visuals.feed(food_type)


## Changes the creature's name, and derives a new short name and creature id from their new name.
##
## A creature's name shouldn't change during regular gameplay. This is only for the creature editor and for other
## randomly generated creatures.
func rename(new_creature_name: String) -> void:
	set_creature_name(new_creature_name)
	creature_short_name = NameUtils.sanitize_short_name(creature_name)


func restart_idle_timer() -> void:
	creature_visuals.restart_idle_timer()


func set_creature_def(new_creature_def: CreatureDef) -> void:
	creature_id = new_creature_def.creature_id
	set_dna(new_creature_def.dna)
	set_chat_theme(new_creature_def.chat_theme)
	set_creature_name(new_creature_def.creature_name)
	creature_short_name = new_creature_def.creature_short_name
	set_chat_selectors(new_creature_def.chat_selectors)
	min_fatness = new_creature_def.min_fatness
	weight_gain_scale = new_creature_def.weight_gain_scale
	metabolism_scale = new_creature_def.metabolism_scale
	if PlayerData.creature_library.has_fatness(creature_id) and not suppress_fatness:
		set_fatness(PlayerData.creature_library.get_fatness(creature_id))
	else:
		set_fatness(min_fatness)
	base_fatness = get_fatness()
	creature_visuals.visual_fatness = get_fatness()
	feed_count = 0
	box_feed_count = 0


func get_creature_def() -> CreatureDef:
	var result := CreatureDef.new()
	result.creature_id = creature_id
	result.dna = DnaUtils.trim_dna(dna)
	# create a copy to prevent our chat theme from being modified accidentally
	result.chat_theme.from_json_dict(chat_theme.to_json_dict())
	result.creature_name = creature_name
	result.creature_short_name = creature_short_name
	result.chat_selectors = chat_selectors
	result.min_fatness = min_fatness
	result.weight_gain_scale = weight_gain_scale
	result.metabolism_scale = metabolism_scale
	return result


func refresh_dna() -> void:
	if not is_inside_tree():
		return

	if dna:
		dna = DnaUtils.fill_dna(dna)
	creature_visuals.dna = dna


## Workaround for Godot #21789 (https://github.com/godotengine/godot/issues/21789) to make get_class return class_name
func get_class() -> String:
	return "Creature"


## Workaround for Godot #21789 (https://github.com/godotengine/godot/issues/21789) to make is_class match class_name
func is_class(name: String) -> bool:
	return name == "Creature" or .is_class(name)


func get_movement_mode() -> int:
	return creature_visuals.movement_mode


func get_chat_extents() -> Vector2:
	return $CollisionShape2D.shape.extents


## Temporarily suppresses creature-related sound effects.
##
## This includes voices, eating sounds, sounds made while emoting, and movement sound effects.
func briefly_suppress_sfx(duration: float = 1.0) -> void:
	_creature_sfx.briefly_suppress_sfx(duration)


## Make the creature visible and gradually adjust their alpha up to 1.0.
func fade_in() -> void:
	if not visible:
		visible = true
		modulate.a = 0.0
	
	_launch_fade_tween(1.0, CREATURE_FADE_IN_DURATION)
	Stool.update_stool_occupied(self, true)


## Launches a talking animation, opening and closes the creature's mouth for a few seconds.
func talk() -> void:
	creature_visuals.talk()


## Returns 'true' of the creature's talk animation is playing.
func is_talking() -> bool:
	return creature_visuals.is_talking()


## Gradually adjust this creature's alpha down to 0.0 and make them invisible.
func fade_out() -> void:
	_launch_fade_tween(0.0, CREATURE_FADE_OUT_DURATION)
	Stool.update_stool_occupied(self, false)


## Returns the number of seconds between the beginning of the eating animation and the 'chomp' noise.
func get_eating_delay() -> float:
	return creature_visuals.get_eating_delay()


## Converts a score in the range [0.0, 5000.0] to a fatness in the range [1.0, 10.0]
func score_to_fatness(in_score: float) -> float:
	var result: float
	if weight_gain_scale == 0.0:
		# tutorial sensei doesn't gain weight
		result = base_fatness
	else:
		result = sqrt(1 + in_score * weight_gain_scale / 50.0)
	return result


func score_to_comfort(combo: float, customer_score: float) -> float:
	var comfort := 0.0
	if weight_gain_scale == 0.0:
		# tutorial sensei doesn't become comfortable
		pass
	else:
		# ate five things; comfortable
		comfort += clamp(inverse_lerp(5, 15, combo), 0.0, 1.0)
		# starting to overeat; less comfortable
		comfort -= clamp(inverse_lerp(400, 600, customer_score * weight_gain_scale), 0.0, 1.0)
		# overate; uncomfortable
		comfort -= clamp(inverse_lerp(600, 1200, customer_score * weight_gain_scale), 0.0, 1.0)
	return comfort


## Converts the creature's fatness in the range [1.0, 10.0] to a score in the range [0.0, 5000.0]
func fatness_to_score(in_fatness: float) -> float:
	return (50 / max(weight_gain_scale, 0.01)) * (pow(in_fatness, 2) - 1)


## Converts a coordinate relative to the creature's head into a coordinate relative to the creature's body.
##
## Parameters:
## 	'v': A coordinate relative to the creature's head.
##
## Returns:
## 	A coordinate relative to the creature's body.
func body_pos_from_head_pos(v: Vector2) -> Vector2:
	return _mouth_hook.get_global_transform_with_canvas().xform(v * creature_visuals.scale.y)


func get_run_speed() -> float:
	return MAX_RUN_SPEED * _run_anim_speed()


## Starts a tween which changes this creature's opacity.
func _launch_fade_tween(new_alpha: float, duration: float) -> void:
	_fade_tween = Utils.recreate_tween(self, _fade_tween)
	_fade_tween.tween_property(self, "modulate", Utils.to_transparent(modulate, new_alpha), duration)
	_fade_tween.tween_callback(self, "_on_Tween_completed")


func _refresh_creature_id() -> void:
	if not is_inside_tree():
		return
	
	var new_creature_def: CreatureDef = PlayerData.creature_library.get_creature_def(creature_id)
	if new_creature_def:
		set_creature_def(new_creature_def)


func _refresh_elevation() -> void:
	if not is_inside_tree():
		return
	if Engine.editor_hint:
		# MouthHook.set_elevation is not available in tool scripts
		return
	_creature_outline.set_elevation(elevation)
	_mouth_hook.set_elevation(elevation)


func _apply_friction() -> void:
	if _iso_velocity and iso_walk_direction:
		_friction = _non_iso_velocity.normalized().dot(non_iso_walk_direction.normalized()) < 0.25
	else:
		_friction = true
	
	if _friction:
		set_non_iso_velocity(lerp(_non_iso_velocity, Vector2.ZERO, FRICTION))
		if _non_iso_velocity.length() < MIN_RUN_SPEED * _run_anim_speed():
			set_non_iso_velocity(Vector2.ZERO)


func _apply_walk(delta: float) -> void:
	if iso_walk_direction:
		_accelerate_xy(delta, non_iso_walk_direction, MAX_RUN_ACCELERATION, MAX_RUN_SPEED * _run_anim_speed())


## Accelerates the creature horizontally.
##
## If the creature would be accelerated beyond the specified maximum speed, the creature's acceleration is reduced.
func _accelerate_xy(delta: float, _non_iso_push_direction: Vector2,
		acceleration: float, max_speed: float) -> void:
	if _non_iso_push_direction.length() == 0:
		return

	var accel_vector := _non_iso_push_direction.normalized() * acceleration * delta
	var new_velocity := _non_iso_velocity + accel_vector
	if new_velocity.length() > _non_iso_velocity.length() and new_velocity.length() > max_speed:
		new_velocity = new_velocity.normalized() * max_speed
	set_non_iso_velocity(new_velocity)


## Plays a bonk sound if a creature bumps into a wall.
func _maybe_play_bonk_sound(old_non_iso_velocity: Vector2) -> void:
	var velocity_diff := _non_iso_velocity - old_non_iso_velocity
	if velocity_diff.length() > MAX_RUN_SPEED * _run_anim_speed() * 0.9:
		_creature_sfx.play_bonk_sound()


## Updates the movement animation and run speed.
##
## The run speed varies based on how fat the creature is.
func _update_animation() -> void:
	if non_iso_walk_direction.length() > 0:
		var animation_prefix: String
		if creature_visuals.fatness >= 3.5:
			animation_prefix = "wiggle"
		elif creature_visuals.fatness >= 2.2:
			animation_prefix = "walk"
		elif creature_visuals.fatness >= 1.1:
			animation_prefix = "run"
		else:
			animation_prefix = "sprint"
		
		play_movement_animation(animation_prefix, non_iso_walk_direction)
	elif creature_visuals.movement_mode != Creatures.IDLE:
		play_movement_animation("idle", _non_iso_velocity)


## number from [0.0 - 1.0] based on how fast the creature can move with their current animation
func _run_anim_speed() -> float:
	var result := creature_visuals.scale.y
	if creature_visuals.fatness >= 3.5:
		result *= 0.200
	elif creature_visuals.fatness >= 2.2:
		result *= 0.400
	elif creature_visuals.fatness >= 1.1:
		result *= 0.700
	else:
		result *= 1.000
	return result


## When the creature is removed from the tree, we disconnect the 'fade_in_started' listener
##
## If we don't disconnect this listener, we receive errors during scene changes because the 'fade_in_started' listener
## tries to create scene tree tweens when the creature is not in the scene tree. These errors are caused by
## Breadcrumb's Godot #85692 workaround which delays the freeing of nodes in the previous scene.
func _on_tree_exited() -> void:
	if SceneTransition.is_connected("fade_in_started", self, "_on_SceneTransition_fade_in_started"):
		SceneTransition.disconnect("fade_in_started", self, "_on_SceneTransition_fade_in_started")


func _on_CreatureVisuals_fatness_changed() -> void:
	emit_signal("fatness_changed")


func _on_CreatureVisuals_dna_loaded() -> void:
	visible = true
	emit_signal("dna_loaded")


func _on_CreatureVisuals_food_eaten(food_type: int) -> void:
	emit_signal("food_eaten", food_type)


func _on_CreatureVisuals_landed() -> void:
	emit_signal("landed")


func _on_CreatureVisuals_visual_fatness_changed() -> void:
	emit_signal("visual_fatness_changed")


func _on_CreatureVisuals_movement_mode_changed(_old_mode: int, new_mode: int) -> void:
	if new_mode in [Creatures.WALK, Creatures.RUN]:
		# when on two legs, the body is a little higher off the ground
		set_elevation(35)
	else:
		set_elevation(0)


func _on_Tween_completed() -> void:
	if modulate.a == 0.0:
		visible = false
		emit_signal("fade_out_finished")
	else:
		emit_signal("fade_in_finished")


func _on_CreatureVisuals_talking_changed() -> void:
	emit_signal("talking_changed")


## When a new scene is loaded, creatures fade in. This conceals visual glitches as their body parts load.
func _on_SceneTransition_fade_in_started(_duration: float) -> void:
	if visible:
		Global.print_verbose("Fading in creature %s; valid=%s" % [creature_id, is_instance_valid(self)])
		visible = false
		fade_in()
		Global.print_verbose("Finished fading in creature %s" % [creature_id])
	else:
		# Don't fade in invisible creatures. Some creatures start invisible during cutscenes.
		pass
