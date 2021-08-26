extends TileMap
"""
Tilemap which covers the corners of another tilemap.

Without this tilemap, a simple 16-tile autotiling would result in tiny holes at the corners of a filled in area. This
tilemap fills in the holes.

This tilemap assumes tiles are arranged so that the X coordinates of the tiles correspond to the directions they're
connected. This type of tilemap is used for puzzle pieces.
"""

onready var _parent_map: TileMap = get_parent()

var dirty := false

func _process(_delta: float) -> void:
	if dirty:
		clear()
		for cell in _parent_map.get_used_cells():
			var pacx := _pacx(cell)
			var pacy := _pacy(cell)
			if _parent_map.get_cellv(cell) == 2:
				# vegetable cell?
				continue
			# check for corner connected up and left
			if PuzzleConnect.is_u(pacx) and PuzzleConnect.is_l(pacx) \
					and not PuzzleConnect.is_u(_pacx(cell + Vector2.LEFT)):
				_set_corner_cell(Vector2(cell.x * 2, cell.y * 2), Vector2(0, pacy * 2))
			# check for corner connected up and right
			if PuzzleConnect.is_u(pacx) and PuzzleConnect.is_r(pacx) \
					and not PuzzleConnect.is_u(_pacx(cell + Vector2.RIGHT)):
				_set_corner_cell(Vector2(cell.x * 2 + 1, cell.y * 2), Vector2(1, pacy * 2))
			# check for corner connected down and left
			if PuzzleConnect.is_d(pacx) and PuzzleConnect.is_l(pacx) \
					and not PuzzleConnect.is_d(_pacx(cell + Vector2.LEFT)):
				_set_corner_cell(Vector2(cell.x * 2, cell.y * 2 + 1), Vector2(0, pacy * 2 + 1))
			# check for corner connected down and right
			if PuzzleConnect.is_d(pacx) and PuzzleConnect.is_r(pacx) \
					and not PuzzleConnect.is_d(_pacx(cell + Vector2.RIGHT)):
				_set_corner_cell(Vector2(cell.x * 2 + 1, cell.y * 2 + 1), Vector2(1, pacy * 2 + 1))
		dirty = false


"""
Sets the specified cell with the specified tile from the corner atlas tileset.

Parameters:
	'pos': Position of the cell
	
	'autotile_coord': Coordinate of the autotile variation in the corner atlas tileset
"""
func _set_corner_cell(pos: Vector2, autotile_coord: Vector2) -> void:
	set_cell(pos.x, pos.y, PuzzleTileMap.TILE_CORNER, false, false, false, autotile_coord);


"""
Returns the x component of the parent autotile coordinate (PAC) for the specified cell.

This function has a confusingly short name because it's referenced repetitively in some long lines of code.
"""
func _pacx(pos: Vector2) -> int:
	return int(_parent_map.get_cell_autotile_coord(pos.x, pos.y).x)


"""
Returns the y component of the parent autotile coordinate (PAC) for the specified cell.

This function has a confusingly short name because it's referenced repetitively in some long lines of code.
"""
func _pacy(pos: Vector2) -> int:
	return int(_parent_map.get_cell_autotile_coord(pos.x, pos.y).y)
