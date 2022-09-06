extends TileMap
## Draws shadows under tiles from an obstacle tilemap.

export (NodePath) var obstacle_map_path: NodePath setget set_obstacle_map_path

## Maps tile indexes to their grid size. This allows us to generate larger shadows for tiles which span multiple cells.
##
## This mapping is optional. Tile indexes which are absent will be given a 1x1 cell shadow.
##
## key: (int) tile index corresponding to a tile in the obstacle map
## value: (Rect2) a rectangle which measures tile's grid size, in cells
export (Dictionary) var cell_shadow_mapping setget set_cell_shadow_mapping

var _obstacle_map: TileMap

func _ready() -> void:
	_refresh_obstacle_map_path()
	_refresh_shadows()


func set_obstacle_map_path(new_obstacle_map_path: NodePath) -> void:
	obstacle_map_path = new_obstacle_map_path
	_refresh_obstacle_map_path()
	_refresh_shadows()


func set_cell_shadow_mapping(new_cell_shadow_mapping: Dictionary) -> void:
	cell_shadow_mapping = new_cell_shadow_mapping
	_refresh_shadows()


func _refresh_obstacle_map_path() -> void:
	if obstacle_map_path:
		_obstacle_map = get_node(obstacle_map_path)


func _refresh_shadows() -> void:
	if not (is_inside_tree() and obstacle_map_path):
		return
	
	clear()
	for cell_obj in _obstacle_map.get_used_cells():
		var cell: Vector2 = cell_obj
		var cell_id := _obstacle_map.get_cellv(cell)
		
		if cell_shadow_mapping.has(cell_id):
			# shade the surrounding cells for objects which are larger than the cell extents
			var cell_rect: Rect2 = cell_shadow_mapping[cell_id]
			for x in range(cell_rect.position.x + cell.x, cell_rect.end.x + cell.x):
				for y in range(cell_rect.position.y + cell.y, cell_rect.end.y + cell.y):
					set_cell(x, y, 0)
		else:
			set_cellv(cell, 0)
