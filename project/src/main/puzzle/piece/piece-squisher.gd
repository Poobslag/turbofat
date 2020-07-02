class_name PieceSquisher
extends Node
"""
Handles squish moves for the player's active piece.
"""

signal lock_cancelled
signal squish_moved(piece, old_pos)

# state of the current squish move
enum SquishState {
	UNKNOWN, # unknown; we haven't checked yet
	INVALID, # invalid; there's no empty space beneath the piece
	VALID, # valid; there's empty space beneath the piece
}

const UNKNOWN = SquishState.UNKNOWN
const INVALID = SquishState.INVALID
const VALID = SquishState.VALID

export (NodePath) var input_path: NodePath

# potential source/target for the current squish move
var squish_state: int = SquishState.UNKNOWN
var _squish_target_pos: Vector2

onready var input: PieceInput = get_node(input_path)

func attempt_squish(piece: ActivePiece) -> void:
	if not input.is_soft_drop_pressed() \
			or piece.can_move_to(Vector2(piece.pos.x, piece.pos.y + 1), piece.orientation):
		return
	
	if squish_state == SquishState.UNKNOWN:
		piece.reset_target()
		_calc_squish_target(piece)
		squish_state = SquishState.INVALID if _squish_target_pos == piece.pos else SquishState.VALID
	
	if input.is_soft_drop_just_pressed():
		if squish_state == SquishState.VALID:
			_squish_to_target(piece)
		else:
			# Player can tap soft drop to lock cancel if their timing is good. This lets them hard-drop into a
			# horizontal move or squish move to play faster
			piece.perform_lock_reset()
			emit_signal("lock_cancelled")
	else:
		if squish_state == SquishState.VALID:
			if piece.lock >= PieceSpeeds.current_speed.lock_delay:
				_squish_to_target(piece)


"""
Returns a number from [0, 1] for how close the piece is to squishing.
"""
func squish_percent(piece: ActivePiece) -> float:
	var result := 0.0
	if input.is_soft_drop_pressed() and squish_state == VALID:
		result = clamp(piece.lock / max(1.0, PieceSpeeds.current_speed.lock_delay), 0.0, 1.0)
	return result


"""
Squishes a piece through other blocks towards the target.
"""
func _squish_to_target(piece: ActivePiece) -> void:
	piece.target_pos = _squish_target_pos
	var old_pos := piece.pos
	piece.move_to_target()
	piece.gravity = 0
	emit_signal("squish_moved", piece, old_pos)


"""
Calculates the position a piece can 'squish' to. This squish will be successful if there's a location below the
piece's current location where the piece can fit, and if at least one of the piece's blocks remains unobstructed
along its path to the target location.

If a squish is possible, the piece.target_pos field will be updated. If unsuccessful, the field will retain its
original value.
"""
func _calc_squish_target(piece: ActivePiece) -> void:
	var unblocked_blocks := []
	for _i in range(piece.type.pos_arr[piece.target_orientation].size()):
		unblocked_blocks.append(true)
	
	var valid_target_pos := false
	while not valid_target_pos and piece.target_pos.y < PuzzleTileMap.ROW_COUNT:
		piece.target_pos.y += 1
		valid_target_pos = true
		for i in range(piece.type.pos_arr[piece.target_orientation].size()):
			var target_block_pos := piece.type.get_cell_position(piece.target_orientation, i) + piece.target_pos
			var valid_block_pos := not piece.is_cell_blocked(Vector2(target_block_pos.x, target_block_pos.y))
			valid_target_pos = valid_target_pos and valid_block_pos
			unblocked_blocks[i] = unblocked_blocks[i] and valid_block_pos
			
	# for the squish to succeed, at least one block needs to have been
	# unblocked the entire way down, and the target needs to be valid
	var any_unblocked_blocks := false
	for unblocked_block in unblocked_blocks:
		if unblocked_block:
			any_unblocked_blocks = true
	if not valid_target_pos or not any_unblocked_blocks:
		piece.reset_target()
	_squish_target_pos = piece.target_pos
