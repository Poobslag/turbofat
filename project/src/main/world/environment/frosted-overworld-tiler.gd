tool
extends Node
## Autotiles a tilemap for frosted/unfrosted overworld cakes.
##
## The overworld cake autotiling rules involve multiple cell types and cannot be handled by Godot's built-in
## autotiling. Instead of configuring the autotiling behavior with the TileSet's autotile bitmask, it is configured
## with several dictionary constants defined in this script.
##
## This class also assigns appropriate 'corner covers', tiles which cover the corners of an overworld tilemap.

enum TileTypes {
	NONE,
	BLOCK,
	MIDFROST,
	FROST,
}

## Constants for adjacent cake tiles.
const CAKE_TOP := 1
const CAKE_BOTTOM := 2
const CAKE_LEFT := 4
const CAKE_RIGHT := 8
const CAKE_ALL := CAKE_RIGHT | CAKE_LEFT | CAKE_BOTTOM | CAKE_TOP

## Constants for adjacent frosted tiles.
const FROST_TOP := 16
const FROST_BOTTOM := 32
const FROST_LEFT := 64
const FROST_RIGHT := 128
const FROST_CENTER := 256

## Constants for corner covers.
const FROST_TOPLEFT := 512
const CAKE_CENTER := 1024

## Defines which tiles are used for different combination of frosted/unfrosted surrounding tiles.
##
## The key is a bitmask with the following components:
##   * CAKE_ALL
##   * CAKE_BOTTOM
##   * CAKE_LEFT
##   * CAKE_RIGHT
##   * CAKE_TOP
##   * FROST_BOTTOM
##   * FROST_CENTER
##   * FROST_LEFT
##   * FROST_RIGHT
##   * FROST_TOP
##
## key: (int) bitmask of surrounding tiles
## value: (Vector2) array of two elements which define a 'binding value':
##  value[0]: an enum from TileTypes defining the new tile type, such as 'frost' or 'midfrost'
##  value[1]: autotile coordinate of the new tile
const BLOCK_AUTOTILE_COORDS_BY_BINDING := {
	# unfrosted tiles
	0: [TileTypes.BLOCK,
			[Vector2(0, 0), Vector2(1, 0)]],
	CAKE_TOP: [TileTypes.BLOCK,
			[Vector2(2, 0), Vector2(3, 0)]],
	CAKE_BOTTOM: [TileTypes.BLOCK,
			[Vector2(4, 0), Vector2(5, 0)]],
	CAKE_BOTTOM | CAKE_TOP: [TileTypes.BLOCK,
			[Vector2(0, 1), Vector2(1, 1)]],
	CAKE_LEFT: [TileTypes.BLOCK,
			[Vector2(2, 1), Vector2(3, 1)]],
	CAKE_LEFT | CAKE_TOP: [TileTypes.BLOCK,
			[Vector2(4, 1), Vector2(5, 1)]],
	CAKE_LEFT | CAKE_BOTTOM: [TileTypes.BLOCK,
			[Vector2(0, 2), Vector2(1, 2)]],
	CAKE_LEFT | CAKE_BOTTOM | CAKE_TOP: [TileTypes.BLOCK,
			[Vector2(2, 2), Vector2(3, 2)]],
	CAKE_RIGHT: [TileTypes.BLOCK,
			[Vector2(4, 2), Vector2(5, 2)]],
	CAKE_RIGHT | CAKE_TOP: [TileTypes.BLOCK,
			[Vector2(0, 3), Vector2(1, 3)]],
	CAKE_RIGHT | CAKE_BOTTOM: [TileTypes.BLOCK,
			[Vector2(2, 3), Vector2(3, 3)]],
	CAKE_RIGHT | CAKE_BOTTOM | CAKE_TOP: [TileTypes.BLOCK,
			[Vector2(4, 3), Vector2(5, 3)]],
	CAKE_RIGHT | CAKE_LEFT: [TileTypes.BLOCK,
			[Vector2(0, 4), Vector2(1, 4)]],
	CAKE_RIGHT | CAKE_LEFT | CAKE_TOP: [TileTypes.BLOCK,
			[Vector2(2, 4), Vector2(3, 4)]],
	CAKE_RIGHT | CAKE_LEFT | CAKE_BOTTOM: [TileTypes.BLOCK,
			[Vector2(4, 4), Vector2(5, 4)]],
	CAKE_RIGHT | CAKE_LEFT | CAKE_BOTTOM | CAKE_TOP: [TileTypes.BLOCK,
			[Vector2(0, 5), Vector2(1, 5)]],
	
	# fully frosted tiles, where all adjacent blocks are also frosted
	FROST_CENTER:
			[TileTypes.FROST, [Vector2(0, 0)]],
	FROST_CENTER | CAKE_TOP | FROST_TOP:
			[TileTypes.FROST, [Vector2(1, 0)]],
	FROST_CENTER | CAKE_BOTTOM | FROST_BOTTOM:
			[TileTypes.FROST, [Vector2(2, 0)]],
	FROST_CENTER | CAKE_BOTTOM | CAKE_TOP | FROST_BOTTOM | FROST_TOP:
			[TileTypes.FROST, [Vector2(3, 0)]],
	FROST_CENTER | CAKE_LEFT | FROST_LEFT:
			[TileTypes.FROST, [Vector2(4, 0)]],
	FROST_CENTER | CAKE_LEFT | CAKE_TOP | FROST_LEFT | FROST_TOP:
			[TileTypes.FROST, [Vector2(5, 0)]],
	FROST_CENTER | CAKE_LEFT | CAKE_BOTTOM | FROST_LEFT | FROST_BOTTOM:
			[TileTypes.FROST, [Vector2(0, 1)]],
	FROST_CENTER | CAKE_LEFT | CAKE_BOTTOM | CAKE_TOP | FROST_LEFT | FROST_BOTTOM | FROST_TOP:
			[TileTypes.FROST, [Vector2(1, 1)], Vector2(2, 1), Vector2(3, 1), Vector2(4, 1)],
	FROST_CENTER | CAKE_RIGHT | FROST_RIGHT:
			[TileTypes.FROST, [Vector2(5, 1)]],
	FROST_CENTER | CAKE_RIGHT | CAKE_TOP | FROST_RIGHT | FROST_TOP:
			[TileTypes.FROST, [Vector2(0, 2)]],
	FROST_CENTER | CAKE_BOTTOM | CAKE_RIGHT | FROST_BOTTOM | FROST_RIGHT:
			[TileTypes.FROST, [Vector2(1, 2)]],
	FROST_CENTER | CAKE_RIGHT | CAKE_BOTTOM | CAKE_TOP | FROST_RIGHT | FROST_BOTTOM | FROST_TOP:
			[TileTypes.FROST, [Vector2(2, 2)]],
	FROST_CENTER | CAKE_RIGHT | CAKE_LEFT | FROST_RIGHT | FROST_LEFT:
			[TileTypes.FROST, [Vector2(3, 2)]],
	FROST_CENTER | CAKE_RIGHT | CAKE_LEFT | CAKE_TOP | FROST_RIGHT | FROST_LEFT | FROST_TOP:
			[TileTypes.FROST, [Vector2(4, 2), Vector2(5, 2), Vector2(0, 3), Vector2(1, 3)]],
	FROST_CENTER | CAKE_BOTTOM | CAKE_RIGHT | CAKE_LEFT | FROST_RIGHT | FROST_LEFT | FROST_BOTTOM:
			[TileTypes.FROST, [Vector2(2, 3)]],
	FROST_CENTER | CAKE_ALL | FROST_RIGHT | FROST_LEFT | FROST_BOTTOM | FROST_TOP:
			[TileTypes.FROST, [Vector2(3, 3)]],
	
	# partially frosted tiles, where some adjacent blocks are unfrosted
	FROST_CENTER | CAKE_ALL:
			[TileTypes.MIDFROST, [Vector2(0, 0)]],
	FROST_CENTER | CAKE_ALL | FROST_TOP: [TileTypes.MIDFROST,
			[Vector2(1, 0)]],
	FROST_CENTER | CAKE_ALL | FROST_BOTTOM: [TileTypes.MIDFROST,
			[Vector2(2, 0)]],
	FROST_CENTER | CAKE_ALL | FROST_BOTTOM | FROST_TOP: [TileTypes.MIDFROST,
			[Vector2(3, 0), Vector2(4, 0)]],
	FROST_CENTER | CAKE_ALL | FROST_LEFT: [TileTypes.MIDFROST,
			[Vector2(5, 0)]],
	FROST_CENTER | CAKE_ALL | FROST_LEFT | FROST_TOP: [TileTypes.MIDFROST,
			[Vector2(6, 0), Vector2(7, 0)]],
	FROST_CENTER | CAKE_ALL | FROST_LEFT | FROST_BOTTOM: [TileTypes.MIDFROST,
			[Vector2(0, 1), Vector2(1, 1)]],
	FROST_CENTER | CAKE_ALL | FROST_LEFT | FROST_BOTTOM | FROST_TOP: [TileTypes.MIDFROST,
			[Vector2(2, 1), Vector2(3, 1)]],
	FROST_CENTER | CAKE_ALL | FROST_RIGHT: [TileTypes.MIDFROST,
			[Vector2(4, 1)]],
	FROST_CENTER | CAKE_ALL | FROST_RIGHT | FROST_TOP: [TileTypes.MIDFROST,
			[Vector2(5, 1), Vector2(6, 1)]],
	FROST_CENTER | CAKE_ALL | FROST_RIGHT | FROST_BOTTOM: [TileTypes.MIDFROST,
			[Vector2(7, 1), Vector2(0, 2)]],
	FROST_CENTER | CAKE_ALL | FROST_RIGHT | FROST_BOTTOM | FROST_TOP: [TileTypes.MIDFROST,
			[Vector2(1, 2), Vector2(2, 2)]],
	FROST_CENTER | CAKE_ALL | FROST_RIGHT | FROST_LEFT: [TileTypes.MIDFROST,
			[Vector2(3, 2), Vector2(4, 2)]],
	FROST_CENTER | CAKE_ALL | FROST_RIGHT | FROST_LEFT | FROST_TOP: [TileTypes.MIDFROST,
			[Vector2(5, 2), Vector2(6, 2)]],
	FROST_CENTER | CAKE_ALL | FROST_RIGHT | FROST_LEFT | FROST_BOTTOM: [TileTypes.MIDFROST,
			[Vector2(7, 2), Vector2(0, 3)]],
	
	# partially frosted tiles on an edge
	FROST_CENTER | CAKE_LEFT | CAKE_BOTTOM | CAKE_TOP | FROST_TOP: [TileTypes.MIDFROST,
			[Vector2(1, 3)]],
	FROST_CENTER | CAKE_LEFT | CAKE_BOTTOM | CAKE_TOP | FROST_BOTTOM: [TileTypes.MIDFROST,
			[Vector2(2, 3)]],
	FROST_CENTER | CAKE_LEFT | CAKE_BOTTOM | CAKE_TOP | FROST_LEFT | FROST_TOP: [TileTypes.MIDFROST,
			[Vector2(3, 3)]],
	FROST_CENTER | CAKE_LEFT | CAKE_BOTTOM | CAKE_TOP | FROST_LEFT | FROST_BOTTOM: [TileTypes.MIDFROST,
			[Vector2(4, 3)]],
	FROST_CENTER | CAKE_RIGHT | CAKE_BOTTOM | CAKE_TOP | FROST_TOP: [TileTypes.MIDFROST,
			[Vector2(5, 3)]],
	FROST_CENTER | CAKE_RIGHT | CAKE_BOTTOM | CAKE_TOP | FROST_BOTTOM: [TileTypes.MIDFROST,
			[Vector2(6, 3)]],
	FROST_CENTER | CAKE_RIGHT | CAKE_BOTTOM | CAKE_TOP | FROST_RIGHT | FROST_TOP: [TileTypes.MIDFROST,
			[Vector2(7, 3)]],
	FROST_CENTER | CAKE_RIGHT | CAKE_BOTTOM | CAKE_TOP | FROST_RIGHT | FROST_BOTTOM: [TileTypes.MIDFROST,
			[Vector2(0, 4)]],
	FROST_CENTER | CAKE_RIGHT | CAKE_LEFT | CAKE_TOP | FROST_LEFT: [TileTypes.MIDFROST,
			[Vector2(1, 4)]],
	FROST_CENTER | CAKE_RIGHT | CAKE_LEFT | CAKE_TOP | FROST_LEFT | FROST_TOP: [TileTypes.MIDFROST,
			[Vector2(2, 4)]],
	FROST_CENTER | CAKE_RIGHT | CAKE_LEFT | CAKE_TOP | FROST_RIGHT: [TileTypes.MIDFROST,
			[Vector2(3, 4)]],
	FROST_CENTER | CAKE_RIGHT | CAKE_LEFT | CAKE_TOP | FROST_RIGHT | FROST_TOP: [TileTypes.MIDFROST,
			[Vector2(4, 4)]],
	FROST_CENTER | CAKE_RIGHT | CAKE_LEFT | CAKE_BOTTOM | FROST_LEFT: [TileTypes.MIDFROST,
			[Vector2(5, 4)]],
	FROST_CENTER | CAKE_RIGHT | CAKE_LEFT | CAKE_BOTTOM | FROST_LEFT | FROST_BOTTOM: [TileTypes.MIDFROST,
			[Vector2(6, 4)]],
	FROST_CENTER | CAKE_RIGHT | CAKE_LEFT | CAKE_BOTTOM | FROST_RIGHT: [TileTypes.MIDFROST,
			[Vector2(7, 4)]],
	FROST_CENTER | CAKE_RIGHT | CAKE_LEFT | CAKE_BOTTOM | FROST_RIGHT | FROST_BOTTOM: [TileTypes.MIDFROST,
			[Vector2(0, 5)]],
}

## Defines which corner covers are used for different sets of surrounding tiles.
##
## The key is a bitmask with the following components:
##   * FROST_CENTER
##   * FROST_LEFT
##   * FROST_TOP
##   * FROST_TOP_LEFT
##
## key: (int) A bitmask of surrounding tiles
## value: (Vector2) autotile coordinate of the corner cover
const CORNER_COVERS_BY_BINDING := {
	0: Vector2(0, 0),
	FROST_TOP: Vector2(0, 0),
	FROST_LEFT: Vector2(0, 0),
	FROST_LEFT | FROST_TOP: Vector2(0, 0),
	FROST_CENTER: Vector2(0, 0),
	FROST_CENTER | FROST_TOP: Vector2(1, 0),
	FROST_CENTER | FROST_LEFT: Vector2(2, 0),
	FROST_CENTER | FROST_LEFT | FROST_TOP: Vector2(0, 1),
	FROST_TOPLEFT: Vector2(0, 0),
	FROST_TOPLEFT | FROST_TOP: Vector2(1, 1),
	FROST_TOPLEFT | FROST_LEFT: Vector2(2, 1),
	FROST_TOPLEFT | FROST_LEFT | FROST_TOP: Vector2(0, 2),
	FROST_TOPLEFT | FROST_CENTER: Vector2(0, 0),
	FROST_TOPLEFT | FROST_CENTER | FROST_TOP: Vector2(1, 2),
	FROST_TOPLEFT | FROST_CENTER | FROST_LEFT: Vector2(2, 2),
	FROST_TOPLEFT | FROST_CENTER | FROST_LEFT | FROST_TOP: Vector2(0, 3),
}

## The parent tilemap's tile ID for unfrosted blocks
export (int) var block_tile_index: int setget set_block_tile_index

## The parent tilemap's tile ID for partially frosted blocks
export (int) var midfrost_tile_index: int setget set_midfrost_tile_index

## The parent tilemap's tile ID for frosted blocks
export (int) var frost_tile_index: int setget set_frost_tile_index

## the corner tilemap's tile ID for unfrosted/partially frosted/frosted corner covers
export (int) var corner_tile_index: int

## An editor toggle which manually applies autotiling.
##
## Godot has no way of automatically reacting to GridMap/TileMap changes. See Godot #11855
## https://github.com/godotengine/godot/issues/11855
export (bool) var _autotile: bool setget autotile

## key: an enum from TileTypes
## value: a tile index from the parent tilemap for the specified enum, as defined by block_tile_index,
## 	midfrost_tile_index and frost_tile_index
var _tile_indexes_by_type := {}

## key: a tile index from the parent tilemap
## value: an enum from TileTypes corresponding to the specified tile index, as defined by block_tile_index,
## 	midfrost_tile_index and frost_tile_index
var _tile_types_by_index := {}

## indexes of cake tiles in the parent tilemap, both frosted and unfrosted
var _cake_indexes := []

## indexes of frosted cake tiles in the parent tilemap, both partially and fully frosted
var _frost_indexes := []

## a tilemap with frosted/unfrosted overworld cakes which we should autotile
onready var _tile_map := get_parent()

## A tilemap of corner covers which cover the corners of an overworld tilemap.
##
## Without this tilemap, a simple 16-tile autotiling would result in tiny holes at the corners of a filled in area.
## This tilemap fills in the holes.
onready var _corner_map := $"../CornerMap"

func _ready() -> void:
	autotile(true)


## Preemptively initialize onready variables to avoid null references.
func _enter_tree() -> void:
	_initialize_onready_variables()


## Autotiles tiles with frosting.
##
## The frosting autotiling involves multiple cell types and cannot be handled by Godot's built-in autotiling.
## Instead of configuring the autotiling behavior with the TileSet's autotile bitmask, it is configured with several
## dictionary constants defined in this script.
func autotile(value: bool) -> void:
	if not value:
		# only autotile in the editor when the 'Autotile' property is toggled
		return
	
	if Engine.editor_hint:
		if not _tile_map or not _corner_map:
			# initialize variables to avoid nil reference errors in the editor when editing tool scripts
			_initialize_onready_variables()
	
	_corner_map.clear()
	for cell in _tile_map.get_used_cells():
		match _tile_types_by_index.get(_tile_map.get_cellv(cell)):
			TileTypes.BLOCK, TileTypes.MIDFROST, TileTypes.FROST: _autotile_cake(cell)


func set_block_tile_index(new_block_tile_index: int) -> void:
	block_tile_index = new_block_tile_index
	_refresh_tile_indexes()


func set_midfrost_tile_index(new_midfrost_tile_index: int) -> void:
	midfrost_tile_index = new_midfrost_tile_index
	_refresh_tile_indexes()


func set_frost_tile_index(new_frost_tile_index: int) -> void:
	frost_tile_index = new_frost_tile_index
	_refresh_tile_indexes()


## Preemptively initialize onready variables to avoid null references.
func _initialize_onready_variables() -> void:
	_tile_map = get_parent()
	_corner_map = $"../CornerMap"


## Refreshes our various internal helper fields.
##
## The frosted overworld tiler uses internal helper fields which depend on the 'tile_index' export fields. This
## function initializes the internal helper fields when the tiler is initialized or when the export fields change.
func _refresh_tile_indexes() -> void:
	_tile_indexes_by_type = {
		TileTypes.BLOCK: block_tile_index,
		TileTypes.MIDFROST: midfrost_tile_index,
		TileTypes.FROST: frost_tile_index,
	}
	_tile_types_by_index = {
		block_tile_index: TileTypes.BLOCK,
		midfrost_tile_index: TileTypes.MIDFROST,
		frost_tile_index: TileTypes.FROST,
	}
	_cake_indexes = [block_tile_index, midfrost_tile_index, frost_tile_index]
	_frost_indexes = [midfrost_tile_index, frost_tile_index]


## Autotiles the cake at the specified coordinates.
func _autotile_cake(cell: Vector2) -> void:
	var adjacencies := _adjacencies(cell)
	if adjacencies & FROST_CENTER == FROST_CENTER:
		# autotile a frosted cake tile
		if BLOCK_AUTOTILE_COORDS_BY_BINDING.has(adjacencies):
			_set_cell_autotile_coord(cell, BLOCK_AUTOTILE_COORDS_BY_BINDING[adjacencies])
	else:
		# autotile an unfrosted cake tile
		if BLOCK_AUTOTILE_COORDS_BY_BINDING.has(adjacencies & CAKE_ALL):
			_set_cell_autotile_coord(cell, BLOCK_AUTOTILE_COORDS_BY_BINDING[adjacencies & CAKE_ALL])
	
	var corner_cover_adjacencies := _corner_cover_adjacencies(cell)
	if CORNER_COVERS_BY_BINDING.has(corner_cover_adjacencies):
		# add a corner cover for this cake tile
		_set_corner_cover_autotile_coord(cell, CORNER_COVERS_BY_BINDING[corner_cover_adjacencies])


## Updates the autotile coordinate for a TileMap cell.
##
## Parameters:
## 	'cell': The TileMap coordinates of the cell to be updated.
##
## 	'binding_value': An array of two items defining the tile and autotile coordinates to assign:
## 		[0]: (int) tile id to assign
## 		[1]: (Array, Vector2) list of possible autotile coordinates to assign
func _set_cell_autotile_coord(cell: Vector2, binding_value: Array) -> void:
	var tile: int = _tile_indexes_by_type[binding_value[0]]
	var autotile_coord: Vector2 = Utils.rand_value(binding_value[1])
	var flip_x: bool = _tile_map.is_cell_x_flipped(cell.x, cell.y)
	var flip_y: bool = _tile_map.is_cell_y_flipped(cell.x, cell.y)
	var transpose: bool = _tile_map.is_cell_transposed(cell.x, cell.y)
	_tile_map.set_cell(cell.x, cell.y, tile, flip_x, flip_y, transpose, autotile_coord)


## Updates the corner cover for a TileMap cell.
##
## Parameters:
## 	'cell': The TileMap coordinates of the corner cover to be updated.
##
## 	'autotile_coord': autotile coordinates of the corner cover to assign
func _set_corner_cover_autotile_coord(cell: Vector2, autotile_coord: Vector2) -> void:
	var tile: int = corner_tile_index
	var flip_x: bool = _tile_map.is_cell_x_flipped(cell.x, cell.y)
	var flip_y: bool = _tile_map.is_cell_y_flipped(cell.x, cell.y)
	var transpose: bool = _tile_map.is_cell_transposed(cell.x, cell.y)
	_corner_map.set_cell(cell.x, cell.y, tile, flip_x, flip_y, transpose, autotile_coord)


## Calculates which of the five adjacent cells have blocks or frosting.
##
## This includes the current block and its four neighbors.
##
## Parameters:
## 	'cell': The TileMap coordinates of the cell to be analyzed.
##
## Returns:
## 	An int bitmask of cell directions containing blocks (CAKE_TOP, CAKE_BOTTOM, CAKE_LEFT, CAKE_RIGHT) or frosting
## 	(FROST_CENTER, FROST_TOP, FROST_BOTTOM, FROST_LEFT, FROST_RIGHT)
func _adjacencies(cell: Vector2) -> int:
	var binding := 0
	binding |= CAKE_TOP if _tile_map.get_cellv(cell + Vector2.UP) in _cake_indexes else 0
	binding |= CAKE_BOTTOM if _tile_map.get_cellv(cell + Vector2.DOWN) in _cake_indexes else 0
	binding |= CAKE_LEFT if _tile_map.get_cellv(cell + Vector2.LEFT) in _cake_indexes else 0
	binding |= CAKE_RIGHT if _tile_map.get_cellv(cell + Vector2.RIGHT) in _cake_indexes else 0
	binding |= FROST_CENTER if _tile_map.get_cellv(cell) in _frost_indexes else 0
	binding |= FROST_TOP if _tile_map.get_cellv(cell + Vector2.UP) in _frost_indexes else 0
	binding |= FROST_BOTTOM if _tile_map.get_cellv(cell + Vector2.DOWN) in _frost_indexes else 0
	binding |= FROST_LEFT if _tile_map.get_cellv(cell + Vector2.LEFT) in _frost_indexes else 0
	binding |= FROST_RIGHT if _tile_map.get_cellv(cell + Vector2.RIGHT) in _frost_indexes else 0
	return binding


## Calculates which of the four cells in the up/left direction have frosting.
##
## This includes the current block, its top neighbor, its left neighbor, and its topleft diagonal neighbor.
##
## Returns:
## 	An int bitmask of cell directions containing frosting (FROST_CENTER, FROST_TOP, FROST_LEFT, FROST_TOPLEFT)
func _corner_cover_adjacencies(cell: Vector2) -> int:
	var binding := -1
	if _tile_map.get_cellv(cell) != TileMap.INVALID_CELL \
			and _tile_map.get_cellv(cell + Vector2.UP) != TileMap.INVALID_CELL \
			and _tile_map.get_cellv(cell + Vector2.LEFT) != TileMap.INVALID_CELL \
			and _tile_map.get_cellv(cell + Vector2.UP + Vector2.LEFT) != TileMap.INVALID_CELL:
		binding = 0
		binding |= FROST_CENTER if _tile_map.get_cellv(cell) in _frost_indexes else 0
		binding |= FROST_TOP if _tile_map.get_cellv(cell + Vector2.UP) in _frost_indexes else 0
		binding |= FROST_LEFT if _tile_map.get_cellv(cell + Vector2.LEFT) in _frost_indexes else 0
		binding |= FROST_TOPLEFT if _tile_map.get_cellv(cell + Vector2.UP + Vector2.LEFT) in _frost_indexes else 0
	return binding
