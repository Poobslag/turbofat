class_name BlocksStart
"""
Blocks/boxes which begin on the playfield.
"""

var used_cells := []
var tiles := {}
var autotile_coords := {}

"""
Populates this object from a json dictionary.
"""
func from_dict(dict: Dictionary) -> void:
	if dict.has("tiles"):
		for json_tile in dict["tiles"]:
			var json_pos_arr: PoolStringArray = json_tile["pos"].split(" ")
			var json_tile_arr: PoolStringArray = json_tile["tile"].split(" ")
			var pos := Vector2(int(json_pos_arr[0]), int(json_pos_arr[1]))
			var tile := int(json_tile_arr[0])
			var autotile_coord := Vector2(int(json_tile_arr[1]), int(json_tile_arr[2]))
			set_block(pos, tile, autotile_coord)


func set_block(pos: Vector2, tile: int, autotile_coord: Vector2) -> void:
	used_cells.append(pos)
	tiles[pos] = tile
	autotile_coords[pos] = autotile_coord
