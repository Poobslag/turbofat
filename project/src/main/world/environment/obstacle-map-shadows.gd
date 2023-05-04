extends TileMap
## Draws shadows under tiles from an obstacle tilemap.

@export var obstacle_map_path: NodePath: set = set_obstacle_map_path

## Maps tile indexes to their grid size. This allows us to generate larger shadows for tiles which span multiple cells.
##
## This mapping is optional. Tile indexes which are absent will be given a 1x1 cell shadow.
##
## key: (int) tile index corresponding to a tile in the obstacle map
## value: (Rect2i) tile's grid size, in cells
@export var cell_shadow_mapping: Dictionary: set = set_cell_shadow_mapping

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
	_obstacle_map = get_node(obstacle_map_path) if obstacle_map_path else null


func _refresh_shadows() -> void:
	if not (is_inside_tree() and not obstacle_map_path.is_empty()):
		return
	
	clear()
	for cell_obj in _obstacle_map.get_used_cells(0):
		var cell: Vector2i = cell_obj
		var cell_id := _obstacle_map.get_cell_source_id(0, cell)
		
		if cell_shadow_mapping.has(cell_id):
			# shade the surrounding cells for objects which are larger than the cell extents
			var cell_rect: Rect2i = cell_shadow_mapping[cell_id]
			for x in range(cell_rect.position.x + cell.x, cell_rect.end.x + cell.x):
				for y in range(cell_rect.position.y + cell.y, cell_rect.end.y + cell.y):
					set_cell(0, Vector2i(x, y), 0)
		else:
			set_cell(0, cell, 0)
