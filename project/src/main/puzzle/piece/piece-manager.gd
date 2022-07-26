class_name PieceManager
extends Control
## Contains logic for spawning new pieces, moving/rotating pieces, handling player input, and locking pieces into the
## playfield.

## Emitted when the playfield changes in a way which might move the current piece or alter its behavior. For example,
## inserting a row might bump the piece up, or erasing a row might shift the ghost piece down.
signal playfield_disturbed(piece)

signal piece_spawned

## emitted when the current piece changes in some way (moved, replaced, reoriented)
signal piece_disturbed(piece)

## emitted when the player rotates a piece
signal initial_rotated_cw
signal initial_rotated_ccw
signal initial_rotated_180

## emitted when the player moves a piece
signal initial_das_moved_left
signal initial_das_moved_right
signal das_moved_left
signal das_moved_right
signal moved_left
signal moved_right
signal rotated_ccw
signal rotated_cw
signal rotated_180
signal soft_dropped # emitted when the player presses the soft drop key
signal hard_dropped # emitted when the player presses the hard drop key
signal dropped # emitted when the piece falls as a result of a soft drop, hard drop, or gravity
signal squish_moved(piece, old_pos)

## emitted for piece locks
signal lock_cancelled
signal lock_started

signal tiles_changed(tile_map)

## the z index the piece manager's tilemap defaults to
const TILE_MAP_DEFAULT_Z_INDEX := 3

## the z index the piece manager's tilemap switches to temporarily when topping out
const TILE_MAP_TOP_OUT_Z_INDEX := 4

export (NodePath) var playfield_path: NodePath
export (NodePath) var piece_queue_path: NodePath

## settings and state for the currently active piece.
var piece: ActivePiece

## information about the piece previously rendered to the tilemap
var drawn_piece_type: PieceType
var drawn_piece_pos: Vector2
var drawn_piece_orientation: int

## TileMap containing the puzzle blocks which make up the active piece
onready var tile_map: PuzzleTileMap = $TileMap
onready var input: PieceInput = $Input

onready var _physics: PiecePhysics = $Physics
onready var _playfield: Playfield = get_node(playfield_path)
onready var _piece_queue: PieceQueue = get_node(piece_queue_path)
onready var _states: PieceStates = $States

func _ready() -> void:
	CurrentLevel.connect("settings_changed", self, "_on_Level_settings_changed")
	PuzzleState.connect("game_prepared", self, "_on_PuzzleState_game_prepared")
	PuzzleState.connect("game_started", self, "_on_PuzzleState_game_started")
	PuzzleState.connect("before_level_changed", self, "_on_PuzzleState_before_level_changed")
	PuzzleState.connect("after_level_changed", self, "_on_PuzzleState_after_level_changed")
	PuzzleState.connect("finish_triggered", self, "_on_PuzzleState_finish_triggered")
	PuzzleState.connect("game_ended", self, "_on_PuzzleState_game_ended")
	Pauser.connect("paused_changed", self, "_on_Pauser_paused_changed")
	
	piece = ActivePiece.new(PieceTypes.piece_null, funcref(tile_map, "is_cell_blocked"))

	PieceSpeeds.current_speed = PieceSpeeds.speed("0")
	_states.set_state(_states.none)
	_clear_piece()
	_prepare_tileset()


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


## Writes the current piece to the _playfield, checking whether it builds any boxes or clears any lines.
##
## Returns true if the newly written piece results in a line clear.
func write_piece_to_playfield() -> void:
	_playfield.write_piece(piece.pos, piece.orientation, piece.type)
	_clear_piece()


## Immobilizes the piece when the player tops out.
##
## When the player tops out but doesn't lose, the playfield deletes some lines to make space. During this time the
## piece enters a state of immobility. This 'enter_top_out_state' function makes the piece temporarily immobile.
func enter_top_out_state() -> void:
	_states.set_state(_states.top_out)
	
	# prevent the piece from spawning until the playfield is ready
	piece.spawn_delay = 999999


## Restores piece mobility after the player finishes topping out.
##
## When the player tops out but doesn't lose, the playfield deletes some lines to make space. During this time the
## piece enters a state of immobility. This 'exit_top_out_state()' function makes the piece mobile again.
func exit_top_out_state() -> void:
	piece.spawn_delay = 0


## Spawns a new piece at the top of the _playfield.
##
## Returns 'true' if the piece was spawned successfully, or 'false' if the player topped out.
func spawn_piece() -> bool:
	var next_piece := _piece_queue.pop_next_piece()
	piece = ActivePiece.new(next_piece.type, funcref(_playfield.tile_map, "is_cell_blocked"))
	piece.orientation = next_piece.orientation
	var success := _physics.initially_move_piece(piece)
	emit_signal("piece_spawned")
	emit_signal("piece_disturbed", piece)
	return success


func initially_move_piece() -> bool:
	var success := _physics.initially_move_piece(piece)
	emit_signal("piece_disturbed", piece)
	return success


func move_piece() -> void:
	var piece_disturbed := _physics.move_piece(piece)
	if piece_disturbed:
		emit_signal("piece_disturbed", piece)


## Records any inputs to a buffer to be replayed later.
func buffer_inputs() -> void:
	input.buffer_inputs()


## Replays any inputs which were pressed while buffering.
func pop_buffered_inputs() -> void:
	input.pop_buffered_inputs()


## Returns a number from [0, 1] for how close the piece is to squishing.
func squish_percent() -> float:
	return _physics.squish_percent(piece)


## Increments the piece's 'lock'. A piece will become locked once its accumulated 'lock' exceeds a certain threshold,
## usually about half a second.
func apply_lock() -> void:
	if not piece.can_move_to(Vector2(piece.pos.x, piece.pos.y + 1), piece.orientation):
		piece.lock += 1
		piece.gravity = 0
	else:
		piece.lock = 0


func is_playfield_clearing_lines() -> bool:
	return _playfield.get_remaining_line_erase_frames() > 0


## Set the state frames so that the piece spawns immediately.
func skip_prespawn() -> void:
	if CurrentLevel.settings.other.non_interactive:
		return
	
	if _states.get_state() != _states.prespawn:
		_states.set_state(_states.prespawn)
	_states.prespawn.frames = 3600


func _prepare_tileset() -> void:
	tile_map.puzzle_tile_set_type = CurrentLevel.settings.other.tile_set


func _clear_piece() -> void:
	piece = ActivePiece.new(PieceTypes.piece_null, funcref(tile_map, "is_cell_blocked"))


## Refresh the tilemap which displays the piece, based on the current piece's position and orientation.
func _update_tile_map() -> void:
	tile_map.clear()
	var pos_arr := piece.get_pos_arr()
	for i in range(pos_arr.size()):
		var block_pos: Vector2 = piece.pos + pos_arr[i]
		var block_color := piece.type.get_cell_color(piece.orientation, i)
		tile_map.set_block(block_pos, 0, block_color)


## Spawns the first piece of a level.
func _start_first_piece() -> void:
	if CurrentLevel.settings.other.non_interactive:
		return
	
	_states.set_state(_states.prespawn)
	skip_prespawn()


func _on_Level_settings_changed() -> void:
	_prepare_tileset()


func _on_States_entered_state(prev_state: State, state: State) -> void:
	# when topping out, the piece temporarily moves in front of other playfield elements
	if state in [_states.top_out, _states.game_ended]:
		tile_map.z_index = TILE_MAP_TOP_OUT_Z_INDEX
	elif prev_state in [_states.top_out, _states.game_ended]:
		tile_map.z_index = TILE_MAP_DEFAULT_Z_INDEX
	
	if state == _states.prelock:
		emit_signal("lock_started")


func _on_PuzzleState_game_prepared() -> void:
	_clear_piece()


func _on_PuzzleState_game_started() -> void:
	_start_first_piece()


## The player finished the level, possibly while they were still moving a piece around. We clear their piece so that
## it's not left floating.
func _on_PuzzleState_finish_triggered() -> void:
	_clear_piece()
	_states.set_state(_states.game_ended)


## The game ended the game, possibly by a top out. We leave the piece in place so that they can see why they topped
## out.
func _on_PuzzleState_game_ended() -> void:
	_states.set_state(_states.game_ended)


func _on_PuzzleState_before_level_changed(_new_level_id: String) -> void:
	set_physics_process(false)


func _on_PuzzleState_after_level_changed() -> void:
	set_physics_process(true)
	_start_first_piece()


## When the player pauses, we hide the playfield so they can't cheat.
func _on_Pauser_paused_changed(value: bool) -> void:
	visible = not value


## When a line is inserted which intersects with the active piece, we shift it up.
func _on_Playfield_line_inserted(_y: int, _tiles_key: String, _src_y: int) -> void:
	piece.reset_target()
	while piece.target_pos.y > 0 and not piece.can_move_to_target():
		piece.target_pos.y -= 1
	piece.move_to_target()
	
	# regardless of whether the piece shifted, we emit the 'playfield_disturbed'
	# signal so other piece scripts can react to the playfield shifting.
	emit_signal("playfield_disturbed", piece)


func _on_Dropper_hard_dropped() -> void: emit_signal("hard_dropped")
func _on_Dropper_soft_dropped() -> void: emit_signal("soft_dropped")
func _on_Dropper_dropped() -> void: emit_signal("dropped")

func _on_Squisher_lock_cancelled() -> void: emit_signal("lock_cancelled")
func _on_Squisher_squish_moved(squished_piece: ActivePiece, old_pos: Vector2) -> void:
	emit_signal("squish_moved", squished_piece, old_pos)

func _on_Mover_initial_das_moved_left() -> void: emit_signal("initial_das_moved_left")
func _on_Mover_initial_das_moved_right() -> void: emit_signal("initial_das_moved_right")
func _on_Mover_das_moved_left() -> void: emit_signal("das_moved_left")
func _on_Mover_das_moved_right() -> void: emit_signal("das_moved_right")
func _on_Mover_moved_left() -> void: emit_signal("moved_left")
func _on_Mover_moved_right() -> void: emit_signal("moved_right")

func _on_Rotator_rotated_ccw() -> void: emit_signal("rotated_ccw")
func _on_Rotator_rotated_cw() -> void: emit_signal("rotated_cw")
func _on_Rotator_rotated_180() -> void: emit_signal("rotated_180")
func _on_Rotator_initial_rotated_ccw() -> void: emit_signal("initial_rotated_ccw")
func _on_Rotator_initial_rotated_cw() -> void: emit_signal("initial_rotated_cw")
func _on_Rotator_initial_rotated_180() -> void: emit_signal("initial_rotated_180")
