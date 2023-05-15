extends TileMap
## Tilemap which draws the shadows behind the blocks on the playfield, as well as the shadow behind the currently
## active piece.

@export (NodePath) var playfield_tile_map_path: NodePath

## Tilemap for the active piece
var piece_tile_map: TileMap

@onready var _playfield_tile_map := get_node(playfield_tile_map_path)

func _process(_delta: float) -> void:
	clear()
	
	# draw shadows cast by the left wall
	for y in range(PuzzleTileMap.ROW_COUNT):
		set_cell(-1, y, 0, false, false, false, Vector2(15, 0))
	
	# draw shadows cast by the bottom wall
	set_cell(-1, PuzzleTileMap.ROW_COUNT, 0, false, false, false, Vector2(15, 0))
	for x in range(PuzzleTileMap.COL_COUNT):
		set_cell(x, PuzzleTileMap.ROW_COUNT, 0, false, false, false, Vector2(15, 0))
	
	# draw shadows cast by blocks in the playfield
	for cell in _playfield_tile_map.get_used_cells():
		var autotile_coord: Vector2 = _playfield_tile_map.get_cell_autotile_coord(cell.x, cell.y)
		set_cellv(cell, _playfield_tile_map.get_cellv(cell), false, false, false, autotile_coord)

	# draw shadows cast by the current piece
	if piece_tile_map:
		for cell in piece_tile_map.get_used_cells():
			var autotile_coord: Vector2 = piece_tile_map.get_cell_autotile_coord(cell.x, cell.y)
			set_cellv(cell, piece_tile_map.get_cellv(cell), false, false, false, autotile_coord)
