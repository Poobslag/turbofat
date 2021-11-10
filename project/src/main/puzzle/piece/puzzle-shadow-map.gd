extends TileMap
## Tilemap which draws the shadows behind the blocks on the playfield, as well as the shadow behind the currently
## active piece.

export (NodePath) var _playfield_tile_map_path: NodePath

## Tilemap for the active piece
var piece_tile_map: TileMap

onready var _playfield_tile_map := get_node(_playfield_tile_map_path)

func _process(_delta: float) -> void:
	clear()
	
	# draw shadows cast by the left wall
	for row in range(PuzzleTileMap.ROW_COUNT):
		set_cell(-1, row, 0, false, false, false, Vector2(15, 0))
	
	# draw shadows cast by the bottom wall
	set_cell(-1, PuzzleTileMap.ROW_COUNT, 0, false, false, false, Vector2(15, 0))
	for col in range(PuzzleTileMap.COL_COUNT):
		set_cell(col, PuzzleTileMap.ROW_COUNT, 0, false, false, false, Vector2(15, 0))
	
	# draw shadows cast by blocks in the playfield
	for cell in _playfield_tile_map.get_used_cells():
		var autotile_coord: Vector2 = _playfield_tile_map.get_cell_autotile_coord(cell.x, cell.y)
		set_cell(cell.x, cell.y, _playfield_tile_map.get_cellv(cell), false, false, false, autotile_coord)

	# draw shadows cast by the current piece
	if piece_tile_map:
		for cell in piece_tile_map.get_used_cells():
			var autotile_coord: Vector2 = piece_tile_map.get_cell_autotile_coord(cell.x, cell.y)
			set_cell(cell.x, cell.y, piece_tile_map.get_cellv(cell), false, false, false, autotile_coord)
		
		if piece_tile_map.ghost_shadow_offset:
			# if the ghost_shadow_offset is set, draw a copy of our shadows at the target location
			for cell in piece_tile_map.get_used_cells():
				var autotile_coord: Vector2 = piece_tile_map.get_cell_autotile_coord(cell.x, cell.y)
				var ghost_cell: Vector2 = piece_tile_map.ghost_shadow_offset + cell
				# merge our autotile bitmask with the existing bitmask to combine the shadows
				var merged_x := int(autotile_coord.x) | int(get_cell_autotile_coord(ghost_cell.x, ghost_cell.y).x)
				set_cell(ghost_cell.x, ghost_cell.y, piece_tile_map.get_cellv(cell), false, false, false, \
						Vector2(merged_x, autotile_coord.y))
