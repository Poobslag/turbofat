extends TileMap
"""
Draws shadows under tiles from an obstacle tilemap.
"""

export (NodePath) var obstacle_map_path: NodePath

"""
Maps tile indexes to their grid size. This allows us to generate larger shadows for tiles which span multiple cells.

This mapping is optional. Tile indexes which are absent will be given a 1x1 cell shadow.

key: tile index corresponding to a tile in the obstacle map
value: a rectangle which measures tile's grid size, in cells
"""
export (Dictionary) var cell_shadow_mapping

onready var _obstacle_map: TileMap = get_node(obstacle_map_path)

func _ready() -> void:
	clear()
	
	for cell_obj in _obstacle_map.get_used_cells():
		var cell: Vector2 = cell_obj
		var cell_id := _obstacle_map.get_cell(cell.x, cell.y)
		
		if cell_shadow_mapping.has(cell_id):
			# block the surrounding cells for objects which are larger than the cell extents
			var cell_rect: Rect2 = cell_shadow_mapping[cell_id]
			for x in range(cell_rect.position.x + cell.x, cell_rect.end.x + cell.x):
				for y in range(cell_rect.position.y + cell.y, cell_rect.end.y + cell.y):
					set_cell(x, y, 0)
		else:
			set_cell(cell.x, cell.y, 0)
