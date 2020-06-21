class_name ActivePiece
"""
Contains the settings and state for the currently active piece.
"""

var pos := Vector2(3, 3)

# The current orientation.
# For most pieces, this will range from [0, 1, 2, 3] for [unrotated, clockwise, flipped, counterclockwise]
var orientation := 0

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
var type: PieceType

# Can be enabled to trace detailed information about piece kicks
var _trace_kicks := false

func _init(piece_type: PieceType) -> void:
	setType(piece_type)


func setType(new_type: PieceType) -> void:
	type = new_type
	orientation %= type.pos_arr.size()


"""
Returns the orientation the piece will be in if it rotates clockwise.
"""
func get_cw_orientation() -> int:
	return wrapi(orientation + 1, 0, type.pos_arr.size())


"""
Returns the orientation the piece will be in if it rotates 180 degrees.
"""
func get_flip_orientation() -> int:
	return wrapi(orientation + 2, 0, type.pos_arr.size())


"""
Returns the position the piece will be in if it rotates 180 degrees.
"""
func get_flip_position() -> Vector2:
	return pos + type.flips[orientation]


"""
Returns the orientation the piece will be in if it rotates counter-clockwise.
"""
func get_ccw_orientation() -> int:
	return wrapi(orientation - 1, 0, type.pos_arr.size())


"""
Returns 'true' if the specified position and location is unobstructed, and the piece could fit there. Returns 'false'
if parts of this piece would be out of the playfield or obstructed by blocks.

Parameters:
	'is_cell_blocked': A callback function which returns 'true' if a specified cell is blocked, either because it lies
		outside the playfield or is obstructed by a block
	
	'pos': The desired position to move the piece to
	
	'orientation': The desired orientation to rotate the piece to
"""
func can_move_piece_to(is_cell_blocked: FuncRef, pos: Vector2, orientation: int) -> bool:
	var valid_target_pos := true
	if type.pos_arr.empty():
		# Return 'false' for an empty piece to avoid an infinite loop
		valid_target_pos = false
	else:
		for block_pos in type.pos_arr[orientation]:
			valid_target_pos = valid_target_pos and not is_cell_blocked.call_func(pos + block_pos)
	return valid_target_pos


"""
Kicks a rotated piece into a nearby empty space. This should only be called when orientation has already failed.

Parameters:
	'is_cell_blocked': A callback function which returns 'true' if a specified cell is blocked, either because it lies
		outside the playfield or is obstructed by a block
	
	'target_pos': The player's desired position for the piece.
	
	'target_orientation': The player's desired orientation for the piece.
	
	'kicks': A list of positions to try.

Returns:
	The new 'kicked' position for the piece, or (0, 0) if the piece could not be kicked.
"""
func kick_piece(is_cell_blocked: FuncRef, target_pos: Vector2, target_orientation: int, kicks: Array = []) -> Vector2:
	if kicks == []:
		if _trace_kicks: print("%s to %s -> %s" % [type.string, orientation, target_orientation])
		if target_orientation == get_cw_orientation():
			kicks = type.cw_kicks[orientation]
		elif target_orientation == get_ccw_orientation():
			kicks = type.ccw_kicks[target_orientation]
		else:
			kicks = []
	else:
		if _trace_kicks: print("%s to: %s" % [type.string, kicks])
	
	var successful_kick: Vector2
	for kick in kicks:
		if kick.y < 0 and not can_floor_kick():
			if _trace_kicks: print("no: ", kick, " (too many floor kicks)")
			continue
		if can_move_piece_to(is_cell_blocked, target_pos + kick, target_orientation):
			successful_kick = kick
			if _trace_kicks: print("yes: ", kick)
			break
		else:
			if _trace_kicks: print("no: ", kick)
	if _trace_kicks: print("-")
	return successful_kick


func can_floor_kick() -> bool:
	return floor_kicks < type.max_floor_kicks
