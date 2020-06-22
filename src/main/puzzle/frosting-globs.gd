extends Node2D
"""
Creates frosting globs on the playfield when the player does well.

These frosting globs are pulled from a pool, reset to a specific color and position, and launched in a random
direction.
"""

# emitted when a frosting glob hits a wall
signal hit_wall(glob, glob_alpha)

# emitted when a frosting glob smears against the playfield, next pieces, or gutter.
# passes in a copy of the original frosting glob, because the original remains unchanged
signal hit_playfield(glob_copy, glob_alpha)
signal hit_next_pieces(glob_copy, glob_alpha)
signal hit_gutter(glob_copy, glob_alpha)

# The maximum number of frosting globs we can display at once.
const GLOB_POOL_SIZE := 800

# The cell size for the TileMap containing the playfield blocks. This is used to position our globs.
const CELL_SIZE = Vector2(36, 32)

# The pool of unspawned globs. When spawning a new glob, we should look in this pool first and recycle one.
var _offscreen_globs: Dictionary

# The pool of spawned globs. We periodically check this list to move items back into unspawned_globs.
var _onscreen_globs: Dictionary

# The index of the next glob to spawn from the pool
var _glob_index := 0
var _rainbow_glob_index := 0

onready var FrostingGlobScene := preload("res://src/main/puzzle/FrostingGlob.tscn")

onready var _puzzle: Puzzle = get_parent()
onready var _playfield := _puzzle.get_playfield()

func _ready() -> void:
	for i in range(GLOB_POOL_SIZE):
		var glob: FrostingGlob = FrostingGlobScene.instance()
		_offscreen_globs[glob] = "_"
		glob.connect("hit_wall", self, "_on_FrostingGlob_hit_wall")
		glob.connect("hit_playfield", self, "_on_FrostingGlob_hit_playfield")
		glob.connect("hit_next_pieces", self, "_on_FrostingGlob_hit_next_pieces")
		glob.connect("hit_gutter", self, "_on_FrostingGlob_hit_gutter")


func _exit_tree() -> void:
	for glob in _offscreen_globs.keys() + _onscreen_globs.keys():
		glob.reparent(null)
		
		# calling queue_free results in 'ObjectDB Instances still exist' errors, so we free globs this way
		glob.call_deferred("free")


"""
Launches new frosting globs from the specified tile.

Parameters:
	'x', 'y': An (x, y) position in the TileMap containing the playfield blocks
	'color_int': One of Playfield's food color indexes (brown, pink, bread, white, cake)
	'glob_count': The number of frosting globs to launch
"""
func _spawn_globs(x: int, y: int, color_int: int, glob_count: int) -> void:
	if not _offscreen_globs and not _onscreen_globs:
		# pool is empty
		return
	
	var viewport: Viewport
	if PuzzleTileMap.is_cake_box(color_int):
		viewport = $GlobViewports/RainbowViewport
	else:
		viewport = $GlobViewports/Viewport
	
	for _i in range(glob_count):
		var glob: FrostingGlob = _recycle_glob(viewport)
		glob.initialize(color_int, Vector2(x + randf(), y - 3 + randf()) * CELL_SIZE + _playfield.rect_position)
		glob.fall()


"""
Reuse a FrostingGlob object without reallocating or 'newing' it.

Attempts to reuse an offscreen/expired frosting glob if one is available, but will fall back to onscreen frosting
globs if needed.
"""
func _recycle_glob(new_parent: Node = null) -> FrostingGlob:
	var glob: FrostingGlob
	if _offscreen_globs:
		glob = _offscreen_globs.keys()[0]
		_offscreen_globs.erase(glob)
		_onscreen_globs[glob] = "_"
	else:
		glob = _onscreen_globs.keys()[0]
	glob.reparent(new_parent)
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


func _on_FrostingGlob_hit_wall(glob: FrostingGlob) -> void:
	emit_signal("hit_wall", glob, glob.modulate.a)


func _on_FrostingGlob_hit_playfield(glob: FrostingGlob) -> void:
	var glob_copy := _recycle_glob()
	glob_copy.copy_from(glob)
	emit_signal("hit_playfield", glob_copy, glob_copy.modulate.a)


func _on_FrostingGlob_hit_next_pieces(glob: FrostingGlob) -> void:
	var glob_copy := _recycle_glob()
	glob_copy.copy_from(glob)
	emit_signal("hit_next_pieces", glob_copy, glob_copy.modulate.a)


func _on_FrostingGlob_hit_gutter(glob: FrostingGlob) -> void:
	var glob_copy := _recycle_glob()
	glob_copy.copy_from(glob)
	emit_signal("hit_gutter", glob_copy, glob_copy.modulate.a)


"""
Repopulates the pool of offscreen frosting globs.

The pool of offscreen globs is populated from globs which have been onscreen too long, or which have become invisible.
"""
func _on_GcTimer_timeout() -> void:
	var globs_to_erase := []
	for glob_obj in _onscreen_globs:
		var glob: FrostingGlob = glob_obj
		if not glob.visible or glob.get_age() > FrostingGlob.MAX_AGE:
			globs_to_erase.append(glob)
	for glob in globs_to_erase:
		_onscreen_globs.erase(glob)
		_offscreen_globs[glob] = "_"
