class_name LineFiller
extends Node
## Fills lines in a puzzle tilemap.
##
## 'Line filling' replaces all empty lines with a predefined set of lines. This occurs after lines are deleted and
## inserted. This is typically used to narrow the playfield by replacing empty lines with lines where the left and
## right columns are filled with blocks.
##
## Most levels don't fill lines, but this script handles it for the levels that do.

## emitted when lines are filled in from the top. some levels fill in lines, but most do not
signal line_filled(y, tiles_key, src_y)

## emitted after a set of lines are filled, either following a topout/refresh or line clear
signal after_lines_filled

export (NodePath) var pickups_path: NodePath

export (NodePath) var tile_map_path: NodePath

## key: (String) a tiles key for tiles referenced by level rules
## value: (int) the next row to fill from the referenced tiles
var _row_index_by_tiles_key := {}

## key: (String) a tiles key for the tiles referenced by level rules
## value: (Array, int) array of possible next rows to fill from the referenced tiles
var _row_bag_by_tiles_key := {}

## key: (String) a tiles key for tiles referenced by level rules
## value: (int) the total number of rows in the referenced tiles
var _row_count_by_tiles_key := {}

## List of frame timings for scheduled line fills.
var _lines_being_filled := []

## Remaining frame count for scheduled line fills.
var _remaining_line_fill_frames := 0

## The next line being filled for scheduled line fills.
var _filled_line_index := 0

## The index of the next line fill sound to play.
var _line_fill_sfx_index := 0

onready var _pickups: Pickups = get_node(pickups_path)
onready var _tile_map: PuzzleTileMap = get_node(tile_map_path)
onready var _line_fill_sounds := [$LineFillSound1, $LineFillSound2, $LineFillSound3]
onready var _line_fill_sfx_reset_timer := $LineFillSfxResetTimer

func _ready() -> void:
	set_physics_process(false)
	PuzzleState.connect("game_prepared", self, "_on_PuzzleState_game_prepared")
	CurrentLevel.connect("settings_changed", self, "_on_Level_settings_changed")


func _physics_process(_delta: float) -> void:
	# fill lines from lines_being_filled
	while _lines_being_filled and _remaining_line_fill_frames <= _lines_being_filled[0]:
		_fill_line("start", _filled_line_index)
		_lines_being_filled.pop_front()
		_filled_line_index -= 1

	_remaining_line_fill_frames -= 1
	if _remaining_line_fill_frames <= 0:
		set_physics_process(false)
		emit_signal("after_lines_filled")


## Schedules the specified lines to be filled later.
func _schedule_playfield_refill() -> void:
	set_physics_process(true)
	
	_reset()
	
	_lines_being_filled.clear()
	_remaining_line_fill_frames = max(1, PieceSpeeds.current_speed.playfield_refill_delay())
	_filled_line_index = PuzzleTileMap.ROW_COUNT - 1
	
	var visible_row_count := clamp(_row_count_by_tiles_key.get("start", 0),
			0, PuzzleTileMap.ROW_COUNT - PuzzleTileMap.FIRST_VISIBLE_ROW)
	var line_fill_timing_window := PieceSpeeds.current_speed.playfield_refill_delay()
	var per_line_fill_delay := floor(line_fill_timing_window / max(1, visible_row_count))
	
	for i in range(_row_count_by_tiles_key.get("start", 0)):
		_lines_being_filled.append(max(1, (visible_row_count - i) * per_line_fill_delay))


## Immediately fills empty lines on the playfield.
##
## Only the top few lines of the playfield are considered. This is because the fill pattern might include gaps which we
## don't want filled.
##
## Parameters:
## 	'filled_line_count': The number of lines at the top of the playfield to fill. Empty lines are filled, non-empty
## 		lines are skipped.
func _fill_empty_lines(filled_line_count: int) -> void:
	if _fill_lines_tiles_key().empty():
		return
	
	# fill the empty rows from bottom to top
	var y := filled_line_count
	while y > 0:
		if _tile_map.row_is_empty(y) and _pickups.row_is_empty(y):
			_fill_line(_fill_lines_tiles_key(), y)
		y -= 1
	
	emit_signal("after_lines_filled")


## Fills a line in the puzzle tilemap.
##
## Parameters:
## 	'tiles_key': A key for the LevelTiles entry for the tiles to insert.
##
## 	'dest_y': The y coordinate of the row to fill.
func _fill_line(tiles_key: String, dest_y: int) -> void:
	if dest_y >= PuzzleTileMap.FIRST_VISIBLE_ROW:
		_play_line_fill_sound()
	
	var tiles: LevelTiles.BlockBunch = CurrentLevel.settings.tiles.get_tiles(tiles_key)
	var src_y := _tiles_src_y(tiles_key)
	for x in range(PuzzleTileMap.COL_COUNT):
		var src_pos := Vector2(x, src_y)
		var tile: int = tiles.block_tiles.get(src_pos, -1)
		var autotile_coord: Vector2
		if tile == PuzzleTileMap.TILE_VEG:
			autotile_coord = PuzzleTileMap.random_veg_autotile_coord()
		else:
			autotile_coord = tiles.block_autotile_coords.get(src_pos, Vector2.ZERO)
		_tile_map.set_block(Vector2(x, dest_y), tile, autotile_coord)
	
	emit_signal("line_filled", dest_y, tiles_key, src_y)


## Plays a line fill sound effect.
##
## Successive line fill sound effects are subtly quieter and change pitch. This resets after a period of time
## determined by the _line_fill_sfx_reset_timer.
func _play_line_fill_sound() -> void:
	_line_fill_sfx_reset_timer.start()
	
	var sound_index := clamp(_line_fill_sfx_index, 0, _line_fill_sounds.size() - 1)
	var sound: AudioStreamPlayer = _line_fill_sounds[sound_index]
	sound.pitch_scale = rand_range(0.90, 1.10)
	sound.play()
	
	_line_fill_sfx_index += 1


## Calculate the y position from the source tilemap to be filled into the target tilemap.
func _tiles_src_y(tiles_key: String) -> int:
	var src_y := -1
	if tiles_key == "start":
		# return the next decremental y value (bottom to top)
		
		src_y = _row_index_by_tiles_key.get(tiles_key, 0)
		# increment the row index to the next non-empty row
		var min_y: int = PuzzleTileMap.ROW_COUNT - _row_count_by_tiles_key.get(tiles_key, 1)
		var max_y: int = PuzzleTileMap.ROW_COUNT
		_row_index_by_tiles_key[tiles_key] = wrapi(src_y - 1, min_y, max_y)
	elif CurrentLevel.settings.blocks_during.shuffle_filled_lines \
				in [BlocksDuringRules.ShuffleLinesType.NONE, BlocksDuringRules.ShuffleLinesType.SLICE]:
		# return the next incremental y value (top to bottom)
		
		src_y = _row_index_by_tiles_key.get(tiles_key, 0)
		# increment the row index to the next non-empty row
		_row_index_by_tiles_key[tiles_key] = (src_y + 1) % _row_count_by_tiles_key.get(tiles_key, 1)
	elif CurrentLevel.settings.blocks_during.shuffle_filled_lines == BlocksDuringRules.ShuffleLinesType.BAG:
		# return the next random y value
		
		# obtain the row bag
		var row_bag: Array = _row_bag_by_tiles_key.get(tiles_key, [])
		if row_bag.empty():
			# refill the row bag
			for i in range(_row_count_by_tiles_key[tiles_key]):
				row_bag.append(i)
			_row_bag_by_tiles_key[tiles_key] = row_bag
		
		# select and remove a random row from the row bag
		var row_bag_index := randi() % row_bag.size()
		src_y = row_bag[row_bag_index]
		row_bag.remove(row_bag_index)
	return src_y


## Resets and recalculates the tile counts and upcoming random values.
func _reset() -> void:
	_row_index_by_tiles_key.clear()
	_row_bag_by_tiles_key.clear()
	_row_count_by_tiles_key.clear()
	
	# initialize _row_count_by_tiles_key
	for tiles_key in CurrentLevel.settings.tiles.bunches:
		if tiles_key == "start":
			var min_y := PuzzleTileMap.ROW_COUNT - 1
			for cell in CurrentLevel.settings.tiles.bunches[tiles_key].block_tiles:
				min_y = int(min(min_y, cell.y))
			for cell in CurrentLevel.settings.tiles.bunches[tiles_key].pickups:
				min_y = int(min(min_y, cell.y))
			_row_count_by_tiles_key[tiles_key] = PuzzleTileMap.ROW_COUNT - min_y
		else:
			var max_y := 0
			for cell in CurrentLevel.settings.tiles.bunches[tiles_key].block_tiles:
				max_y = int(max(max_y, cell.y))
			for cell in CurrentLevel.settings.tiles.bunches[tiles_key].pickups:
				max_y = int(max(max_y, cell.y))
			_row_count_by_tiles_key[tiles_key] = max_y + 1
	
	# initialize _row_index_by_tiles_key
	for tiles_key in CurrentLevel.settings.tiles.bunches:
		if tiles_key == "start":
			# 'start' rows are always filled from bottom to top
			_row_index_by_tiles_key[tiles_key] = PuzzleTileMap.ROW_COUNT - 1
		if CurrentLevel.settings.blocks_during.shuffle_filled_lines == BlocksDuringRules.ShuffleLinesType.SLICE:
			_row_index_by_tiles_key[tiles_key] = randi() % _row_count_by_tiles_key[tiles_key]

	# initialize _row_index_by_tiles_key
	if CurrentLevel.settings.blocks_during.shuffle_filled_lines == BlocksDuringRules.ShuffleLinesType.SLICE:
		for tiles_key in CurrentLevel.settings.tiles.bunches:
			if tiles_key == "start":
				# don't shuffle 'start' rows; those are only filled when refreshing a level
				continue
			_row_index_by_tiles_key[tiles_key] = randi() % _row_count_by_tiles_key[tiles_key]


## Returns the tiles key for 'filled' lines -- lines which fill from the top for levels with narrow playfields
func _fill_lines_tiles_key() -> String:
	return CurrentLevel.settings.blocks_during.fill_lines


func _on_PuzzleState_game_prepared() -> void:
	_reset()


func _on_Level_settings_changed() -> void:
	_reset()


func _on_LineClearer_after_lines_deleted(lines: Array) -> void:
	if PuzzleState.topping_out and CurrentLevel.settings.blocks_during.refresh_on_top_out:
		# schedule line fills after a top out
		_schedule_playfield_refill()
	else:
		# fill empty lines after a line clear
		_fill_empty_lines(lines.size())


func _on_LineFillSfxResetTimer_timeout() -> void:
	_line_fill_sfx_index = 0
