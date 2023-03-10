class_name Carrots
extends Node2D
## Handles carrots, puzzle critters which rocket up the screen, blocking the player's vision.
##
## Carrots remain onscreen for several seconds. They have many different sizes, and can also leave behind a smokescreen
## which blocks the player's vision for even longer.

## tracks whether the carrot sfx are playing
enum MoveSfxState {
	STOPPED, # sfx are not playing
	STARTING, # sfx are playing, and volume is increasing
	PLAYING, # sfx are playing, and volume is at 100%
	STOPPING, # sfx are playing, and volume is decreasing
}

## volume to fade out to; once the music reaches this volume, it's stopped
const MIN_VOLUME := -40.0

## volume of the carrot's movement sound
const MOVE_SOUND_DB := -4.0

export (PackedScene) var CarrotScene: PackedScene

var playfield_path: NodePath setget set_playfield_path

var _playfield: Playfield

## tracks whether the carrot sfx are playing
var _move_sfx_state: int = MoveSfxState.STOPPED

## node which contains all of the child carrot nodes
onready var _carrot_holder: Node2D = $CarrotHolder

## sound which plays when the carrot appears/disappears
onready var _carrot_poof_sound: AudioStreamPlayer = $CarrotPoofSound

## sound which plays while at least one carrot is moving
onready var _carrot_move_sound: AudioStreamPlayer = $CarrotMoveSound

## tweens carrot sfx
onready var _tween: Tween = $SfxTween

func _ready() -> void:
	_refresh_playfield_path()


func set_playfield_path(new_playfield_path: NodePath) -> void:
	playfield_path = new_playfield_path
	_refresh_playfield_path()


## Removes the newest carrots from the playfield.
##
## Parameters:
## 	'count': The number of carrots to remove. If there aren't enough carrots on the playfield, all carrots are removed.
func remove_carrots(count: int) -> void:
	for _i in range(count):
		var result := _remove_carrot()
		if not result:
			# No more children to remove; immediately terminate the loop. This avoids a substantial performance
			# degradation when this method is called with a huge number (999,999)
			break


## Adds carrots to the playfield.
##
## Details like the number of carrots to add, where to add them and how fast they move are all specified by the config
## parameter.
##
## Parameters:
## 	'config': rules for how many carrots to add, where to add them, and how fast they move.
func add_carrots(config: CarrotConfig) -> void:
	var potential_carrot_x_coords: Array
	if config.columns:
		potential_carrot_x_coords = config.columns.duplicate()
	else:
		potential_carrot_x_coords = range(PuzzleTileMap.COL_COUNT)
	
	# don't allow carrots to spawn too far to the right
	var carrot_dimensions: Vector2 = CarrotConfig.DIMENSIONS_BY_CARROT_SIZE[config.size]
	potential_carrot_x_coords = Utils.intersection(potential_carrot_x_coords, \
			range(PuzzleTileMap.COL_COUNT - carrot_dimensions.x + 1))
	potential_carrot_x_coords.shuffle()
	
	potential_carrot_x_coords = deconflict_carrots(potential_carrot_x_coords, carrot_dimensions)
	
	for i in range(min(config.count, potential_carrot_x_coords.size())):
		_add_carrot(Vector2(potential_carrot_x_coords[i], PuzzleTileMap.ROW_COUNT), config)
	SfxDeconflicter.play(_carrot_poof_sound)


func _refresh_playfield_path() -> void:
	if not (is_inside_tree() and playfield_path):
		return
	
	if _playfield:
		_playfield.disconnect("blocks_prepared", self, "_on_Playfield_blocks_prepared")
	
	_playfield = get_node(playfield_path) if playfield_path else null
	
	if _playfield:
		_playfield.connect("blocks_prepared", self, "_on_Playfield_blocks_prepared")


## Adds a carrot to the specified cell.
##
## Details like the number of carrots to add, where to add them and how fast they move are all specified by the config
## parameter.
##
## Parameters:
## 	'config': rules for how many carrots to add, where to add them, and how fast they move.
func _add_carrot(cell: Vector2, config: CarrotConfig) -> void:
	var carrot_dimensions: Vector2 = CarrotConfig.DIMENSIONS_BY_CARROT_SIZE[config.size]
	
	# initialize the carrot and add it to the scene
	var carrot: Carrot = CarrotScene.instance()
	
	carrot.z_index = 5
	carrot.scale = _playfield.tile_map.scale
	
	carrot.position = _playfield.tile_map.map_to_world(cell + Vector2(0, -3))
	carrot.position += _playfield.tile_map.cell_size * Vector2(carrot_dimensions.x * 0.5, 0.5)
	carrot.position *= _playfield.tile_map.scale
	
	carrot.smoke = config.smoke
	carrot.carrot_size = config.size
	
	_carrot_holder.add_child(carrot)
	
	carrot.connect("started_hiding", self, "_on_Carrot_started_hiding")
	
	# launch the carrot towards its destination at the top of the screen
	var destination_cell := Vector2(cell.x, 0)
	var destination_position: Vector2
	destination_position = _playfield.tile_map.map_to_world(destination_cell + Vector2(0, -carrot_dimensions.y))
	destination_position += _playfield.tile_map.cell_size * Vector2(carrot_dimensions.x * 0.5, 0.5)
	destination_position *= _playfield.tile_map.scale
	
	var duration := config.duration
	carrot.launch(destination_position, duration)
	
	_refresh_carrot_move_sound()


## Removes the newest carrot.
##
## Returns:
## 	'true' if a carrot was successfully removed. False if no carrots were found.
func _remove_carrot() -> bool:
	var result := false
	var i := _carrot_holder.get_child_count() - 1
	while i >= 0:
		var carrot: Carrot = _carrot_holder.get_child(i)
		if not carrot.hiding:
			carrot.hide()
			result = true
			break
		i -= 1
	return result


## Immediately remove all carrots from the playfield, with no animation.
func _clear_carrots() -> void:
	for carrot in _carrot_holder.get_children():
		carrot.hide() # also call hide to ensure the sound stops playing
		carrot.queue_free()
	_refresh_carrot_move_sound()


func _refresh_carrot_move_sound() -> void:
	var active_carrots := false
	
	for carrot in _carrot_holder.get_children():
		if not carrot.hiding:
			active_carrots = true
			break
	
	if active_carrots and _move_sfx_state in [MoveSfxState.STOPPED, MoveSfxState.STOPPING]:
		_move_sfx_state = MoveSfxState.STARTING
		_tween.remove(_carrot_move_sound, "volume_db")
		_tween.interpolate_property(_carrot_move_sound, "volume_db", MIN_VOLUME, MOVE_SOUND_DB,
				0.8, Tween.TRANS_SINE, Tween.EASE_OUT)
		_tween.start()
		_carrot_move_sound.play()
	elif not active_carrots and _move_sfx_state in [MoveSfxState.PLAYING, MoveSfxState.STARTING]:
		_move_sfx_state = MoveSfxState.STOPPING
		_tween.remove(_carrot_move_sound, "volume_db")
		_tween.interpolate_property(_carrot_move_sound, "volume_db", null, MIN_VOLUME,
				0.4, Tween.TRANS_SINE, Tween.EASE_IN)
		_tween.start()


func _on_Playfield_blocks_prepared() -> void:
	_clear_carrots()
	_refresh_carrot_move_sound()


func _on_Carrot_started_hiding() -> void:
	SfxDeconflicter.play(_carrot_poof_sound)
	_refresh_carrot_move_sound()


func _on_Tween_tween_completed(object: Object, key: String) -> void:
	if object == _carrot_move_sound and key == ":volume_db":
		if abs(_carrot_move_sound.volume_db - MIN_VOLUME) < 0.01:
			_carrot_move_sound.stop()
			_move_sfx_state = MoveSfxState.STOPPED
		else:
			_move_sfx_state = MoveSfxState.PLAYING
	else:
		pass


## Prioritizes carrots so that non-overlapping carrots will appear if possible.
##
## Parameters:
## 	'potential_columns': Carrot columns in priority order.
##
## 	'carrot_dimensions': Carrot width and height in cells. The width determines how close carrots can be.
##
## Returns:
## 	A new list of carrot columns in priority order, so that non-overlapping carrots appear at the front of the list.
static func deconflict_carrots(potential_columns: Array, carrot_dimensions: Vector2) -> Array:
	var results := []
	
	# set of columns which are near other carrot columns.
	# key: (int) carrot column
	# value: (bool) true
	var overlapping_columns: Dictionary = {}
	
	var next_non_overlapping_column_index := 0
	for i in range(potential_columns.size()):
		var potential_column: int = potential_columns[i]
		if overlapping_columns.has(potential_column):
			# column overlaps; push it to the back of the results array
			results.append(potential_column)
		else:
			# column does not overlap; insert it into the front of the results array
			results.insert(next_non_overlapping_column_index, potential_column)
			next_non_overlapping_column_index += 1
			
			# append neighboring columns to the overlapping_columns set
			var min_overlapping_column := potential_column - carrot_dimensions.x + 1
			var max_overlapping_column := potential_column + carrot_dimensions.x - 1
			for overlapping_column in range(min_overlapping_column, max_overlapping_column + 1):
				overlapping_columns[overlapping_column] = true
	
	return results
