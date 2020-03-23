"""
Fine-grained tilemap which draws the inner corners of 90-degree angles.
"""
extends TileMap

onready var ParentMap = get_node("..")

var dirty := false

func _process(_delta: float) -> void:
	if dirty:
		clear()
		for cell in ParentMap.get_used_cells():
			var autotile_coord: Vector2 = ParentMap.get_cell_autotile_coord(cell.x, cell.y)
			if ParentMap.get_cell(cell.x, cell.y) == 2:
				# vegetable cell?
				continue
			# check for corner connected up and left
			if int(autotile_coord.x) & PieceTypes.CONNECTED_UP > 0 \
					&& int(autotile_coord.x) & PieceTypes.CONNECTED_LEFT > 0 \
					&& int(ParentMap.get_cell_autotile_coord(cell.x - 1, cell.y).x) & PieceTypes.CONNECTED_UP == 0:
				set_cell(cell.x * 2, cell.y * 2, 0, false, false, false, Vector2(0, autotile_coord.y * 2))
			# check for corner connected up and right
			if int(autotile_coord.x) & PieceTypes.CONNECTED_UP > 0 \
					&& int(autotile_coord.x) & PieceTypes.CONNECTED_RIGHT > 0 \
					&& int(ParentMap.get_cell_autotile_coord(cell.x + 1, cell.y).x) & PieceTypes.CONNECTED_UP == 0:
				set_cell(cell.x * 2 + 1, cell.y * 2, 0, false, false, false, Vector2(1, autotile_coord.y * 2))
			# check for corner connected down and left
			if int(autotile_coord.x) & PieceTypes.CONNECTED_DOWN > 0 \
					&& int(autotile_coord.x) & PieceTypes.CONNECTED_LEFT > 0 \
					&& int(ParentMap.get_cell_autotile_coord(cell.x - 1, cell.y).x) & PieceTypes.CONNECTED_DOWN == 0:
				set_cell(cell.x * 2, cell.y * 2 + 1, 0, false, false, false, Vector2(0, autotile_coord.y * 2 + 1))
			# check for corner connected down and right
			if int(autotile_coord.x) & PieceTypes.CONNECTED_DOWN > 0 \
					&& int(autotile_coord.x) & PieceTypes.CONNECTED_RIGHT > 0 \
					&& int(ParentMap.get_cell_autotile_coord(cell.x + 1, cell.y).x) & PieceTypes.CONNECTED_DOWN == 0:
				set_cell(cell.x * 2 + 1, cell.y * 2 + 1, 0, false, false, false, Vector2(1, autotile_coord.y * 2 + 1))
		dirty = false
