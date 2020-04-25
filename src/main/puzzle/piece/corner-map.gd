extends TileMap
"""
Fine-grained tilemap which draws the inner corners of 90-degree angles.
"""

const UP = PieceTypes.CONNECTED_UP
const DOWN = PieceTypes.CONNECTED_DOWN
const LEFT = PieceTypes.CONNECTED_LEFT
const RIGHT = PieceTypes.CONNECTED_RIGHT

onready var _parent_map: TileMap = get_parent()

var dirty := false

func _process(_delta: float) -> void:
	if dirty:
		clear()
		for cell in _parent_map.get_used_cells():
			var pacx := _pacx(cell.x, cell.y)
			var pacy := _pacy(cell.x, cell.y)
			if _parent_map.get_cell(cell.x, cell.y) == 2:
				# vegetable cell?
				continue
			# check for corner connected up and left
			if pacx & UP > 0 and pacx & LEFT > 0 and _pacx(cell.x - 1, cell.y) & UP == 0:
				set_cell(cell.x * 2, cell.y * 2, 0, false, false, false, Vector2(0, pacy * 2))
			# check for corner connected up and right
			if pacx & UP > 0 and pacx & RIGHT > 0 and _pacx(cell.x + 1, cell.y) & UP == 0:
				set_cell(cell.x * 2 + 1, cell.y * 2, 0, false, false, false, Vector2(1, pacy * 2))
			# check for corner connected down and left
			if pacx & DOWN > 0 and pacx & LEFT > 0  and _pacx(cell.x - 1, cell.y) & DOWN == 0:
				set_cell(cell.x * 2, cell.y * 2 + 1, 0, false, false, false, Vector2(0, pacy * 2 + 1))
			# check for corner connected down and right
			if pacx & DOWN > 0 and pacx & RIGHT > 0 and _pacx(cell.x + 1, cell.y) & DOWN == 0:
				set_cell(cell.x * 2 + 1, cell.y * 2 + 1, 0, false, false, false, Vector2(1, pacy * 2 + 1))
		dirty = false


func _pacx(x: int, y: int) -> int:
	return int(_parent_map.get_cell_autotile_coord(x, y).x)


func _pacy(x: int, y: int) -> int:
	return int(_parent_map.get_cell_autotile_coord(x, y).y)
