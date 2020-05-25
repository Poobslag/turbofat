class_name BlocksStart
"""
Blocks/boxes which begin on the playfield.
"""

var used_cells := []
var tiles := {}
var autotile_coords := {}

func from_json_dict(json: Dictionary) -> void:
	for json_tile in json.get("tiles", []):
		var json_pos_arr: PoolStringArray = json_tile.get("pos", "").split(" ")
		var json_tile_arr: PoolStringArray = json_tile.get("tile", "").split(" ")
		if json_pos_arr.size() < 2 or json_tile_arr.size() < 3:
			continue
		var pos := Vector2(int(json_pos_arr[0]), int(json_pos_arr[1]))
		var tile := int(json_tile_arr[0])
		var autotile_coord := Vector2(int(json_tile_arr[1]), int(json_tile_arr[2]))
		set_block(pos, tile, autotile_coord)


func set_block(pos: Vector2, tile: int, autotile_coord: Vector2) -> void:
	used_cells.append(pos)
	tiles[pos] = tile
	autotile_coords[pos] = autotile_coord
