tool
class_name ObstacleMapIndoors
extends ObstacleMap
"""
Maintains a tilemap for indoor obstacles.

The indoor tilemap is an isometric tilemap which must be drawn from left to right. This tilemap includes functionality
for sorting tiles by their x coordinate.
"""

# editor toggle which sorts tiles by their y coordinate and x coordinate
export (bool) var xsort: bool setget xsort

func _ready() -> void:
	xsort(true)

"""
Sorts tiles by their x coordinate.

TileMaps render tiles from oldest to newest. To get Godot to render objects by their x coordinate, this method removes
all tiles from the TileMap and adds them again from left to right.
"""
func xsort(value: bool) -> void:
	if not value:
		return
	
	# create an X-sorted list of used cells in the tilemap
	var x_sorted_cells := get_used_cells().duplicate()
	x_sorted_cells.sort_custom(self, "_compare_by_x")
	
	# we cache the previous x coordinate to track if the x coordinate increases during the loop
	var prev_cell_x: int
	if x_sorted_cells:
		prev_cell_x = x_sorted_cells[0].x
	
	# replace the tiles from left to right
	for cell in x_sorted_cells:
		# cache the tilemap's metadata for this tile
		var tile: int = get_cell(cell.x, cell.y)
		var flip_x: bool = is_cell_x_flipped(cell.x, cell.y)
		var flip_y: bool = is_cell_y_flipped(cell.x, cell.y)
		var transpose: bool = is_cell_transposed(cell.x, cell.y)
		var autotile_coord: Vector2 = get_cell_autotile_coord(cell.x, cell.y)
		
		# remove the cell from the tilemap
		set_cell(cell.x, cell.y, -1)
		
		# we must pause when advancing the x coordinate or the render order will not change
		if cell.x != prev_cell_x:
			prev_cell_x = cell.x
			yield(get_tree(), "idle_frame")
		
		# add the tile to the tilemap
		set_cell(cell.x, cell.y, tile, flip_x, flip_y, transpose, autotile_coord)


func _compare_by_x(a: Vector2, b: Vector2) -> bool:
	return a.x < b.x
