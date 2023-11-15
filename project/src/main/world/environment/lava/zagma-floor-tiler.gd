tool
extends Node
## Randomizes brick patterns for the floors in Zagma studios.

## The parent tilemap's tile ID for small 1x1 tiles to apply brick patterns to
export (int) var small_tile_index := -1

## The parent tilemap's tile ID for large 2x2 tiles to apply brick patterns to
export (int) var large_tile_index := -1

## percent of cells without brick patterns, in the range [0.0, 1.0]
export (float, 0.0, 1.0) var quality := 1.0

## Editor toggle which manually applies autotiling.
##
## Godot has no way of automatically reacting to GridMap/TileMap changes. See Godot #11855
## (https://github.com/godotengine/godot/issues/11855)
export (bool) var _autotile: bool setget autotile

## Editor toggle which undoes autotiling, removing all brick patterns.
export (bool) var _unautotile: bool setget unautotile

const SMALL_FLAWED_TILE_INDEXES := [
	Vector2(1, 0), Vector2(2, 0),
	Vector2(0, 1), Vector2(1, 1), Vector2(2, 1),
	Vector2(0, 2), Vector2(1, 2), Vector2(2, 2),
	Vector2(0, 3), Vector2(1, 3), Vector2(2, 3),
]

const LARGE_FLAWED_TILE_INDEXES := [
	Vector2(0, 0), Vector2(1, 0), Vector2(2, 0),
	Vector2(0, 1), Vector2(1, 1), Vector2(2, 1),
	Vector2(0, 2), Vector2(1, 2), Vector2(2, 2),
	Vector2(0, 3), Vector2(1, 3), Vector2(2, 3),
]

const LARGE_NEIGHBOR_DIRS := [
	Vector2.ZERO, Vector2.RIGHT, Vector2.DOWN, Vector2.RIGHT + Vector2.DOWN
]

## tilemap to apply brick patterns to
onready var _tile_map: TileMap = get_parent()

## Autotiles the parent tilemap, applying random brick patterns.
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
	
	# replace all target cells with good small 1x1 tiles.
	_inner_unautotile()
	
	# replace all target cells with a good/bad tile.
	for cell in _tile_map.get_used_cells_by_id(small_tile_index):
		if randf() < quality:
			# leave the cell with a good small 1x1 tile
			pass
		else:
			# assign a flawed cell
			if randf() < 0.5:
				# assign a small 1x1 flawed cell 50% of the time
				_maybe_assign_small_flawed_tile(cell)
			elif randf() < 0.25:
				# assign a large 2x2 flawed cell 12% of the time
				_maybe_assign_large_flawed_tile(cell)
			else:
				# preserve the good cell 38% of the time. this balances out the 2x2 flawed cells which are 4 times
				# larger than regular flawed cells, so that on average we will assign one flawed cell
				pass


## Removes all brick patterns.
func unautotile(value: bool) -> void:
	if not value:
		# only unautotile in the editor when the 'unautotile' property is toggled
		return
	
	if Engine.editor_hint:
		if not _tile_map:
			# initialize variables to avoid nil reference errors in the editor when editing tool scripts
			_initialize_onready_variables()
	
	_inner_unautotile()


## Assigns a small 1x1 flawed tile to the specified tile, if it contains a small 1x1 tile.
func _maybe_assign_small_flawed_tile(cell: Vector2) -> void:
	var can_assign := _tile_map.get_cellv(cell) == small_tile_index
	
	if can_assign:
		# replace the cell with a small 1x1 flawed tile.
		_set_cell_autotile_coord(cell, small_tile_index, Utils.rand_value(SMALL_FLAWED_TILE_INDEXES))


## Assigns a large 2x2 flawed tile to the specified tile, if it and its neighbors all contain small 1x1 tiles.
func _maybe_assign_large_flawed_tile(cell: Vector2) -> void:
	var can_assign := true
	
	# check if this cell and all neighboring cells are small flawed cells
	for neighbor_dir in LARGE_NEIGHBOR_DIRS:
		if _tile_map.get_cellv(cell + neighbor_dir) != small_tile_index:
			can_assign = false
			break
	
	if can_assign:
		# change all neighboring cells to empty
		for neighbor_dir in LARGE_NEIGHBOR_DIRS:
			_tile_map.set_cellv(cell + neighbor_dir, -1)
		
		# assign a random large 2x2 flawed tile
		_set_cell_autotile_coord(cell, large_tile_index, Utils.rand_value(LARGE_FLAWED_TILE_INDEXES))


## Removes all brick patterns.
func _inner_unautotile() -> void:
	# replace all small tiles with good tiles.
	for cell in _tile_map.get_used_cells_by_id(small_tile_index):
		# replace the cell with a good tile
		_set_cell_autotile_coord(cell, small_tile_index, Vector2(0, 0))
	
	# replace all large 2x2 tiles with good small 1x1 tiles.
	for cell in _tile_map.get_used_cells_by_id(large_tile_index):
		for neighbor_dir in LARGE_NEIGHBOR_DIRS:
			_set_cell_autotile_coord(cell + neighbor_dir, small_tile_index, Vector2(0, 0))


## Preemptively initializes onready variables to avoid null references.
func _initialize_onready_variables() -> void:
	_tile_map = get_parent()


## Updates the autotile coordinate for a TileMap cell.
##
## Parameters:
## 	'cell': The TileMap coordinates of the cell to be updated.
##
## 	'tile': The TileMap tile id to assign
##
## 	'autotile_coord': The autotile coordinates to assign.
func _set_cell_autotile_coord(cell: Vector2, tile: int, autotile_coord: Vector2) -> void:
	_tile_map.set_cellv(cell, tile, false, false, false, autotile_coord)
