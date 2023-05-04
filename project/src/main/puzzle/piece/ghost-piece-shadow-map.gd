extends TileMap
## Tilemap which draws the ghost piece.

## Tilemap for the active piece
var piece_tile_map: TileMap

## tilemap which covers the corners of this tilemap
@onready var corner_map: TileMap = $CornerMap

func _process(_delta: float) -> void:
	if not piece_tile_map:
		return
	
	clear()
	corner_map.dirty = true
	
	if piece_tile_map.ghost_shadow_offset:
		# copy the piece's tilemap contents to our shadow map
		for cell in piece_tile_map.get_used_cells(0):
			var autotile_coord: Vector2i = piece_tile_map.get_cell_atlas_coords(0, cell)
			var ghost_cell: Vector2i = piece_tile_map.ghost_shadow_offset + cell
			set_cell(0, ghost_cell, piece_tile_map.get_cell_source_id(0, cell), \
					autotile_coord)
	else:
		# If the ghost_shadow_offset is zero, we don't copy the piece's tilemap contents. Drawing the ghost piece
		# directly behind the active piece would result in minor visual artifacts around the piece edge.
		pass
