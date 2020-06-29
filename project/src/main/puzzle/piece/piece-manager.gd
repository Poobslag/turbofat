class_name PieceManager
extends Control
"""
Contains logic for spawning new pieces, moving/rotating pieces, handling player input, and locking pieces into the
playfield.
"""

# emitted when the current piece can't be placed in the playfield
signal topped_out
signal piece_spawned

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

# state of the current squish move
enum SquishState {
	UNKNOWN, # unknown; we haven't checked yet
	INVALID, # invalid; there's no empty space beneath the piece
	VALID, # valid; there's empty space beneath the piece
}

# source/target for the current squish move
var _squish_state: int = SquishState.UNKNOWN
var _squish_target_pos: Vector2

# target for the current movement/rotation
var _target_piece_pos: Vector2
var _target_piece_orientation: int

var _gravity_delay_frames := 0

export (NodePath) var _playfield_path: NodePath
export (NodePath) var _next_piece_displays_path: NodePath

# settings and state for the currently active piece.
var piece := ActivePiece.new(PieceTypes.piece_null)

# 'true' if the tile map's contents needs to be updated based on the currently active piece
var tile_map_dirty := false

# how many times the piece has moved horizontally this frame
var _horizontal_movement_count := 0

onready var _next_piece_displays: NextPieceDisplays = get_node(_next_piece_displays_path)
onready var playfield: Playfield = get_node(_playfield_path)
onready var tile_map: PuzzleTileMap = $TileMap

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
	_horizontal_movement_count = 0
	
	$States.update()
	
	if tile_map_dirty:
		_update_tile_map()
		tile_map_dirty = false
		emit_signal("tiles_changed", $TileMap)


func get_state() -> State:
	return $States.get_state()


func playfield_ready_for_new_piece() -> bool:
	return playfield.ready_for_new_piece()


"""
Writes the current piece to the playfield, checking whether it builds any boxes or clears any lines.

Returns true if the newly written piece results in a line clear.
"""
func write_piece_to_playfield() -> void:
	playfield.write_piece(piece.pos, piece.orientation, piece.type)
	_clear_piece()


"""
Called when the player tops out, but doesn't lose.

Enters a state which waits for the playfield to make room for the current piece.
"""
func enter_top_out_state(top_out_frames: int) -> void:
	$States.set_state($States/TopOut)
	piece.spawn_delay = top_out_frames


"""
Spawns a new piece at the top of the playfield.

Returns 'true' if the piece was spawned successfully, or 'false' if the player topped out.
"""
func spawn_piece() -> bool:
	var piece_type := _next_piece_displays.pop_next_piece()
	piece = ActivePiece.new(piece_type)
	
	tile_map_dirty = true
	_squish_state = SquishState.UNKNOWN
	
	# apply initial orientation if rotate buttons are pressed
	if $InputCw.is_pressed() or $InputCcw.is_pressed():
		if $InputCw.is_pressed() and $InputCcw.is_pressed():
			piece.orientation = piece.get_flip_orientation()
			$InputCw.set_input_as_handled()
			$InputCcw.set_input_as_handled()
			emit_signal("initial_rotated_twice")
		elif $InputCw.is_pressed():
			piece.orientation = piece.get_cw_orientation()
			$InputCw.set_input_as_handled()
			emit_signal("initial_rotated_right")
		elif $InputCcw.is_pressed():
			piece.orientation = piece.get_ccw_orientation()
			$InputCcw.set_input_as_handled()
			emit_signal("initial_rotated_left")
		
		# relocate rotated piece to the top of the playfield
		var pos_arr: Array = piece.type.pos_arr[piece.orientation]
		var highest_pos := 3
		for pos in pos_arr:
			if pos.y < highest_pos:
				highest_pos = pos.y
		piece.pos.y -= highest_pos
	
	# apply initial infinite DAS
	var initial_das_dir := 0
	if $InputLeft.is_das_active():
		$InputLeft.set_input_as_handled()
		initial_das_dir -= 1
	if $InputRight.is_das_active():
		$InputRight.set_input_as_handled()
		initial_das_dir += 1
	
	if initial_das_dir == -1:
		# player is holding left; start piece on the left side
		var old_pos := piece.pos
		_reset_piece_target()
		_kick_piece([Vector2(-4, 0), Vector2(-4, -1), Vector2(-3, 0), Vector2(-3, -1),
				Vector2(-2, 0), Vector2(-2, -1), Vector2(-1, 0), Vector2(-1, -1),
				Vector2(0, 0), Vector2(0, -1), Vector2(1, 0), Vector2(1, -1),
			])
		_move_piece_to_target()
		if old_pos != piece.pos:
			emit_signal("initial_das_moved_left")
	elif initial_das_dir == 0:
		_reset_piece_target()
		_kick_piece([Vector2(0, 0), Vector2(0, -1), Vector2(-1, 0),
				Vector2(-1, -1), Vector2(1, 0), Vector2(1, -1),
			])
		_move_piece_to_target()
	elif initial_das_dir == 1:
		# player is holding right; start piece on the right side
		var old_pos := piece.pos
		_reset_piece_target()
		_kick_piece([Vector2(4, 0), Vector2(4, -1), Vector2(3, 0), Vector2(3, -1),
				Vector2(2, 0), Vector2(2, -1), Vector2(1, 0), Vector2(1, -1),
				Vector2(0, 0), Vector2(0, -1), Vector2(-1, 0), Vector2(-1, -1),
			])
		_move_piece_to_target()
		if old_pos != piece.pos:
			emit_signal("initial_das_moved_right")
	
	# lose?
	var topped_out: bool = false
	if not _can_move_piece_to(piece.pos, piece.orientation):
		emit_signal("topped_out")
		topped_out = true
	
	emit_signal("piece_spawned")
	return not topped_out


"""
Records any inputs to a buffer to be replayed later.
"""
func buffer_inputs() -> void:
	$InputLeft.buffer_input()
	$InputRight.buffer_input()
	$InputCw.buffer_input()
	$InputCcw.buffer_input()
	$InputSoftDrop.buffer_input()
	$InputHardDrop.buffer_input()


"""
Replays any inputs which were pressed while buffering.
"""
func pop_buffered_inputs() -> void:
	$InputLeft.pop_buffered_input()
	$InputRight.pop_buffered_input()
	$InputCw.pop_buffered_input()
	$InputCcw.pop_buffered_input()
	$InputSoftDrop.pop_buffered_input()
	$InputHardDrop.pop_buffered_input()


"""
If any move/rotate keys were pressed, this method will move the block accordingly.

Returns 'true' if the piece was interacted with successfully resulting in a movement change, orientation change, or
	lock reset
"""
func apply_player_input() -> bool:
	var did_hard_drop := false
	var old_piece_pos := piece.pos
	var old_piece_orientation := piece.orientation
	var applied_player_input := false

	if $States.get_state() == $States/MovePiece:
		if $InputCw.is_pressed() or $InputCcw.is_pressed():
			_attempt_rotation()
		
		if $InputLeft.is_pressed() or $InputRight.is_pressed():
			_attempt_horizontal_movement()
		
		# automatically trigger DAS if you're pushing a piece towards an obstruction. otherwise, pieces might slip
		# past a nook if you're holding a direction before DAS triggers
		if $InputLeft.is_pressed() \
				and not _can_move_piece_to(Vector2(piece.pos.x - 1, piece.pos.y), piece.orientation):
			$InputLeft.frames = 3600
		if $InputRight.is_pressed() \
				and not _can_move_piece_to(Vector2(piece.pos.x + 1, piece.pos.y), piece.orientation):
			$InputRight.frames = 3600
		
		if $InputHardDrop.is_just_pressed() or $InputHardDrop.is_das_active():
			_reset_piece_target()
			while _move_piece_to_target():
				_target_piece_pos.y += 1
			# lock piece
			piece.lock = PieceSpeeds.current_speed.lock_delay
			emit_signal("hard_dropped")
			did_hard_drop = true
	
	if $InputSoftDrop.is_pressed() \
			and not _can_move_piece_to(Vector2(piece.pos.x, piece.pos.y + 1), piece.orientation):
		if _squish_state == SquishState.UNKNOWN:
			_reset_piece_target()
			_calc_squish_target()
			_squish_state = SquishState.INVALID if _squish_target_pos == piece.pos else SquishState.VALID
		
		if $InputSoftDrop.is_just_pressed():
			if _squish_state == SquishState.VALID:
				_squish_to_target()
			else:
				# Player can tap soft drop to lock cancel, if their timing is good. This lets them hard-drop into a
				# horizontal move or squish move to play faster
				_perform_lock_reset()
				applied_player_input = true
				emit_signal("lock_cancelled")
		else:
			if _squish_state == SquishState.VALID:
				if piece.lock >= PieceSpeeds.current_speed.lock_delay:
					_squish_to_target()
	
	if old_piece_pos != piece.pos or old_piece_orientation != piece.orientation:
		_squish_state = SquishState.UNKNOWN
		if piece.lock > 0 and not did_hard_drop:
			_perform_lock_reset()
			applied_player_input = true
	return applied_player_input


func squish_percent() -> float:
	var result := 0.0
	if $States.get_state() == $States/MovePiece and $InputSoftDrop.is_pressed() \
			and _squish_state == SquishState.VALID:
		result = clamp(piece.lock / max(1.0, PieceSpeeds.current_speed.lock_delay), 0.0, 1.0)
	return result


func _clear_piece() -> void:
	piece = ActivePiece.new(PieceTypes.piece_null)
	tile_map_dirty = true


"""
Returns 'true' if the specified position and location is unobstructed, and the active piece could fit there. Returns
'false' if parts of this piece would be out of the playfield or obstructed by blocks.
"""
func _can_move_piece_to(pos: Vector2, orientation: int) -> bool:
	return piece.can_move_piece_to(funcref(self, "_is_cell_blocked"), pos, orientation)


"""
Squishes a piece through other blocks towards the target.
"""
func _squish_to_target() -> void:
	_target_piece_pos = _squish_target_pos
	var old_pos := piece.pos
	_move_piece_to_target()
	emit_signal("squish_moved", piece, old_pos)
	piece.gravity = 0
	_gravity_delay_frames = PieceSpeeds.SQUISH_FRAMES


"""
Resets the piece's 'lock' value, preventing it from locking for a moment.
"""
func _perform_lock_reset() -> void:
	if piece.lock_resets >= PieceSpeeds.MAX_LOCK_RESETS or piece.lock == 0:
		return
	piece.lock = 0
	piece.lock_resets += 1


"""
Tries to 'squish' a piece past the playfield blocks. This squish will be successful if there's a location below the
piece's current location where the piece can fit, and if at least one of the piece's blocks remains unobstructed
along its path to the target location.

If the 'squish' is successful, the '_target_piece_pos' field will be updated accordingly. If it is unsuccessful, the
'_target_piece_pos' field will retain its original value.
"""
func _calc_squish_target() -> void:
	var unblocked_blocks := []
	for _i in range(piece.type.pos_arr[_target_piece_orientation].size()):
		unblocked_blocks.append(true)
	
	var valid_target_pos := false
	while not valid_target_pos and _target_piece_pos.y < PuzzleTileMap.ROW_COUNT:
		_target_piece_pos.y += 1
		valid_target_pos = true
		for i in range(piece.type.pos_arr[_target_piece_orientation].size()):
			var target_block_pos := piece.type.get_cell_position(_target_piece_orientation, i) \
					+ _target_piece_pos
			var valid_block_pos := true
			valid_block_pos = valid_block_pos and target_block_pos.x >= 0 \
					and target_block_pos.x < PuzzleTileMap.COL_COUNT
			valid_block_pos = valid_block_pos and target_block_pos.y >= 0 \
					and target_block_pos.y < PuzzleTileMap.ROW_COUNT
			if playfield:
				valid_block_pos = valid_block_pos and playfield.is_cell_empty(target_block_pos.x, target_block_pos.y)
			valid_target_pos = valid_target_pos and valid_block_pos
			unblocked_blocks[i] = unblocked_blocks[i] and valid_block_pos
			
	# for the slide to succeed, at least one block needs to have been unblocked the entire way down, and the
	# target needs to be valid
	var any_unblocked_blocks := false
	for unblocked_block in unblocked_blocks:
		if unblocked_block:
			any_unblocked_blocks = true
	if not valid_target_pos or not any_unblocked_blocks:
		_reset_piece_target()
	_squish_target_pos = _target_piece_pos


"""
Kicks a rotated piece into a nearby empty space.

This does not attempt to preserve the original position/orientation unless explicitly given a kick of (0, 0).
"""
func _kick_piece(kicks: Array = []) -> void:
	var kick_vector := piece.kick_piece(funcref(self, "_is_cell_blocked"), _target_piece_pos,
			_target_piece_orientation, kicks)
	
	if kick_vector:
		_target_piece_pos += kick_vector


"""
Increments the piece's 'gravity'. A piece will fall once its accumulated 'gravity' exceeds a certain threshold.
"""
func apply_gravity() -> void:
	if _gravity_delay_frames > 0:
		_gravity_delay_frames -= 1
	else:
		if $InputSoftDrop.is_pressed():
			# soft drop
			piece.gravity += int(max(PieceSpeeds.DROP_G, PieceSpeeds.current_speed.gravity))
			emit_signal("soft_dropped")
		else:
			piece.gravity += PieceSpeeds.current_speed.gravity
		
		while piece.gravity >= PieceSpeeds.G:
			piece.gravity -= PieceSpeeds.G
			_reset_piece_target()
			_target_piece_pos.y = piece.pos.y + 1
			if not _move_piece_to_target():
				break
			
			_squish_state = SquishState.UNKNOWN
			if _horizontal_movement_count == 0:
				# move piece once per frame to allow pieces to slide into nooks during 20G
				_attempt_horizontal_movement()


"""
Increments the piece's 'lock'. A piece will become locked once its accumulated 'lock' exceeds a certain threshold,
usually about half a second.
"""
func apply_lock() -> void:
	if not _can_move_piece_to(Vector2(piece.pos.x, piece.pos.y + 1), piece.orientation):
		piece.lock += 1
		piece.gravity = 0
	else:
		piece.lock = 0


func is_playfield_clearing_lines() -> bool:
	return playfield.get_remaining_line_erase_frames() > 0


func _is_cell_blocked(pos: Vector2) -> bool:
	var blocked := false
	if pos.x < 0 or pos.x >= PuzzleTileMap.COL_COUNT: blocked = true
	if pos.y < 0 or pos.y >= PuzzleTileMap.ROW_COUNT: blocked = true
	if not playfield.is_cell_empty(pos.x, pos.y): blocked = true
	return blocked


func _move_piece_to_target(play_sfx := false) -> bool:
	var valid_target_pos := _can_move_piece_to(_target_piece_pos, _target_piece_orientation)
	
	if valid_target_pos:
		if play_sfx:
			if piece.orientation != _target_piece_orientation:
				if _target_piece_orientation == piece.get_cw_orientation():
					emit_signal("rotated_right")
				elif _target_piece_orientation == piece.get_ccw_orientation():
					emit_signal("rotated_left")
				elif _target_piece_orientation == piece.get_flip_orientation():
					emit_signal("rotated_twice")
			elif piece.pos != _target_piece_pos:
				if _target_piece_pos.x > piece.pos.x:
					if $InputRight.is_das_active():
						emit_signal("das_moved_right")
					else:
						emit_signal("moved_right")
				elif _target_piece_pos.x < piece.pos.x:
					if $InputLeft.is_das_active():
						emit_signal("das_moved_left")
					else:
						emit_signal("moved_left")
		piece.pos = _target_piece_pos
		piece.orientation = _target_piece_orientation
		tile_map_dirty = true
	
	_reset_piece_target()
	return valid_target_pos


func _reset_piece_target() -> void:
	_target_piece_pos = piece.pos
	_target_piece_orientation = piece.orientation


func _attempt_rotation() -> void:
	_calc_rotate_target()
	if _target_piece_orientation == piece.orientation:
		return
	
	var old_piece_y := piece.pos.y
	if not _can_move_piece_to(_target_piece_pos, _target_piece_orientation):
		_kick_piece()
	
	var rotate_result := _move_piece_to_target(true)
	if not rotate_result and $InputCw.is_pressed() and $InputCcw.is_pressed():
		# flip the piece 180 degrees
		_target_piece_pos = piece.get_flip_position()
		_target_piece_orientation = piece.get_flip_orientation()
		if _target_piece_pos.y < piece.pos.y and not piece.can_floor_kick():
			pass
		else:
			rotate_result = _move_piece_to_target(true)
	
	if piece.pos.y < old_piece_y and rotate_result:
		piece.floor_kicks += 1


func _attempt_horizontal_movement() -> void:
	_reset_piece_target()
	if $InputLeft.is_just_pressed() or $InputLeft.is_das_active():
		_target_piece_pos.x -= 1
	
	if $InputRight.is_just_pressed() or $InputRight.is_das_active():
		_target_piece_pos.x += 1
	
	if _target_piece_pos.x != piece.pos.x and _move_piece_to_target(true):
		_horizontal_movement_count += 1


"""
Calculates the position and orientation the player is trying to rotate the piece to.
"""
func _calc_rotate_target() -> void:
	_target_piece_pos = piece.pos
	if $InputCw.is_just_pressed():
		if $InputCcw.is_pressed():
			# flip the piece by rotating it again in the same direction
			_target_piece_orientation = piece.get_ccw_orientation()
		else:
			_target_piece_orientation = piece.get_cw_orientation()
		
	if $InputCcw.is_just_pressed():
		if $InputCw.is_pressed():
			# flip the piece by rotating it again in the same direction
			_target_piece_orientation = piece.get_cw_orientation()
		else:
			_target_piece_orientation = piece.get_ccw_orientation()


"""
Refresh the tilemap which displays the piece, based on the current piece's position and orientation.
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
	tile_map_dirty = true


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
