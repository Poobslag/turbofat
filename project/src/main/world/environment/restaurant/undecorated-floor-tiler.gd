#@tool
extends Node
## Autotiles a tilemap for undecorated floors.
##
## The undecorated floor tiling logic renders floors with deliberate imperfections.

## groups of autotile coordinates to decide between when autotiling.
##
## Each entry is an array of similar autotile coordinates. The first tile in each array is free from imperfections.
## The second tile and onward in each array have deliberate imperfections.
const ALL_AUTOTILE_ALTERNATIVES := [
	[Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)], # no lines
	[Vector2i(0, 2), Vector2i(1, 2)], # vertical line
	[Vector2i(2, 2), Vector2i(0, 3)], # horizontal line
	[Vector2i(1, 3), Vector2i(2, 3)], # vertical + horizontal lines
]

## percent of cells without imperfections, in the range [0.0, 1.0]
const UNDECORATED_QUALITY := 0.88

## Parent tilemap's tile ID for undecorated floor tiles
@export var undecorated_tile_index: int = -1

## Editor toggle which manually applies autotiling.
##
## Godot has no way of automatically reacting to GridMap/TileMap changes. See Godot #11855
## https://github.com/godotengine/godot/issues/11855
@export var _autotile: bool: set = autotile

## tilemap containing floors
@onready var _tile_map: TileMap = get_parent()


## Preemptively initializes onready variables to avoid null references.
func _enter_tree() -> void:
	_initialize_onready_variables()


## Autotiles floors, applying imperfections.
##
## The floor autotiling logic applies probabilities and cannot be handled by Godot's built-in autotiling.
func autotile(_value: bool) -> void:
	for cell in _tile_map.get_used_cells_by_id(undecorated_tile_index):
		_autotile_undecorated_floor(cell)


## Preemptively initializes onready variables to avoid null references.
func _initialize_onready_variables() -> void:
	_tile_map = get_parent()


## Autotiles a tile containing a tiled undecorated floor.
##
## Tiles containing regular floors are randomly blemished, while tiles containing drains are left alone.
##
## Parameters:
## 	'cell': The TileMap coordinates of the cell to be autotiled.
func _autotile_undecorated_floor(cell: Vector2i) -> void:
	var autotile_coord := _tile_map.get_cell_atlas_coords(0, cell)
	var tile_alternatives := []
	for possible_autotile_alternatives in ALL_AUTOTILE_ALTERNATIVES:
		if autotile_coord in possible_autotile_alternatives:
			tile_alternatives = possible_autotile_alternatives
			break
	if tile_alternatives.size() < 2:
		# we have only one (or zero!) candidates for this cell. this is unusual so we push a warning
		push_warning("Insufficient candidates for cell at %s (autotile_coord=%s)" % [cell, autotile_coord])
		return
	elif randf() < UNDECORATED_QUALITY:
		# replace the cell with a perfect undecorated floor tile
		_set_cell_autotile_coord(cell, tile_alternatives[0])
	else:
		# replace the cell with a blemished undecorated floor tile
		_set_cell_autotile_coord(cell, tile_alternatives[randi_range(1, tile_alternatives.size() - 1)])


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
