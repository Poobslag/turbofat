class_name PieceManager
extends Control
"""
Contains logic for spawning new pieces, moving/rotating pieces, handling player input, and locking pieces into the
playfield.
"""

# signal emitted when the current piece can't be placed in the playfield
signal piece_spawn_blocked

var _target_piece_pos: Vector2
var _target_piece_orientation: int

var _input_left_frames := 0
var _input_right_frames := 0
var _input_down_frames := 0
var _input_hard_drop_frames := 0
var _input_cw_frames := 0
var _input_ccw_frames := 0

var _gravity_delay_frames := 0

onready var playfield: Playfield = $"../Playfield"
onready var _next_piece_displays: NextPieceDisplays = $"../NextPieceDisplays"
onready var _game_over_voices := [$GameOverVoice0, $GameOverVoice1, $GameOverVoice2, $GameOverVoice3, $GameOverVoice4]

# settings and state for the currently active piece.
var active_piece := ActivePiece.new(PieceTypes.piece_null)

# 'true' if the tile map's contents needs to be updated based on the currently active piece
var tile_map_dirty := false

# how many times the piece has moved horizontally this frame
var _horizontal_movement_count := 0

func _ready() -> void:
	PuzzleScore.connect("game_prepared", self, "_on_PuzzleScore_game_prepared")
	PuzzleScore.connect("game_started", self, "_on_PuzzleScore_game_started")
	PuzzleScore.connect("game_ended", self, "_on_PuzzleScore_game_ended")
	
	PieceSpeeds.current_speed = PieceSpeeds.speed("0")
	$States.set_state($States/None)
	clear_piece()


func get_state() -> State:
	return $States.get_state()


func _process(_delta: float) -> void:
	if $StretchMap._stretch_seconds_remaining > 0:
		$StretchMap.show()
		$TileMap.hide()
		
		# if the player continues to move the piece, we keep stretching to its new location
		$StretchMap.stretch_to(active_piece.type.pos_arr[active_piece.orientation], active_piece.pos)
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
	_horizontal_movement_count = 0
	
	# Pressing a new key overrides das. Otherwise pieces can feel like they get stuck to a wall if you press left
	# after holding right
	if Input.is_action_just_pressed("ui_left"):
		_input_right_frames = 0
	if Input.is_action_just_pressed("ui_right"):
		_input_left_frames = 0
	
	$States.update()
	
	if tile_map_dirty:
		_update_tile_map()
		tile_map_dirty = false


func clear_piece() -> void:
	active_piece = ActivePiece.new(PieceTypes.piece_null)
	tile_map_dirty = true


"""
Writes the current piece to the playfield, checking whether it makes any boxes or clears any lines.

Returns true if the newly written piece results in a line clear.
"""
func write_piece_to_playfield() -> bool:
	var caused_line_clear := playfield.write_piece(active_piece.pos, active_piece.orientation, active_piece.type)
	clear_piece()
	return caused_line_clear


"""
Spawns a new piece at the top of the playfield.
"""
func _spawn_piece() -> void:
	var piece_type := _next_piece_displays.pop_next_piece()
	active_piece = ActivePiece.new(piece_type)
	tile_map_dirty = true
	
	# apply initial orientation if the button is held
	if _input_cw_frames > 1 or _input_ccw_frames > 1:
		if _input_cw_frames > 1 and _input_ccw_frames > 1:
			active_piece.orientation = active_piece.get_flip_orientation(active_piece.orientation)
			$Rotate0Sound.play()
		elif _input_cw_frames > 1:
			active_piece.orientation = active_piece.get_cw_orientation(active_piece.orientation)
			$Rotate0Sound.play()
		elif _input_ccw_frames > 1:
			active_piece.orientation = active_piece.get_ccw_orientation(active_piece.orientation)
			$Rotate1Sound.play()
		
		# relocate rotated piece to the top of the playfield
		var pos_arr: Array = active_piece.type.pos_arr[active_piece.orientation]
		var highest_pos := 3
		for pos in pos_arr:
			if pos.y < highest_pos:
				highest_pos = pos.y
		active_piece.pos.y -= highest_pos
	
	# apply initial infinite DAS
	var initial_das_dir := 0
	if _input_left_frames >= PieceSpeeds.current_speed.delayed_auto_shift_delay:
		initial_das_dir -= 1
	if _input_right_frames >= PieceSpeeds.current_speed.delayed_auto_shift_delay:
		initial_das_dir += 1
	
	if initial_das_dir == -1:
		# player is holding left; start piece on the left side
		var old_pos := active_piece.pos
		_reset_piece_target()
		_kick_piece([Vector2(-4, 0), Vector2(-4, -1), Vector2(-3, 0), Vector2(-3, -1),
				Vector2(-2, 0), Vector2(-2, -1), Vector2(-1, 0), Vector2(-1, -1),
				Vector2(0, 0), Vector2(0, -1), Vector2(1, 0), Vector2(1, -1)])
		_move_piece_to_target()
		if old_pos != active_piece.pos:
			$MoveSound.play()
	elif initial_das_dir == 0:
		_reset_piece_target()
		_kick_piece([Vector2(0, 0), Vector2(0, -1), Vector2(-1, 0), Vector2(-1, -1),
				Vector2(1, 0), Vector2(1, -1)])
		_move_piece_to_target()
	elif initial_das_dir == 1:
		# player is holding right; start piece on the right side
		var old_pos := active_piece.pos
		_reset_piece_target()
		_kick_piece([Vector2(4, 0), Vector2(4, -1), Vector2(3, 0), Vector2(3, -1),
				Vector2(2, 0), Vector2(2, -1), Vector2(1, 0), Vector2(1, -1),
				Vector2(0, 0), Vector2(0, -1), Vector2(-1, 0), Vector2(-1, -1)])
		_move_piece_to_target()
		if old_pos != active_piece.pos:
			$MoveSound.play()
	
	# lose?
	if not _can_move_active_piece_to(active_piece.pos, active_piece.orientation):
		$GameOverSound.play()
		_game_over_voices[randi() % _game_over_voices.size()].play()
		PuzzleScore.scenario_performance.died = true
		emit_signal("piece_spawn_blocked")


"""
Returns 'true' if the specified position and location is unobstructed, and the active piece could fit there. Returns
'false' if parts of this piece would be out of the playfield or obstructed by blocks.
"""
func _can_move_active_piece_to(pos: Vector2, orientation: int) -> bool:
	return active_piece.can_move_piece_to(funcref(self, "_is_cell_blocked"), pos, orientation)


"""
Counts the number of frames an input has been held for. If the player is pressing the specified action button, this
increments and returns the new frame count. Otherwise, this returns 0.
"""
func _increment_input_frames(frames: int, action: String) -> int:
	return frames + 1 if Input.is_action_pressed(action) else 0


"""
If any move/rotate keys were pressed, this method will move the block accordingly.

Returns 'true' if the piece was interacted with successfully resulting in a movement change, orientation change, or
	lock reset
"""
func apply_player_input() -> bool:
	if not Input.is_action_pressed("hard_drop") \
			and not Input.is_action_pressed("soft_drop") \
			and not Input.is_action_pressed("ui_left") \
			and not Input.is_action_pressed("ui_right") \
			and not Input.is_action_pressed("rotate_cw") \
			and not Input.is_action_pressed("rotate_ccw"):
		return false
	
	var did_hard_drop := false
	var old_piece_pos := active_piece.pos
	var old_piece_orientation := active_piece.orientation
	var applied_player_input := false

	if $States.get_state() == $States/MovePiece:
		_reset_piece_target()
		_calc_target_orientation()
		if _target_piece_orientation != active_piece.orientation and not _can_move_active_piece_to(
				_target_piece_pos, _target_piece_orientation):
			_kick_piece()
		_move_piece_to_target(true)
		
		_attempt_horizontal_movement()
		
		# automatically trigger DAS if you're pushing a piece towards an obstruction. otherwise, pieces might slip
		# past a nook if you're holding a direction before DAS triggers
		if Input.is_action_pressed("ui_left") and not _can_move_active_piece_to(
				Vector2(active_piece.pos.x - 1, active_piece.pos.y), active_piece.orientation):
			_input_left_frames = 3600
		if Input.is_action_pressed("ui_right") and not _can_move_active_piece_to(
				Vector2(active_piece.pos.x + 1, active_piece.pos.y), active_piece.orientation):
			_input_right_frames = 3600
		
		if Input.is_action_just_pressed("hard_drop") \
				or _input_hard_drop_frames > PieceSpeeds.current_speed.delayed_auto_shift_delay:
			_reset_piece_target()
			while _move_piece_to_target():
				_target_piece_pos.y += 1
			# lock piece
			active_piece.lock = PieceSpeeds.current_speed.lock_delay
			did_hard_drop = true

	if Input.is_action_just_pressed("soft_drop"):
		if not _can_move_active_piece_to(
				Vector2(active_piece.pos.x, active_piece.pos.y + 1), active_piece.orientation):
			_reset_piece_target()
			_calc_smush_target()
			if _target_piece_pos != active_piece.pos:
				_smush_to_target()
			else:
				# Player can tap soft drop to reset lock, if their timing is good. This lets them hard-drop into
				# a soft-drop for a fast sliding move
				_perform_lock_reset()
				applied_player_input = true
				$MoveSound.play()
	elif Input.is_action_pressed("soft_drop") and active_piece.lock >= PieceSpeeds.current_speed.lock_delay:
		if not _can_move_active_piece_to(
				Vector2(active_piece.pos.x, active_piece.pos.y + 1), active_piece.orientation):
			_reset_piece_target()
			_calc_smush_target()
			if _target_piece_pos != active_piece.pos:
				_smush_to_target()
	
	if old_piece_pos != active_piece.pos or old_piece_orientation != active_piece.orientation:
		if active_piece.lock > 0 and not did_hard_drop:
			_perform_lock_reset()
			applied_player_input = true
	return applied_player_input


"""
Smushes a piece through other blocks towards the target.
"""
func _smush_to_target() -> void:
	# initialize the stretch animation for long stretches
	if _target_piece_pos.y - active_piece.pos.y >= 3:
		var unblocked_blocks: Array = active_piece.type.pos_arr[_target_piece_orientation].duplicate()
		$StretchMap.start_stretch(PieceSpeeds.SMUSH_FRAMES, active_piece.type.color_arr[active_piece.orientation][0].y)
		for dy in range(_target_piece_pos.y - active_piece.pos.y):
			var i := 0
			while i < unblocked_blocks.size():
				var target_block_pos: Vector2 = unblocked_blocks[i] + active_piece.pos + Vector2(0, dy)
				var valid_block_pos := true
				if target_block_pos.x < 0 or target_block_pos.x >= Playfield.COL_COUNT:
					valid_block_pos = false
				elif target_block_pos.y < 0 or target_block_pos.y >= Playfield.ROW_COUNT:
					valid_block_pos = false
				elif not playfield.is_cell_empty(target_block_pos.x, target_block_pos.y):
					valid_block_pos = false
				if not valid_block_pos:
					unblocked_blocks.remove(i)
				else:
					i += 1
			$StretchMap.stretch_to(unblocked_blocks, active_piece.pos + Vector2(0, dy))
	
	_move_piece_to_target()
	$SmushSound.play()
	active_piece.gravity = 0
	_gravity_delay_frames = PieceSpeeds.SMUSH_FRAMES


"""
Resets the piece's 'lock' value, preventing it from locking for a moment.
"""
func _perform_lock_reset() -> void:
	if active_piece.lock_resets >= PieceSpeeds.MAX_LOCK_RESETS or active_piece.lock == 0:
		return
	active_piece.lock = 0
	active_piece.lock_resets += 1


"""
Tries to 'smush' a piece past the playfield blocks. This smush will be successful if there's a location below the
piece's current location where the piece can fit, and if at least one of the piece's blocks remains unobstructed
along its path to the target location.

If the 'smush' is successful, the '_target_piece_pos' field will be updated accordingly. If it is unsuccessful, the
'_target_piece_pos' field will retain its original value.
"""
func _calc_smush_target() -> void:
	var unblocked_blocks := []
	for _i in range(active_piece.type.pos_arr[_target_piece_orientation].size()):
		unblocked_blocks.append(true)
	
	var valid_target_pos := false
	while not valid_target_pos and _target_piece_pos.y < Playfield.ROW_COUNT:
		_target_piece_pos.y += 1
		valid_target_pos = true
		for i in range(active_piece.type.pos_arr[_target_piece_orientation].size()):
			var target_block_pos := active_piece.type.get_cell_position(_target_piece_orientation, i) \
					+ _target_piece_pos
			var valid_block_pos := true
			valid_block_pos = valid_block_pos and target_block_pos.x >= 0 and target_block_pos.x < Playfield.COL_COUNT
			valid_block_pos = valid_block_pos and target_block_pos.y >= 0 and target_block_pos.y < Playfield.ROW_COUNT
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


"""
Kicks a rotated piece into a nearby empty space.

This does not attempt to preserve the original position/orientation unless explicitly given a kick of (0, 0).
"""
func _kick_piece(kicks: Array = []) -> void:
	var successful_kick := active_piece.kick_piece(funcref(self, "_is_cell_blocked"), _target_piece_pos,
			_target_piece_orientation, kicks)
	
	if successful_kick:
		_target_piece_pos += successful_kick
		if successful_kick.y < 0:
			active_piece.floor_kicks += 1


"""
Increments the piece's 'gravity'. A piece will fall once its accumulated 'gravity' exceeds a certain threshold.
"""
func apply_gravity() -> void:
	if _gravity_delay_frames > 0:
		_gravity_delay_frames -= 1
	else:
		if Input.is_action_pressed("soft_drop"):
			# soft drop
			active_piece.gravity += int(max(PieceSpeeds.DROP_G, PieceSpeeds.current_speed.gravity))
		else:
			active_piece.gravity += PieceSpeeds.current_speed.gravity
		
		while active_piece.gravity >= PieceSpeeds.G:
			active_piece.gravity -= PieceSpeeds.G
			_reset_piece_target()
			_target_piece_pos.y = active_piece.pos.y + 1
			if not _move_piece_to_target():
				break
			
			if _horizontal_movement_count == 0:
				# move piece once per frame to allow pieces to slide into nooks during 20G
				_attempt_horizontal_movement()


"""
Increments the piece's 'lock'. A piece will become locked once its accumulated 'lock' exceeds a certain threshold,
usually about half a second.
"""
func apply_lock() -> void:
	if not _can_move_active_piece_to(Vector2(active_piece.pos.x, active_piece.pos.y + 1), active_piece.orientation):
		active_piece.lock += 1
		active_piece.gravity = 0
	else:
		active_piece.lock = 0


func _is_cell_blocked(pos: Vector2) -> bool:
	var blocked := false
	if pos.x < 0 or pos.x >= Playfield.COL_COUNT: blocked = true
	if pos.y < 0 or pos.y >= Playfield.ROW_COUNT: blocked = true
	if not playfield.is_cell_empty(pos.x, pos.y): blocked = true
	return blocked


func _move_piece_to_target(play_sfx := false) -> bool:
	var valid_target_pos := _can_move_active_piece_to(_target_piece_pos, _target_piece_orientation)
	
	if valid_target_pos:
		if play_sfx:
			if active_piece.orientation != _target_piece_orientation:
				if _target_piece_orientation == active_piece.get_cw_orientation():
					$Rotate0Sound.play()
				else:
					$Rotate1Sound.play()
			elif active_piece.pos != _target_piece_pos:
				if $MoveSound.playing:
					# Adjust the pitch/volume of DAS moves so they don't sound as grating and samey
					$MoveSound.pitch_scale = clamp($MoveSound.pitch_scale + 0.08, 0.94, 2.00)
					$MoveSound.volume_db = clamp($MoveSound.volume_db * 0.92, 0.50, 1.00)
				else:
					$MoveSound.pitch_scale = 0.94
					$MoveSound.volume_db = 1.00
				$MoveSound.play()
		active_piece.pos = _target_piece_pos
		active_piece.orientation = _target_piece_orientation
		tile_map_dirty = true
	
	_reset_piece_target()
	return valid_target_pos

func _reset_piece_target() -> void:
	_target_piece_pos = active_piece.pos
	_target_piece_orientation = active_piece.orientation


func _attempt_horizontal_movement() -> void:
	if Input.is_action_just_pressed("ui_left") \
			or _input_left_frames >= PieceSpeeds.current_speed.delayed_auto_shift_delay:
		_target_piece_pos.x -= 1
	
	if Input.is_action_just_pressed("ui_right") \
			or _input_right_frames >= PieceSpeeds.current_speed.delayed_auto_shift_delay:
		_target_piece_pos.x += 1

	if _target_piece_pos.x != active_piece.pos.x and _move_piece_to_target(true):
		_horizontal_movement_count += 1


"""
Calculates the orientation the player is trying to rotate the piece to.
"""
func _calc_target_orientation() -> void:
	if Input.is_action_just_pressed("rotate_cw"):
		_target_piece_orientation = active_piece.get_cw_orientation(_target_piece_orientation)
		
	if Input.is_action_just_pressed("rotate_ccw"):
		_target_piece_orientation = active_piece.get_ccw_orientation(_target_piece_orientation)


"""
Refresh the tilemap which displays the piece, based on the current piece's position and orientation.
"""
func _update_tile_map() -> void:
	$TileMap.clear()
	for i in range(active_piece.type.pos_arr[active_piece.orientation].size()):
		var block_pos := active_piece.type.get_cell_position(active_piece.orientation, i)
		var block_color := active_piece.type.get_cell_color(active_piece.orientation, i)
		$TileMap.set_block(active_piece.pos + block_pos, 0, block_color)


func _on_States_entered_state(state: State) -> void:
	if state == $States/Prelock:
		$LockSound.play()


func _on_PuzzleScore_game_prepared() -> void:
	clear_piece()


func _on_PuzzleScore_game_started() -> void:
	$States.set_state($States/Prespawn)
	# Set the state frames so that the piece spawns immediately
	$States/Prespawn.frames = 3600
	tile_map_dirty = true


func _on_PuzzleScore_game_ended() -> void:
	$States.set_state($States/GameEnded)
