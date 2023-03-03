class_name Onions
extends Node2D
## Handles onions, puzzle critters which darken things making it hard to see.

export (PackedScene) var OnionScene: PackedScene

var playfield_path: NodePath setget set_playfield_path

## Onion currently in the playfield, if any. The playfield can only have one onion.
var _onion: Onion
var _playfield: Playfield

func _ready() -> void:
	PuzzleState.connect("game_prepared", self, "_on_PuzzleState_game_prepared")
	PuzzleState.connect("game_ended", self, "_on_PuzzleState_game_ended")
	_refresh_playfield_path()


func set_playfield_path(new_playfield_path: NodePath) -> void:
	playfield_path = new_playfield_path
	_refresh_playfield_path()


func _refresh_playfield_path() -> void:
	if not (is_inside_tree() and playfield_path):
		return
	
	_playfield = get_node(playfield_path) if playfield_path else null


## Adds an onion to the playfield.
func add_onion(onion_config: OnionConfig) -> void:
	if _onion:
		return
	
	_onion = OnionScene.instance()
	_onion.z_index = 4
	_onion.scale = _playfield.tile_map.scale
	_onion.sky_position = Vector2(162, 92)
	_onion.connect("float_animation_playing_changed", self, "_on_Onion_float_animation_playing_changed")
	_update_onion_position(_onion, Vector2(4, PuzzleTileMap.ROW_COUNT - 1))
	add_child(_onion)
	
	_initialize_onion_states(onion_config)


## Teleport the onion into the sky.
func skip_to_night_mode() -> void:
	if _onion:
		_onion.skip_to_night_mode()


## Advances the onion to the next state in its day/night cycle.
func advance_onion() -> void:
	if not _onion:
		return
	
	_onion.advance_state()


## Immediately removes the onion from the playfield.
func remove_onion() -> void:
	if not _onion:
		return
	
	_onion.poof_and_free()
	_onion = null
	CurrentLevel.puzzle.set_night_mode(false)


func starts_in_night_mode() -> bool:
	var initial_add_onion_effect := _initial_add_onion_effect()
	return initial_add_onion_effect and initial_add_onion_effect.config.get_state(0) == OnionConfig.OnionState.NIGHT


## Initializes the onion's states with the specified onion config.
func _initialize_onion_states(config: OnionConfig) -> void:
	_onion.clear_states()
	for i in range(config.cycle_length()):
		_onion.append_next_state(config.get_state(i))
	
	if CurrentLevel.puzzle.is_night_mode():
		_onion.skip_to_night_mode()
	
	_onion.advance_state()


## Returns the AddOnionEffect which takes place before the level starts, if any.
func _initial_add_onion_effect() -> LevelTriggerEffects.AddOnionEffect:
	var initial_add_onion_effect: LevelTriggerEffects.AddOnionEffect
	for trigger_obj in CurrentLevel.settings.triggers.triggers.get(LevelTrigger.BEFORE_START, []):
		var trigger: LevelTrigger = trigger_obj
		if trigger.effect is LevelTriggerEffects.AddOnionEffect:
			initial_add_onion_effect = trigger.effect
	return initial_add_onion_effect


## Recalculates an onion's position based on their playfield cell.
##
## Parameters:
## 	'onion': The onion whose position should be recalculated
##
## 	'cell': The onion's playfield cell
func _update_onion_position(onion: Onion, cell: Vector2) -> void:
	onion.position = _playfield.tile_map.map_to_world(cell + Vector2(0, -3))
	onion.position += _playfield.tile_map.cell_size * Vector2(0.5, 0.5)
	onion.position *= _playfield.tile_map.scale


func _on_Onion_float_animation_playing_changed(_value: bool) -> void:
	CurrentLevel.puzzle.set_night_mode(_onion.state == OnionConfig.OnionState.NIGHT)


## When the game ends, the onion falls from the sky.
##
## This lets the player see their playfield at the end. It would be cruel to keep it hidden.
func _on_PuzzleState_game_ended() -> void:
	if not _onion:
		return
	
	_onion.clear_states()
	_onion.advance_state()


## Remove the onion at the start of the puzzle.
##
## Some levels introduce an onion in the middle of the level, we want to remove it when the level is restarted.
func _on_PuzzleState_game_prepared() -> void:
	if not _onion:
		return
	
	if starts_in_night_mode():
		_initialize_onion_states(_initial_add_onion_effect().config)
	else:
		remove_onion()
		CurrentLevel.puzzle.set_night_mode(false)
