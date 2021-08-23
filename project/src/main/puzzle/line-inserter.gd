extends Node
"""
Inserts lines in a puzzle tilemap.

Most levels don't insert lines, but this script handles it for the levels that do.
"""

# emitted after one or more lines are inserted
signal lines_inserted(lines)

export (NodePath) var tile_map_path: NodePath

onready var _tile_map: PuzzleTileMap = get_node(tile_map_path)
onready var _line_insert_sound := $LineInsertSound

"""
Inserts a line into the puzzle tilemap.

Parameters:
	'new_line_y': (Optional) The y coordinate of the line to insert. If omitted, the line will be inserted at the
		bottom of the puzzle tilemap.
"""
func insert_line(new_line_y: int = PuzzleTileMap.ROW_COUNT - 1) -> void:
	# shift playfield up
	_tile_map.insert_row(new_line_y)
	
	# fill bottom row
	_line_insert_sound.play()
	for x in range(0, PuzzleTileMap.COL_COUNT):
		var pos := Vector2(x, new_line_y)
		var veg_autotile_coord := Vector2(randi() % 18, randi() % 4)
		_tile_map.set_block(pos, PuzzleTileMap.TILE_VEG, veg_autotile_coord)
	_tile_map.set_block(Vector2(randi() % PuzzleTileMap.COL_COUNT, new_line_y), -1)
	
	emit_signal("lines_inserted", [new_line_y])
