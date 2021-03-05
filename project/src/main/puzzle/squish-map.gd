class_name SquishMap
extends PuzzleTileMap
"""
This TileMap handles drawing the stretched-out piece during a squish move.
"""

var squish_seconds_remaining := 0.0
var squish_seconds_total := 0.0

var _stretch_pos := []
var _max_distance := 0
var _color_y: int

func _ready() -> void:
	for row in range(ROW_COUNT):
		_stretch_pos.append([])
		for _col in range(COL_COUNT):
			_stretch_pos[row].append(0)
	set_process(false)


func _process(delta: float) -> void:
	for row in range(ROW_COUNT):
		for col in range(COL_COUNT):
			if _stretch_pos[row][col] > _max_distance \
					* (squish_seconds_total - squish_seconds_remaining) / squish_seconds_total:
				set_block(Vector2(col, row), 0, Vector2(0, _color_y))
			else:
				set_block(Vector2(col, row), -1)
	
	for row in range(ROW_COUNT):
		for col in range(COL_COUNT):
			var cell_pos := Vector2(col, row)
			if is_cell_empty(cell_pos):
				continue
			var color_x := 0
			if row > 0 and is_cell_blocked(cell_pos + Vector2.UP):
				color_x = PuzzleConnect.set_u(color_x)
			if row < ROW_COUNT - 1 and is_cell_blocked(cell_pos + Vector2.DOWN):
				color_x = PuzzleConnect.set_d(color_x)
			if col > 0 and is_cell_blocked(cell_pos + Vector2.LEFT):
				color_x = PuzzleConnect.set_l(color_x)
			if col < COL_COUNT - 1 and is_cell_blocked(cell_pos + Vector2.RIGHT):
				color_x = PuzzleConnect.set_r(color_x)
			set_block(cell_pos, 0, Vector2(color_x, _color_y))
	
	squish_seconds_remaining -= delta
	if squish_seconds_remaining <= 0:
		set_process(false)


"""
Adds the specified cells to the current squish move.
"""
func stretch_to(piece_pos_arr: Array, offset: Vector2) -> void:
	if not _is_stretched_to(piece_pos_arr, offset):
		return
	
	_max_distance += 1
	
	for piece_pos in piece_pos_arr:
		_stretch_pos[piece_pos.y + offset.y][piece_pos.x + offset.x] = _max_distance


"""
Starts a new squish move, which will make the piece appear vertically stretched for a few frames.
"""
func start_squish(squish_frames: int, new_color_y: int) -> void:
	squish_seconds_total = squish_frames / 60.0
	squish_seconds_remaining = squish_seconds_total
	set_process(true)
	_max_distance = 0
	_color_y = new_color_y
	
	clear()
	$CornerMap.dirty = true
	for row in range(ROW_COUNT):
		for col in range(COL_COUNT):
			_stretch_pos[row][col] = 0


"""
Returns 'true' if the piece is already stretched to the specified position.
"""
func _is_stretched_to(piece_pos_arr: Array, offset: Vector2) -> bool:
	var result := false
	if _max_distance == 0:
		result = true
	else:
		for piece_pos in piece_pos_arr:
			if _stretch_pos[piece_pos.y + offset.y][piece_pos.x + offset.x] < _max_distance:
				result = true
	return result
