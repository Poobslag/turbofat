tool
extends TileMap
## Maintains a tilemap for indoor floors.
##
## The indoor tilemap special tiling logic to render floors with deliberate imperfections.

## the index of specific tiles in the tilemap's tileset
const CARPET_TILE_INDEX := 82455
const KITCHEN_TILE_INDEX := 54907

## autotile coordinates for a carpet cell without imperfections
const CARPET_FLAWLESS_CELL := Vector2(0, 0)

## autotile coordinates for carpet cells with imperfections
const CARPET_FLAWED_CELLS := [
	Vector2(1, 0), Vector2(2, 0),
	Vector2(0, 1), Vector2(1, 1), Vector2(2, 1),
	Vector2(0, 2), Vector2(1, 2), Vector2(2, 2),
	Vector2(0, 3), Vector2(1, 3), Vector2(2, 3),
]

## percent of carpet cells without imperfections, in the range [0.0, 1.0]
const CARPET_QUALITY := 0.86

## autotile coordinates for a kitchen cell with a drain
const KITCHEN_DRAIN_CELL := Vector2(1, 0)

## autotile coordinates for a kitchen cell without imperfections
const KITCHEN_FLAWLESS_CELL := Vector2(0, 0)

## autotile coordinates for a kitchen cell with imperfections
const KITCHEN_FLAWED_CELLS := [
	Vector2(2, 0),
	Vector2(0, 1), Vector2(1, 1), Vector2(2, 1),
	Vector2(0, 2), Vector2(1, 2), Vector2(2, 2),
	Vector2(0, 3), Vector2(1, 3), Vector2(2, 3),
]
## percent of kitchen cells without imperfections, in the range [0.0, 1.0]
const KITCHEN_QUALITY := 0.93

## An editor toggle which manually applies autotiling.
##
## Godot has no way of automatically reacting to GridMap/TileMap changes. See Godot #11855
## https://github.com/godotengine/godot/issues/11855
export (bool) var _autotile: bool setget autotile

## Autotiles floors, applying imperfections.
##
## The floor autotiling logic applies probabilities and cannot be handled by Godot's built-in autotiling.
func autotile(_value: bool) -> void:
	for cell in get_used_cells():
		match get_cellv(cell):
			CARPET_TILE_INDEX: _autotile_carpet(cell)
			KITCHEN_TILE_INDEX: _autotile_kitchen_floor(cell)


## Autotiles a tile containing a carpet.
##
## Parameters:
## 	'cell': The TileMap coordinates of the cell to be autotiled.
func _autotile_carpet(cell: Vector2) -> void:
	if randf() < CARPET_QUALITY:
		# replace the cell with a perfect carpet tile
		_set_cell_autotile_coord(cell, CARPET_FLAWLESS_CELL)
	else:
		# replace the cell with a fuzzy carpet tile
		_set_cell_autotile_coord(cell, Utils.rand_value(CARPET_FLAWED_CELLS))


## Autotiles a tile containing a tiled kitchen floor.
##
## Tiles containing regular floors are randomly blemished, while tiles containing drains are left alone.
##
## Parameters:
## 	'cell': The TileMap coordinates of the cell to be autotiled.
func _autotile_kitchen_floor(cell: Vector2) -> void:
	if get_cell_autotile_coord(cell.x, cell.y) == KITCHEN_DRAIN_CELL:
		# cell contains a drain; leave it alone
		pass
	elif randf() < KITCHEN_QUALITY:
		# replace the cell with a perfect kitchen floor tile
		_set_cell_autotile_coord(cell, KITCHEN_FLAWLESS_CELL)
	else:
		# replace the cell with a blemished kitchen floor tile
		_set_cell_autotile_coord(cell, Utils.rand_value(KITCHEN_FLAWED_CELLS))


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
