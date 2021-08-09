tool
class_name ObstacleMap
extends TileMap
"""
Maintains a tilemap for overworld obstacles.

This includes visible obstacles such as walls, as well as invisible obstacles which prevent the player from running off
the edge of the world.
"""

export (NodePath) var ground_map_path: NodePath

# the tile index in this tilemap which should be used to make tiles impassable
export (int) var impassable_tile_index := -1

# tilemap containing data on which cells are walkable
onready var _ground_map: TileMap = get_node(ground_map_path)

func _ready() -> void:
	_refresh_invisible_obstacles()


"""
Refreshes the position of invisible obstacles which keep the player from stepping off the edge.

These invisible obstacles are placed wherever there's an 'unwalkable cell' like a cliff next to a 'walkable cell' like
a patch of ground.
"""
func _refresh_invisible_obstacles() -> void:
	# remove all invisible obstacles
	for cell_obj in get_used_cells_by_id(impassable_tile_index):
		var cell: Vector2 = cell_obj
		set_cell(cell.x, cell.y, -1)
	
	# calculate empty unwalkable cells which are adjacent to walkable cells
	var unwalkable_cells := {}
	for cell_obj in _ground_map.get_used_cells():
		var cell: Vector2 = cell_obj
		for neighbor_x in range(cell.x - 1, cell.x + 2):
			for neighbor_y in range(cell.y - 1, cell.y + 2):
				if unwalkable_cells.has(Vector2(neighbor_x, neighbor_y)):
					# already added an entry to the map
					continue
				
				if _ground_map.get_cell(neighbor_x, neighbor_y) != INVALID_CELL:
					# walkable; the ground map has terrain at that cell
					continue
				
				if get_cell(neighbor_x, neighbor_y) != INVALID_CELL:
					# the obstacle map already has an obstacle at that cell; don't overwrite it
					continue
				
				unwalkable_cells[Vector2(neighbor_x, neighbor_y)] = true
	
	# place an invisible obstacle on each unwalkable cell
	for unwalkable_cell_obj in unwalkable_cells:
		var unwalkable_cell: Vector2 = unwalkable_cell_obj
		set_cell(unwalkable_cell.x, unwalkable_cell.y, impassable_tile_index)
