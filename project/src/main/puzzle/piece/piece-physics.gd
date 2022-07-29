class_name PiecePhysics
extends Node
## Handles rules for when the piece moves, rotates and locks into the place.
##
## Some of this logic is pushed out into child nodes such as Rotator and Mover. This class only contains reusable code
## and code requiring coordination from different child nodes.

export (NodePath) var piece_states_path: NodePath

onready var rotator := $Rotator
onready var mover := $Mover
onready var dropper := $Dropper
onready var squisher := $Squisher

onready var _states: PieceStates = get_node(piece_states_path)

## Positions a new piece at the top of the _playfield.
##
## Returns 'true' if the piece was spawned successfully, or 'false' if the player topped out.
func initially_move_piece(piece: ActivePiece) -> bool:
	piece.reset_target()
	var rotation_signal: String = rotator.apply_initial_rotate_input(piece)
	
	# relocate piece to the top of the playfield
	var highest_pos := 3
	for pos_arr_item in piece.get_target_pos_arr():
		if pos_arr_item.y < highest_pos:
			highest_pos = pos_arr_item.y
	piece.pos.y -= highest_pos
	
	var movement_signal: String = mover.apply_initial_move_input(piece)
	
	var success := true
	if not piece.can_move_to_target():
		PuzzleState.top_out()
		success = false
	else:
		piece.move_to_target()
		rotator.emit_initial_rotate_signal(piece, rotation_signal)
		mover.emit_initial_move_signal(piece, movement_signal)
	return success


## Moves the piece based on player input and gravity.
##
## If any move/rotate keys were pressed, this method will move the block accordingly. Gravity will then be applied.
##
## Returns 'true' if the piece was interacted with successfully resulting in a movement change, orientation change, or
## lock reset
func move_piece(piece: ActivePiece) -> bool:
	var old_piece_pos := piece.pos
	var old_piece_orientation := piece.orientation
	
	# Squish first to avoid bugs when squishing/rotating/moving in the same frame.
	squisher.attempt_squish(piece)
	if _states.get_state() == _states.move_piece:
		rotator.apply_rotate_input(piece)
		mover.apply_move_input(piece)
		dropper.apply_hard_drop_input(piece)
	dropper.apply_gravity(piece)
	
	var result := false
	if old_piece_pos != piece.pos or old_piece_orientation != piece.orientation:
		result = true
		if piece.lock > 0:
			if dropper.did_hard_drop:
				# hard drop doesn't cause lock reset
				pass
			elif squisher.did_squish_drop:
				# don't reset lock if doing a squish drop
				pass
			else:
				piece.perform_lock_reset()
	
	return result


func squish_percent(piece: ActivePiece) -> float:
	if _states.get_state() != _states.move_piece:
		return 0.0
	
	return squisher.squish_percent(piece)


func hard_drop_target_pos() -> Vector2:
	return dropper.hard_drop_target_pos
