extends TileMap
"""
Fine-grained tile map which draws the inner corners of 90-degree angles.
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
			if Connect.is_u(pacx) and Connect.is_l(pacx) and not Connect.is_u(_pacx(cell + Vector2.LEFT)):
				set_cell(cell.x * 2, cell.y * 2, 0, false, false, false, Vector2(0, pacy * 2))
			# check for corner connected up and right
			if Connect.is_u(pacx) and Connect.is_r(pacx) and not Connect.is_u(_pacx(cell + Vector2.RIGHT)):
				set_cell(cell.x * 2 + 1, cell.y * 2, 0, false, false, false, Vector2(1, pacy * 2))
			# check for corner connected down and left
			if Connect.is_d(pacx) and Connect.is_l(pacx) and not Connect.is_d(_pacx(cell + Vector2.LEFT)):
				set_cell(cell.x * 2, cell.y * 2 + 1, 0, false, false, false, Vector2(0, pacy * 2 + 1))
			# check for corner connected down and right
			if Connect.is_d(pacx) and Connect.is_r(pacx) and not Connect.is_d(_pacx(cell + Vector2.RIGHT)):
				set_cell(cell.x * 2 + 1, cell.y * 2 + 1, 0, false, false, false, Vector2(1, pacy * 2 + 1))
		dirty = false


func _pacx(pos: Vector2) -> int:
	return int(_parent_map.get_cell_autotile_coord(pos.x, pos.y).x)


func _pacy(pos: Vector2) -> int:
	return int(_parent_map.get_cell_autotile_coord(pos.x, pos.y).y)
