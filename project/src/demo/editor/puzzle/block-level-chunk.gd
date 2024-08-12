class_name BlockLevelChunk
## Draggable chunk of level editor data made up of playfield blocks.

var used_cells := []
var tiles := {}
var autotile_coords := {}

func set_block(pos: Vector2, tile: int, autotile_coord: Vector2) -> void:
	used_cells.append(pos)
	tiles[pos] = tile
	autotile_coords[pos] = autotile_coord
