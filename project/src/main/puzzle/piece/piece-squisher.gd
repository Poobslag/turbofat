class_name PieceSquisher
extends Node
## Handles squish moves for the player's active piece.

signal lock_cancelled
signal squish_moved(piece, old_pos)

## state of the current squish move
enum SquishState {
	UNKNOWN, # unknown; we haven't checked yet
	INVALID, # invalid; there's no empty space beneath the piece
	VALID, # valid; there's empty space beneath the piece
}

const UNKNOWN := SquishState.UNKNOWN
const INVALID := SquishState.INVALID
const VALID := SquishState.VALID

export (NodePath) var input_path: NodePath

## 'true' if the player did a squish drop this frame
var did_squish_drop: bool

## potential source/target for the current squish move
var squish_state: int = SquishState.UNKNOWN
var _squish_target_pos: Vector2

onready var input: PieceInput = get_node(input_path)

func _physics_process(_delta: float) -> void:
	did_squish_drop = false


func attempt_squish(piece: ActivePiece) -> void:
	if not input.is_soft_drop_pressed():
		return
	
	if input.is_hard_drop_just_pressed() and not input.is_hard_drop_das_active():
		# calculate squish drop target
		var squish_drop_target := _squish_target(piece)
		while squish_drop_target != piece.pos:
			var prev_squish_drop_target := squish_drop_target
			squish_drop_target = _squish_target(piece, false)
			if squish_drop_target == piece.pos:
				squish_drop_target = prev_squish_drop_target
				break
		
		if squish_drop_target != piece.pos:
			# squish drop
			_squish_to(piece, squish_drop_target)
			did_squish_drop = true
	elif not piece.can_move_to(Vector2(piece.pos.x, piece.pos.y + 1), piece.orientation):
		# calculate and cache squish target
		if squish_state == SquishState.UNKNOWN:
			_squish_target_pos = _squish_target(piece)
			squish_state = SquishState.INVALID if _squish_target_pos == piece.pos else SquishState.VALID
		
		if input.is_soft_drop_just_pressed() and squish_state == SquishState.VALID:
			# fast squish
			_squish_to(piece, _squish_target_pos)
		elif input.is_soft_drop_just_pressed() and squish_state == SquishState.INVALID:
			# lock cancel
			piece.perform_lock_reset()
			emit_signal("lock_cancelled")
		elif squish_state == SquishState.VALID and piece.lock >= PieceSpeeds.current_speed.lock_delay:
			# slow squish
			_squish_to(piece, _squish_target_pos)


## Returns a number from [0, 1] for how close the piece is to squishing.
func squish_percent(piece: ActivePiece) -> float:
	var result := 0.0
	if input.is_soft_drop_pressed() and squish_state == VALID:
		result = clamp(piece.lock / max(1.0, PieceSpeeds.current_speed.lock_delay), 0.0, 1.0)
	return result


## Squishes a piece through other blocks towards the target.
func _squish_to(piece: ActivePiece, target_pos: Vector2) -> void:
	var old_pos := piece.pos
	piece.target_pos = target_pos
	piece.move_to_target()
	piece.gravity = 0
	piece.lock = 0
	emit_signal("squish_moved", piece, old_pos)


## Calculates the position a piece can 'squish' to. This squish will be successful if there's a location below the
## piece's current location where the piece can fit, and if at least one of the piece's blocks remains unobstructed
## along its path to the target location.
##
## If a squish is possible, the piece.target_pos field will be updated. If unsuccessful, the target_pos field will be
## reset to the piece's current position.
##
## Parameters:
## 	'piece': The piece to squish
##
## 	'reset_target': If true, the piece's target will be reset to its current position before starting the squish. If
## 		false, the piece will be squished from its current target.
func _squish_target(piece: ActivePiece, reset_target: bool = true) -> Vector2:
	if reset_target:
		piece.reset_target()
	
	var target_pos_arr := piece.get_target_pos_arr()
	
	var unobstructed_blocks := []
	for pos_arr_item in target_pos_arr:
		unobstructed_blocks.append(true)
	
	var valid_target_pos := false
	while not valid_target_pos and piece.target_pos.y < PuzzleTileMap.ROW_COUNT:
		piece.target_pos.y += 1
		valid_target_pos = true
		for i in range(target_pos_arr.size()):
			var valid_block_pos := not piece.is_cell_obstructed(target_pos_arr[i] + piece.target_pos)
			valid_target_pos = valid_target_pos and valid_block_pos
			unobstructed_blocks[i] = unobstructed_blocks[i] and valid_block_pos
			
	# for the squish to succeed, at least one block needs to have been
	# unobstructed the entire way down, and the target needs to be valid
	var any_unobstructed_blocks := false
	for unobstructed_block in unobstructed_blocks:
		if unobstructed_block:
			any_unobstructed_blocks = true
	if not valid_target_pos or not any_unobstructed_blocks:
		piece.reset_target()
	return piece.target_pos


func _on_PieceManager_piece_disturbed(_piece: ActivePiece) -> void:
	squish_state = UNKNOWN


func _on_PieceManager_playfield_disturbed(_piece: ActivePiece) -> void:
	squish_state = UNKNOWN
