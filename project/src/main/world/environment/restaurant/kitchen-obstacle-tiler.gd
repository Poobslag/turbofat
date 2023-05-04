@tool
extends Node
## Autotiles a tilemap for kitchen obstacles.
##
## The kitchen tiles like grills, counters and sinks involve multiple cell types and cannot be handled by Godot's
## built-in autotiling. Instead of configuring the autotiling behavior with the TileSet's autotile bitmask, it is
## configured with several dictionary constants defined in this script.

const BIND_TOP := 1
const BIND_BOTTOM := 2
const BIND_LEFT := 4
const BIND_RIGHT := 8

## constants representing the orientation of certain tiles, which direction objects are facing
const UP := 1
const DOWN := 2
const LEFT := 4
const RIGHT := 8

## key: (int) union of TileSet bindings for adjacent cells containing countertops
## value: (Vector2i) countertop autotile coordinate
const COUNTERTOP_AUTOTILE_COORDS_BY_BINDING := {
	0: Vector2i(0, 0),
	BIND_TOP: Vector2i(1, 0),
	BIND_BOTTOM: Vector2i(2, 0),
	BIND_TOP | BIND_BOTTOM: Vector2i(3, 0),
	BIND_LEFT: Vector2i(0, 1),
	BIND_TOP | BIND_LEFT: Vector2i(1, 1),
	BIND_BOTTOM | BIND_LEFT: Vector2i(2, 1),
	BIND_RIGHT: Vector2i(3, 1),
	BIND_TOP | BIND_RIGHT: Vector2i(0, 2),
	BIND_BOTTOM | BIND_RIGHT: Vector2i(1, 2),
	BIND_LEFT | BIND_RIGHT: Vector2i(2, 2),
}

## key: (int) union of TileSet bindings for adjacent cells containing countertops
## value: (Vector2i) array of possible countertop-plates autotile coordinates
const COUNTERTOP_PLATES_AUTOTILE_COORDS_BY_BINDING := {
	0: [Vector2i(0, 0), Vector2i(1, 0)],
	BIND_TOP: [Vector2i(2, 0), Vector2i(3, 0)],
	BIND_BOTTOM: [Vector2i(4, 0), Vector2i(5, 0)],
	BIND_TOP | BIND_BOTTOM: [Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1)],
	BIND_LEFT: [Vector2i(4, 1), Vector2i(5, 1)],
	BIND_TOP | BIND_LEFT: [Vector2i(0, 2), Vector2i(1, 2)],
	
	BIND_BOTTOM | BIND_LEFT: [Vector2i(2, 2), Vector2i(3, 2)],
	BIND_RIGHT: [Vector2i(4, 2), Vector2i(5, 2)],
	BIND_TOP | BIND_RIGHT: [Vector2i(0, 3), Vector2i(1, 3)],
	BIND_BOTTOM | BIND_RIGHT: [Vector2i(2, 3), Vector2i(3, 3)],
	BIND_LEFT | BIND_RIGHT: [Vector2i(4, 3), Vector2i(5, 3), Vector2i(0, 4), Vector2i(1, 4)],
}

## key: (Vector2i) countertop autotile coordinate
## value: (int) direction which the grill is facing on that tile (UP, DOWN, LEFT, RIGHT)
const GRILL_ORIENTATION_BY_CELL := {
	Vector2i(0, 0): UP,
	Vector2i(1, 0): UP,
	Vector2i(2, 0): UP,
	Vector2i(3, 0): UP,
	Vector2i(0, 1): UP,
	Vector2i(1, 1): UP,
	Vector2i(2, 1): UP,
	Vector2i(3, 1): UP,
	Vector2i(0, 2): DOWN,
	Vector2i(1, 2): DOWN,
	Vector2i(2, 2): DOWN,
	Vector2i(3, 2): DOWN,
	Vector2i(0, 3): DOWN,
	Vector2i(1, 3): DOWN,
	Vector2i(2, 3): DOWN,
	Vector2i(3, 3): DOWN,
	Vector2i(0, 4): LEFT,
	Vector2i(1, 4): LEFT,
	Vector2i(2, 4): LEFT,
	Vector2i(3, 4): LEFT,
	Vector2i(0, 5): LEFT,
	Vector2i(1, 5): LEFT,
	Vector2i(2, 5): LEFT,
	Vector2i(3, 5): LEFT,
	Vector2i(0, 6): RIGHT,
	Vector2i(1, 6): RIGHT,
	Vector2i(2, 6): RIGHT,
	Vector2i(3, 6): RIGHT,
	Vector2i(0, 7): RIGHT,
	Vector2i(1, 7): RIGHT,
	Vector2i(2, 7): RIGHT,
	Vector2i(3, 7): RIGHT,
}

## key: (Array) array containing 3 elements representing TileSet bindings and metadata:
## 	key[0]: (int) direction which the grill is currently facing (UP, DOWN, LEFT, RIGHT)
## 	key[1]: (int) union of TileSet bindings for adjacent cells containing grills
## 	key[2]: (int) union of TileSet bindings for adjacent cells containing grills and countertops
## value: (Vector2i) grill autotile coordinate
const GRILL_AUTOTILE_COORDS_BY_BINDING := {
	[UP, 0, 0]: Vector2i(0, 0),
	[UP, 0, BIND_LEFT]: Vector2i(1, 0),
	[UP, 0, BIND_RIGHT]: Vector2i(2, 0),
	[UP, 0, BIND_LEFT | BIND_RIGHT]: Vector2i(3, 0),
	[UP, BIND_LEFT, BIND_LEFT]: Vector2i(0, 1),
	[UP, BIND_LEFT, BIND_LEFT | BIND_RIGHT]: Vector2i(1, 1),
	[UP, BIND_RIGHT, BIND_RIGHT]: Vector2i(2, 1),
	[UP, BIND_RIGHT, BIND_LEFT | BIND_RIGHT]: Vector2i(3, 1),
	[DOWN, 0, 0]: Vector2i(0, 2),
	[DOWN, 0, BIND_LEFT]: Vector2i(1, 2),
	[DOWN, 0, BIND_RIGHT]: Vector2i(2, 2),
	[DOWN, 0, BIND_LEFT | BIND_RIGHT]: Vector2i(3, 2),
	[DOWN, BIND_LEFT, BIND_LEFT]: Vector2i(0, 3),
	[DOWN, BIND_LEFT, BIND_LEFT | BIND_RIGHT]: Vector2i(1, 3),
	[DOWN, BIND_RIGHT, BIND_RIGHT]: Vector2i(2, 3),
	[DOWN, BIND_RIGHT, BIND_LEFT | BIND_RIGHT]: Vector2i(3, 3),
	[LEFT, 0, 0]: Vector2i(0, 4),
	[LEFT, 0, BIND_TOP]: Vector2i(1, 4),
	[LEFT, 0, BIND_BOTTOM]: Vector2i(2, 4),
	[LEFT, 0, BIND_TOP | BIND_BOTTOM]: Vector2i(3, 4),
	[LEFT, BIND_TOP, BIND_TOP]: Vector2i(0, 5),
	[LEFT, BIND_TOP, BIND_TOP | BIND_BOTTOM]: Vector2i(1, 5),
	[LEFT, BIND_BOTTOM, BIND_BOTTOM]: Vector2i(2, 5),
	[LEFT, BIND_BOTTOM, BIND_TOP | BIND_BOTTOM]: Vector2i(3, 5),
	[RIGHT, 0, 0]: Vector2i(0, 6),
	[RIGHT, 0, BIND_TOP]: Vector2i(1, 6),
	[RIGHT, 0, BIND_BOTTOM]: Vector2i(2, 6),
	[RIGHT, 0, BIND_TOP | BIND_BOTTOM]: Vector2i(3, 6),
	[RIGHT, BIND_TOP, BIND_TOP]: Vector2i(0, 7),
	[RIGHT, BIND_TOP, BIND_TOP | BIND_BOTTOM]: Vector2i(1, 7),
	[RIGHT, BIND_BOTTOM, BIND_BOTTOM]: Vector2i(2, 7),
	[RIGHT, BIND_BOTTOM, BIND_TOP | BIND_BOTTOM]: Vector2i(3, 7),
}

## key: (Vector2i) sink autotile coordinate
## value: (int) direction which the sink is facing on that tile (UP, DOWN, LEFT, RIGHT)
const SINK_ORIENTATION_BY_CELL := {
	Vector2i(0, 0): UP,
	Vector2i(1, 0): UP,
	Vector2i(2, 0): UP,
	Vector2i(0, 1): DOWN,
	Vector2i(1, 1): DOWN,
	Vector2i(2, 1): DOWN,
	Vector2i(0, 2): LEFT,
	Vector2i(1, 2): LEFT,
	Vector2i(2, 2): LEFT,
	Vector2i(0, 3): RIGHT,
	Vector2i(1, 3): RIGHT,
	Vector2i(2, 3): RIGHT,
}

## key: (Array) array containing 3 elements representing TileSet bindings and metadata:
## 	key[0]: (int) direction which the sink is currently facing (UP, DOWN, LEFT, RIGHT)
## 	key[1]: (int) union of TileSet bindings for adjacent cells containing sinks
## value: (Vector2i) sink autotile coordinate
const SINK_AUTOTILE_COORDS_BY_BINDING := {
	[UP, 0]: Vector2i(0, 0),
	[UP, BIND_LEFT]: Vector2i(1, 0),
	[UP, BIND_RIGHT]: Vector2i(2, 0),
	[DOWN, 0]: Vector2i(0, 1),
	[DOWN, BIND_LEFT]: Vector2i(1, 1),
	[DOWN, BIND_RIGHT]: Vector2i(2, 1),
	[LEFT, 0]: Vector2i(0, 2),
	[LEFT, BIND_TOP]: Vector2i(1, 2),
	[LEFT, BIND_BOTTOM]: Vector2i(2, 2),
	[RIGHT, 0]: Vector2i(0, 3),
	[RIGHT, BIND_TOP]: Vector2i(1, 3),
	[RIGHT, BIND_BOTTOM]: Vector2i(2, 3),
}

## Parent tilemap's tile ID for bare countertops
@export var bare_countertop_tile_index: int

## Parent tilemap's tile ID for countertops with a grill
@export var grill_tile_index: int

## Parent tilemap's tile ID for countertops with a sink
@export var sink_tile_index: int

## Parent tilemap's tile ID for countertops with plates
@export var countertop_plates_tile_index: int

## Editor toggle which manually applies autotiling.
##
## Godot has no way of automatically reacting to GridMap/TileMap changes. See Godot #11855
## https://github.com/godotengine/godot/issues/11855
@export var _autotile: bool: set = autotile

## tilemap containing obstacles
@onready var _tile_map: TileMap = get_parent()

## Preemptively initializes onready variables to avoid null references.
func _enter_tree() -> void:
	_initialize_onready_variables()


## Autotiles tiles with kitchen countertops, grills, sinks and other complex tiles.
##
## The kitchen autotiling involves multiple cell types and cannot be handled by Godot's built-in autotiling. Instead
## of configuring the autotiling behavior with the TileSet's autotile bitmask, it is configured with several
## dictionary constants defined in this script.
func autotile(value: bool) -> void:
	if not value:
		# only autotile in the editor when the 'Autotile' property is toggled
		return
	
	if Engine.is_editor_hint():
		if not _tile_map:
			# initialize variables to avoid nil reference errors in the editor when editing tool scripts
			_initialize_onready_variables()
	
	for cell in _tile_map.get_used_cells(0):
		match _tile_map.get_cell_source_id(0, cell):
			bare_countertop_tile_index: _autotile_bare_countertop(cell)
			grill_tile_index: _autotile_grill(cell)
			sink_tile_index: _autotile_sink(cell)
			countertop_plates_tile_index: _autotile_countertop_plates(cell)


## Preemptively initializes onready variables to avoid null references.
func _initialize_onready_variables() -> void:
	_tile_map = get_parent()


## Autotiles a tile containing a bare countertop.
##
## Parameters:
## 	'cell': The TileMap coordinates of the cell to be autotiled.
func _autotile_bare_countertop(cell: Vector2i) -> void:
	var adjacent_countertops := _adjacencies(cell,
			[bare_countertop_tile_index, grill_tile_index, countertop_plates_tile_index])
	
	# update the autotile if a matching countertop cell exists
	if COUNTERTOP_AUTOTILE_COORDS_BY_BINDING.has(adjacent_countertops):
		_set_cell_autotile_coord(cell, COUNTERTOP_AUTOTILE_COORDS_BY_BINDING[adjacent_countertops])


## Autotiles a tile containing a countertop with plates on it.
##
## Parameters:
## 	'cell': The TileMap coordinates of the cell to be autotiled.
func _autotile_countertop_plates(cell: Vector2i) -> void:
	var adjacent_countertops := _adjacencies(cell,
			[bare_countertop_tile_index, grill_tile_index, countertop_plates_tile_index])
	
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
func _set_cell_autotile_coord(cell: Vector2i, autotile_coord: Vector2i) -> void:
	var tile: int = _tile_map.get_cell_source_id(0, cell)
	var flip_x: bool = _tile_map.is_cell_x_flipped(cell.x, cell.y)
	var flip_y: bool = _tile_map.is_cell_y_flipped(cell.x, cell.y)
	var transpose: bool = _tile_map.is_cell_transposed(cell.x, cell.y)
	_tile_map.set_cell(0, cell, tile, autotile_coord)
	# flip_x, flip_y, transpose


## Autotiles a tile containing a grill.
##
## Parameters:
## 	'cell': The TileMap coordinates of the cell to be autotiled.
func _autotile_grill(cell: Vector2i) -> void:
	# calculate the grill's current orientation
	var grill_orientation: int = GRILL_ORIENTATION_BY_CELL.get(_tile_map.get_cell_atlas_coords(0, cell))
	
	var adjacent_grills := _adjacencies(cell, [grill_tile_index])
	var adjacent_countertops := _adjacencies(cell,
			[bare_countertop_tile_index, grill_tile_index, countertop_plates_tile_index])
	
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
func _autotile_sink(cell: Vector2i) -> void:
	var orientation: int = SINK_ORIENTATION_BY_CELL.get(_tile_map.get_cell_atlas_coords(0, cell))
	
	var adjacent_sinks := _adjacencies(cell, [sink_tile_index])
	
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
## Parameters:
## 	'cell': The TileMap coordinates of the cell to be analyzed.
##
## 	'tile_indexes': The tile indexes to check for in adjacent cells
##
## Returns:
## 	An int bitmask of matching cell directions (UP, DOWN, LEFT, RIGHT)
func _adjacencies(cell: Vector2i, tile_indexes: Array) -> int:
	var binding := 0
	binding |= BIND_TOP if _tile_map.get_cell_source_id(0, cell + Vector2i.UP) in tile_indexes else 0
	binding |= BIND_BOTTOM if _tile_map.get_cell_source_id(0, cell + Vector2i.DOWN) in tile_indexes else 0
	binding |= BIND_LEFT if _tile_map.get_cell_source_id(0, cell + Vector2i.LEFT) in tile_indexes else 0
	binding |= BIND_RIGHT if _tile_map.get_cell_source_id(0, cell + Vector2i.RIGHT) in tile_indexes else 0
	return binding
