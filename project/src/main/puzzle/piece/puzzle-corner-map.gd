extends TileMap
"""
Tile map which covers the corners of another tilemap.

Without this tile map, a simple 16-tile autotiling would result in tiny holes at the corners of a filled in area. This
tile map fills in the holes.

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
				set_cell(cell.x * 2, cell.y * 2, 0, false, false, false, Vector2(0, pacy * 2))
			# check for corner connected up and right
			if PuzzleConnect.is_u(pacx) and PuzzleConnect.is_r(pacx) \
					and not PuzzleConnect.is_u(_pacx(cell + Vector2.RIGHT)):
				set_cell(cell.x * 2 + 1, cell.y * 2, 0, false, false, false, Vector2(1, pacy * 2))
			# check for corner connected down and left
			if PuzzleConnect.is_d(pacx) and PuzzleConnect.is_l(pacx) \
					and not PuzzleConnect.is_d(_pacx(cell + Vector2.LEFT)):
				set_cell(cell.x * 2, cell.y * 2 + 1, 0, false, false, false, Vector2(0, pacy * 2 + 1))
			# check for corner connected down and right
			if PuzzleConnect.is_d(pacx) and PuzzleConnect.is_r(pacx) \
					and not PuzzleConnect.is_d(_pacx(cell + Vector2.RIGHT)):
				set_cell(cell.x * 2 + 1, cell.y * 2 + 1, 0, false, false, false, Vector2(1, pacy * 2 + 1))
		dirty = false


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
