class_name BlocksStartRules
"""
Blocks/boxes which begin on the playfield.
"""

# Vector2 array with the positions of all cells containing a tile
var used_cells := []

# key: (Vector2) positions of cells containing a tile
# value: (int) tile indexes of each cell
var tiles := {}

# key: (Vector2) positions of cells containing a tile
# value: (Vector2) coordinate of the autotile variation in the tileset
var autotile_coords := {}

func from_json_dict(json: Dictionary) -> void:
	PuzzleTileMapReader.read(json.get("tiles", []), funcref(self, "set_block"))


"""
Defines a block which will begin on the playfield.

Parameters:
	'pos': Position of the cell
	
	'tile': Tile index of the cell
	
	'autotile_coord': Coordinate of the autotile variation in the tileset
"""
func set_block(pos: Vector2, tile: int, autotile_coord: Vector2) -> void:
	used_cells.append(pos)
	tiles[pos] = tile
	autotile_coords[pos] = autotile_coord
