extends Node2D
"""
Creates frosting globs on the playfield when the player does well.

These frosting globs are pulled from a pool, reset to a specific color and position, and launched in a random
direction.
"""

# The maximum number of frosting globs we can display at once.
const GLOB_POOL_SIZE := 200

# The cell size for the TileMap containing the playfield blocks. This is used to position our globs.
const CELL_SIZE = Vector2(36, 32)

# The pool of globs we're able to spawn. Some of these may be active but most will be inactive (process=false)
var _globs := []
var _rainbow_globs := []

# The index of the next glob to spawn from the pool
var _glob_index := 0
var _rainbow_glob_index := 0

onready var FrostingGlobScene := preload("res://src/main/puzzle/FrostingGlob.tscn")

onready var _puzzle: Puzzle = get_parent()
onready var _playfield := _puzzle.get_playfield()

func _ready() -> void:
	for i in range(GLOB_POOL_SIZE):
		var glob: FrostingGlob = FrostingGlobScene.instance()
		if i % 2 == 0:
			$Viewport.add_child(glob)
			_globs.append(glob)
		else:
			$RainbowViewport.add_child(glob)
			_rainbow_globs.append(glob)


"""
Launches a new frosting glob from the specified position.

Parameters:
	'color': The color of the frosting glob to launch
	'position': An (x, y) coordinate relative to this node where the glob will appear
"""
func spawn_glob(color: Color, position: Vector2) -> void:
	var glob: FrostingGlob = _globs[_glob_index]
	_glob_index = (_glob_index + 1) % _globs.size()
	glob.initialize(color, position)


"""
Launches a new rainbow colored frosting glob from the specified position.

Parameters:
	'position': An (x, y) coordinate relative to this node where the glob will appear
"""
func spawn_rainbow_glob(position: Vector2) -> void:
	var glob: FrostingGlob = _rainbow_globs[_rainbow_glob_index]
	_rainbow_glob_index = (_rainbow_glob_index + 1) % _rainbow_globs.size()
	glob.initialize(Color.white, position)


"""
When a line is cleared, we generate frosting globs for any boxes involved in the line clear.

This must be called before the line is cleared so that we can evaluate the food blocks before they're erased.
"""
func _on_Playfield_before_line_cleared(y: int, total_lines: int, remaining_lines: int, box_ints: Array) -> void:
	for x in range(Playfield.COL_COUNT):
		var color_int: int
		var glob_count: int
		if _playfield.get_cell(x, y) == 1:
			color_int = _playfield.get_cell_autotile_coord(x, y).y
			if PuzzleTileMap.is_snack_box(color_int):
				glob_count = 2
			elif PuzzleTileMap.is_cake_box(color_int):
				glob_count = 4
		elif _playfield.get_cell(x, y) == 2:
			# vegetable
			pass
		_spawn_globs(x, y, color_int, glob_count)


"""
When a box is made, we generate frosting globs on the inside of the box.
"""
func _on_Playfield_box_made(left_x: int, top_y: int, width: int, height: int, color_int: int) -> void:
	for y in range(top_y, top_y + height):
		for x in range(left_x, left_x + width):
			var glob_count: int
			if PuzzleTileMap.is_snack_box(color_int):
				glob_count = 1
			elif PuzzleTileMap.is_cake_box(color_int):
				glob_count = 2
			_spawn_globs(x, y, color_int, glob_count)


"""
Launches new frosting globs from the specified tile.

Parameters:
	'x', 'y': An (x, y) position in the TileMap containing the playfield blocks
	'color_int': One of Playfield's food color indexes (brown, pink, bread, white, cake)
	'glob_count': The number of frosting globs to launch
"""
func _spawn_globs(x: int, y: int, color_int: int, glob_count: int) -> void:
	for _i in range(glob_count):
		if PuzzleTileMap.is_snack_box(color_int):
			var color: Color = Playfield.FOOD_COLORS[color_int]
			spawn_glob(color, Vector2(x + randf(), y - 3 + randf()) * CELL_SIZE + _playfield.rect_position)
		elif PuzzleTileMap.is_cake_box(color_int):
			spawn_rainbow_glob(Vector2(x + randf(), y - 3 + randf()) * CELL_SIZE + _playfield.rect_position)
