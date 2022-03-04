extends TileMap
## Tilemap which covers the corners of the overworld tilemap.
##
## Without this tilemap, a simple 16-tile autotiling would result in tiny holes at the corners of a filled in area.
## This tilemap fills in the holes.

## Defines which tiles should be covered by a corner cover. Corner covers are given the same tile index as the source
## tile, but their autotile index is defined by this mapping.
##
## key: (int) tile index which should be covered with a corner cover
## value: (Vector2) autotile coordinate of the corner cover
export (Dictionary) var cornerable_tiles := {}

onready var _parent_map: TileMap = get_parent()

var dirty := true

func _process(_delta: float) -> void:
	if dirty:
		clear()
		for cell in _parent_map.get_used_cells():
			var cell_index := _parent_map.get_cellv(cell)
			if not cell_index in cornerable_tiles:
				# not a merrymellow marsh cell; don't fill in the corner
				continue
			
			var pab := _pab(cell_index, cell)
			# check for corner connected up and left
			if (pab & TileSet.BIND_TOP > 0) and (pab & TileSet.BIND_LEFT > 0) \
					and (_pab(cell_index, cell + Vector2.LEFT) & TileSet.BIND_TOP):
				set_cell(cell.x, cell.y, cell_index, false, false, false, cornerable_tiles[cell_index])
		dirty = false


## Returns the parent autotile bitmask (PAB) for the specified cell.
##
## This function has a confusingly short name because it's referenced repetitively in some long lines of code.
func _pab(cell_index: int, cell_pos: Vector2) -> int:
	var coord := _parent_map.get_cell_autotile_coord(cell_pos.x, cell_pos.y)
	return _parent_map.tile_set.autotile_get_bitmask(cell_index, coord)
