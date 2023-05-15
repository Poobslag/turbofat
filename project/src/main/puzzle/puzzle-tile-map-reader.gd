class_name PuzzleTileMapReader

## Parses a json fragment listing tiles in a puzzle tilemap.
##
## Instead of directly populating a puzzle tilemap, we invoke a callback function for greater flexibility.
##
## Parameters:
## 	'json_tiles': A json fragment listing tiles in a puzzle tilemap.
##
## 	'set_block': A reference to a function which accepts three parameters:
## 		'pos' (Vector2): Position of the cell
## 		'tile' (int): Tile index of the cell
## 		'autotile_coord' (Vector2): Coordinate of the autotile variation in the tileset
##
## 	'set_pickup': (Optional) Reference to a function which accepts two parameters:
## 		'pos' (Vector2): Position of the cell
## 		'box_type' (int): Enum from Foods.BoxType defining the pickup's color
static func read(json_tiles: Array, set_block: FuncRef, set_pickup: FuncRef = null) -> void:
	for json_tile in json_tiles:
		var json_pos_arr: PackedStringArray = json_tile.get("pos", "").split(" ")
		var json_tile_arr: PackedStringArray = json_tile.get("tile", "").split(" ")
		var json_pickup_str: String = json_tile.get("pickup", "")
		if json_pos_arr.size() < 2:
			continue
		var pos := Vector2(int(json_pos_arr[0]), int(json_pos_arr[1]))
		if json_tile_arr.size() >= 3 and set_block:
			var tile := int(json_tile_arr[0])
			var autotile_coord := Vector2(int(json_tile_arr[1]), int(json_tile_arr[2]))
			set_block.call_func(pos, tile, autotile_coord)
		if json_pickup_str and set_pickup:
			var box_type := int(json_pickup_str)
			set_pickup.call_func(pos, box_type)
