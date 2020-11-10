extends TileMap
"""
Tile map which covers the corners of the overworld tilemap.

Without this tile map, a simple 16-tile autotiling would result in tiny holes at the corners of a filled in area. This
tile map fills in the holes.
"""

onready var _parent_map: TileMap = get_parent()

var dirty := true

func _process(_delta: float) -> void:
	if dirty:
		clear()
		for cell in _parent_map.get_used_cells():
			if _parent_map.get_cellv(cell) != 0:
				# not a merrymellow marsh cell; don't fill in the corner
				continue
			
			var pab := _pab(cell)
			# check for corner connected down and right
			if (pab & TileSet.BIND_BOTTOM > 0) and (pab & TileSet.BIND_RIGHT > 0) \
					and (_pab(cell + Vector2.RIGHT) & TileSet.BIND_BOTTOM):
				set_cell(cell.x, cell.y, 0, false, false, false, Vector2(1, 3))
		dirty = false


"""
Returns the parent autotile bitmask (PAB) for the specified cell.

This function has a confusingly short name because it's referenced repetitively in some long lines of code.
"""
func _pab(pos: Vector2) -> int:
	var coord := _parent_map.get_cell_autotile_coord(pos.x, pos.y)
	return _parent_map.tile_set.autotile_get_bitmask(0, coord)
