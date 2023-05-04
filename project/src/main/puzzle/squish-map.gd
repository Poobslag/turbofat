class_name SquishMap
extends PuzzleTileMap
## This TileMap handles drawing the stretched-out piece during a squish move.

var squish_seconds_remaining := 0.0
var squish_seconds_total := 0.0

## key: (Vector2i) tile map cell
## value: (int) Number proportional to how long this cell should contain a stretched block. Higher numbered cells are
## 	drawn for more frames, lower numbered cells are drawn for fewer frames. Cells with a value of zero are never drawn.
var _stretch_pos := {}

## Threshold for which cells should be drawn with stretched blocks.
var _max_distance := 0

## Autotile y for filled tilemap cells.
var _color_y: int

func _ready() -> void:
	set_process(false)


func _process(delta: float) -> void:
	for y in range(ROW_COUNT):
		for x in range(COL_COUNT):
			var cell_pos := Vector2i(x, y)
			if _stretch_pos.get(cell_pos, 0) > _max_distance \
					* (squish_seconds_total - squish_seconds_remaining) / squish_seconds_total:
				set_block(cell_pos, 0, Vector2i(0, _color_y))
			else:
				set_block(cell_pos, -1)
	
	for y in range(ROW_COUNT):
		for x in range(COL_COUNT):
			var cell_pos := Vector2i(x, y)
			if is_cell_empty(cell_pos):
				continue
			var color_x := 0
			if y > 0 and is_cell_obstructed(cell_pos + Vector2i.UP):
				color_x = PuzzleConnect.set_u(color_x)
			if y < ROW_COUNT - 1 and is_cell_obstructed(cell_pos + Vector2i.DOWN):
				color_x = PuzzleConnect.set_distance(color_x)
			if x > 0 and is_cell_obstructed(cell_pos + Vector2i.LEFT):
				color_x = PuzzleConnect.set_l(color_x)
			if x < COL_COUNT - 1 and is_cell_obstructed(cell_pos + Vector2i.RIGHT):
				color_x = PuzzleConnect.set_r(color_x)
			set_block(cell_pos, 0, Vector2i(color_x, _color_y))
	
	squish_seconds_remaining -= delta
	if squish_seconds_remaining <= 0:
		set_process(false)


## Adds the specified cells to the current squish move.
func stretch_to(piece_pos_arr: Array, offset: Vector2i) -> void:
	if not _is_stretched_to(piece_pos_arr, offset):
		return
	
	_max_distance += 1
	
	for piece_pos in piece_pos_arr:
		_stretch_pos[Vector2i(piece_pos.x + offset.x, piece_pos.y + offset.y)] = _max_distance


## Starts a new squish move, which will make the piece appear vertically stretched for a few frames.
func start_squish(post_squish_frames: int, new_color_y: int) -> void:
	squish_seconds_total = post_squish_frames / 60.0
	squish_seconds_remaining = squish_seconds_total
	set_process(true)
	_max_distance = 0
	_color_y = new_color_y
	
	clear()
	corner_map.dirty = true
	_stretch_pos.clear()


## Returns 'true' if the piece is already stretched to the specified position.
func _is_stretched_to(piece_pos_arr: Array, offset: Vector2i) -> bool:
	var result := false
	if _max_distance == 0:
		result = true
	else:
		for piece_pos in piece_pos_arr:
			if _stretch_pos.get(Vector2i(piece_pos.x + offset.x, piece_pos.y + offset.y), 0) < _max_distance:
				result = true
	return result
