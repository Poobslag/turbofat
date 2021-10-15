extends Node2D
"""
Combo indicators which appear when the player clears a line in puzzle mode.
"""

export (NodePath) var piece_manager_path: NodePath
export (NodePath) var playfield_path: NodePath
export (PackedScene) var ComboCounterScene: PackedScene

# Stores the x position of the previous combo counter to ensure consecutive counters aren't vertically aligned
var _previous_cell_x := -1

# Tracke the most x position of the most recent piece placed in each row
# key: y value of a recently dropped piece
# value: average x position of the piece's blocks in that row
var _piece_x_by_y: Dictionary

onready var _piece_manager: PieceManager = get_node(piece_manager_path)
onready var _playfield: Playfield = get_node(playfield_path)

func _ready() -> void:
	PuzzleState.connect("before_piece_written", self, "_on_PuzzleState_before_piece_written")


"""
When the player places a piece, we store the piece's position in _piece_x_by_y

This allows combo counters to appear horizontally aligned with the most recent piece.
"""
func _on_PuzzleState_before_piece_written() -> void:
	var piece_min_x_by_y := {}
	var piece_max_x_by_y := {}
	for pos_arr_item in _piece_manager.piece.get_pos_arr():
		var target_cell: Vector2 = pos_arr_item + _piece_manager.piece.pos
		if not piece_min_x_by_y.has(target_cell.y):
			piece_min_x_by_y[target_cell.y] = target_cell.x
			piece_max_x_by_y[target_cell.y] = target_cell.x
		else:
			piece_min_x_by_y[target_cell.y] = min(piece_min_x_by_y[target_cell.y], target_cell.x)
			piece_max_x_by_y[target_cell.y] = max(piece_max_x_by_y[target_cell.y], target_cell.x)
	
	for y in piece_min_x_by_y:
		_piece_x_by_y[int(y)] = (piece_min_x_by_y[y] + piece_max_x_by_y[y]) / 2


"""
When a line is cleared we add a new combo counter.
"""
func _on_Playfield_before_line_cleared(y: int, _total_lines: int, _remaining_lines: int, _box_ints: Array) -> void:
	if PuzzleState.combo < 3:
		# no combo counters below 3x
		return
	
	# calculate the combo counter's column
	var target_cell := Vector2(_piece_x_by_y.get(y, 4), y)
	if fmod(target_cell.x, 1.0) > 0.0:
		# if a piece has two blocks side-by-side, we position the combo counter over one or the other
		if floor(target_cell.x) == _previous_cell_x or ceil(target_cell.x) == _previous_cell_x:
			# ensure the combo counter doesn't vertically align with the previous counter
			target_cell.x = floor(target_cell.x) if _previous_cell_x == ceil(target_cell.x) else ceil(target_cell.x)
		else:
			# decide randomly between the two blocks
			target_cell.x = floor(target_cell.x) if randf() > 0.5 else ceil(target_cell.x)
	elif target_cell.x == _previous_cell_x:
		# if a combo counter vertically aligns with the previous counter, we move it horizontally
		if target_cell.x == 0:
			target_cell.x += 1
		elif target_cell.x == PuzzleTileMap.COL_COUNT - 1:
			target_cell.x -= 1
		else:
			target_cell.x += Utils.rand_value([-1, 1])
	_previous_cell_x = target_cell.x
	
	var combo_counter: ComboCounter = ComboCounterScene.instance()
	combo_counter.position = Utils.map_to_world_centered(_playfield.tile_map, target_cell + Vector2(0, -3))
	combo_counter.position *= _playfield.tile_map.scale
	combo_counter.combo = PuzzleState.combo
	add_child(combo_counter)
