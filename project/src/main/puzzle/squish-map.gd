extends PuzzleTileMap
"""
This TileMap handles drawing the active piece during a squish move.
"""

var squish_seconds_remaining := 0.0

var _row_count: int
var _col_count: int

var _squish_pos := []
var _squish_seconds_total := 0.0
var _max_distance := 0
var _color_y: int

func _ready() -> void:
	_col_count = PuzzleTileMap.COL_COUNT
	_row_count = PuzzleTileMap.ROW_COUNT
	for row in range(_row_count):
		_squish_pos.append([])
		for _col in range(_col_count):
			_squish_pos[row].append(0)
	set_process(false)


func _process(delta: float) -> void:
	for row in range(_row_count):
		for col in range(_col_count):
			if _squish_pos[row][col] > _max_distance \
					* (_squish_seconds_total - squish_seconds_remaining) / _squish_seconds_total:
				set_block(Vector2(col, row), 0, Vector2(0, _color_y))
			else:
				set_block(Vector2(col, row), -1)
	
	for row in range(_row_count):
		for col in range(_col_count):
			if get_cell(col, row) != 0:
				continue
			var color_x := 0
			if row > 0 and get_cell(col, row - 1) == 0:
				color_x = Connect.set_u(color_x)
			if row < _row_count - 1 and get_cell(col, row + 1) == 0:
				color_x = Connect.set_d(color_x)
			if col > 0 and get_cell(col - 1, row) == 0:
				color_x = Connect.set_l(color_x)
			if col < _col_count - 1 and get_cell(col + 1, row) == 0:
				color_x = Connect.set_r(color_x)
			set_block(Vector2(col, row), 0, Vector2(color_x, _color_y))
	
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
		_squish_pos[piece_pos.y + offset.y][piece_pos.x + offset.x] = _max_distance


"""
Starts a new squish move, which will make the piece appear vertically stretched for a few frames.
"""
func start_squish(squish_frames: int, new_color_y: int) -> void:
	_squish_seconds_total = squish_frames / 60.0
	squish_seconds_remaining = _squish_seconds_total
	set_process(true)
	_max_distance = 0
	_color_y = new_color_y
	
	clear()
	$CornerMap.dirty = true
	for row in range(_row_count):
		for col in range(_col_count):
			_squish_pos[row][col] = 0


"""
Returns 'true' if the piece is already stretched to the specified position.
"""
func _is_stretched_to(piece_pos_arr: Array, offset: Vector2) -> bool:
	var result := false
	if _max_distance == 0:
		result = true
	else:
		for piece_pos in piece_pos_arr:
			if _squish_pos[piece_pos.y + offset.y][piece_pos.x + offset.x] < _max_distance:
				result = true
	return result
