class_name LevelTiles
"""
Sets of blocks which are shown initially, or appear during the game
"""

class BlockBunch:
	"""
	A set of blocks which is shown initially, or appears during the game
	"""

	# key: (Vector2) positions of cells containing a tile
	# value: (int) tile indexes of each cell
	var block_tiles := {}

	# key: (Vector2) positions of cells containing a tile
	# value: (Vector2) coordinate of the autotile variation in the tileset
	var block_autotile_coords := {}
	
	# key: (Vector2) positions of cells containing a pickup
	# value: (int) an enum from Foods.BoxType defining the pickup's color
	var pickups := {}

	"""
	Defines a block which will appear on the playfield.

	Parameters:
		'pos': Position of the cell
		
		'tile': Tile index of the cell
		
		'autotile_coord': Coordinate of the autotile variation in the tileset
	"""
	func set_block(pos: Vector2, tile: int, autotile_coord: Vector2) -> void:
		block_tiles[pos] = tile
		block_autotile_coords[pos] = autotile_coord
	
	
	"""
	Defines a pickup which will appear on the playfield.
	
	Parameters:
		'pos': Position of the cell
		
		'box_type': An enum from Foods.BoxType defining the pickup's color
	"""
	func set_pickup(pos: Vector2, box_type: int) -> void:
		pickups[pos] = box_type

# key: a tiles key for tiles referenced by level rules, or the string 'start' for the initial set of tiles
# value: a BlockBunch instance
var bunches: Dictionary = {}

func from_json_dict(json: Dictionary) -> void:
	for tiles_key in json.keys():
		var bunch := BlockBunch.new()
		PuzzleTileMapReader.read(json[tiles_key], funcref(bunch, "set_block"), funcref(bunch, "set_pickup"))
		bunches[tiles_key] = bunch


"""
Returns the initial set of tiles.
"""
func blocks_start() -> BlockBunch:
	return get_tiles("start")


"""
Returns a set of tiles referenced by level rules.

Parameters:
	'tiles_key': a key for tiles referenced by level rules, or the string 'start' for the initial set of tiles

Returns:
	A set of tiles for the specified key, or an empty BlockBunch if the key is not found.
"""
func get_tiles(tiles_key: String) -> BlockBunch:
	var result: BlockBunch
	if bunches.has(tiles_key):
		result = bunches[tiles_key]
	else:
		# Not all levels define start blocks. We shouldn't treat this case as an error.
		result = BlockBunch.new()
	return result
