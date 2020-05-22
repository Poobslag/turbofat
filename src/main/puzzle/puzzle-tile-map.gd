class_name PuzzleTileMap
extends TileMap
"""
TileMap containing puzzle blocks such as pieces, boxes and vegetables.
"""

const TILE_EMPTY := -1
const TILE_PIECE := 0 # part of an intact piece
const TILE_BOX := 1 # part of a snack/cake box
const TILE_VEG := 2 # vegetable created from line clears

func _ready() -> void:
	clear()


func clear() -> void:
	.clear()
	$CornerMap.clear()


func set_block(pos: Vector2, tile: int, autotile_coord: Vector2 = Vector2.ZERO) -> void:
	set_cell(pos.x, pos.y, tile, false, false, false, autotile_coord)
	$CornerMap.dirty = true


"""
Disconnects a block from its surrounding directions.

Parameters:
	'dir_mask': Directions to be disconnected. Defaults to 15 which disconnects it from all four directions.
"""
func disconnect_block(x: int, y: int, dir_mask: int = 15) -> void:
	if get_cell(x, y) == -1:
		# empty cell; nothing to disconnect
		return
	var autotile_coord := get_cell_autotile_coord(x, y)
	autotile_coord.x = Connect.unset_dirs(autotile_coord.x, dir_mask)
	set_block(Vector2(x, y), get_cell(x, y), autotile_coord)


"""
Creates a snack box or cake box.
"""
func make_box(x: int, y: int, width: int, height: int, box_int: int) -> void:
	for curr_x in range(x, x + width):
		for curr_y in range (y, y + height):
			set_block(Vector2(curr_x, curr_y), TILE_BOX, Vector2(15, box_int))
	
	# top/bottom edge
	for curr_x in range(x, x + width):
		disconnect_block(curr_x, y, Connect.UP)
		disconnect_block(curr_x, y + height - 1, Connect.DOWN)
	
	# left/right edge
	for curr_y in range(y, y + height):
		disconnect_block(x, curr_y, Connect.LEFT)
		disconnect_block(x + width - 1, curr_y, Connect.RIGHT)
