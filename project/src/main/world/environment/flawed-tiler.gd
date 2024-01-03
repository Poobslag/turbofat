tool
extends Node
## Renders tilemaps with deliberate imperfections.
##
## This autotiler is given a target tile index, a set of perfect tiles, and a set of tiles with imperfections. It
## randomly swaps out tiles with imperfect tiles to give the tilemap a less monotonous appearance.

## The parent tilemap's tile ID for tiles to apply imperfections to
export (int) var target_tile_index := -1

## autotile coordinates for a cell without imperfections
export (Array, Vector2) var good_cells := []

## autotile coordinates for a cell with imperfections
export (Array, Vector2) var bad_cells := []

## percent of cells without imperfections, in the range [0.0, 1.0]
export (float, 0.0, 1.0) var quality := 1.0

## Editor toggle which manually applies autotiling.
##
## Godot has no way of automatically reacting to GridMap/TileMap changes. See Godot #11855
## (https://github.com/godotengine/godot/issues/11855)
export (bool) var _autotile: bool setget autotile

## Editor toggle which undoes autotiling, removing all imperfections.
export (bool) var _unautotile: bool setget unautotile

## tilemap to apply imperfections to
onready var _tile_map: TileMap = get_parent()

## Preemptively initializes onready variables to avoid null references.
func _enter_tree() -> void:
	_initialize_onready_variables()


## Autotiles the parent tilemap, applying random imperfections.
##
## The floor autotiling logic applies probabilities and cannot be handled by Godot's built-in autotiling.
func autotile(value: bool) -> void:
	if not value:
		# only autotile in the editor when the 'autotile' property is toggled
		return
	
	if Engine.editor_hint:
		if not _tile_map:
			# initialize variables to avoid nil reference errors in the editor when editing tool scripts
			_initialize_onready_variables()
	
	# replace all target cells with a good/bad tile.
	for cell in _tile_map.get_used_cells_by_id(target_tile_index):
		var autotile_coord := _tile_map.get_cell_autotile_coord(cell.x, cell.y)
		if not autotile_coord in good_cells and not autotile_coord in bad_cells:
			# This tile isn't a good or bad tile, it's something else, ignore it. (Our tiled kitchen floors have good
			# tiles, bad tiles, and drain tiles for example.)
			continue
		
		if randf() < quality:
			# replace the cell with a good tile
			_set_cell_autotile_coord(cell, Utils.rand_value(good_cells))
		else:
			# replace the cell with a bad tile
			_set_cell_autotile_coord(cell, Utils.rand_value(bad_cells))


## Removes all imperfections.
func unautotile(value: bool) -> void:
	if not value:
		# only unautotile in the editor when the 'unautotile' property is toggled
		return
	
	if Engine.editor_hint:
		if not _tile_map:
			# initialize variables to avoid nil reference errors in the editor when editing tool scripts
			_initialize_onready_variables()
	
	# replace all target cells with good tiles.
	for cell in _tile_map.get_used_cells_by_id(target_tile_index):
		var autotile_coord := _tile_map.get_cell_autotile_coord(cell.x, cell.y)
		if not autotile_coord in good_cells and not autotile_coord in bad_cells:
			# This tile isn't a good or bad tile, it's something else, ignore it. (Our tiled kitchen floors have good
			# tiles, bad tiles, and drain tiles for example.)
			continue
		
		# replace the cell with a good tile
		_set_cell_autotile_coord(cell, Utils.rand_value(good_cells))


## Preemptively initializes onready variables to avoid null references.
func _initialize_onready_variables() -> void:
	_tile_map = get_parent()


## Updates the autotile coordinate for a TileMap cell.
##
## Parameters:
## 	'cell': The TileMap coordinates of the cell to be updated.
##
## 	'autotile_coord': The autotile coordinates to assign.
func _set_cell_autotile_coord(cell: Vector2, autotile_coord: Vector2) -> void:
	var tile: int = _tile_map.get_cellv(cell)
	var flip_x: bool = _tile_map.is_cell_x_flipped(cell.x, cell.y)
	var flip_y: bool = _tile_map.is_cell_y_flipped(cell.x, cell.y)
	var transpose: bool = _tile_map.is_cell_transposed(cell.x, cell.y)
	_tile_map.set_cellv(cell, tile, flip_x, flip_y, transpose, autotile_coord)
