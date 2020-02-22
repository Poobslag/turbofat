"""
Contains logic for moving/rotating blocks, handling player input, locking blocks into the grid.
"""
extends Control

# All gravity constants are integers like '16', which actually correspond to fractions like '16/256' which means the
# block takes 16 frames to drop one row. GRAVITY_DENOMINATOR is the denominator of that fraction.
const GRAVITY_DENOMINATOR = 256

# The maximum number of 'lock resets' the player is allotted for a single block. A lock reset occurs when a block is at
# the bottom of the screen but the player moves or rotates it to prevent from locking.
const MAX_LOCK_RESETS = 12

# The gravity constant used when the player soft-drops a block. This drop speed should be slow enough that the player
# can slide blocks into nooks left in vertical stacks.
const DROP_G = 128

"""
Contains the settings and state for the currently active block.
"""
class Block:
	var pos = Vector2(3, 3)
	var rotation = 0
	
	# Amount of accumulated gravity for this block. When this number reaches 256, the block will move down one row
	var gravity = 0
	
	# Number of frames this block has been locked into the grid, or '0' if the block is not locked
	var lock = 0
	
	# Number of 'lock resets' which have been applied to this block
	var lock_resets = 0
	
	# Number of 'floor kicks' which have been applied to this block
	var floor_kicks = 0
	
	# Number of frames to wait before spawning the block after this one
	var spawn_delay = 0
	
	# Block shape, color, kick information
	var type
	
	func setType(new_type):
		type = new_type
		rotation %= type.pos_arr.size()
	
	func _init(block_type):
		setType(block_type)
	
	"""
	Returns the rotational state the block will be in if it rotates clockwise.
	"""
	func cw_rotation(in_rotation = -1):
		if in_rotation == -1:
			in_rotation = rotation
		return (in_rotation + 1) % type.pos_arr.size()
	
	"""
	Returns the rotational state the block will be in if it rotates 180 degrees.
	"""
	func flip_rotation(in_rotation = -1):
		if in_rotation == -1:
			in_rotation = rotation
		return (in_rotation + 2) % type.pos_arr.size()

	"""
	Returns the rotational state the block will be in if it rotates counter-clockwise.
	"""
	func ccw_rotation(in_rotation = -1):
		if in_rotation == -1:
			in_rotation = rotation
		return (in_rotation + 3) % type.pos_arr.size()

# signal emitted when the current block can't be placed in the grid
signal game_over

# information about the current 'speed level', such as how fast blocks drop, how long it takes them to lock into the
# grid, and how long to pause when clearing lines.
var block_speed

# settings and state for the currently active block.
var block

var target_block_pos
var target_block_rotation
var tile_map_dirty = false

var input_left_frames = 0
var input_right_frames = 0
var input_down_frames = 0
var input_hard_drop_frames = 0
var input_cw_frames = 0
var input_ccw_frames = 0
var dead = false

onready var Grid = get_node("../Grid")
onready var NextBlocks = get_node("../NextBlocks")
onready var BlockTypes = preload("res://scenes/BlockTypes.gd").new()
onready var BlockSpeeds = preload("res://scenes/BlockSpeeds.gd").new()

func _ready():
	# ensure the block isn't visible outside the grid
	set_clip_contents(true)
	
	block = Block.new(BlockTypes.block_null)
	block_speed = BlockSpeeds.all_speeds[0]
	update_tile_map()

func clear_block():
	dead = true
	block = Block.new(BlockTypes.block_null)
	tile_map_dirty = true

func start_game():
	dead = false
	block = Block.new(BlockTypes.block_null)
	tile_map_dirty = true
	Grid.clock_running = true

func set_block_speed(new_block_speed):
	block_speed = BlockSpeeds.all_speeds[clamp(new_block_speed, 0, BlockSpeeds.all_speeds.size() - 1)]

func new_block():
	var block_type
	if NextBlocks == null:
		block_type = BlockTypes.all_types[randi() % BlockTypes.all_types.size()]
	else:
		block_type = NextBlocks.pop_block_type()
	block = Block.new(block_type)
	tile_map_dirty = true
	
	# apply initial rotation
	if input_cw_frames > 1 && input_ccw_frames > 1:
		block.rotation = block.flip_rotation(block.rotation)
		$RotateSound.play()
	elif input_cw_frames > 1:
		block.rotation = block.cw_rotation(block.rotation)
		$RotateSound.play()
	elif input_ccw_frames > 1:
		block.rotation = block.ccw_rotation(block.rotation)
		$RotateSound.play()
	
	# apply initial infinite DAS
	var initial_das_dir = 0
	if input_left_frames >= block_speed.delayed_auto_shift_delay:
		initial_das_dir -= 1
	if input_right_frames >= block_speed.delayed_auto_shift_delay:
		initial_das_dir += 1
	
	if initial_das_dir == -1:
		# player is holding left; start block on the left side
		var old_pos = block.pos
		reset_block_target()
		kick_block([Vector2(-4, 0), Vector2(-4, -1), Vector2(-3, 0), Vector2(-3, -1), Vector2(-2, 0), Vector2(-2, -1), Vector2(-1, 0), Vector2(-1, -1)])
		move_block_to_target()
		if old_pos != block.pos:
			$MoveSound.play()
	elif initial_das_dir == 0:
		reset_block_target()
		kick_block([Vector2(0, 0), Vector2(0, -1), Vector2(-1, 0), Vector2(-1, -1), Vector2(1, 0), Vector2(1, -1)])
		move_block_to_target()
	elif initial_das_dir == 1:
		# player is holding right; start block on the right side
		var old_pos = block.pos
		reset_block_target()
		kick_block([Vector2(4, 0), Vector2(4, -1), Vector2(3, 0), Vector2(3, -1), Vector2(2, 0), Vector2(2, -1), Vector2(1, 0), Vector2(1, -1)])
		move_block_to_target()
		if old_pos != block.pos:
			$MoveSound.play()
	
	# lose?
	if !can_move_block_to(block.pos, block.rotation):
		Grid.write_block(block.pos, block.rotation, block.type, block_speed.line_clear_delay, true)
		$GameOverSound.play()
		Grid.clock_running = false
		dead = true
		emit_signal("game_over")

func _physics_process(delta):
	input_left_frames = increment_input_frames(input_left_frames, "ui_left")
	input_right_frames = increment_input_frames(input_right_frames, "ui_right")
	input_down_frames = increment_input_frames(input_down_frames, "ui_down")
	input_hard_drop_frames = increment_input_frames(input_hard_drop_frames, "hard_drop")
	input_cw_frames = increment_input_frames(input_cw_frames, "rotate_cw")
	input_ccw_frames = increment_input_frames(input_ccw_frames, "rotate_ccw")
	
	if dead:
		return
	
	# Pressing a new key overrides das. Otherwise blocks can feel like they get stuck to a wall, if you press left
	# after holding right
	if Input.is_action_just_pressed("ui_left"):
		input_right_frames = 0
	if Input.is_action_just_pressed("ui_right"):
		input_left_frames = 0
	
	if BlockTypes.is_null(block.type):
		# no block; spawn a block?
		if Grid != null && !Grid.ready_for_new_block():
			pass
		elif block.spawn_delay <= 0:
			new_block()
		else:
			block.spawn_delay -= 1
		return;
	
	if Input.is_action_pressed("hard_drop") \
			or Input.is_action_pressed("ui_down") \
			or Input.is_action_pressed("ui_left") \
			or Input.is_action_pressed("ui_right") \
			or Input.is_action_pressed("rotate_cw") \
			or Input.is_action_pressed("rotate_ccw"):
		apply_player_input()
	
	apply_gravity()
	apply_lock()
	
	if block.lock > block_speed.lock_delay:
		$LockSound.play()
		if Grid != null:
			if Grid.write_block(block.pos, block.rotation, block.type, block_speed.line_clear_delay):
				# line was cleared; reduced appearance delay
				block.spawn_delay = block_speed.line_appearance_delay
			else:
				block.spawn_delay = block_speed.appearance_delay
		block.setType(BlockTypes.block_null)
		tile_map_dirty = true
	
	if tile_map_dirty:
		update_tile_map()
		tile_map_dirty = false

func increment_input_frames(frames, action):
	if Input.is_action_pressed(action):
		return frames + 1
	return 0

func apply_player_input():
	if block.lock > block_speed.lock_delay:
		# block is locked; ignore all input
		return
	
	var old_block_pos = block.pos
	var old_block_rotation = block.rotation
	
	reset_block_target()
	
	calc_target_rotation()
	if target_block_rotation != block.rotation && !can_move_block_to(target_block_pos, target_block_rotation):
		kick_block()
	move_block_to_target(true)
	
	calc_target_position()
	if !move_block_to_target(true):
		# automatically trigger DAS if you push against a block. otherwise, blocks might slip past a nook if you're
		# holding a direction before DAS triggers
		if Input.is_action_just_pressed("ui_left"):
			input_left_frames = 3600
		if Input.is_action_just_pressed("ui_right"):
			input_right_frames = 3600
	
	if Input.is_action_just_pressed("hard_drop") or input_hard_drop_frames > block_speed.delayed_auto_shift_delay:
		while(move_block_to_target()):
			target_block_pos.y += 1
		# lock block
		block.lock = block_speed.lock_delay
		block.lock_resets = MAX_LOCK_RESETS
		$DropSound.play()
	
	if old_block_pos != block.pos || old_block_rotation != block.rotation:
		if block.lock > 0 && block.lock_resets < MAX_LOCK_RESETS:
			# lock reset
			block.lock = 0
			block.lock_resets += 1
			if block.lock_resets >= MAX_LOCK_RESETS:
				# last reset has been performed: lock block
				block.lock = block_speed.lock_delay
	
	# if the player moved the block down, don't apply gravity
	if old_block_pos.y < block.pos.y:
		block.gravity = max(block.gravity - GRAVITY_DENOMINATOR, 0)	

"""
Kicks a rotated block into a nearby empty space. This should only be called when rotation has already failed.
"""
func kick_block(kicks = null):
	if kicks == null:
		print(block.type.string," to ",block.rotation," -> ",target_block_rotation)
		if target_block_rotation == block.cw_rotation():
			kicks = block.type.cw_kicks[block.rotation]
		elif target_block_rotation == block.ccw_rotation():
			kicks = block.type.ccw_kicks[target_block_rotation]
		else:
			kicks = []
	else:
		print(block.type.string," to: ",kicks)

	for kick in kicks:
		if kick.y < 0 && block.floor_kicks >= block.type.max_floor_kicks:
			print("no: ", kick, " (too many floor kicks)")
			continue
		if can_move_block_to(target_block_pos + kick, target_block_rotation):
			target_block_pos += kick
			if kick.y < 0:
				block.floor_kicks += 1
			print("yes: ", kick)
			break
		else:
			print("no: ", kick)
	print("-")

func apply_gravity():
	if Input.is_action_pressed("ui_down"):
		# soft drop
		block.gravity += max(DROP_G, block_speed.gravity)
	else:
		block.gravity += block_speed.gravity;
	while (block.gravity >= GRAVITY_DENOMINATOR):
		block.gravity -= GRAVITY_DENOMINATOR
		reset_block_target()
		target_block_pos.y = block.pos.y + 1
		move_block_to_target()

func apply_lock():
	if !can_move_block_to(Vector2(block.pos.x, block.pos.y + 1), block.rotation):
		block.lock += 1
	else:
		block.lock = 0

func can_move_block_to(pos, rotation):
	var valid_target_pos = true
	for cubit_pos in block.type.pos_arr[rotation]:
		var target_cubit_pos = Vector2(pos.x + cubit_pos.x, pos.y + cubit_pos.y)
		valid_target_pos = valid_target_pos && target_cubit_pos.x >= 0 and target_cubit_pos.x < Grid.COL_COUNT
		valid_target_pos = valid_target_pos && target_cubit_pos.y >= 0 and target_cubit_pos.y < Grid.ROW_COUNT
		if Grid != null:
			valid_target_pos = valid_target_pos && Grid.is_cell_empty(target_cubit_pos.x, target_cubit_pos.y)
	return valid_target_pos

func move_block_to_target(play_sfx = false):
	var valid_target_pos = can_move_block_to(target_block_pos, target_block_rotation)
	
	if valid_target_pos:
		if play_sfx:
			if block.rotation != target_block_rotation:
				$RotateSound.play()
			if block.pos != target_block_pos:
				$MoveSound.play()
		block.pos = target_block_pos
		block.rotation = target_block_rotation
		tile_map_dirty = true
	
	reset_block_target()
	return valid_target_pos

func reset_block_target():
	target_block_pos = block.pos
	target_block_rotation = block.rotation

func calc_target_position():
	if Input.is_action_just_pressed("ui_left") or input_left_frames >= block_speed.delayed_auto_shift_delay:
		target_block_pos.x -= 1
	
	if Input.is_action_just_pressed("ui_right") or input_right_frames >= block_speed.delayed_auto_shift_delay:
		target_block_pos.x += 1

func calc_target_rotation():
	if Input.is_action_just_pressed("rotate_cw"):
		target_block_rotation = block.cw_rotation(target_block_rotation)
		
	if Input.is_action_just_pressed("rotate_ccw"):
		target_block_rotation = block.ccw_rotation(target_block_rotation)

func update_tile_map():
	$TileMap.clear()
	for i in range(0, block.type.pos_arr[block.rotation].size()):
		var cubit_pos = block.type.pos_arr[block.rotation][i]
		var cubit_color = block.type.color_arr[block.rotation][i]
		$TileMap.set_cell(block.pos.x + cubit_pos.x, block.pos.y + cubit_pos.y, \
				0, false, false, false, cubit_color)
