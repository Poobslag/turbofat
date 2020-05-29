class_name PuzzleTileMap
extends TileMap
"""
TileMap containing puzzle blocks such as pieces, boxes and vegetables.
"""

enum BoxInt {
	BROWN,
	PINK,
	BREAD,
	WHITE,
	CAKE,
}

const TILE_EMPTY := -1
const TILE_PIECE := 0 # part of an intact piece
const TILE_BOX := 1 # part of a snack/cake box
const TILE_VEG := 2 # vegetable created from line clears

# fields used to roll the tile map back to a previous state
var _saved_used_cells := []
var _saved_tiles := []
var _saved_autotile_coords := []

func _ready() -> void:
	clear()


func clear() -> void:
	.clear()
	$CornerMap.clear()


func save_state() -> void:
	_saved_used_cells.clear()
	_saved_tiles.clear()
	_saved_autotile_coords.clear()
	for cell_obj in get_used_cells():
		var cell: Vector2 = cell_obj
		_saved_used_cells.append(cell)
		_saved_tiles.append(get_cell(cell.x, cell.y))
		_saved_autotile_coords.append(get_cell_autotile_coord(cell.x, cell.y))


func restore_state() -> void:
	clear()
	for i in range(_saved_used_cells.size()):
		var cell: Vector2 = _saved_used_cells[i]
		var tile: int = _saved_tiles[i]
		var autotile_coord: Vector2 = _saved_autotile_coords[i]
		set_block(cell, tile, autotile_coord)


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


static func is_snack_box(box_int: int) -> bool:
	return box_int in [BoxInt.BROWN, BoxInt.PINK, BoxInt.BREAD, BoxInt.WHITE]


static func is_cake_box(box_int: int) -> bool:
	return box_int == BoxInt.CAKE
