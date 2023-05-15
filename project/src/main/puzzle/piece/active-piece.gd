class_name ActivePiece
## Contains the settings and state for the currently active piece.

const MAX_FLOOR_KICKS := 3

## Current position/orientation. For most pieces, orientation will range from
## [0, 1, 2, 3] for [unrotated, clockwise, flipped, counterclockwise]
var pos := Vector2(3, 3)
var orientation := 0

## Desired position/orientation when the piece is trying to move/rotate.
var target_pos := Vector2(3, 3)
var target_orientation := 0

## Amount of accumulated gravity for this piece. When this number reaches 256, the piece will move down one row
var gravity := 0

## Number of frames until gravity affects this piece again. After the player does a 'squish move' the piece is
## unaffected by gravity for a few frames.
var remaining_post_squish_frames := 0

## Number of frames this piece has been locked into the playfield, or '0' if the piece is not locked
var lock := 0

## Number of 'lock resets' which have been applied to this piece
var lock_resets := 0

## Number of 'floor kicks' which have been applied to this piece
var floor_kicks := 0

## Number of 'hold piece swaps' which have been applied without placing a piece
var hold_piece_swaps := 0

## Number of frames to wait before spawning the piece after this one
var spawn_delay := 0

## Piece shape, color, kick information
var type: PieceType

## Callback function which returns 'true' if a specified cell is obstructed,
## either because it lies outside the playfield or is obstructed by a block
var cell_obstructed_func: FuncRef

## Can be enabled to trace detailed information about piece kicks
var _trace_kicks := false

## Parameters:
## 	'init_type': Piece shape, color, kick information
##
## 	'init_is_cell_obstructed': A callback function which returns 'true' if a specified cell is
## 		obstructed, either because it lies outside the playfield or is obstructed by a block
func _init(init_type: PieceType, init_cell_obstructed_func: FuncRef) -> void:
	type = init_type
	cell_obstructed_func = init_cell_obstructed_func
	
	orientation %= type.pos_arr.size()


## Returns the center position of the piece.
##
## This calculates the center of the smallest rectangle encompassing the piece. It does not care if the piece has more
## cells on one side. If the piece's dimensions are even, this will return a fractional result.
func center() -> Vector2:
	if get_pos_arr().empty():
		return Vector2.ZERO
	var cell_bounds: Rect2 = Rect2(get_pos_arr()[0], Vector2.ZERO)
	for cell_pos in get_pos_arr():
		cell_bounds = cell_bounds.expand(cell_pos)
	return cell_bounds.position + cell_bounds.size / 2.0 + pos


## Returns 'true' if a specified playfield cell is obstructed, either
## because it lies outside the playfield or is obstructed by a block.
func is_cell_obstructed(cell_pos: Vector2) -> bool:
	return cell_obstructed_func.call_func(cell_pos)


func reset_target() -> void:
	target_pos = pos
	target_orientation = orientation


## Returns the orientation the piece will be in if it rotates clockwise.
func get_cw_orientation() -> int:
	return type.get_cw_orientation(orientation)


## Returns the orientation the piece will be in if it rotates counter-clockwise.
func get_ccw_orientation() -> int:
	return type.get_ccw_orientation(orientation)


## Returns the orientation the piece will be in if it rotates 180 degrees.
func get_flip_orientation() -> int:
	return type.get_flip_orientation(orientation)


## Returns the position the piece will be in if it rotates 180 degrees.
func get_flip_position() -> Vector2:
	return pos + type.flips[orientation]


## Returns the position of the piece's used cells, factoring in orientation but not position.
func get_pos_arr() -> Array:
	return type.pos_arr[orientation]


## Returns the desired position of the piece's used cells, factoring in orientation but not position.
func get_target_pos_arr() -> Array:
	return type.pos_arr[target_orientation]


## Returns 'true' if the specified position and location is unobstructed, and the piece could fit there. Returns
## 'false' if parts of this piece would be out of the playfield or obstructed by blocks.
##
## Parameters:
## 	'new_pos': The desired position to move the piece to
##
## 	'new_orientation': The desired orientation to rotate the piece to
func can_move_to(new_pos: Vector2, new_orientation: int) -> bool:
	var valid_target_pos := true
	if type.empty():
		# Return 'false' for an empty piece to avoid an infinite loop
		valid_target_pos = false
	else:
		for block_pos in type.pos_arr[new_orientation]:
			valid_target_pos = valid_target_pos and not is_cell_obstructed(new_pos + block_pos)
	return valid_target_pos


## Returns 'true' if the target position and location is unobstructed, and the piece could fit there. Returns 'false'
## if parts of this piece would be out of the playfield or obstructed by blocks.
func can_move_to_target() -> bool:
	return can_move_to(target_pos, target_orientation)


## Move and orient the piece to its target position and orientation.
func move_to_target() -> void:
	pos = target_pos
	orientation = target_orientation


## Resets the piece's 'lock' value, preventing it from locking for a moment.
func perform_lock_reset() -> void:
	if lock_resets >= PieceSpeeds.MAX_LOCK_RESETS or lock == 0:
		return
	lock = 0
	lock_resets += 1


## Kicks a rotated piece into a nearby empty space.
##
## This does not attempt to preserve the original position/orientation unless explicitly given a kick of (0, 0).
##
## Parameters:
## 	'kicks': A list of positions to try.
func kick_piece(kicks: Array = []) -> void:
	if kicks == []:
		if _trace_kicks: print("%s to %s -> %s" % [type.string, orientation, target_orientation])
		kicks = type.kicks.get(orientation * 10 + target_orientation, [])
	else:
		if _trace_kicks: print("%s to: %s" % [type.string, kicks])
	
	var successful_kick: Vector2
	for kick in kicks:
		if kick.y < 0 and not can_floor_kick():
			if _trace_kicks: print("no: ", kick, " (too many floor kicks)")
			# don't try any kicks after a failed floor kick; otherwise the player's forced to clumsily exhaust all
			# floor kicks to get the piece to kick differently
			break
		if can_move_to(target_pos + kick, target_orientation):
			successful_kick = kick
			target_pos += successful_kick
			if _trace_kicks: print("yes: ", kick)
			break
		else:
			if _trace_kicks: print("no: ", kick)
	if _trace_kicks: print("-")


func can_floor_kick() -> bool:
	return floor_kicks < MAX_FLOOR_KICKS


## Returns 'true' if the piece is obstructed from moving in all four directions.
func is_sealed() -> bool:
	var sealed := true
	var pos_arr := get_pos_arr()
	for dir in [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]:
		var dir_sealed := false
		for cell_pos in pos_arr:
			if is_cell_obstructed(pos + cell_pos + dir):
				dir_sealed = true
				break
		if not dir_sealed:
			sealed = false
			break
	
	return sealed
