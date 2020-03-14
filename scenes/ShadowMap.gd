"""
Tilemap which draws the shadows behind the blocks on the playfield, as well as the shadow behind the currently active
piece.
"""
extends TileMap

onready var Playfield = get_node("../..")
onready var ParentTileMap = get_node("../TileMap")

# Tilemap for the active piece
var piece_tile_map: TileMap

func _process(delta: float) -> void:
	clear()
	
	# draw shadows cast by the left wall
	for row in range(0, Playfield.ROW_COUNT):
		set_cell(-1, row, 0, false, false, false, Vector2(15, 0))
	
	# draw shadows cast by the bottom wall
	set_cell(-1, Playfield.ROW_COUNT, 0, false, false, false, Vector2(15, 0))
	for col in range(0, Playfield.COL_COUNT):
		set_cell(col, Playfield.ROW_COUNT, 0, false, false, false, Vector2(15, 0))
	
	# draw shadows cast by blocks in the playfield
	for cell in ParentTileMap.get_used_cells():
		var autotile_coord: Vector2 = ParentTileMap.get_cell_autotile_coord(cell.x, cell.y)
		set_cell(cell.x, cell.y, ParentTileMap.get_cell(cell.x, cell.y), false, false, false, Vector2(autotile_coord.x, autotile_coord.y))

	# draw shadows cast by the current piece
	if piece_tile_map != null:
		for cell in piece_tile_map.get_used_cells():
			var autotile_coord: Vector2 = piece_tile_map.get_cell_autotile_coord(cell.x, cell.y)
			set_cell(cell.x, cell.y, piece_tile_map.get_cell(cell.x, cell.y), false, false, false, Vector2(autotile_coord.x, autotile_coord.y))
