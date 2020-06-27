extends Node2D
"""
Creates frosting globs on the playfield when the player does well.

These frosting globs are pulled from a pool, reset to a specific color and position, and launched in a random
direction.
"""

# emitted when a frosting glob hits a wall
signal hit_wall(glob)

# emitted when a frosting glob smears against the playfield, next pieces, or gutter.
# passes in a copy of the original frosting glob, because the original remains unchanged
signal hit_playfield(glob)
signal hit_next_pieces(glob)
signal hit_gutter(glob)

# The maximum number of frosting globs we can display at once.
const GLOB_POOL_SIZE := 800

# The cell size for the TileMap containing the playfield blocks. This is used to position our globs.
const CELL_SIZE = Vector2(36, 32)

export (NodePath) var _playfield_path: NodePath

onready var FrostingGlobScene := preload("res://src/main/puzzle/FrostingGlob.tscn")
onready var _playfield := get_node(_playfield_path)

"""
Launches new frosting globs from the specified tile.

Parameters:
	'x', 'y': An (x, y) position in the TileMap containing the playfield blocks
	'color_int': One of PuzzleTileMap's food color indexes (brown, pink, bread, white, cake)
	'glob_count': The number of frosting globs to launch
	'glob_alpha': The initial alpha component of the globs. Affects their size and duration
"""
func _spawn_globs(x: int, y: int, color_int: int, glob_count: int, glob_alpha: float = 1.0) -> void:
	var viewport: Viewport
	if PuzzleTileMap.is_cake_box(color_int):
		viewport = $GlobViewports/RainbowViewport
	else:
		viewport = $GlobViewports/Viewport
	
	for _i in range(glob_count):
		var glob: FrostingGlob = _recycle_glob(viewport)
		glob.initialize(color_int, Vector2(x + randf(), y - 3 + randf()) * CELL_SIZE + _playfield.rect_position)
		glob.modulate.a = glob_alpha
		glob.fall()


"""
Reuse a FrostingGlob object without reallocating or 'newing' it.

Attempts to reuse an offscreen/expired frosting glob if one is available, but will fall back to onscreen frosting
globs if needed.
"""
func _recycle_glob(new_parent: Node = null) -> FrostingGlob:
	var glob: FrostingGlob = FrostingGlobScene.instance()
	glob.connect("hit_wall", self, "_on_FrostingGlob_hit_wall")
	glob.connect("hit_playfield", self, "_on_FrostingGlob_hit_playfield")
	glob.connect("hit_next_pieces", self, "_on_FrostingGlob_hit_next_pieces")
	glob.connect("hit_gutter", self, "_on_FrostingGlob_hit_gutter")
	new_parent.add_child(glob)
	return glob


"""
When a line is cleared, we generate frosting globs for any boxes involved in the line clear.

This must be called before the line is cleared so that we can evaluate the food blocks before they're erased.
"""
func _on_Playfield_before_line_cleared(y: int, total_lines: int, remaining_lines: int, box_ints: Array) -> void:
	for x in range(PuzzleTileMap.COL_COUNT):
		var color_int: int
		var glob_count: int
		if _playfield.get_cell(x, y) == PuzzleTileMap.TILE_BOX:
			color_int = _playfield.get_cell_autotile_coord(x, y).y
			if PuzzleTileMap.is_snack_box(color_int):
				glob_count = 2
			elif PuzzleTileMap.is_cake_box(color_int):
				glob_count = 4
		_spawn_globs(x, y, color_int, glob_count)


"""
When a box is built, we generate frosting globs on the inside of the box.
"""
func _on_Playfield_box_built(left_x: int, top_y: int, width: int, height: int, color_int: int) -> void:
	for y in range(top_y, top_y + height):
		for x in range(left_x, left_x + width):
			var glob_count: int
			if PuzzleTileMap.is_snack_box(color_int):
				glob_count = 1
			elif PuzzleTileMap.is_cake_box(color_int):
				glob_count = 2
			_spawn_globs(x, y, color_int, glob_count)


"""
When a squish move is performed, we generate frosting globs around the old and new piece position.
"""
func _on_PieceManager_squish_moved(piece: ActivePiece, old_pos: Vector2) -> void:
	for i in range(piece.type.pos_arr[piece.orientation].size()):
		var pos_arr_item: Vector2 = piece.type.pos_arr[piece.orientation][i]
		var glob_cell_from := old_pos + pos_arr_item
		var glob_cell_to := piece.pos + pos_arr_item
		_spawn_globs(glob_cell_from.x, glob_cell_from.y, piece.type.get_color_int(), 1, 0.8)
		_spawn_globs(glob_cell_to.x, glob_cell_to.y, piece.type.get_color_int(), 1, 0.8)


func _on_FrostingGlob_hit_wall(glob: FrostingGlob) -> void:
	emit_signal("hit_wall", glob)
	glob.queue_free()


func _on_FrostingGlob_hit_playfield(glob: FrostingGlob) -> void:
	emit_signal("hit_playfield", glob)


func _on_FrostingGlob_hit_next_pieces(glob: FrostingGlob) -> void:
	emit_signal("hit_next_pieces", glob)


func _on_FrostingGlob_hit_gutter(glob: FrostingGlob) -> void:
	emit_signal("hit_gutter", glob)
