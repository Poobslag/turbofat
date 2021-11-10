tool
class_name ObstacleMapIndoors
extends ObstacleMap
## Maintains a tilemap for indoor obstacles.
##
## The indoor tilemap is an isometric tilemap which must be drawn from left to right. This tilemap includes
## functionality for sorting tiles by their x coordinate.

const BIND_TOP := TileSet.BIND_TOP
const BIND_BOTTOM := TileSet.BIND_BOTTOM
const BIND_LEFT := TileSet.BIND_LEFT
const BIND_RIGHT := TileSet.BIND_RIGHT

## constants representing the orientation of certain tiles, which direction objects are facing
const UP := 1
const DOWN := 2
const LEFT := 4
const RIGHT := 8

## the index of specific tiles in the tilemap's tileset
const BARE_COUNTERTOP_TILE_INDEX := 8
const GRILL_TILE_INDEX := 9
const SINK_TILE_INDEX := 10
const COUNTERTOP_PLATES_TILE_INDEX := 11

## key: union of TileSet bindings for adjacent cells containing countertops
## value: countertop autotile coordinate
var COUNTERTOP_AUTOTILE_COORDS_BY_BINDING := {
	0: Vector2(0, 0),
	BIND_TOP: Vector2(1, 0),
	BIND_BOTTOM: Vector2(2, 0),
	BIND_TOP | BIND_BOTTOM: Vector2(3, 0),
	BIND_LEFT: Vector2(0, 1),
	BIND_TOP | BIND_LEFT: Vector2(1, 1),
	BIND_BOTTOM | BIND_LEFT: Vector2(2, 1),
	BIND_RIGHT: Vector2(3, 1),
	BIND_TOP | BIND_RIGHT: Vector2(0, 2),
	BIND_BOTTOM | BIND_RIGHT: Vector2(1, 2),
	BIND_LEFT | BIND_RIGHT: Vector2(2, 2),
}

## key: union of TileSet bindings for adjacent cells containing countertops
## value: array of possible countertop-plates autotile coordinates
var COUNTERTOP_PLATES_AUTOTILE_COORDS_BY_BINDING := {
	0: [Vector2(0, 0), Vector2(1, 0)],
	BIND_TOP: [Vector2(2, 0), Vector2(3, 0)],
	BIND_BOTTOM: [Vector2(4, 0), Vector2(5, 0)],
	BIND_TOP | BIND_BOTTOM: [Vector2(0, 1), Vector2(1, 1), Vector2(2, 1), Vector2(3, 1)],
	BIND_LEFT: [Vector2(4, 1), Vector2(5, 1)],
	BIND_TOP | BIND_LEFT: [Vector2(0, 2), Vector2(1, 2)],
	
	BIND_BOTTOM | BIND_LEFT: [Vector2(2, 2), Vector2(3, 2)],
	BIND_RIGHT: [Vector2(4, 2), Vector2(5, 2)],
	BIND_TOP | BIND_RIGHT: [Vector2(0, 3), Vector2(1, 3)],
	BIND_BOTTOM | BIND_RIGHT: [Vector2(2, 3), Vector2(3, 3)],
	BIND_LEFT | BIND_RIGHT: [Vector2(4, 3), Vector2(5, 3), Vector2(0, 4), Vector2(1, 4)],
}

## key: countertop autotile coordinate
## value: direction which the grill is facing on that tile (UP, DOWN, LEFT, RIGHT)
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

## key: array containing 3 elements representing TileSet bindings and metadata:
##    key[0] = direction which the grill is currently facing (UP, DOWN, LEFT, RIGHT)
##    key[1] = union of TileSet bindings for adjacent cells containing grills
##    key[2] = union of TileSet bindings for adjacent cells containing grills and countertops
## value: grill autotile coordinate
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

## key: sink autotile coordinate
## value: direction which the sink is facing on that tile (UP, DOWN, LEFT, RIGHT)
const SINK_ORIENTATION_BY_CELL := {
	Vector2(0, 0): UP,
	Vector2(1, 0): UP,
	Vector2(2, 0): UP,
	Vector2(0, 1): DOWN,
	Vector2(1, 1): DOWN,
	Vector2(2, 1): DOWN,
	Vector2(0, 2): LEFT,
	Vector2(1, 2): LEFT,
	Vector2(2, 2): LEFT,
	Vector2(0, 3): RIGHT,
	Vector2(1, 3): RIGHT,
	Vector2(2, 3): RIGHT,
}

## key: array containing 3 elements representing TileSet bindings and metadata:
##    key[0] = direction which the sink is currently facing (UP, DOWN, LEFT, RIGHT)
##    key[1] = union of TileSet bindings for adjacent cells containing sinks
## value: sink autotile coordinate
const SINK_AUTOTILE_COORDS_BY_BINDING := {
	[UP, 0]: Vector2(0, 0),
	[UP, BIND_LEFT]: Vector2(1, 0),
	[UP, BIND_RIGHT]: Vector2(2, 0),
	[DOWN, 0]: Vector2(0, 1),
	[DOWN, BIND_LEFT]: Vector2(1, 1),
	[DOWN, BIND_RIGHT]: Vector2(2, 1),
	[LEFT, 0]: Vector2(0, 2),
	[LEFT, BIND_TOP]: Vector2(1, 2),
	[LEFT, BIND_BOTTOM]: Vector2(2, 2),
	[RIGHT, 0]: Vector2(0, 3),
	[RIGHT, BIND_TOP]: Vector2(1, 3),
	[RIGHT, BIND_BOTTOM]: Vector2(2, 3),
}

## An editor toggle which manually applies autotiling.
#
## Godot has no way of automatically reacting to GridMap/TileMap changes. See Godot #11855
## https://github.com/godotengine/godot/issues/11855
export (bool) var _autotile: bool setget autotile


## Autotiles tiles with kitchen countertops.
##
## The kitchen countertop autotiling involves multiple cell types and cannot be handled by Godot's built-in autotiling.
## Instead of configuring the autotiling behavior with the TileSet's autotile bitmask, it is configured with several
## dictionary constants defined in this script.
func autotile(_value: bool) -> void:
	for cell in get_used_cells():
		match get_cellv(cell):
			BARE_COUNTERTOP_TILE_INDEX: _autotile_bare_countertop(cell)
			GRILL_TILE_INDEX: _autotile_grill(cell)
			SINK_TILE_INDEX: _autotile_sink(cell)
			COUNTERTOP_PLATES_TILE_INDEX: _autotile_countertop_plates(cell)


## Autotiles a tile containing a bare countertop.
##
## Parameters:
## 	'cell': The TileMap coordinates of the cell to be autotiled.
func _autotile_bare_countertop(cell: Vector2) -> void:
	var adjacent_countertops := _adjacencies(cell,
			[BARE_COUNTERTOP_TILE_INDEX, GRILL_TILE_INDEX, COUNTERTOP_PLATES_TILE_INDEX])
	
	# update the autotile if a matching countertop cell exists
	if COUNTERTOP_AUTOTILE_COORDS_BY_BINDING.has(adjacent_countertops):
		_set_cell_autotile_coord(cell, COUNTERTOP_AUTOTILE_COORDS_BY_BINDING[adjacent_countertops])


## Autotiles a tile containing a countertop with plates on it.
##
## Parameters:
## 	'cell': The TileMap coordinates of the cell to be autotiled.
func _autotile_countertop_plates(cell: Vector2) -> void:
	var adjacent_countertops := _adjacencies(cell,
			[BARE_COUNTERTOP_TILE_INDEX, GRILL_TILE_INDEX, COUNTERTOP_PLATES_TILE_INDEX])
	
	# update the autotile if a matching countertop cell exists
	if COUNTERTOP_PLATES_AUTOTILE_COORDS_BY_BINDING.has(adjacent_countertops):
		var bindings: Array = COUNTERTOP_PLATES_AUTOTILE_COORDS_BY_BINDING[adjacent_countertops]
		_set_cell_autotile_coord(cell, Utils.rand_value(bindings))


## Updates the autotile coordinate for a TileMap cell.
##
## Parameters:
## 	'cell': The TileMap coordinates of the cell to be updated.
##
## 	'autotile_coord': The autotile coordinates to assign.
func _set_cell_autotile_coord(cell: Vector2, autotile_coord: Vector2) -> void:
	var tile: int = get_cell(cell.x, cell.y)
	var flip_x: bool = is_cell_x_flipped(cell.x, cell.y)
	var flip_y: bool = is_cell_y_flipped(cell.x, cell.y)
	var transpose: bool = is_cell_transposed(cell.x, cell.y)
	set_cell(cell.x, cell.y, tile, flip_x, flip_y, transpose, autotile_coord)


## Autotiles a tile containing a grill.
##
## Parameters:
## 	'cell': The TileMap coordinates of the cell to be autotiled.
func _autotile_grill(cell: Vector2) -> void:
	# calculate the grill's current orientation
	var grill_orientation: int = GRILL_ORIENTATION_BY_CELL.get(get_cell_autotile_coord(cell.x, cell.y))
	
	var adjacent_grills := _adjacencies(cell, [GRILL_TILE_INDEX])
	var adjacent_countertops := _adjacencies(cell,
			[BARE_COUNTERTOP_TILE_INDEX, GRILL_TILE_INDEX, COUNTERTOP_PLATES_TILE_INDEX])
	
	# Calculate which countertop cell matches the specified grill key. If the key is not found, we reorient the grill
	# to force a match.
	var grill_key := [grill_orientation, adjacent_grills, adjacent_countertops]
	if not GRILL_AUTOTILE_COORDS_BY_BINDING.has(grill_key):
		grill_key[0] = DOWN
	if not GRILL_AUTOTILE_COORDS_BY_BINDING.has(grill_key):
		grill_key[0] = RIGHT
	
	# update the autotile if a matching grill cell exists
	if GRILL_AUTOTILE_COORDS_BY_BINDING.has(grill_key):
		_set_cell_autotile_coord(cell, GRILL_AUTOTILE_COORDS_BY_BINDING.get(grill_key))


## Autotiles a cell containing a sink.
##
## Parameters:
## 	'cell': The TileMap coordinates of the cell to be autotiled.
func _autotile_sink(cell: Vector2) -> void:
	var orientation: int = SINK_ORIENTATION_BY_CELL.get(get_cell_autotile_coord(cell.x, cell.y))
	
	var adjacent_sinks := _adjacencies(cell, [SINK_TILE_INDEX])
	
	# Calculate which sink cell matches the specified sink key. If the key is not found, we reorient the grill
	# to force a match.
	var sink_key := [orientation, adjacent_sinks]
	if not SINK_AUTOTILE_COORDS_BY_BINDING.has(sink_key):
		sink_key[0] = DOWN
	if not SINK_AUTOTILE_COORDS_BY_BINDING.has(sink_key):
		sink_key[0] = RIGHT
	
	# update the autotile if a matching sink cell exists
	if SINK_AUTOTILE_COORDS_BY_BINDING.has(sink_key):
		_set_cell_autotile_coord(cell, SINK_AUTOTILE_COORDS_BY_BINDING.get(sink_key))

## Calculates which adjacent cells match the specified tile indexes.
##
##
## Parameters:
## 	'cell': The TileMap coordinates of the cell to be analyzed.
##
## 	'tile_indexes': The tile indexes to check for in adjacent cells
##
## Returns:
## 	An int bitmask of matching cell directions (UP, DOWN, LEFT, RIGHT)
func _adjacencies(cell: Vector2, tile_indexes: Array) -> int:
	var binding := 0
	binding |= BIND_TOP if get_cellv(cell + Vector2.UP) in tile_indexes else 0
	binding |= BIND_BOTTOM if get_cellv(cell + Vector2.DOWN) in tile_indexes else 0
	binding |= BIND_LEFT if get_cellv(cell + Vector2.LEFT) in tile_indexes else 0
	binding |= BIND_RIGHT if get_cellv(cell + Vector2.RIGHT) in tile_indexes else 0
	return binding
