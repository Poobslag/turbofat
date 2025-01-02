class_name PieceManager
extends Control
## Contains logic for spawning new pieces, moving/rotating pieces, handling player input, and locking pieces into the
## playfield.

## Emitted when the playfield changes in a way which might move the current piece or alter its behavior. For example,
## inserting a row might bump the piece up, or erasing a row might shift the ghost piece down.
signal playfield_disturbed(piece)

signal piece_spawned(piece)

## emitted when the current piece changes in some way (moved, replaced, reoriented)
signal piece_disturbed(piece)

signal hold_piece_swapped(piece)

## emitted when the player rotates a piece
signal initial_rotated_cw(piece)
signal initial_rotated_ccw(piece)
signal initial_rotated_180(piece)

## emitted when the player moves a piece
signal initial_das_moved_left(piece)
signal initial_das_moved_right(piece)
signal das_moved_left(piece)
signal das_moved_right(piece)
signal moved_left(piece)
signal moved_right(piece)
signal rotated_ccw(piece)
signal rotated_cw(piece)
signal rotated_180(piece)
signal soft_dropped(piece) # emitted when the player presses the soft drop key
signal hard_dropped(piece) # emitted when the player presses the hard drop key
signal dropped(piece) # emitted when the piece falls as a result of a soft drop, hard drop, or gravity
signal squish_moved(piece, old_pos)

## emitted when the player places a sealed-in piece with a spin move
signal finished_spin_move(piece, lines_cleared)

## emitted when the player places a sealed-in piece with a squish move
signal finished_squish_move(piece, lines_cleared)

## emitted for piece locks
signal lock_cancelled(piece)
signal lock_started(piece)

signal tiles_changed(tile_map)

## z index the piece manager's tilemap defaults to
const TILE_MAP_DEFAULT_Z_INDEX := 3

## z index the piece manager's tilemap switches to temporarily when topping out
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
onready var tech_move_detector: TechMoveDetector = $TechMoveDetector

onready var states: PieceStates = $States
onready var physics: PiecePhysics = $Physics
onready var _playfield: Playfield = get_node(playfield_path)
onready var _piece_queue: PieceQueue = get_node(piece_queue_path)

func _ready() -> void:
	CurrentLevel.connect("settings_changed", self, "_on_Level_settings_changed")
	PuzzleState.connect("game_prepared", self, "_on_PuzzleState_game_prepared")
	PuzzleState.connect("game_started", self, "_on_PuzzleState_game_started")
	PuzzleState.connect("before_level_changed", self, "_on_PuzzleState_before_level_changed")
	PuzzleState.connect("after_level_changed", self, "_on_PuzzleState_after_level_changed")
	PuzzleState.connect("finish_triggered", self, "_on_PuzzleState_finish_triggered")
	PuzzleState.connect("game_ended", self, "_on_PuzzleState_game_ended")
	PuzzleState.connect("topping_out_changed", self, "_on_PuzzleState_topping_out_changed")
	Pauser.connect("paused_changed", self, "_on_Pauser_paused_changed")
	
	_clear_piece()
	
	PieceSpeeds.current_speed = PieceSpeeds.speed("0")
	_clear_piece()
	states.set_state(states.none)
	_prepare_tileset()


func _physics_process(_delta: float) -> void:
	states.update()
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
	return states.get_state()


## Updates our piece state to a specific state from PieceStates.
##
## PieceManager typically updates its own state, but unusual level gimmicks may need to interrupt it with a custom
## state.
func set_state(new_state: State) -> void:
	states.set_state(new_state)


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
	states.set_state(states.top_out)
	
	# prevent the piece from spawning until the playfield is ready
	piece.spawn_delay = 999999


## Restores piece mobility after the player finishes topping out.
##
## When the player tops out but doesn't lose, the playfield deletes some lines to make space. During this time the
## piece enters a state of immobility. This 'exit_top_out_state()' function makes the piece mobile again.
func exit_top_out_state() -> void:
	piece.spawn_delay = 0


## Spawns a new piece at the top of the playfield.
##
## This is usually from the piece queue, but can also be the player's hold piece if they have the appropriate cheat
## enabled and are holding the swap key.
func spawn_piece() -> void:
	if CurrentLevel.is_hold_piece_cheat_enabled() \
			and input.is_swap_hold_piece_pressed():
		# pop the next piece, which will then be swapped for the hold piece
		PuzzleState.level_performance.pieces += 1
		var next_piece := _piece_queue.pop_next_piece()
		_initialize_piece(next_piece.type, next_piece.orientation)
		swap_hold_piece()
	else:
		_spawn_piece_from_next_queue()


func initially_move_piece() -> bool:
	var success := physics.initially_move_piece(piece)
	emit_signal("piece_disturbed", piece)
	return success


func apply_swap_input() -> void:
	if not input.is_swap_hold_piece_just_pressed():
		return
	
	if CurrentLevel.is_hold_piece_cheat_enabled() and piece.hold_piece_swaps < 1:
		swap_hold_piece()


func swap_hold_piece() -> void:
	var next_piece: NextPiece = _piece_queue.swap_hold_piece(piece.type)
	if next_piece.type == PieceTypes.piece_null:
		# first swap; advance the piece queue
		PuzzleState.level_performance.pieces += 1
		next_piece = _piece_queue.pop_next_piece()
	
	var old_hold_piece_swaps := piece.hold_piece_swaps
	_initialize_piece(next_piece.type, next_piece.orientation)
	piece.hold_piece_swaps = old_hold_piece_swaps + 1
	if piece.type == PieceTypes.piece_null:
		# don't attempt to move/rotate null pieces; just say it spawned successfully. this only comes up during edge
		# cases in levels with limited pieces
		pass
	else:
		physics.initially_move_piece(piece)
	emit_signal("piece_spawned", piece)
	emit_signal("piece_disturbed", piece)
	emit_signal("hold_piece_swapped", piece)
	
	if piece.type == PieceTypes.piece_null:
		PuzzleState.trigger_finish()


func move_piece() -> void:
	var piece_disturbed := physics.move_piece(piece)
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
	return physics.squish_percent(piece)


## Increments the piece's 'lock'. A piece will become locked once its accumulated 'lock' exceeds a certain threshold,
## usually about half a second.
func apply_lock() -> void:
	if not piece.can_move_to(Vector2(piece.pos.x, piece.pos.y + 1), piece.orientation):
		piece.lock += 1
		piece.gravity = 0
	else:
		piece.lock = 0


func is_playfield_clearing_lines() -> bool:
	return _playfield.is_clearing_lines()


## Returns the y coordinate of lines currently being cleared.
func get_playfield_lines_being_cleared() -> Array:
	return _playfield.get_lines_being_cleared()


## Set the state frames so that the piece spawns immediately.
func skip_prespawn() -> void:
	if CurrentLevel.settings.other.non_interactive:
		return
	
	if states.get_state() != states.prespawn:
		states.set_state(states.prespawn)
	states.prespawn.frames = 3600


func finish_spin_move(spin_piece: ActivePiece, lines_cleared: int) -> void:
	emit_signal("finished_spin_move", spin_piece, lines_cleared)


func finish_squish_move(squish_piece: ActivePiece, lines_cleared: int) -> void:
	emit_signal("finished_squish_move", squish_piece, lines_cleared)


func get_squish_fx() -> SquishFx:
	return $SquishFx as SquishFx


func _prepare_tileset() -> void:
	tile_map.puzzle_tile_set_type = CurrentLevel.settings.other.tile_set


func _clear_piece() -> void:
	_initialize_piece(PieceTypes.piece_null)


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
	
	states.set_state(states.prespawn)
	skip_prespawn()


## Shifts the active piece when a line is inserted.
func _shift_piece_for_inserted_line(inserted_line: int) -> void:
	piece.reset_target()
	
	var highest_piece_cell_y := 999
	for i in range(piece.type.pos_arr[piece.orientation].size()):
		var block_pos := piece.type.get_cell_position(piece.orientation, i)
		highest_piece_cell_y = min(highest_piece_cell_y, piece.pos.y + block_pos.y)
	
	if highest_piece_cell_y <= inserted_line and highest_piece_cell_y > 0 and not piece.can_move_to_target():
		piece.target_pos.y -= 1
	piece.move_to_target()


## Shifts the active piece when a line is deleted.
func _shift_piece_for_deleted_lines(deleted_lines: Array) -> void:
	# if the piece is above a deleted line, move it down
	piece.reset_target()
	
	# iterate over the deleted lines from highest to lowest
	deleted_lines = deleted_lines.duplicate()
	deleted_lines.sort()
	deleted_lines.invert()
	
	for deleted_line in deleted_lines:
		var lowest_piece_cell_y := -999
		for i in range(piece.type.pos_arr[piece.orientation].size()):
			var block_pos := piece.type.get_cell_position(piece.orientation, i)
			lowest_piece_cell_y = max(lowest_piece_cell_y, piece.pos.y + block_pos.y)
		
		if lowest_piece_cell_y < deleted_line and lowest_piece_cell_y < PuzzleTileMap.ROW_COUNT:
			piece.target_pos.y += 1
	
	if piece.can_move_to_target():
		piece.move_to_target()
	else:
		# make room for the piece
		for i in range(piece.type.pos_arr[piece.orientation].size()):
			var block_pos := piece.type.get_cell_position(piece.orientation, i)
			tile_map.erase_cell(piece.target_pos + block_pos)
		
		# write the piece to the playfield
		piece.move_to_target()
		write_piece_to_playfield()
		states.set_state(states.wait_for_playfield)
	emit_signal("piece_disturbed", piece)


func _spawn_piece_from_next_queue() -> void:
	PuzzleState.level_performance.pieces += 1
	var next_piece := _piece_queue.pop_next_piece()
	
	# We immediately calculate whether or not we dequeued a null piece. There are edge cases where a piece might become
	# null, such as if a shark eats it during initial movement
	var no_more_pieces := next_piece.type == PieceTypes.piece_null
	
	_initialize_piece(next_piece.type, next_piece.orientation)
	if piece.type == PieceTypes.piece_null:
		# don't attempt to move/rotate null pieces; just say it spawned successfully. this only comes up during edge
		# cases in levels with limited pieces
		pass
	else:
		physics.initially_move_piece(piece)
	emit_signal("piece_spawned", piece)
	emit_signal("piece_disturbed", piece)
	
	if no_more_pieces:
		PuzzleState.trigger_finish()


func _initialize_piece(type: PieceType, orientation: int = 0) -> void:
	piece = ActivePiece.new(type, funcref(_playfield.tile_map, "is_cell_obstructed"))
	piece.orientation = orientation


func _on_Level_settings_changed() -> void:
	_prepare_tileset()


func _on_States_entered_state(prev_state: State, state: State) -> void:
	# when topping out, the piece temporarily moves in front of other playfield elements
	if state in [states.top_out, states.game_ended]:
		tile_map.z_index = TILE_MAP_TOP_OUT_Z_INDEX
	elif prev_state in [states.top_out, states.game_ended]:
		tile_map.z_index = TILE_MAP_DEFAULT_Z_INDEX
	
	if state == states.prelock:
		emit_signal("lock_started", piece)


func _on_PuzzleState_game_prepared() -> void:
	# enable physics_process if it was temporarily disabled
	set_physics_process(true)
	_clear_piece()
	states.set_state(states.none)


func _on_PuzzleState_game_started() -> void:
	_start_first_piece()


## The player finished the level, possibly while they were still moving a piece around. We clear their piece so that
## it's not left floating.
func _on_PuzzleState_finish_triggered() -> void:
	_clear_piece()
	states.set_state(states.game_ended)


## The game ended the game, possibly by a top out. We leave the piece in place so that they can see why they topped
## out.
func _on_PuzzleState_game_ended() -> void:
	states.set_state(states.game_ended)


func _on_PuzzleState_before_level_changed(_new_level_id: String) -> void:
	set_physics_process(false)


func _on_PuzzleState_after_level_changed() -> void:
	set_physics_process(true)
	_start_first_piece()


## When the player pauses, we hide the playfield so they can't cheat.
func _on_Pauser_paused_changed(value: bool) -> void:
	visible = not value


## When a line is inserted which intersects with the active piece, we shift it up.
func _on_Playfield_line_inserted(y: int, _tiles_key: String, _src_y: int) -> void:
	if states.get_state() in [states.move_piece, states.prelock]:
		_shift_piece_for_inserted_line(y)
	
	emit_signal("playfield_disturbed", piece)


func _on_Playfield_after_lines_filled() -> void:
	emit_signal("playfield_disturbed", piece)


func _on_Playfield_line_erased(_y: int, _total_lines: int, _remaining_lines: int, _box_ints: Array) -> void:
	emit_signal("playfield_disturbed", piece)


## When playfield lines are deleted, we shift the piece if the player is currently controlling it.
##
## Most levels only delete lines after the player drops a piece, but unusual levels might delete lines at other times.
func _on_Playfield_after_lines_deleted(deleted_lines: Array) -> void:
	if states.get_state() in [states.move_piece, states.prelock]:
		_shift_piece_for_deleted_lines(deleted_lines)
	
	emit_signal("playfield_disturbed", piece)


func _on_PuzzleState_topping_out_changed(value: bool) -> void:
	if not PuzzleState.game_active:
		return
	
	if value:
		enter_top_out_state()
	else:
		exit_top_out_state()


func _on_Dropper_hard_dropped(dropped_piece: ActivePiece) -> void: emit_signal("hard_dropped", dropped_piece)
func _on_Dropper_soft_dropped(dropped_piece: ActivePiece) -> void: emit_signal("soft_dropped", dropped_piece)
func _on_Dropper_dropped(dropped_piece: ActivePiece) -> void: emit_signal("dropped", dropped_piece)

func _on_Squisher_hard_dropped(dropped_piece: ActivePiece) -> void: emit_signal("hard_dropped", dropped_piece)
func _on_Squisher_lock_cancelled(cancelled_piece: ActivePiece) -> void: emit_signal("lock_cancelled", cancelled_piece)
func _on_Squisher_squish_moved(squished_piece: ActivePiece, old_pos: Vector2) -> void: emit_signal("squish_moved", \
		squished_piece, old_pos)

func _on_Mover_initial_das_moved_left(moved_piece: ActivePiece) -> void: emit_signal("initial_das_moved_left", \
		moved_piece)
func _on_Mover_initial_das_moved_right(moved_piece: ActivePiece) -> void: emit_signal("initial_das_moved_right", \
		moved_piece)
func _on_Mover_das_moved_left(moved_piece: ActivePiece) -> void: emit_signal("das_moved_left", moved_piece)
func _on_Mover_das_moved_right(moved_piece: ActivePiece) -> void: emit_signal("das_moved_right", moved_piece)
func _on_Mover_moved_left(moved_piece: ActivePiece) -> void: emit_signal("moved_left", moved_piece)
func _on_Mover_moved_right(moved_piece: ActivePiece) -> void: emit_signal("moved_right", moved_piece)

func _on_Rotator_rotated_ccw(rotated_piece: ActivePiece) -> void: emit_signal("rotated_ccw", rotated_piece)
func _on_Rotator_rotated_cw(rotated_piece: ActivePiece) -> void: emit_signal("rotated_cw", rotated_piece)
func _on_Rotator_rotated_180(rotated_piece: ActivePiece) -> void: emit_signal("rotated_180", rotated_piece)
func _on_Rotator_initial_rotated_ccw(rotated_piece: ActivePiece) -> void: emit_signal("initial_rotated_ccw", \
		rotated_piece)
func _on_Rotator_initial_rotated_cw(rotated_piece: ActivePiece) -> void: emit_signal("initial_rotated_cw", \
		rotated_piece)
func _on_Rotator_initial_rotated_180(rotated_piece: ActivePiece) -> void: emit_signal("initial_rotated_180", \
		rotated_piece)
