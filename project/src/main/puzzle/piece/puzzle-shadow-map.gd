extends TileMap
## Tilemap which draws the shadows behind the blocks on the playfield, as well as the shadow behind the currently
## active piece.

@export var playfield_tile_map_path: NodePath

## Tilemap for the active piece
var piece_tile_map: TileMap

@onready var _playfield_tile_map := get_node(playfield_tile_map_path)

func _process(_delta: float) -> void:
	clear()
	
	# draw shadows cast by the left wall
	for y in range(PuzzleTileMap.ROW_COUNT):
		set_cell(0, Vector2i(-1, y), 0, Vector2i(15, 0))
	
	# draw shadows cast by the bottom wall
	set_cell(0, Vector2i(-1, PuzzleTileMap.ROW_COUNT), 0, Vector2i(15, 0))
	for x in range(PuzzleTileMap.COL_COUNT):
		set_cell(0, Vector2i(x, PuzzleTileMap.ROW_COUNT), 0, Vector2i(15, 0))
	
	# draw shadows cast by blocks in the playfield
	for cell in _playfield_tile_map.get_used_cells(0):
		var autotile_coord: Vector2i = _playfield_tile_map.get_cell_atlas_coords(0, cell)
		set_cell(0, cell, _playfield_tile_map.get_cell_source_id(0, cell), autotile_coord)

	# draw shadows cast by the current piece
	if piece_tile_map:
		for cell in piece_tile_map.get_used_cells(0):
			var autotile_coord: Vector2i = piece_tile_map.get_cell_atlas_coords(0, cell)
			set_cell(0, cell, piece_tile_map.get_cell_source_id(0, cell), autotile_coord)
