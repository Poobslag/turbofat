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
	if not _onion:
		_onion = OnionScene.instance()
		_onion.z_index = 4
		_onion.scale = _playfield.tile_map.scale
		_onion.sky_position = Vector2(162, 92)
		_onion.connect("float_animation_playing_changed", self, "_on_Onion_float_animation_playing_changed")
		_update_onion_position(_onion, Vector2(4, PuzzleTileMap.ROW_COUNT - 1))
		add_child(_onion)
	
	_onion.clear_states()
	for i in range(onion_config.cycle_length()):
		_onion.append_next_state(onion_config.get_state(i))
	_onion.advance_state()


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
	
	remove_onion()
