extends Node
"""
Inserts lines in a puzzle tilemap.

Most levels don't insert lines, but this script handles it for the levels that do.
"""

# emitted after a line is inserted
signal line_inserted(y, tiles_key, src_y)

export (NodePath) var tile_map_path: NodePath

# key: a tiles key for tiles referenced by level rules
# value: the next row to insert from the referenced tiles
var _row_index_by_tiles_key := {}

# key: a tiles key for tiles referenced by level rules
# value: the total number of rows in the referenced tiles
var _row_count_by_tiles_key := {}

onready var _tile_map: PuzzleTileMap = get_node(tile_map_path)
onready var _line_insert_sound := $LineInsertSound

func _ready() -> void:
	PuzzleState.connect("game_prepared", self, "_on_PuzzleState_game_prepared")
	CurrentLevel.connect("settings_changed", self, "_on_Level_settings_changed")


"""
Inserts a line into the puzzle tilemap.

Parameters:
	'tiles_key': (Optional) a key for the LevelTiles entry for the tiles to insert
	
	'dest_y': (Optional) The y coordinate of the line to insert. If omitted, the line will be inserted at the
		bottom of the puzzle tilemap.
"""
func insert_line(tiles_key: String = "", dest_y: int = PuzzleTileMap.ROW_COUNT - 1) -> void:
	# shift playfield up
	_tile_map.insert_row(dest_y)
	
	var src_y := -1
	
	# fill bottom row
	if tiles_key:
		# fill bottom row with blocks from LevelTiles
		var tiles: LevelTiles.BlockBunch = CurrentLevel.settings.tiles.get_tiles(tiles_key)
		src_y = _row_index_by_tiles_key.get(tiles_key, 0)
		
		# get the tiles for this row
		for x in range(PuzzleTileMap.COL_COUNT):
			var src_pos := Vector2(x, src_y)
			var tile: int = tiles.block_tiles.get(src_pos, -1)
			var autotile_coord: Vector2 = tiles.block_autotile_coords.get(src_pos, Vector2(0, 0))
			_tile_map.set_block(Vector2(x, dest_y), tile, autotile_coord)
		
		# increment the row index to the next non-empty row
		_row_index_by_tiles_key[tiles_key] = (src_y + 1) % (_row_count_by_tiles_key.get(tiles_key, 1))
	else:
		# fill bottom row with random veggie garbage
		_line_insert_sound.play()
		for x in range(PuzzleTileMap.COL_COUNT):
			var veg_autotile_coord := Vector2(randi() % 18, randi() % 4)
			_tile_map.set_block(Vector2(x, dest_y), PuzzleTileMap.TILE_VEG, veg_autotile_coord)
		_tile_map.set_block(Vector2(randi() % PuzzleTileMap.COL_COUNT, dest_y), -1)
	
	emit_signal("line_inserted", dest_y, tiles_key, src_y)


func _reset() -> void:
	_row_index_by_tiles_key.clear()
	_row_count_by_tiles_key.clear()
	
	# initialize _row_count_by_tiles_key
	for tiles_key in CurrentLevel.settings.tiles.bunches:
		var max_y := 0
		for cell in CurrentLevel.settings.tiles.bunches[tiles_key].block_tiles:
			max_y = max(max_y, cell.y)
		_row_count_by_tiles_key[tiles_key] = max_y + 1
	
	# initialize _row_index_by_tiles_key
	if CurrentLevel.settings.blocks_during.random_tiles_start:
		for tiles_key in CurrentLevel.settings.tiles.bunches:
			_row_index_by_tiles_key[tiles_key] = randi() % _row_count_by_tiles_key[tiles_key]


func _on_PuzzleState_game_prepared() -> void:
	_reset()


func _on_Level_settings_changed() -> void:
	_reset()
