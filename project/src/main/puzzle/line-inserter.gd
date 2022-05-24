extends Node
## Inserts lines in a puzzle tilemap.
##
## Most levels don't insert lines, but this script handles it for the levels that do.

## emitted after a line is inserted
signal line_inserted(y, tiles_key, src_y)

export (NodePath) var tile_map_path: NodePath

## key: a tiles key for tiles referenced by level rules
## value: the next row to insert from the referenced tiles
var _row_index_by_tiles_key := {}

## key: a tiles key for the tiles referenced by level rules
## value: array of possible next rows to insert from the referenced tiles
var _row_bag_by_tiles_key := {}

## key: a tiles key for tiles referenced by level rules
## value: the total number of rows in the referenced tiles
var _row_count_by_tiles_key := {}

onready var _tile_map: PuzzleTileMap = get_node(tile_map_path)
onready var _line_insert_sound := $LineInsertSound

func _ready() -> void:
	PuzzleState.connect("game_prepared", self, "_on_PuzzleState_game_prepared")
	CurrentLevel.connect("settings_changed", self, "_on_Level_settings_changed")


## Inserts a line into the puzzle tilemap.
##
## Parameters:
## 	'tiles_key': (Optional) a key for the LevelTiles entry for the tiles to insert
##
## 	'dest_y': (Optional) The y coordinate of the line to insert. If omitted, the line will be inserted at the
## 		bottom of the puzzle tilemap.
func insert_line(tiles_key: String = "", dest_y: int = PuzzleTileMap.ROW_COUNT - 1) -> void:
	if dest_y >= PuzzleTileMap.FIRST_VISIBLE_ROW:
		_line_insert_sound.play()
	
	# shift playfield up
	_tile_map.insert_row(dest_y)
	
	var src_y := -1
	
	# fill bottom row
	if tiles_key:
		# fill bottom row with blocks from LevelTiles
		var tiles: LevelTiles.BlockBunch = CurrentLevel.settings.tiles.get_tiles(tiles_key)
		
		# get the tiles for this row
		src_y = _tiles_src_y(tiles_key)
		for x in range(PuzzleTileMap.COL_COUNT):
			var src_pos := Vector2(x, src_y)
			var tile: int = tiles.block_tiles.get(src_pos, -1)
			var autotile_coord: Vector2 = tiles.block_autotile_coords.get(src_pos, Vector2.ZERO)
			_tile_map.set_block(Vector2(x, dest_y), tile, autotile_coord)
	else:
		# fill bottom row with random veggie garbage
		for x in range(PuzzleTileMap.COL_COUNT):
			var veg_autotile_coord := Vector2(randi() % 18, randi() % 4)
			_tile_map.set_block(Vector2(x, dest_y), PuzzleTileMap.TILE_VEG, veg_autotile_coord)
		_tile_map.set_block(Vector2(randi() % PuzzleTileMap.COL_COUNT, dest_y), -1)
	
	emit_signal("line_inserted", dest_y, tiles_key, src_y)


## Calculate the y position from the source tilemap to be inserted into the target tilemap.
##
## Parameters:
## 	'tiles_key': a key for the LevelTiles entry for the tiles to insert
func _tiles_src_y(tiles_key: String) -> int:
	var src_y := -1
	match CurrentLevel.settings.blocks_during.shuffle_inserted_lines:
		BlocksDuringRules.ShuffleInsertedLinesType.NONE, BlocksDuringRules.ShuffleInsertedLinesType.SLICE:
			src_y = _row_index_by_tiles_key.get(tiles_key, 0)
			# increment the row index to the next non-empty row
			_row_index_by_tiles_key[tiles_key] = (src_y + 1) % (_row_count_by_tiles_key.get(tiles_key, 1))
		
		BlocksDuringRules.ShuffleInsertedLinesType.BAG:
			# obtain the row bag
			var row_bag: Array = _row_bag_by_tiles_key.get(tiles_key, [])
			if not row_bag:
				# refill the row bag
				for i in range(_row_count_by_tiles_key[tiles_key]):
					row_bag.append(i)
				_row_bag_by_tiles_key[tiles_key] = row_bag
			
			# select and remove a random row from the row bag
			var row_bag_index := randi() % row_bag.size()
			src_y = row_bag[row_bag_index]
			row_bag.remove(row_bag_index)
	return src_y

func _reset() -> void:
	_row_index_by_tiles_key.clear()
	_row_bag_by_tiles_key.clear()
	_row_count_by_tiles_key.clear()
	
	# initialize _row_count_by_tiles_key
	for tiles_key in CurrentLevel.settings.tiles.bunches:
		var max_y := 0
		for cell in CurrentLevel.settings.tiles.bunches[tiles_key].block_tiles:
			max_y = int(max(max_y, cell.y))
		_row_count_by_tiles_key[tiles_key] = max_y + 1
	
	# initialize _row_index_by_tiles_key
	if CurrentLevel.settings.blocks_during.shuffle_inserted_lines == BlocksDuringRules.ShuffleInsertedLinesType.SLICE:
		for tiles_key in CurrentLevel.settings.tiles.bunches:
			_row_index_by_tiles_key[tiles_key] = randi() % _row_count_by_tiles_key[tiles_key]


func _on_PuzzleState_game_prepared() -> void:
	_reset()


func _on_Level_settings_changed() -> void:
	_reset()
