extends Control
"""
Contains logic for spawning new pieces, moving/rotating pieces, handling player input, and locking pieces into the
playfield.
"""

# signal emitted when the current piece can't be placed in the playfield
signal game_ended

# information about the current 'speed level', such as how fast pieces drop, how long it takes them to lock into the
# playfield, and how long to pause when clearing lines.
var _piece_speed

# settings and state for the currently active piece.
var _active_piece: ActivePiece

var _target_piece_pos: Vector2
var _target_piece_rotation: int
var _tile_map_dirty := false

var _input_left_frames := 0
var _input_right_frames := 0
var _input_down_frames := 0
var _input_hard_drop_frames := 0
var _input_cw_frames := 0
var _input_ccw_frames := 0

var _gravity_delay_frames := 0

var _piece_state: String
var _state_frames: int

var _row_count: int
var _col_count: int

onready var _playfield = $"../Playfield"
onready var _next_pieces = $"../NextPieces"
onready var _game_over_voices := [$GameOverVoice0, $GameOverVoice1, $GameOverVoice2, $GameOverVoice3, $GameOverVoice4]

func _ready() -> void:
	# ensure the piece isn't visible outside the playfield
	set_piece_speed(PieceSpeeds.beginner_level_0)
	if _playfield:
		_col_count = _playfield.COL_COUNT
		_row_count = _playfield.ROW_COUNT
		_set_piece_state("")
		_active_piece = ActivePiece.new(PieceTypes.piece_null)
	else:
		_col_count = 9
		_row_count = 20
		_set_piece_state("_state_move_piece")
		_spawn_piece()
	_update_tile_map()


func _process(_delta: float) -> void:
	if $StretchMap._stretch_seconds_remaining > 0:
		$StretchMap.show()
		$TileMap.hide()
		
		# if the player continues to move the piece, we keep stretching to its new location
		$StretchMap.stretch_to(_active_piece.type.pos_arr[_active_piece.orientation], _active_piece.pos)
	else:
		$StretchMap.hide()
		$TileMap.show()


func _physics_process(_delta: float) -> void:
	_input_left_frames = _increment_input_frames(_input_left_frames, "ui_left")
	_input_right_frames = _increment_input_frames(_input_right_frames, "ui_right")
	_input_down_frames = _increment_input_frames(_input_down_frames, "soft_drop")
	_input_hard_drop_frames = _increment_input_frames(_input_hard_drop_frames, "hard_drop")
	_input_cw_frames = _increment_input_frames(_input_cw_frames, "rotate_cw")
	_input_ccw_frames = _increment_input_frames(_input_ccw_frames, "rotate_ccw")
	
	# Pressing a new key overrides das. Otherwise pieces can feel like they get stuck to a wall if you press left
	# after holding right
	if Input.is_action_just_pressed("ui_left"):
		_input_right_frames = 0
	if Input.is_action_just_pressed("ui_right"):
		_input_left_frames = 0
	
	if _piece_state != "":
		call(_piece_state)
		_state_frames += 1
	
	if _tile_map_dirty:
		_update_tile_map()
		_tile_map_dirty = false


func clear_piece() -> void:
	_set_piece_state("")
	_active_piece = ActivePiece.new(PieceTypes.piece_null)
	_tile_map_dirty = true


func start_game() -> void:
	_set_piece_state("_state_wait_for_playfield")
	_active_piece = ActivePiece.new(PieceTypes.piece_null)
	_tile_map_dirty = true
	_playfield.clock_running = true


func end_game() -> void:
	if _piece_state == "_state_game_ended":
		return
	_playfield.clock_running = false
	_set_piece_state("_state_game_ended")


func set_piece_speed(new_piece_speed) -> void:
	_piece_speed = new_piece_speed


func _set_piece_state(new_piece_state) -> void:
	_piece_state = new_piece_state
	_state_frames = 0


"""
Spawns a new piece at the top of the playfield. Returns 'true' if the piece spawned successfully, or 'false' if the
piece was blocked and the player loses.
"""
func _spawn_piece() -> void:
	var piece_type
	if _next_pieces == null:
		piece_type = PieceTypes.all_types[randi() % PieceTypes.all_types.size()]
	else:
		piece_type = _next_pieces.pop_piece_type()
	_active_piece = ActivePiece.new(piece_type)
	_tile_map_dirty = true
	
	# apply initial orientation if the button is held
	if _input_cw_frames > 1 or _input_ccw_frames > 1:
		if _input_cw_frames > 1 and _input_ccw_frames > 1:
			_active_piece.orientation = _active_piece.get_flip_orientation(_active_piece.orientation)
			$Rotate0Sound.play()
		elif _input_cw_frames > 1:
			_active_piece.orientation = _active_piece.get_cw_orientation(_active_piece.orientation)
			$Rotate0Sound.play()
		elif _input_ccw_frames > 1:
			_active_piece.orientation = _active_piece.get_ccw_orientation(_active_piece.orientation)
			$Rotate1Sound.play()
		
		# relocate rotated piece to the top of the playfield
		var pos_arr = _active_piece.type.pos_arr[_active_piece.orientation]
		var highest_pos = 3
		for pos in pos_arr:
			if pos.y < highest_pos:
				highest_pos = pos.y
		_active_piece.pos.y -= highest_pos
	
	# apply initial infinite DAS
	var initial_das_dir := 0
	if _input_left_frames >= _piece_speed.delayed_auto_shift_delay:
		initial_das_dir -= 1
	if _input_right_frames >= _piece_speed.delayed_auto_shift_delay:
		initial_das_dir += 1
	
	if initial_das_dir == -1:
		# player is holding left; start piece on the left side
		var old_pos := _active_piece.pos
		_reset_piece_target()
		_kick_piece([Vector2(-4, 0), Vector2(-4, -1), Vector2(-3, 0), Vector2(-3, -1), Vector2(-2, 0), Vector2(-2, -1), Vector2(-1, 0), Vector2(-1, -1)])
		_move_piece_to_target()
		if old_pos != _active_piece.pos:
			$MoveSound.play()
	elif initial_das_dir == 0:
		_reset_piece_target()
		_kick_piece([Vector2(0, 0), Vector2(0, -1), Vector2(-1, 0), Vector2(-1, -1), Vector2(1, 0), Vector2(1, -1)])
		_move_piece_to_target()
	elif initial_das_dir == 1:
		# player is holding right; start piece on the right side
		var old_pos := _active_piece.pos
		_reset_piece_target()
		_kick_piece([Vector2(4, 0), Vector2(4, -1), Vector2(3, 0), Vector2(3, -1), Vector2(2, 0), Vector2(2, -1), Vector2(1, 0), Vector2(1, -1)])
		_move_piece_to_target()
		if old_pos != _active_piece.pos:
			$MoveSound.play()
	
	# lose?
	if not _can_move_active_piece_to(_active_piece.pos, _active_piece.orientation):
		$GameOverSound.play()
		_game_over_voices[randi() % _game_over_voices.size()].play()
		Global.scenario_performance.died = true
		end_game()
		emit_signal("game_ended")


"""
Returns 'true' if the specified position and location is unobstructed, and the active piece could fit there. Returns
'false' if parts of this piece would be out of the playfield or obstructed by blocks.
"""
func _can_move_active_piece_to(pos: Vector2, orientation: int) -> bool:
	return _active_piece.can_move_piece_to(funcref(self, "_is_cell_blocked"), pos, orientation)


"""
Counts the number of frames an input has been held for. If the player is pressing the specified action button, this
increments and returns the new frame count. Otherwise, this returns 0.
"""
func _increment_input_frames(frames: int, action: String) -> int:
	return frames + 1 if Input.is_action_pressed(action) else 0


"""
If any move/rotate keys were pressed, this method will move the block accordingly.
"""
func _apply_player_input() -> void:
	if not Input.is_action_pressed("hard_drop") \
			and not Input.is_action_pressed("soft_drop") \
			and not Input.is_action_pressed("ui_left") \
			and not Input.is_action_pressed("ui_right") \
			and not Input.is_action_pressed("rotate_cw") \
			and not Input.is_action_pressed("rotate_ccw"):
		return
	
	var did_hard_drop := false
	var old_piece_pos := _active_piece.pos
	var old_piece_rotation := _active_piece.orientation
	
	if _piece_state == "_state_move_piece":
		_reset_piece_target()
		_calc_target_rotation()
		if _target_piece_rotation != _active_piece.orientation and not _can_move_active_piece_to(_target_piece_pos, _target_piece_rotation):
			_kick_piece()
		_move_piece_to_target(true)
		
		_calc_target_position()
		_move_piece_to_target(true)
		
		# automatically trigger DAS if you're pushing a piece towards an obstruction. otherwise, pieces might slip
		# past a nook if you're holding a direction before DAS triggers
		if Input.is_action_pressed("ui_left") and not _can_move_active_piece_to(Vector2(_active_piece.pos.x - 1, _active_piece.pos.y), _active_piece.orientation):
			_input_left_frames = 3600
		if Input.is_action_pressed("ui_right") and not _can_move_active_piece_to(Vector2(_active_piece.pos.x + 1, _active_piece.pos.y), _active_piece.orientation):
			_input_right_frames = 3600
		
		if Input.is_action_just_pressed("hard_drop") or _input_hard_drop_frames > _piece_speed.delayed_auto_shift_delay:
			_reset_piece_target()
			while _move_piece_to_target():
				_target_piece_pos.y += 1
			# lock piece
			_active_piece.lock = _piece_speed.lock_delay
			did_hard_drop = true

	if Input.is_action_just_pressed("soft_drop"):
		if not _can_move_active_piece_to(Vector2(_active_piece.pos.x, _active_piece.pos.y + 1), _active_piece.orientation):
			_reset_piece_target()
			_calc_smush_target()
			if _target_piece_pos != _active_piece.pos:
				_smush_to_target()
			else:
				# Player can tap soft drop to reset lock, if their timing is good. This lets them hard-drop into
				# a soft-drop for a fast sliding move
				_perform_lock_reset()
				$MoveSound.play()
				_set_piece_state("_state_move_piece")
	elif Input.is_action_pressed("soft_drop") and _active_piece.lock >= _piece_speed.lock_delay:
		if not _can_move_active_piece_to(Vector2(_active_piece.pos.x, _active_piece.pos.y + 1), _active_piece.orientation):
			_reset_piece_target()
			_calc_smush_target()
			if _target_piece_pos != _active_piece.pos:
				_smush_to_target()
	
	if old_piece_pos != _active_piece.pos or old_piece_rotation != _active_piece.orientation:
		if _active_piece.lock > 0 and not did_hard_drop:
			_perform_lock_reset()


"""
Smushes a piece through other blocks towards the target.
"""
func _smush_to_target() -> void:
	# initialize the stretch animation for long stretches
	if _target_piece_pos.y - _active_piece.pos.y >= 3:
		var unblocked_blocks: Array = _active_piece.type.pos_arr[_target_piece_rotation].duplicate()
		$StretchMap.start_stretch(PieceSpeeds.SMUSH_FRAMES, _active_piece.type.color_arr[_active_piece.orientation][0].y)
		for dy in range(_target_piece_pos.y - _active_piece.pos.y):
			var i := 0
			while i < unblocked_blocks.size():
				var target_block_pos: Vector2 = unblocked_blocks[i] + _active_piece.pos + Vector2(0, dy)
				var valid_block_pos := true
				valid_block_pos = valid_block_pos and target_block_pos.x >= 0 and target_block_pos.x < _col_count
				valid_block_pos = valid_block_pos and target_block_pos.y >= 0 and target_block_pos.y < _row_count
				if _playfield:
					valid_block_pos = valid_block_pos and _playfield.is_cell_empty(target_block_pos.x, target_block_pos.y)
				if not valid_block_pos:
					unblocked_blocks.remove(i)
				else:
					i += 1
			$StretchMap.stretch_to(unblocked_blocks, _active_piece.pos + Vector2(0, dy))
	
	_move_piece_to_target()
	$SmushSound.play()
	_set_piece_state("_state_move_piece")
	_active_piece.gravity = 0
	_gravity_delay_frames = PieceSpeeds.SMUSH_FRAMES


"""
Resets the piece's 'lock' value, preventing it from locking for a moment.
"""
func _perform_lock_reset() -> void:
	if _active_piece.lock_resets >= PieceSpeeds.MAX_LOCK_RESETS or _active_piece.lock == 0:
		return
	_active_piece.lock = 0
	_active_piece.lock_resets += 1


"""
Tries to 'smush' a piece past the playfield blocks. This smush will be successful if there's a location below the
piece's current location where the piece can fit, and if at least one of the piece's blocks remains unobstructed
along its path to the target location.

If the 'smush' is successful, the '_target_piece_pos' field will be updated accordingly. If it is unsuccessful, the
'_target_piece_pos' field will retain its original value.
"""
func _calc_smush_target() -> void:
	var unblocked_blocks := []
	for _i in range(_active_piece.type.pos_arr[_target_piece_rotation].size()):
		unblocked_blocks.append(true)
	
	var valid_target_pos := false
	while not valid_target_pos and _target_piece_pos.y < _row_count:
		_target_piece_pos.y += 1
		valid_target_pos = true
		for i in range(_active_piece.type.pos_arr[_target_piece_rotation].size()):
			var target_block_pos: Vector2 = _active_piece.type.pos_arr[_target_piece_rotation][i] + Vector2(_target_piece_pos.x, _target_piece_pos.y)
			var valid_block_pos := true
			valid_block_pos = valid_block_pos and target_block_pos.x >= 0 and target_block_pos.x < _col_count
			valid_block_pos = valid_block_pos and target_block_pos.y >= 0 and target_block_pos.y < _row_count
			if _playfield:
				valid_block_pos = valid_block_pos and _playfield.is_cell_empty(target_block_pos.x, target_block_pos.y)
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


"""
Kicks a rotated piece into a nearby empty space.

This does not attempt to preserve the original position/rotation unless explicitly given a kick of (0, 0).
"""
func _kick_piece(kicks: Array = []) -> void:
	var successful_kick := _active_piece.kick_piece(funcref(self, "_is_cell_blocked"), _target_piece_pos, \
			_target_piece_rotation, kicks)
	
	if successful_kick:
		_target_piece_pos += successful_kick
		if successful_kick.y < 0:
			_active_piece.floor_kicks += 1


"""
Increments the piece's 'gravity'. A piece will fall once its accumulated 'gravity' exceeds a certain threshold.
"""
func _apply_gravity() -> void:
	if _gravity_delay_frames > 0:
		_gravity_delay_frames -= 1
	else:
		if Input.is_action_pressed("soft_drop"):
			# soft drop
			_active_piece.gravity += int(max(PieceSpeeds.DROP_G, _piece_speed.gravity))
		else:
			_active_piece.gravity += _piece_speed.gravity
		
		while _active_piece.gravity >= PieceSpeeds.G:
			_active_piece.gravity -= PieceSpeeds.G
			_reset_piece_target()
			_target_piece_pos.y = _active_piece.pos.y + 1
			_move_piece_to_target()


"""
Increments the piece's 'lock'. A piece will become locked once its accumulated 'lock' exceeds a certain threshold,
usually about half a second.
"""
func _apply_lock() -> void:
	if not _can_move_active_piece_to(Vector2(_active_piece.pos.x, _active_piece.pos.y + 1), _active_piece.orientation):
		_active_piece.lock += 1
		_active_piece.gravity = 0
	else:
		_active_piece.lock = 0


func _is_cell_blocked(pos: Vector2) -> bool:
	var blocked := false
	if pos.x < 0 or pos.x >= _col_count: blocked = true
	if pos.y < 0 or pos.y >= _row_count: blocked = true
	if _playfield and not _playfield.is_cell_empty(pos.x, pos.y): blocked = true
	return blocked


func _move_piece_to_target(play_sfx := false) -> bool:
	var valid_target_pos := _can_move_active_piece_to(_target_piece_pos, _target_piece_rotation)
	
	if valid_target_pos:
		if play_sfx:
			if _active_piece.orientation != _target_piece_rotation:
				if _target_piece_rotation == _active_piece.get_cw_orientation():
					$Rotate0Sound.play()
				else:
					$Rotate1Sound.play()
			if _active_piece.pos != _target_piece_pos:
				$MoveSound.play()
		_active_piece.pos = _target_piece_pos
		_active_piece.orientation = _target_piece_rotation
		_tile_map_dirty = true
	
	_reset_piece_target()
	return valid_target_pos

func _reset_piece_target() -> void:
	_target_piece_pos = _active_piece.pos
	_target_piece_rotation = _active_piece.orientation


"""
Calculates the position the player is trying to move the piece to.
"""
func _calc_target_position() -> void:
	if Input.is_action_just_pressed("ui_left") or _input_left_frames >= _piece_speed.delayed_auto_shift_delay:
		_target_piece_pos.x -= 1
	
	if Input.is_action_just_pressed("ui_right") or _input_right_frames >= _piece_speed.delayed_auto_shift_delay:
		_target_piece_pos.x += 1


"""
Calculates the orientation the player is trying to rotate the piece to.
"""
func _calc_target_rotation() -> void:
	if Input.is_action_just_pressed("rotate_cw"):
		_target_piece_rotation = _active_piece.get_cw_orientation(_target_piece_rotation)
		
	if Input.is_action_just_pressed("rotate_ccw"):
		_target_piece_rotation = _active_piece.get_ccw_orientation(_target_piece_rotation)


"""
Refresh the tilemap which displays the piece, based on the current piece's position and orientation.
"""
func _update_tile_map() -> void:
	$TileMap.clear()
	for i in range(_active_piece.type.pos_arr[_active_piece.orientation].size()):
		var block_pos: Vector2 = _active_piece.type.pos_arr[_active_piece.orientation][i]
		var block_color: Vector2 = _active_piece.type.color_arr[_active_piece.orientation][i]
		$TileMap.set_cell(_active_piece.pos.x + block_pos.x, _active_piece.pos.y + block_pos.y, \
				0, false, false, false, block_color)
	$TileMap/CornerMap.dirty = true


"""
State #1: Block is about to spawn.
"""
func _state_prespawn() -> void:
	if _state_frames >= _active_piece.spawn_delay:
		_spawn_piece()
		if _piece_state != "_state_prespawn":
			# player may have just died; preserve state if we're not still in prespawn state
			pass
		else:
			_set_piece_state("_state_move_piece")
			
			# apply an immediate frame of player movement and gravity to prevent piece from flickering at the top of the
			# screen at 20G or when hard dropped
			_state_move_piece()


"""
State #2: The block has spawned, and the player is moving it around the playfield.
"""
func _state_move_piece() -> void:
	_apply_player_input()
	_apply_gravity()
	_apply_lock()
	
	if _active_piece.lock > _piece_speed.lock_delay and _piece_state == "_state_move_piece":
		$LockSound.play()
		_set_piece_state("_state_prelock")


"""
State #3: The block has locked in position at the bottom of the playfield. The player can still press 'down' to unlock
it, or squeeze it past other blocks.
"""
func _state_prelock() -> void:
	_apply_player_input()
	
	if _state_frames >= _piece_speed.post_lock_delay:
		if _playfield:
			if _playfield.write_piece(_active_piece.pos, _active_piece.orientation, _active_piece.type, _piece_speed.line_clear_delay):
				# line was cleared; different appearance delay
				_active_piece.spawn_delay = _piece_speed.line_appearance_delay
			else:
				_active_piece.spawn_delay = _piece_speed.appearance_delay
		_active_piece.setType(PieceTypes.piece_null)
		_tile_map_dirty = true
		
		# make sure we're still in the postlock state before switching. writing a piece to the playfield can end the game,
		# and we don't want to come back to life
		if _piece_state == "_state_prelock":
			_set_piece_state("_state_wait_for_playfield")


"""
State #4: The playfield is clearing lines or making blocks. We're waiting for these animations to complete before
spawning a new piece and returning to state #1.
"""
func _state_wait_for_playfield() -> void:
	if _playfield == null or _playfield.ready_for_new_piece():
		_set_piece_state("_state_prespawn")


"""
State: The game has ended, no pieces are being managed.
"""
func _state_game_ended() -> void:
	pass
