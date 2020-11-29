extends TileMap
"""
Draws shadows under tiles from an obstacle tile map.
"""

export (NodePath) var obstacle_map_path: NodePath

onready var _obstacle_map: TileMap = get_node(obstacle_map_path)

func _ready() -> void:
	clear()
	
	for cell_obj in _obstacle_map.get_used_cells():
		var cell: Vector2 = cell_obj
		set_cell(cell.x, cell.y, 0)
