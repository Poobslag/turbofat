extends Node
## Handles horizontal movement for the player's active piece.

## Number of frames of leniency allowed for the two-button "flip" input
##
## We always flip the piece if the player presses both rotate buttons -- but in some cases, rotating the piece will
## kick it out of a nook, so the piece must be flipped without first being rotated. This is the number of frames of
## leniency where we'll bend the rules for the player, moving the piece back to where it was before flipping it.
const FLIP_FRAME_LENIENCY := 7

# warning-ignore:unused_signal
signal initial_rotated_ccw(piece)
# warning-ignore:unused_signal
signal initial_rotated_cw(piece)
# warning-ignore:unused_signal
signal initial_rotated_180(piece)

# warning-ignore:unused_signal
signal rotated_ccw(piece)
# warning-ignore:unused_signal
signal rotated_cw(piece)
# warning-ignore:unused_signal
signal rotated_180(piece)

export (NodePath) var input_path: NodePath

var _prev_rotate_frames := 0
var _prev_rotate_pos := Vector2(3, 3)
var just_flipped := false

onready var input: PieceInput = get_node(input_path)

func apply_initial_rotate_input(piece: ActivePiece) -> String:
	if not input.is_cw_pressed() and not input.is_ccw_pressed():
		return ""
	
	var rotation_signal: String
	
	if CurrentLevel.settings.other.suppress_piece_initial_rotation \
			== OtherRules.SuppressPieceRotation.ROTATION_AND_SIGNALS:
		# suppress signals
		pass
	elif input.is_cw_pressed() and input.is_ccw_pressed():
		input.set_cw_input_as_handled()
		input.set_ccw_input_as_handled()
		rotation_signal = "initial_rotated_180"
	elif input.is_cw_pressed():
		input.set_cw_input_as_handled()
		rotation_signal = "initial_rotated_cw"
	elif input.is_ccw_pressed():
		input.set_ccw_input_as_handled()
		rotation_signal = "initial_rotated_ccw"
	
	if CurrentLevel.settings.other.suppress_piece_initial_rotation \
			== OtherRules.SuppressPieceRotation.ROTATION:
		# suppress rotation
		pass
	else:
		match rotation_signal:
			"initial_rotated_ccw":
				piece.target_orientation = piece.get_ccw_orientation()
			"initial_rotated_cw":
				piece.target_orientation = piece.get_cw_orientation()
			"initial_rotated_180":
				piece.target_orientation = piece.get_flip_orientation()
	
	return rotation_signal


func emit_initial_rotate_signal(rotation_signal: String, piece: ActivePiece) -> void:
	if rotation_signal.empty():
		return
	
	emit_signal(rotation_signal, piece)
	match rotation_signal:
		"initial_rotated_ccw": CurrentLevel.settings.triggers.run_triggers(LevelTrigger.INITIAL_ROTATED_CCW)
		"initial_rotated_cw": CurrentLevel.settings.triggers.run_triggers(LevelTrigger.INITIAL_ROTATED_CW)
		"initial_rotated_180": CurrentLevel.settings.triggers.run_triggers(LevelTrigger.INITIAL_ROTATED_180)


func apply_rotate_input(piece: ActivePiece) -> void:
	if not input.is_cw_pressed() and not input.is_ccw_pressed():
		_prev_rotate_frames = 0
		return
	
	_calc_rotate_target(piece)
	
	if piece.target_orientation != piece.orientation:
		var rotation_signal: String
		if piece.target_orientation == piece.get_cw_orientation():
			rotation_signal = "rotated_cw"
		elif piece.target_orientation == piece.get_ccw_orientation():
			rotation_signal = "rotated_ccw"
		elif piece.target_orientation == piece.get_flip_orientation():
			rotation_signal = "rotated_180"
		
		var old_piece_y := piece.pos.y
		
		if piece.can_move_to_target():
			_nudge_onscreen(piece)
		if not piece.can_move_to_target():
			piece.kick_piece()
		if not piece.can_move_to_target() and input.is_cw_pressed() and input.is_ccw_pressed():
			rotation_signal = "rotated_180"
			piece.target_orientation = piece.get_flip_orientation()
			if not piece.can_move_to_target():
				piece.kick_piece()
		
		if CurrentLevel.settings.other.suppress_piece_rotation in [
				OtherRules.SuppressPieceRotation.ROTATION_AND_SIGNALS,
				OtherRules.SuppressPieceRotation.ROTATION]:
			# don't suppress rotation signals for levels where the current piece does not rotate; otherwise it's
			# unintuitive that rotation triggers occur conditionally based on the state of the current piece
			pass
		elif piece.target_pos.y < piece.pos.y and not piece.can_floor_kick():
			# tried to flip but we don't have any floor kicks for it
			rotation_signal = ""
		elif not piece.can_move_to_target():
			rotation_signal = ""
		
		if rotation_signal:
			match CurrentLevel.settings.other.suppress_piece_rotation:
				OtherRules.SuppressPieceRotation.ROTATION_AND_SIGNALS:
					# 'suppress piece rotation and signals' is enabled; do nothing
					pass
				OtherRules.SuppressPieceRotation.ROTATION:
					# 'suppress piece rotation' is enabled; emit rotation signals but don't rotate
					emit_signal(rotation_signal, piece)
				_:
					# rotate the piece and emit rotation signals
					piece.move_to_target()
					emit_signal(rotation_signal, piece)
		
		if piece.pos.y < old_piece_y:
			piece.floor_kicks += 1
		
		match rotation_signal:
			"rotated_ccw": CurrentLevel.settings.triggers.run_triggers(LevelTrigger.ROTATED_CCW)
			"rotated_cw": CurrentLevel.settings.triggers.run_triggers(LevelTrigger.ROTATED_CW)
			"rotated_180": CurrentLevel.settings.triggers.run_triggers(LevelTrigger.ROTATED_180)


## Gently nudge a piece downward to keep it onscreen.
##
## We do this so that the U piece does not immediately rotate off the top of the playfield.
func _nudge_onscreen(piece: ActivePiece) -> void:
	var old_above_playfield := _is_partially_offscreen(piece, piece.pos, piece.orientation)
	var new_above_playfield := _is_partially_offscreen(piece, piece.pos, piece.target_orientation)
	if new_above_playfield \
			and not old_above_playfield \
			and piece.can_move_to(piece.pos + Vector2.DOWN, piece.target_orientation):
		piece.target_pos += Vector2.DOWN


## Returns 'true' if the piece will be above the playfield in the specified position/orientation.
##
## Parameters:
## 	'piece': The piece whose shape should be evaluated
##
## 	'piece_pos': The position to evaluate
##
## 	'piece_orientation': The orientation to evaluate
##
## Returns:
## 	'true' if the piece will be above the palyfield in the specified position/orientation.
func _is_partially_offscreen(piece: ActivePiece, piece_pos: Vector2, piece_orientation: int) -> bool:
	var result := false
	for pos in piece.type.pos_arr[piece_orientation]:
		if piece_pos.y + pos.y < PuzzleTileMap.FIRST_VISIBLE_ROW:
			result = true
			break
	return result


## Calculates the orientation the player is trying to rotate the piece to.
func _calc_rotate_target(piece: ActivePiece) -> void:
	if not input.is_cw_pressed() and not input.is_ccw_pressed():
		_prev_rotate_frames = 0
		return
	
	piece.reset_target()
	if input.is_cw_just_pressed() and input.is_ccw_just_pressed():
		# flip the piece by rotating it twice
		piece.target_orientation = piece.get_flip_orientation()
		just_flipped = true
	elif input.is_cw_just_pressed():
		if input.is_ccw_pressed():
			# flip the piece by moving it back where it was, and rerotating it
			_restore_prerotate_pos(piece)
			piece.target_orientation = piece.get_ccw_orientation()
			just_flipped = true
		else:
			_prev_rotate_pos = piece.pos
			piece.target_orientation = piece.get_cw_orientation()
			just_flipped = false
	elif input.is_ccw_just_pressed():
		if input.is_cw_pressed():
			# flip the piece by moving it back where it was, and rerotating it
			_restore_prerotate_pos(piece)
			piece.target_orientation = piece.get_cw_orientation()
			just_flipped = true
		else:
			_prev_rotate_pos = piece.pos
			piece.target_orientation = piece.get_ccw_orientation()
			just_flipped = false
	
	_prev_rotate_frames += 1


## Restores a piece to its previous location before flipping the piece.
##
## We always flip the piece if the player presses both rotate buttons -- but in some cases, rotating the piece will
## kick it out of a nook, so the piece must be flipped without first being rotated. This function moves the piece back
## to where it was before the player held the first rotate button.
func _restore_prerotate_pos(piece: ActivePiece) -> void:
	if _prev_rotate_frames > FLIP_FRAME_LENIENCY:
		## too slow; restoring a piece to its old position requires both buttons be pressed around the same time
		pass
	elif _prev_rotate_pos.y < piece.pos.y and not piece.can_floor_kick():
		## out of floor kicks; restoring a piece to a higher position consumes a floor kick to prevent infinispin
		pass
	else:
		piece.target_pos = _prev_rotate_pos
		if _prev_rotate_pos.y < piece.pos.y:
			## restoring a piece to a higher position consumes a floor kick to prevent infinispin
			piece.floor_kicks += 1
