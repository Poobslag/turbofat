class_name PieceManager
extends Control
"""
Contains logic for spawning new pieces, moving/rotating pieces, handling player input, and locking pieces into the
_playfield.
"""

signal piece_spawned

# emitted when the current piece changes in some way (moved, replaced, reoriented)
signal piece_changed(piece)

# emitted when the player rotates a piece
signal initial_rotated_right
signal initial_rotated_left
signal initial_rotated_twice

# emitted when the player moves a piece
signal initial_das_moved_left
signal initial_das_moved_right
signal das_moved_left
signal das_moved_right
signal moved_left
signal moved_right
signal rotated_left
signal rotated_right
signal rotated_twice
signal soft_dropped
signal hard_dropped
signal squish_moved(piece, old_pos)

# emitted for piece locks
signal lock_cancelled
signal lock_started

signal tiles_changed(tile_map)

export (NodePath) var playfield_path: NodePath
export (NodePath) var next_piece_displays_path: NodePath

# settings and state for the currently active piece.
var piece: ActivePiece

# information about the piece previously rendered to the tile map
var drawn_piece_type: PieceType
var drawn_piece_pos: Vector2
var drawn_piece_orientation: int

# TileMap containing the puzzle blocks which make up the active piece
onready var tile_map: PuzzleTileMap = $TileMap

onready var _input: PieceInput = $Input
onready var _next_piece_displays: NextPieceDisplays = get_node(next_piece_displays_path)
onready var _physics: PiecePhysics = $Physics
onready var _playfield: Playfield = get_node(playfield_path)
onready var _states: PieceStates = $States

func _ready() -> void:
	PuzzleScore.connect("game_prepared", self, "_on_PuzzleScore_game_prepared")
	PuzzleScore.connect("game_started", self, "_on_PuzzleScore_game_started")
	PuzzleScore.connect("before_level_changed", self, "_on_PuzzleScore_before_level_changed")
	PuzzleScore.connect("after_level_changed", self, "_on_PuzzleScore_after_level_changed")
	PuzzleScore.connect("finish_triggered", self, "_on_PuzzleScore_finish_triggered")
	PuzzleScore.connect("game_ended", self, "_on_PuzzleScore_game_ended")
	Pauser.connect("paused_changed", self, "_on_Pauser_paused_changed")
	
	piece = ActivePiece.new(PieceTypes.piece_null, funcref(tile_map, "is_cell_blocked"))

	PieceSpeeds.current_speed = PieceSpeeds.speed("0")
	_states.set_state(_states.none)
	_clear_piece()


func _physics_process(_delta: float) -> void:
	_states.update()
	if drawn_piece_type != piece.type \
			or drawn_piece_pos != piece.pos \
			or drawn_piece_orientation != piece.orientation:
		# piece has changed, moved, or rotated
		drawn_piece_type = piece.type
		drawn_piece_pos = piece.pos
		drawn_piece_orientation = piece.orientation
		_update_tile_map()
		emit_signal("tiles_changed", tile_map)


func get_state() -> State:
	return _states.get_state()


func is_playfield_ready_for_new_piece() -> bool:
	return _playfield.ready_for_new_piece()


"""
Writes the current piece to the _playfield, checking whether it builds any boxes or clears any lines.

Returns true if the newly written piece results in a line clear.
"""
func write_piece_to_playfield() -> void:
	_playfield.write_piece(piece.pos, piece.orientation, piece.type)
	_clear_piece()


"""
Called when the player tops out, but doesn't lose.

Enters a state which waits for the _playfield to make room for the current piece.
"""
func enter_top_out_state(top_out_frames: int) -> void:
	_states.set_state(_states.top_out)
	piece.spawn_delay = top_out_frames


"""
Spawns a new piece at the top of the _playfield.

Returns 'true' if the piece was spawned successfully, or 'false' if the player topped out.
"""
func spawn_piece() -> bool:
	var piece_type := _next_piece_displays.pop_next_piece()
	piece = ActivePiece.new(piece_type, funcref(_playfield.tile_map, "is_cell_blocked"))
	var success := _physics.spawn_piece(piece)
	emit_signal("piece_spawned")
	emit_signal("piece_changed", piece)
	return success


func move_piece() -> void:
	var piece_changed := _physics.move_piece(piece)
	if piece_changed:
		emit_signal("piece_changed", piece)


"""
Records any inputs to a buffer to be replayed later.
"""
func buffer_inputs() -> void:
	_input.buffer_inputs()


"""
Replays any inputs which were pressed while buffering.
"""
func pop_buffered_inputs() -> void:
	_input.pop_buffered_inputs()


"""
Returns a number from [0, 1] for how close the piece is to squishing.
"""
func squish_percent() -> float:
	return _physics.squish_percent(piece)


"""
Increments the piece's 'lock'. A piece will become locked once its accumulated 'lock' exceeds a certain threshold,
usually about half a second.
"""
func apply_lock() -> void:
	if not piece.can_move_to(Vector2(piece.pos.x, piece.pos.y + 1), piece.orientation):
		piece.lock += 1
		piece.gravity = 0
	else:
		piece.lock = 0


func is_playfield_clearing_lines() -> bool:
	return _playfield.get_remaining_line_erase_frames() > 0


"""
Set the state frames so that the piece spawns immediately.
"""
func skip_prespawn() -> void:
	if CurrentLevel.settings.other.non_interactive:
		return
	
	if _states.get_state() != _states.prespawn:
		_states.set_state(_states.prespawn)
	_states.prespawn.frames = 3600


func _clear_piece() -> void:
	piece = ActivePiece.new(PieceTypes.piece_null, funcref(tile_map, "is_cell_blocked"))


"""
Refresh the tile map which displays the piece, based on the current piece's position and orientation.
"""
func _update_tile_map() -> void:
	tile_map.clear()
	var pos_arr := piece.get_pos_arr()
	for i in range(pos_arr.size()):
		var block_pos: Vector2 = piece.pos + pos_arr[i]
		var block_color := piece.type.get_cell_color(piece.orientation, i)
		tile_map.set_block(block_pos, 0, block_color)


"""
Spawns the first piece of a level.
"""
func _start_first_piece() -> void:
	if CurrentLevel.settings.other.non_interactive:
		return
	
	_states.set_state(_states.prespawn)
	skip_prespawn()


func _on_States_entered_state(state: State) -> void:
	if state == _states.prelock:
		emit_signal("lock_started")


func _on_PuzzleScore_game_prepared() -> void:
	_clear_piece()


func _on_PuzzleScore_game_started() -> void:
	_start_first_piece()


"""
The player finished the level, possibly while they were still moving a piece around. We clear their piece so that it's
not left floating.
"""
func _on_PuzzleScore_finish_triggered() -> void:
	_clear_piece()
	_states.set_state(_states.game_ended)


"""
The game ended the game, possibly by a top out. We leave the piece in place so that they can see why they topped out.
"""
func _on_PuzzleScore_game_ended() -> void:
	_states.set_state(_states.game_ended)


func _on_PuzzleScore_before_level_changed(_new_level_id: String) -> void:
	set_physics_process(false)


func _on_PuzzleScore_after_level_changed() -> void:
	set_physics_process(true)
	_start_first_piece()


func _on_Pauser_paused_changed(value: bool) -> void:
	visible = !value


func _on_Dropper_hard_dropped() -> void: emit_signal("hard_dropped")
func _on_Dropper_soft_dropped() -> void: emit_signal("soft_dropped")

func _on_Squisher_lock_cancelled() -> void: emit_signal("lock_cancelled")
func _on_Squisher_squish_moved(squished_piece: ActivePiece, old_pos: Vector2) -> void:
	emit_signal("squish_moved", squished_piece, old_pos)

func _on_Mover_initial_das_moved_left() -> void: emit_signal("initial_das_moved_left")
func _on_Mover_initial_das_moved_right() -> void: emit_signal("initial_das_moved_right")
func _on_Mover_das_moved_left() -> void: emit_signal("das_moved_left")
func _on_Mover_das_moved_right() -> void: emit_signal("das_moved_right")
func _on_Mover_moved_left() -> void: emit_signal("moved_left")
func _on_Mover_moved_right() -> void: emit_signal("moved_right")

func _on_Rotator_rotated_left() -> void: emit_signal("rotated_left")
func _on_Rotator_rotated_right() -> void: emit_signal("rotated_right")
func _on_Rotator_rotated_twice() -> void: emit_signal("rotated_twice")
func _on_Rotator_initial_rotated_left() -> void: emit_signal("initial_rotated_left")
func _on_Rotator_initial_rotated_right() -> void: emit_signal("initial_rotated_right")
func _on_Rotator_initial_rotated_twice() -> void: emit_signal("initial_rotated_twice")
