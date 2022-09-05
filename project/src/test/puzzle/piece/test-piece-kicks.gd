extends "res://addons/gut/test.gd"
## Framework for testing piece kicks.

## Unit tests need to distinguish between a piece rotating in place and failing to rotate.
## This should only be used in tests; a piece kicking to -99, -99 could cause a softlock the game.
const FAILED_KICK := Vector2(-99, -99)

var from_grid := []
var to_grid := []

var _from_piece: ActivePiece
var _to_piece: ActivePiece

## A number [0-3] representing the piece's orientation.
##
## For some pieces (such as the O-Block) the orientation is ambiguous but some tests might care which one is selected.
## These fields allow tests to force a specific orientation.
var from_orientation := -1
var to_orientation := -1

func before_each() -> void:
	from_orientation = -1
	to_orientation = -1


## A test which demonstrates the test framework itself is functioning properly.
func test_framework() -> void:
	from_grid = [
		"  :::",
		"  : :",
		" ppp:",
		"  pp:",
		"  :::"
	]
	to_grid = [
		"  :::",
		"  :p:",
		"  pp:",
		"  pp:",
		"  :::"
	]
	_kick_piece()
	
	# framework should have detected a 'p' block at (1, 2) with orientation (0)
	assert_eq(_from_piece.type.string, "p")
	assert_eq(_from_piece.pos, Vector2(1, 2))
	assert_eq(_from_piece.orientation, 0)
	
	# framework should have detected a 'p' block at (1, 1) with orientation (1)
	assert_eq(_to_piece.type.string, "p")
	assert_eq(_to_piece.pos, Vector2(1, 1))
	assert_eq(_to_piece.orientation, 1)


## Verifies that the piece kicks appropriately when rotated.
##
## Verifies the piece shown in 'from_grid' can rotate to the orientation shown in 'to_grid'. Also verifies the piece is
## moved to the correct position.
func assert_kick() -> void:
	var result := _kick_piece()
	var text := "Rotating '%s' piece from %s -> %s should kick %s" \
			% [_from_piece.type.string, _from_piece.orientation,
			_to_piece.orientation, _to_piece.pos - _from_piece.pos]
	if result == FAILED_KICK:
		# fail with a nice message; [none] expected to equal [(0, 1)]
		assert_eq("none", str(_to_piece.pos - _from_piece.pos), text)
	else:
		assert_eq(result, _to_piece.pos - _from_piece.pos, text)


## Attempts to rotate the piece to a new orientation, kicking if necessary
##
## Returns one of the following:
## 	1. FAILED_KICK if the piece could not rotate.
## 	2. A zero vector if the piece could rotate without kicking.
## 	3. A non-zero vector if the piece could rotate, but needed to be kicked.
func _kick_piece() -> Vector2:
	var result: Vector2
	var from_analyzer := AsciiPieceAnalyzer.new(from_grid)
	_from_piece = from_analyzer.create_active_piece(from_orientation)
	
	var to_analyzer := AsciiPieceAnalyzer.new(to_grid)
	_to_piece = to_analyzer.create_active_piece(to_orientation)
	
	var piece := from_analyzer.create_active_piece(from_orientation)
	piece.target_orientation = _to_piece.orientation
	
	# if the piece is obstructed, kick the piece
	if not piece.can_move_to(piece.target_pos, piece.target_orientation):
		piece.kick_piece()
	
	# if the piece is still obstructed, it's a failed kick
	if not piece.can_move_to(piece.target_pos, piece.target_orientation):
		result = FAILED_KICK
	else:
		result = piece.target_pos - piece.pos
	return result
