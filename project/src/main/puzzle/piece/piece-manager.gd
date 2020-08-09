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

onready var _next_piece_displays: NextPieceDisplays = get_node(next_piece_displays_path)
onready var _playfield: Playfield = get_node(playfield_path)
onready var tile_map: PuzzleTileMap = $TileMap

# settings and state for the currently active piece.
onready var piece := ActivePiece.new(PieceTypes.piece_null, funcref(tile_map, "is_cell_blocked"))

# information about the piece previously rendered to the tile map
var drawn_piece_type: PieceType
var drawn_piece_pos: Vector2
var drawn_piece_orientation: int

func _ready() -> void:
	PuzzleScore.connect("game_prepared", self, "_on_PuzzleScore_game_prepared")
	PuzzleScore.connect("game_started", self, "_on_PuzzleScore_game_started")
	PuzzleScore.connect("finish_triggered", self, "_on_PuzzleScore_finish_triggered")
	PuzzleScore.connect("game_ended", self, "_on_PuzzleScore_game_ended")
	
	PieceSpeeds.current_speed = PieceSpeeds.speed("0")
	$States.set_state($States/None)
	_clear_piece()


func _process(_delta: float) -> void:
	if $SquishFx/SquishMap.squish_seconds_remaining > 0:
		$SquishFx/SquishMap.show()
		$TileMap.hide()
		
		# if the player continues to move the piece, we keep stretching to its new location
		$SquishFx/SquishMap.stretch_to(piece.type.pos_arr[piece.orientation], piece.pos)
	else:
		$SquishFx/SquishMap.hide()
		$TileMap.show()


func _physics_process(_delta: float) -> void:
	$States.update()
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
	return $States.get_state()


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
	$States.set_state($States/TopOut)
	piece.spawn_delay = top_out_frames


"""
Spawns a new piece at the top of the _playfield.

Returns 'true' if the piece was spawned successfully, or 'false' if the player topped out.
"""
func spawn_piece() -> bool:
	var piece_type := _next_piece_displays.pop_next_piece()
	piece = ActivePiece.new(piece_type, funcref(_playfield.tile_map, "is_cell_blocked"))
	
	$Physics/Rotator.apply_initial_rotate_input(piece)
	$Physics/Mover.apply_initial_move_input(piece)
	
	# lose?
	var topped_out: bool = false
	if not piece.can_move_to_target():
		PuzzleScore.top_out()
		topped_out = true
	
	emit_signal("piece_spawned")
	emit_signal("piece_changed", piece)
	if PlayerData.gameplay_settings.ghost_piece:
		$TileMap.set_ghost_shadow_offset($Physics/Dropper.hard_drop_target_pos - piece.pos)
	return not topped_out


"""
Records any inputs to a buffer to be replayed later.
"""
func buffer_inputs() -> void:
	$Input.buffer_inputs()


"""
Replays any inputs which were pressed while buffering.
"""
func pop_buffered_inputs() -> void:
	$Input.pop_buffered_inputs()


"""
Moves the piece based on player input and gravity.

If any move/rotate keys were pressed, this method will move the block accordingly. Gravity will then be applied.

Returns 'true' if the piece was interacted with successfully resulting in a movement change, orientation change, or
	lock reset
"""
func move_piece() -> void:
	var old_piece_pos := piece.pos
	var old_piece_orientation := piece.orientation
	
	if $States.get_state() == $States/MovePiece:
		$Physics/Rotator.apply_rotate_input(piece)
		$Physics/Mover.apply_move_input(piece)
		$Physics/Dropper.apply_hard_drop_input(piece)
	
	$Physics/Squisher.attempt_squish(piece)
	$Physics/Dropper.apply_gravity(piece)
	
	if old_piece_pos != piece.pos or old_piece_orientation != piece.orientation:
		emit_signal("piece_changed", piece)
		if PlayerData.gameplay_settings.ghost_piece:
			$TileMap.set_ghost_shadow_offset($Physics/Dropper.hard_drop_target_pos - piece.pos)
		if piece.lock > 0:
			if $Physics/Dropper.did_hard_drop:
				# hard drop doesn't cause lock reset
				pass
			elif $Physics/Squisher.did_squish_drop:
				# don't reset lock if doing a squish drop
				pass
			else:
				piece.perform_lock_reset()


"""
Returns a number from [0, 1] for how close the piece is to squishing.
"""
func squish_percent() -> float:
	if $States.get_state() != $States/MovePiece:
		return 0.0
	
	return $Physics/Squisher.squish_percent(piece)


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


func _clear_piece() -> void:
	piece = ActivePiece.new(PieceTypes.piece_null, funcref(tile_map, "is_cell_blocked"))


"""
Refresh the tile map which displays the piece, based on the current piece's position and orientation.
"""
func _update_tile_map() -> void:
	$TileMap.clear()
	for i in range(piece.type.pos_arr[piece.orientation].size()):
		var block_pos := piece.type.get_cell_position(piece.orientation, i)
		var block_color := piece.type.get_cell_color(piece.orientation, i)
		$TileMap.set_block(piece.pos + block_pos, 0, block_color)


func _on_States_entered_state(state: State) -> void:
	if state == $States/Prelock:
		emit_signal("lock_started")


func _on_PuzzleScore_game_prepared() -> void:
	_clear_piece()


func _on_PuzzleScore_game_started() -> void:
	$States.set_state($States/Prespawn)
	# Set the state frames so that the piece spawns immediately
	$States/Prespawn.frames = 3600


"""
The player finished the level, possibly while they were still moving a piece around. We clear their piece so that it's
not left floating.
"""
func _on_PuzzleScore_finish_triggered() -> void:
	_clear_piece()
	$States.set_state($States/GameEnded)


"""
The game ended the game, possibly by a top out. We leave the piece in place so that they can see why they topped out.
"""
func _on_PuzzleScore_game_ended() -> void:
	$States.set_state($States/GameEnded)


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
