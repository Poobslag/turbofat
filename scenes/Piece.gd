"""
Contains logic for moving/rotating pieces, handling player input, locking pieces into the playfield.
"""
extends Control

# All gravity constants are integers like '16', which actually correspond to fractions like '16/256' which means the
# piece takes 16 frames to drop one row. GRAVITY_DENOMINATOR is the denominator of that fraction.
const GRAVITY_DENOMINATOR = 256

# The maximum number of 'lock resets' the player is allotted for a single piece. A lock reset occurs when a piece is at
# the bottom of the screen but the player moves or rotates it to prevent from locking.
const MAX_LOCK_RESETS = 12

# The gravity constant used when the player soft-drops a piece. This drop speed should be slow enough that the player
# can slide pieces into nooks left in vertical stacks.
const DROP_G = 128

"""
Contains the settings and state for the currently active piece.
"""
class Piece:
	var pos := Vector2(3, 3)
	var rotation := 0
	
	# Amount of accumulated gravity for this piece. When this number reaches 256, the piece will move down one row
	var gravity := 0
	
	# Number of frames this piece has been locked into the playfield, or '0' if the piece is not locked
	var lock := 0
	
	# Number of 'lock resets' which have been applied to this piece
	var lock_resets := 0
	
	# Number of 'floor kicks' which have been applied to this piece
	var floor_kicks := 0
	
	# Number of frames to wait before spawning the piece after this one
	var spawn_delay := 0
	
	# Piece shape, color, kick information
	var type
	
	func setType(new_type) -> void:
		type = new_type
		rotation %= type.pos_arr.size()
	
	func _init(piece_type):
		setType(piece_type)
	
	"""
	Returns the rotational state the piece will be in if it rotates clockwise.
	"""
	func cw_rotation(in_rotation := -1) -> int:
		if in_rotation == -1:
			in_rotation = rotation
		return (in_rotation + 1) % type.pos_arr.size()
	
	"""
	Returns the rotational state the piece will be in if it rotates 180 degrees.
	"""
	func flip_rotation(in_rotation := -1) -> int:
		if in_rotation == -1:
			in_rotation = rotation
		return (in_rotation + 2) % type.pos_arr.size()

	"""
	Returns the rotational state the piece will be in if it rotates counter-clockwise.
	"""
	func ccw_rotation(in_rotation := -1) -> int:
		if in_rotation == -1:
			in_rotation = rotation
		return (in_rotation + 3) % type.pos_arr.size()

# signal emitted when the current piece can't be placed in the playfield
signal game_ended

# information about the current 'speed level', such as how fast pieces drop, how long it takes them to lock into the
# playfield, and how long to pause when clearing lines.
var _piece_speed

# settings and state for the currently active piece.
var _piece: Piece

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

onready var Playfield = get_node("../Playfield")
onready var NextPieces = get_node("../NextPieces")

func _ready() -> void:
	# ensure the piece isn't visible outside the playfield
	set_clip_contents(true)
	set_piece_speed(0)
	if Playfield != null:
		_col_count = Playfield.COL_COUNT
		_row_count = Playfield.ROW_COUNT
		_set_piece_state("")
		_piece = Piece.new(PieceTypes.piece_null)
	else:
		_col_count = 9
		_row_count = 18
		_set_piece_state("_state_move_piece")
		_spawn_piece()
	_update_tile_map()

func _set_piece_state(new_piece_state) -> void:
	_piece_state = new_piece_state
	_state_frames = 0

func clear_piece() -> void:
	_set_piece_state("")
	_piece = Piece.new(PieceTypes.piece_null)
	_tile_map_dirty = true

func start_game() -> void:
	_set_piece_state("_state_wait_for_playfield")
	_piece = Piece.new(PieceTypes.piece_null)
	_tile_map_dirty = true
	Playfield.clock_running = true

func set_piece_speed(new_piece_speed) -> void:
	_piece_speed = PieceSpeeds.all_speeds[clamp(new_piece_speed, 0, PieceSpeeds.all_speeds.size() - 1)]

"""
Spawns a new piece at the top of the playfield. Returns 'true' if the piece spawned successfully, or 'false' if the
piece was blocked and the player loses.
"""
func _spawn_piece() -> bool:
	var piece_type
	if NextPieces == null:
		piece_type = PieceTypes.all_types[randi() % PieceTypes.all_types.size()]
	else:
		piece_type = NextPieces.pop_piece_type()
	_piece = Piece.new(piece_type)
	_tile_map_dirty = true
	
	# apply initial rotation
	if _input_cw_frames > 1 && _input_ccw_frames > 1:
		_piece.rotation = _piece.flip_rotation(_piece.rotation)
		$RotateSound.play()
	elif _input_cw_frames > 1:
		_piece.rotation = _piece.cw_rotation(_piece.rotation)
		$RotateSound.play()
	elif _input_ccw_frames > 1:
		_piece.rotation = _piece.ccw_rotation(_piece.rotation)
		$RotateSound.play()
	
	# apply initial infinite DAS
	var initial_das_dir := 0
	if _input_left_frames >= _piece_speed.delayed_auto_shift_delay:
		initial_das_dir -= 1
	if _input_right_frames >= _piece_speed.delayed_auto_shift_delay:
		initial_das_dir += 1
	
	if initial_das_dir == -1:
		# player is holding left; start piece on the left side
		var old_pos := _piece.pos
		_reset_piece_target()
		_kick_piece([Vector2(-4, 0), Vector2(-4, -1), Vector2(-3, 0), Vector2(-3, -1), Vector2(-2, 0), Vector2(-2, -1), Vector2(-1, 0), Vector2(-1, -1)])
		_move_piece_to_target()
		if old_pos != _piece.pos:
			$MoveSound.play()
	elif initial_das_dir == 0:
		_reset_piece_target()
		_kick_piece([Vector2(0, 0), Vector2(0, -1), Vector2(-1, 0), Vector2(-1, -1), Vector2(1, 0), Vector2(1, -1)])
		_move_piece_to_target()
	elif initial_das_dir == 1:
		# player is holding right; start piece on the right side
		var old_pos := _piece.pos
		_reset_piece_target()
		_kick_piece([Vector2(4, 0), Vector2(4, -1), Vector2(3, 0), Vector2(3, -1), Vector2(2, 0), Vector2(2, -1), Vector2(1, 0), Vector2(1, -1)])
		_move_piece_to_target()
		if old_pos != _piece.pos:
			$MoveSound.play()
	
	# lose?
	if !_can_move_piece_to(_piece.pos, _piece.rotation):
		Playfield.write_piece(_piece.pos, _piece.rotation, _piece.type, _piece_speed.line_clear_delay, true)
		return false
	
	return true

func _physics_process(delta: float) -> void:
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

"""
Counts the number of frames an input has been held for. If the player is pressing the specified action button, this
increments and returns the new frame count. Otherwise, this returns 0.
"""
func _increment_input_frames(frames: int, action: String) -> int:
	if Input.is_action_pressed(action):
		return frames + 1
	return 0

"""
If any movement/rotation keys were pressed, this method will move the block accordingly.
"""
func _apply_player_input() -> void:
	if !Input.is_action_pressed("hard_drop") \
			and !Input.is_action_pressed("soft_drop") \
			and !Input.is_action_pressed("ui_left") \
			and !Input.is_action_pressed("ui_right") \
			and !Input.is_action_pressed("rotate_cw") \
			and !Input.is_action_pressed("rotate_ccw"):
		return
	
	var did_hard_drop := false
	var old_piece_pos := _piece.pos
	var old_piece_rotation := _piece.rotation
	
	if _piece_state == "_state_move_piece":
		_reset_piece_target()
		_calc_target_rotation()
		if _target_piece_rotation != _piece.rotation && !_can_move_piece_to(_target_piece_pos, _target_piece_rotation):
			_kick_piece()
		_move_piece_to_target(true)
		
		_calc_target_position()
		if !_move_piece_to_target(true):
			# automatically trigger DAS if you push against a piece. otherwise, pieces might slip past a nook if you're
			# holding a direction before DAS triggers
			if Input.is_action_just_pressed("ui_left"):
				_input_left_frames = 3600
			if Input.is_action_just_pressed("ui_right"):
				_input_right_frames = 3600
		
		if Input.is_action_just_pressed("hard_drop") or _input_hard_drop_frames > _piece_speed.delayed_auto_shift_delay:
			_reset_piece_target()
			while _move_piece_to_target():
				_target_piece_pos.y += 1
			# lock piece
			_piece.lock = _piece_speed.lock_delay
			$DropSound.play()
			did_hard_drop = true

	if Input.is_action_just_pressed("soft_drop"):
		if !_can_move_piece_to(Vector2(_piece.pos.x, _piece.pos.y + 1), _piece.rotation):
			_reset_piece_target()
			_calc_smush_target()
			if _target_piece_pos != _piece.pos:
				_perform_lock_reset()
				_move_piece_to_target()
				$SmashSound.play()
				_set_piece_state("_state_move_piece")
				_piece.gravity = 0
				_gravity_delay_frames = 4
			else:
				# Player can tap soft drop to reset lock, if their timing is good. This lets them hard-drop into
				# a soft-drop for a fast sliding move
				_perform_lock_reset()
				$MoveSound.play()
				_set_piece_state("_state_move_piece")
	elif Input.is_action_pressed("soft_drop") and _piece.lock == _piece_speed.lock_delay:
		if !_can_move_piece_to(Vector2(_piece.pos.x, _piece.pos.y + 1), _piece.rotation):
			_reset_piece_target()
			_calc_smush_target()
			if _target_piece_pos != _piece.pos:
				_perform_lock_reset()
				_move_piece_to_target()
				$SmashSound.play()
				_set_piece_state("_state_move_piece")
				_piece.gravity = 0
				_gravity_delay_frames = 4
	
	if old_piece_pos != _piece.pos || old_piece_rotation != _piece.rotation:
		if _piece.lock > 0 && !did_hard_drop:
			_perform_lock_reset()

"""
Resets the piece's 'lock' value, preventing it from locking for a moment.
"""
func _perform_lock_reset() -> void:
	if _piece.lock_resets >= MAX_LOCK_RESETS:
		return
	_piece.lock = 0
	_piece.lock_resets += 1

"""
Tries to 'smush' a piece past the playfield blocks. This smush will be successful if there's a location below the
piece's current location where the piece can fit, and if at least one of the piece's blocks remains unobstructed
along its path to the target location.

If the 'smush' is successful, the '_target_piece_pos' field will be updated accordingly. If it is unsuccessful, the
'_target_piece_pos' field will retain its original value.
"""
func _calc_smush_target() -> void:
	var unblocked_blocks := []
	for i in range(0, _piece.type.pos_arr[_target_piece_rotation].size()):
		unblocked_blocks.append(true)
	
	var valid_target_pos := false
	while !valid_target_pos && _target_piece_pos.y < _row_count:
		_target_piece_pos.y += 1
		valid_target_pos = true
		for i in range(0, _piece.type.pos_arr[_target_piece_rotation].size()):
			var block_pos: Vector2 = _piece.type.pos_arr[_target_piece_rotation][i]
			var target_block_pos := Vector2(_target_piece_pos.x + block_pos.x, _target_piece_pos.y + block_pos.y)
			var valid_block_pos := true;
			valid_block_pos = valid_block_pos && target_block_pos.x >= 0 and target_block_pos.x < _col_count
			valid_block_pos = valid_block_pos && target_block_pos.y >= 0 and target_block_pos.y < _row_count
			if Playfield != null:
				valid_block_pos = valid_block_pos && Playfield.is_cell_empty(target_block_pos.x, target_block_pos.y)
			valid_target_pos = valid_target_pos && valid_block_pos
			unblocked_blocks[i] = unblocked_blocks[i] && valid_block_pos
			
	# for the slide to succeed, at least one block needs to have been unblocked the entire way down, and the
	# target needs to be valid
	var any_unblocked_blocks := false
	for unblocked_block in unblocked_blocks:
		if unblocked_block:
			any_unblocked_blocks = true
	if !valid_target_pos || !any_unblocked_blocks:
		_reset_piece_target()

"""
Kicks a rotated piece into a nearby empty space. This should only be called when rotation has already failed.
"""
func _kick_piece(kicks: Array = []) -> void:
	if kicks == []:
		print(_piece.type.string," to ",_piece.rotation," -> ",_target_piece_rotation)
		if _target_piece_rotation == _piece.cw_rotation():
			kicks = _piece.type.cw_kicks[_piece.rotation]
		elif _target_piece_rotation == _piece.ccw_rotation():
			kicks = _piece.type.ccw_kicks[_target_piece_rotation]
		else:
			kicks = []
	else:
		print(_piece.type.string," to: ",kicks)

	for kick in kicks:
		if kick.y < 0 && _piece.floor_kicks >= _piece.type.max_floor_kicks:
			print("no: ", kick, " (too many floor kicks)")
			continue
		if _can_move_piece_to(_target_piece_pos + kick, _target_piece_rotation):
			_target_piece_pos += kick
			if kick.y < 0:
				_piece.floor_kicks += 1
			print("yes: ", kick)
			break
		else:
			print("no: ", kick)
	print("-")

"""
Increments the piece's 'gravity'. A piece will fall once its accumulated 'gravity' exceeds a certain threshold.
"""
func _apply_gravity() -> void:
	if _gravity_delay_frames > 0:
		_gravity_delay_frames -= 1
		return
	
	if Input.is_action_pressed("soft_drop"):
		# soft drop
		_piece.gravity += max(DROP_G, _piece_speed.gravity)
	else:
		_piece.gravity += _piece_speed.gravity;
	while _piece.gravity >= GRAVITY_DENOMINATOR:
		_piece.gravity -= GRAVITY_DENOMINATOR
		_reset_piece_target()
		_target_piece_pos.y = _piece.pos.y + 1
		_move_piece_to_target()

"""
Increments the piece's 'lock'. A piece will become locked once its accumulated 'lock' exceeds a certain threshold,
usually about half a second.
"""
func _apply_lock() -> void:
	if !_can_move_piece_to(Vector2(_piece.pos.x, _piece.pos.y + 1), _piece.rotation):
		_piece.lock += 1
		_piece.gravity = 0
	else:
		_piece.lock = 0

"""
Returns 'true' if the specified position and location is unobstructed. Returns 'false' if it's out of the playfield
bounds or obstructed by blocks.
"""
func _can_move_piece_to(pos: Vector2, rotation: int) -> bool:
	var valid_target_pos := true
	for block_pos in _piece.type.pos_arr[rotation]:
		var target_block_pos := Vector2(pos.x + block_pos.x, pos.y + block_pos.y)
		valid_target_pos = valid_target_pos && target_block_pos.x >= 0 and target_block_pos.x < _col_count
		valid_target_pos = valid_target_pos && target_block_pos.y >= 0 and target_block_pos.y < _row_count
		if Playfield != null:
			valid_target_pos = valid_target_pos && Playfield.is_cell_empty(target_block_pos.x, target_block_pos.y)
	return valid_target_pos

func _move_piece_to_target(play_sfx := false) -> bool:
	var valid_target_pos := _can_move_piece_to(_target_piece_pos, _target_piece_rotation)
	
	if valid_target_pos:
		if play_sfx:
			if _piece.rotation != _target_piece_rotation:
				$RotateSound.play()
			if _piece.pos != _target_piece_pos:
				$MoveSound.play()
		_piece.pos = _target_piece_pos
		_piece.rotation = _target_piece_rotation
		_tile_map_dirty = true
	
	_reset_piece_target()
	return valid_target_pos

func _reset_piece_target() -> void:
	_target_piece_pos = _piece.pos
	_target_piece_rotation = _piece.rotation

"""
Calculates the position the player is trying to move the piece to.
"""
func _calc_target_position() -> void:
	if Input.is_action_just_pressed("ui_left") or _input_left_frames >= _piece_speed.delayed_auto_shift_delay:
		_target_piece_pos.x -= 1
	
	if Input.is_action_just_pressed("ui_right") or _input_right_frames >= _piece_speed.delayed_auto_shift_delay:
		_target_piece_pos.x += 1

"""
Calculates the rotation the player is trying to rotate the piece to.
"""
func _calc_target_rotation() -> void:
	if Input.is_action_just_pressed("rotate_cw"):
		_target_piece_rotation = _piece.cw_rotation(_target_piece_rotation)
		
	if Input.is_action_just_pressed("rotate_ccw"):
		_target_piece_rotation = _piece.ccw_rotation(_target_piece_rotation)

"""
Refresh the tilemap which displays the piece, based on the current piece's position and rotation.
"""
func _update_tile_map() -> void:
	$TileMap.clear()
	for i in range(0, _piece.type.pos_arr[_piece.rotation].size()):
		var block_pos: Vector2 = _piece.type.pos_arr[_piece.rotation][i]
		var block_color: Vector2 = _piece.type.color_arr[_piece.rotation][i]
		$TileMap.set_cell(_piece.pos.x + block_pos.x, _piece.pos.y + block_pos.y, \
				0, false, false, false, block_color)
	$TileMap/CornerMap.dirty = true

"""
State #1: Block is about to spawn.
"""
func _state_prespawn() -> void:
	if _state_frames >= _piece.spawn_delay:
		if !_spawn_piece():
			Playfield.clock_running = false
			$GameOverSound.play()
			_set_piece_state("")
			_piece = Piece.new(PieceTypes.piece_null)
			emit_signal("game_ended")
			return
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
	
	if _piece.lock > _piece_speed.lock_delay and _piece_state == "_state_move_piece":
		$LockSound.play()
		_set_piece_state("_state_prelock")

"""
State #3: The block has locked in position at the bottom of the playfield. The player can still press 'down' to unlock
it, or squeeze it past other blocks.
"""
func _state_prelock() -> void:
	_apply_player_input()
	
	if _state_frames >= _piece_speed.post_lock_delay:
		_set_piece_state("_state_postlock")

"""
State #4: The block is fully locked at the bottom of the playfield, and cannot be controlled.
"""
func _state_postlock() -> void:
	if Playfield != null:
		if Playfield.write_piece(_piece.pos, _piece.rotation, _piece.type, _piece_speed.line_clear_delay):
			# line was cleared; reduced appearance delay
			_piece.spawn_delay = _piece_speed.line_appearance_delay
		else:
			_piece.spawn_delay = _piece_speed.appearance_delay
	_piece.setType(PieceTypes.piece_null)
	_tile_map_dirty = true
	_set_piece_state("_state_wait_for_playfield")

"""
State #5: The playfield is clearing lines or making blocks. We're waiting for these animations to complete before
spawning a new piece.
"""
func _state_wait_for_playfield() -> void:
	if Playfield == null || Playfield.ready_for_new_piece():
		_set_piece_state("_state_prespawn")