"""
Fine-grained tilemap which draws the inner corners of 90-degree angles.
"""
extends TileMap

# constants used when drawing blocks which are connected to other blocks
const CONNECTED_UP = 1
const CONNECTED_DOWN = 2
const CONNECTED_LEFT = 4
const CONNECTED_RIGHT = 8

onready var ParentMap = get_node("..")

var dirty = false

func _process(delta):
	if dirty:
		clear()
		for cell in ParentMap.get_used_cells():
			var autotile_coord = ParentMap.get_cell_autotile_coord(cell.x, cell.y)
			if ParentMap.get_cell(cell.x, cell.y) == 2:
				# vegetable cell?
				continue
			# check for corner connected up and left
			if int(autotile_coord.x) & CONNECTED_UP > 0 \
					&& int(autotile_coord.x) & CONNECTED_LEFT > 0 \
					&& int(ParentMap.get_cell_autotile_coord(cell.x - 1, cell.y).x) & CONNECTED_UP == 0:
				set_cell(cell.x * 2, cell.y * 2, 0, false, false, false, Vector2(0, autotile_coord.y * 2))
			# check for corner connected up and right
			if int(autotile_coord.x) & CONNECTED_UP > 0 \
					&& int(autotile_coord.x) & CONNECTED_RIGHT > 0 \
					&& int(ParentMap.get_cell_autotile_coord(cell.x + 1, cell.y).x) & CONNECTED_UP == 0:
				set_cell(cell.x * 2 + 1, cell.y * 2, 0, false, false, false, Vector2(1, autotile_coord.y * 2))
			# check for corner connected down and left
			if int(autotile_coord.x) & CONNECTED_DOWN > 0 \
					&& int(autotile_coord.x) & CONNECTED_LEFT > 0 \
					&& int(ParentMap.get_cell_autotile_coord(cell.x - 1, cell.y).x) & CONNECTED_DOWN == 0:
				set_cell(cell.x * 2, cell.y * 2 + 1, 0, false, false, false, Vector2(0, autotile_coord.y * 2 + 1))
			# check for corner connected down and right
			if int(autotile_coord.x) & CONNECTED_DOWN > 0 \
					&& int(autotile_coord.x) & CONNECTED_RIGHT > 0 \
					&& int(ParentMap.get_cell_autotile_coord(cell.x + 1, cell.y).x) & CONNECTED_DOWN == 0:
				set_cell(cell.x * 2 + 1, cell.y * 2 + 1, 0, false, false, false, Vector2(1, autotile_coord.y * 2 + 1))
		dirty = false
