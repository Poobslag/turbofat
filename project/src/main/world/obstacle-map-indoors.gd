tool
class_name ObstacleMapIndoors
extends ObstacleMap
"""
Maintains a tilemap for indoor obstacles.

The indoor tilemap is an isometric tilemap which must be drawn from left to right. This tilemap includes functionality
for sorting tiles by their x coordinate.
"""

const BIND_TOP := TileSet.BIND_TOP
const BIND_BOTTOM := TileSet.BIND_BOTTOM
const BIND_LEFT := TileSet.BIND_LEFT
const BIND_RIGHT := TileSet.BIND_RIGHT

# constants representing the orientation of certain tiles, which direction objects are facing
const UP := 1
const DOWN := 2
const LEFT := 4
const RIGHT := 8

const BARE_COUNTERTOP_TILE_INDEX := 8
const GRILL_TILE_INDEX := 9

# key: union of TileSet bindings for adjacent cells containing countertops
# value: countertop autotile coordinate
var COUNTERTOP_AUTOTILE_COORDS_BY_BINDING := {
	0: Vector2(0, 0),
	BIND_TOP: Vector2(1, 0),
	BIND_BOTTOM: Vector2(2, 0),
	BIND_TOP | BIND_BOTTOM: Vector2(3, 0),
	BIND_LEFT: Vector2(0, 1),
	BIND_TOP | BIND_LEFT: Vector2(1, 1),
	BIND_BOTTOM | BIND_LEFT: Vector2(2, 1),
	BIND_RIGHT: Vector2(3, 1),
	BIND_TOP| BIND_RIGHT: Vector2(0, 2),
	BIND_BOTTOM| BIND_RIGHT: Vector2(1, 2),
	BIND_LEFT| BIND_RIGHT: Vector2(2, 2),
}

# key: countertop autotile coordinate
# value: direction which the grill is facing on that tile (UP, DOWN, LEFT, RIGHT)
var GRILL_ORIENTATION_BY_CELL := {
	Vector2(0, 0): UP,
	Vector2(1, 0): UP,
	Vector2(2, 0): UP,
	Vector2(3, 0): UP,
	Vector2(0, 1): UP,
	Vector2(1, 1): UP,
	Vector2(2, 1): UP,
	Vector2(3, 1): UP,
	Vector2(0, 2): DOWN,
	Vector2(1, 2): DOWN,
	Vector2(2, 2): DOWN,
	Vector2(3, 2): DOWN,
	Vector2(0, 3): DOWN,
	Vector2(1, 3): DOWN,
	Vector2(2, 3): DOWN,
	Vector2(3, 3): DOWN,
	Vector2(0, 4): LEFT,
	Vector2(1, 4): LEFT,
	Vector2(2, 4): LEFT,
	Vector2(3, 4): LEFT,
	Vector2(0, 5): LEFT,
	Vector2(1, 5): LEFT,
	Vector2(2, 5): LEFT,
	Vector2(3, 5): LEFT,
	Vector2(0, 6): RIGHT,
	Vector2(1, 6): RIGHT,
	Vector2(2, 6): RIGHT,
	Vector2(3, 6): RIGHT,
	Vector2(0, 7): RIGHT,
	Vector2(1, 7): RIGHT,
	Vector2(2, 7): RIGHT,
	Vector2(3, 7): RIGHT,
}

# key: array containing 3 elements representing TileSet bindings and metadata:
#    key[0] = direction which the grill is currently facing (UP, DOWN, LEFT, RIGHT)
#    key[1] = union of TileSet bindings for adjacent cells containing grills
#    key[2] = union of TileSet bindings for adjacent cells containing grills and countertops
# value: grill autotile coordinate
const GRILL_AUTOTILE_COORDS_BY_BINDING := {
	[UP, 0, 0]: Vector2(0, 0),
	[UP, 0, BIND_LEFT]: Vector2(1, 0),
	[UP, 0, BIND_RIGHT]: Vector2(2, 0),
	[UP, 0, BIND_LEFT | BIND_RIGHT]: Vector2(3, 0),
	[UP, BIND_LEFT, BIND_LEFT]: Vector2(0, 1),
	[UP, BIND_LEFT, BIND_LEFT | BIND_RIGHT]: Vector2(1, 1),
	[UP, BIND_RIGHT, BIND_RIGHT]: Vector2(2, 1),
	[UP, BIND_RIGHT, BIND_LEFT | BIND_RIGHT]: Vector2(3, 1),
	[DOWN, 0, 0]: Vector2(0, 2),
	[DOWN, 0, BIND_LEFT]: Vector2(1, 2),
	[DOWN, 0, BIND_RIGHT]: Vector2(2, 2),
	[DOWN, 0, BIND_LEFT | BIND_RIGHT]: Vector2(3, 2),
	[DOWN, BIND_LEFT, BIND_LEFT]: Vector2(0, 3),
	[DOWN, BIND_LEFT, BIND_LEFT | BIND_RIGHT]: Vector2(1, 3),
	[DOWN, BIND_RIGHT, BIND_RIGHT]: Vector2(2, 3),
	[DOWN, BIND_RIGHT, BIND_LEFT | BIND_RIGHT]: Vector2(3, 3),
	[LEFT, 0, 0]: Vector2(0, 4),
	[LEFT, 0, BIND_TOP]: Vector2(1, 4),
	[LEFT, 0, BIND_BOTTOM]: Vector2(2, 4),
	[LEFT, 0, BIND_TOP | BIND_BOTTOM]: Vector2(3, 4),
	[LEFT, BIND_TOP, BIND_TOP]: Vector2(0, 5),
	[LEFT, BIND_TOP, BIND_TOP | BIND_BOTTOM]: Vector2(1, 5),
	[LEFT, BIND_BOTTOM, BIND_BOTTOM]: Vector2(2, 5),
	[LEFT, BIND_BOTTOM, BIND_TOP | BIND_BOTTOM]: Vector2(3, 5),
	[RIGHT, 0, 0]: Vector2(0, 6),
	[RIGHT, 0, BIND_TOP]: Vector2(1, 6),
	[RIGHT, 0, BIND_BOTTOM]: Vector2(2, 6),
	[RIGHT, 0, BIND_TOP | BIND_BOTTOM]: Vector2(3, 6),
	[RIGHT, BIND_TOP, BIND_TOP]: Vector2(0, 7),
	[RIGHT, BIND_TOP, BIND_TOP | BIND_BOTTOM]: Vector2(1, 7),
	[RIGHT, BIND_BOTTOM, BIND_BOTTOM]: Vector2(2, 7),
	[RIGHT, BIND_BOTTOM, BIND_TOP | BIND_BOTTOM]: Vector2(3, 7),
}

# An editor toggle which sorts tiles by their y coordinate and x coordinate.
#
# Godot has no way to sort TileMaps by their x coordinate. See Godot-Proposals #2838
# https://github.com/godotengine/godot-proposals/issues/2838
export (bool) var _xsort: bool setget xsort

# An editor toggle which manually applies autotiling.
#
# Godot has no way of automatically reacting to GridMap/TileMap changes. See Godot #11855
# https://github.com/godotengine/godot/issues/11855
export (bool) var _autotile_countertops: bool setget autotile_countertops

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


"""
Autotiles tiles with kitchen countertops.

The kitchen countertop autotiling involves multiple cell types and cannot be handled by Godot's built-in autotiling.
Instead of configuring the autotiling behavior with the TileSet's autotile bitmask, it is configured with several
dictionary constants defined in this script.
"""
func autotile_countertops(_value: bool) -> void:
	for cell in get_used_cells():
		match get_cellv(cell):
			BARE_COUNTERTOP_TILE_INDEX: _autotile_bare_countertop(cell)
			GRILL_TILE_INDEX: _autotile_grill(cell)


"""
Autotiles a tile containing a bare countertop.

Parameters:
	'cell': The TileMap coordinates of the cell to be autotiled.
"""
func _autotile_bare_countertop(cell: Vector2) -> void:
	var binding := 0
	
	# calculate which adjacent cells contain countertops and grills
	if get_cellv(cell + Vector2.UP) in [BARE_COUNTERTOP_TILE_INDEX, GRILL_TILE_INDEX]:
		binding |= BIND_TOP
	if get_cellv(cell + Vector2.DOWN) in [BARE_COUNTERTOP_TILE_INDEX, GRILL_TILE_INDEX]:
		binding |= BIND_BOTTOM
	if get_cellv(cell + Vector2.LEFT) in [BARE_COUNTERTOP_TILE_INDEX, GRILL_TILE_INDEX]:
		binding |= BIND_LEFT
	if get_cellv(cell + Vector2.RIGHT) in [BARE_COUNTERTOP_TILE_INDEX, GRILL_TILE_INDEX]:
		binding |= BIND_RIGHT
	
	# update the autotile if a matching countertop cell exists
	if COUNTERTOP_AUTOTILE_COORDS_BY_BINDING.has(binding):
		_set_cell_autotile_coord(cell, COUNTERTOP_AUTOTILE_COORDS_BY_BINDING[binding])


"""
Updates the autotile coordinate for a TileMap cell.

Parameters:
	'cell': The TileMap coordinates of the cell to be updated.
	
	'autotile_coord': The autotile coordinates to assign.
"""
func _set_cell_autotile_coord(cell: Vector2, autotile_coord: Vector2) -> void:
	var tile: int = get_cell(cell.x, cell.y)
	var flip_x: bool = is_cell_x_flipped(cell.x, cell.y)
	var flip_y: bool = is_cell_y_flipped(cell.x, cell.y)
	var transpose: bool = is_cell_transposed(cell.x, cell.y)
	set_cell(cell.x, cell.y, tile, flip_x, flip_y, transpose, autotile_coord)


"""
Autotiles a tile containing a grill.

Parameters:
	'cell': The TileMap coordinates of the cell to be autotiled.
"""
func _autotile_grill(cell: Vector2) -> void:
	# calculate the grill's current orientation
	var grill_orientation: int = GRILL_ORIENTATION_BY_CELL.get(get_cell_autotile_coord(cell.x, cell.y))
	
	# calculate which adjacent cells contain grills
	var grill_binding := 0
	if get_cellv(cell + Vector2.UP) == GRILL_TILE_INDEX:
		grill_binding |= BIND_TOP
	if get_cellv(cell + Vector2.DOWN) == GRILL_TILE_INDEX:
		grill_binding |= BIND_BOTTOM
	if get_cellv(cell + Vector2.LEFT) == GRILL_TILE_INDEX:
		grill_binding |= BIND_LEFT
	if get_cellv(cell + Vector2.RIGHT) == GRILL_TILE_INDEX:
		grill_binding |= BIND_RIGHT
	
	# calculate which adjacent cells contain countertops and grills
	var countertop_binding := 0
	if get_cellv(cell + Vector2.UP) in [BARE_COUNTERTOP_TILE_INDEX, GRILL_TILE_INDEX]:
		countertop_binding |= BIND_TOP
	if get_cellv(cell + Vector2.DOWN) in [BARE_COUNTERTOP_TILE_INDEX, GRILL_TILE_INDEX]:
		countertop_binding |= BIND_BOTTOM
	if get_cellv(cell + Vector2.LEFT) in [BARE_COUNTERTOP_TILE_INDEX, GRILL_TILE_INDEX]:
		countertop_binding |= BIND_LEFT
	if get_cellv(cell + Vector2.RIGHT) in [BARE_COUNTERTOP_TILE_INDEX, GRILL_TILE_INDEX]:
		countertop_binding |= BIND_RIGHT
		
	# Calculate which countertop cell matches the specified grill key. If the key  is not found, we reorient the grill
	# to force a match.
	var grill_key := [grill_orientation, grill_binding, countertop_binding]
	if not GRILL_AUTOTILE_COORDS_BY_BINDING.has(grill_key):
		grill_key[0] = DOWN
	if not GRILL_AUTOTILE_COORDS_BY_BINDING.has(grill_key):
		grill_key[0] = RIGHT
	
	# update the autotile if a matching grill cell exists
	if GRILL_AUTOTILE_COORDS_BY_BINDING.has(grill_key):
		_set_cell_autotile_coord(cell, GRILL_AUTOTILE_COORDS_BY_BINDING.get(grill_key))


func _compare_by_x(a: Vector2, b: Vector2) -> bool:
	return a.x < b.x
