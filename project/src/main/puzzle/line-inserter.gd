extends Node
"""
Inserts lines in a puzzle tilemap.

Most levels don't insert lines, but this script handles it for the levels that do.
"""

# emitted after one or more lines are inserted
signal lines_inserted(lines)

export (NodePath) var tile_map_path: NodePath

# key: a tiles key for tiles referenced by level rules
# value: the next row to insert from the referenced tiles
var row_index_by_tiles_key := {}

# key: a tiles key for tiles referenced by level rules
# value: the total number of rows in the referenced tiles
var row_count_by_tiles_key := {}

onready var _tile_map: PuzzleTileMap = get_node(tile_map_path)
onready var _line_insert_sound := $LineInsertSound

func _ready() -> void:
	PuzzleState.connect("game_prepared", self, "_on_PuzzleState_game_prepared")
	CurrentLevel.connect("settings_changed", self, "_on_Level_settings_changed")


"""
Inserts a line into the puzzle tilemap.

Parameters:
	'tiles_key': (Optional) a key for the LevelTiles entry for the tiles to insert
	
	'new_line_y': (Optional) The y coordinate of the line to insert. If omitted, the line will be inserted at the
		bottom of the puzzle tilemap.
"""
func insert_line(tiles_key: String = "", new_line_y: int = PuzzleTileMap.ROW_COUNT - 1) -> void:
	# shift playfield up
	_tile_map.insert_row(new_line_y)
	
	# fill bottom row
	if tiles_key:
		var tiles: LevelTiles.BlockBunch = CurrentLevel.settings.tiles.get_tiles(tiles_key)
		
		var tiles_row_index: int = row_index_by_tiles_key.get(tiles_key, 0)
		
		# get the tiles for this row
		for x in range(PuzzleTileMap.COL_COUNT):
			var pos := Vector2(x, tiles_row_index)
			var block: int = tiles.tiles.get(pos, -1)
			var autotile_coord: Vector2 = tiles.autotile_coords.get(pos, Vector2(0, 0))
			_tile_map.set_block(Vector2(x, new_line_y), block, autotile_coord)
		
		# increment the row index to the next non-empty row
		row_index_by_tiles_key[tiles_key] = (tiles_row_index + 1) % (row_count_by_tiles_key.get(tiles_key, 1))
	else:
		# fill with random stuff
		_line_insert_sound.play()
		for x in range(0, PuzzleTileMap.COL_COUNT):
			var pos := Vector2(x, new_line_y)
			var veg_autotile_coord := Vector2(randi() % 18, randi() % 4)
			_tile_map.set_block(pos, PuzzleTileMap.TILE_VEG, veg_autotile_coord)
		_tile_map.set_block(Vector2(randi() % PuzzleTileMap.COL_COUNT, new_line_y), -1)
	
	emit_signal("lines_inserted", [new_line_y])


func _reset() -> void:
	row_index_by_tiles_key.clear()
	row_count_by_tiles_key.clear()
	
	# initialize row_count_by_tiles_key
	for tiles_key in CurrentLevel.settings.tiles.bunches:
		var max_y := 0
		for cell in CurrentLevel.settings.tiles.bunches[tiles_key].used_cells:
			max_y = max(max_y, cell.y)
		row_count_by_tiles_key[tiles_key] = max_y + 1


func _on_PuzzleState_game_prepared() -> void:
	_reset()


func _on_Level_settings_changed() -> void:
	_reset()
