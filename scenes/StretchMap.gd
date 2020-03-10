"""
This TileMap handles drawing the active piece when it's stretched around other pieces.
"""
extends TileMap

onready var Playfield = get_node("../../Playfield")

# constants used when drawing blocks which are connected to other blocks
const CONNECTED_UP = 1
const CONNECTED_DOWN = 2
const CONNECTED_LEFT = 4
const CONNECTED_RIGHT = 8

var _row_count: int
var _col_count: int

var _stretch_pos := []
var _stretch_seconds_total := 0.0
var _stretch_seconds_remaining := 0.0
var _max_distance := 0
var _color_y: int

func _ready():
	if Playfield != null:
		_col_count = Playfield.COL_COUNT
		_row_count = Playfield.ROW_COUNT
	else:
		_col_count = 9
		_row_count = 18
	for row in range(0, _row_count):
		_stretch_pos.append([])
		for col in range (0, _col_count):
			_stretch_pos[row].append(0)

func _process(delta: float) -> void:
	if _stretch_seconds_remaining > 0:
		for row in range(0, _row_count):
			for col in range (0, _col_count):
				if _stretch_pos[row][col] > _max_distance * (_stretch_seconds_total -_stretch_seconds_remaining) / _stretch_seconds_total:
					set_cell(col, row, 0, false, false, false, Vector2(0, _color_y))
				else:
					set_cell(col, row, -1)
		
		for row in range(0, _row_count):
			for col in range (0, _col_count):
				if get_cell(col, row) != 0:
					continue
				var color_x = 0
				if row > 0 && get_cell(col, row - 1) == 0:
					color_x |= PieceTypes.CONNECTED_UP
				if row < _row_count - 1 && get_cell(col, row + 1) == 0:
					color_x |= PieceTypes.CONNECTED_DOWN
				if col > 0 && get_cell(col - 1, row) == 0:
					color_x |= PieceTypes.CONNECTED_LEFT
				if col < _col_count - 1 && get_cell(col + 1, row) == 0:
					color_x |= PieceTypes.CONNECTED_RIGHT
				set_cell(col, row, 0, false, false, false, Vector2(color_x, _color_y))
		
		_stretch_seconds_remaining -= delta
		$CornerMap.dirty = true

"""
Adds the specified cells to the current stretch operation.
"""
func stretch_to(piece_pos_arr: Array, offset: Vector2) -> void:
	if !_is_stretched_to(piece_pos_arr, offset):
		return
	
	_max_distance += 1
	
	for piece_pos in piece_pos_arr:
		_stretch_pos[piece_pos.y + offset.y][piece_pos.x + offset.x] = _max_distance

"""
Returns 'true' if the piece is already stretched to the specified position.
"""
func _is_stretched_to(piece_pos_arr: Array, offset: Vector2) -> bool:
	if _max_distance == 0:
		return true
	
	for piece_pos in piece_pos_arr:
		if _stretch_pos[piece_pos.y + offset.y][piece_pos.x + offset.x] < _max_distance:
			return true
	
	return false

"""
Starts a new stretch operation, which will make the piece appear stretched out for a few frames.
"""
func start_stretch(stretch_frames: int, new_color_y: int) -> void:
	_stretch_seconds_total = stretch_frames / 60.0
	_stretch_seconds_remaining = _stretch_seconds_total
	_max_distance = 0
	_color_y = new_color_y
	
	clear()
	$CornerMap.dirty = true
	for row in range(0, _row_count):
		for col in range (0, _col_count):
			_stretch_pos[row][col] = 0