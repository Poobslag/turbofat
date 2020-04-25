extends TileMap
"""
Tilemap which draws the shadows behind the blocks on the playfield, as well as the shadow behind the currently active
piece.
"""

# Tilemap for the active piece
var piece_tile_map: TileMap

onready var _parent_tile_map: TileMap = get_parent()

func _process(_delta: float) -> void:
	clear()
	
	# draw shadows cast by the left wall
	for row in range(Playfield.ROW_COUNT):
		set_cell(-1, row, 0, false, false, false, Vector2(15, 0))
	
	# draw shadows cast by the bottom wall
	set_cell(-1, Playfield.ROW_COUNT, 0, false, false, false, Vector2(15, 0))
	for col in range(Playfield.COL_COUNT):
		set_cell(col, Playfield.ROW_COUNT, 0, false, false, false, Vector2(15, 0))
	
	# draw shadows cast by blocks in the playfield
	for cell in _parent_tile_map.get_used_cells():
		var autotile_coord: Vector2 = _parent_tile_map.get_cell_autotile_coord(cell.x, cell.y)
		set_cell(cell.x, cell.y, _parent_tile_map.get_cell(cell.x, cell.y), false, false, false, Vector2(autotile_coord.x, autotile_coord.y))

	# draw shadows cast by the current piece
	if piece_tile_map:
		for cell in piece_tile_map.get_used_cells():
			var autotile_coord: Vector2 = piece_tile_map.get_cell_autotile_coord(cell.x, cell.y)
			set_cell(cell.x, cell.y, piece_tile_map.get_cell(cell.x, cell.y), false, false, false, Vector2(autotile_coord.x, autotile_coord.y))
