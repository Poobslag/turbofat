extends GutTest
## Framework for testing piece kicks.

## Kick returned if the two grids did not match each other, such as if they had different dimensions or walls in
## different places.
const ANALYZER_MISMATCH := Vector2(-490, -712)

## Kick returned if a piece failed to rotate. Unit tests need to distinguish between a piece rotating in place and
## failing to rotate.
const FAILED_KICK := Vector2(-995, -494)

var from_grid := []
var to_grid := []

## A number [0-3] representing the piece's orientation.
##
## For some pieces (such as the O-Block) orientation is ambiguous but some tests might care which one is selected.
## These fields allow tests to force a specific orientation.
var from_orientation := -1
var to_orientation := -1

var _from_analyzer: AsciiPieceAnalyzer
var _to_analyzer: AsciiPieceAnalyzer

var _from_piece: ActivePiece
var _to_piece: ActivePiece

## Message shown if the two grids did not match each other, such as if they had different dimensions or walls in
## different places.
var _mismatch_message: String

func before_each() -> void:
	from_orientation = -1
	to_orientation = -1


func test_kick_piece_from() -> void:
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


func test_kick_piece_to() -> void:
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
	
	# framework should have detected a 'p' block at (1, 1) with orientation (1)
	assert_eq(_to_piece.type.string, "p")
	assert_eq(_to_piece.pos, Vector2(1, 1))
	assert_eq(_to_piece.orientation, 1)


func test_kick_piece_mismatch_size() -> void:
	from_grid = [
		" ppp ",
		"  pp ",
	]
	to_grid = [
		"     ",
		" ppp ",
		"  pp ",
	]
	_kick_piece()
	
	assert_eq(_mismatch_message, "Piece grid size mismatch; from=(5, 2) to=(5, 3)")


func test_kick_piece_mismatch_wall() -> void:
	from_grid = [
		"     ",
		" ppp ",
		" :pp ",
	]
	to_grid = [
		"  pp ",
		"  pp ",
		"  p  ",
	]
	_kick_piece()
	
	assert_eq(_mismatch_message, "Piece grid wall mismatch at (1, 2)")


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
	elif result == ANALYZER_MISMATCH:
		# report the mismatch
		fail_test(_mismatch_message)
	else:
		assert_eq(result, _to_piece.pos - _from_piece.pos, text)


## Attempts to rotate the piece to a new orientation, kicking if necessary
##
## Returns one of the following:
## 	1. ANALYZER_MISMATCH if the two grids did not match each other.
## 	2. FAILED_KICK if the piece could not rotate.
## 	3. A zero vector if the piece could rotate without kicking.
## 	4. A non-zero vector if the piece could rotate, but needed to be kicked.
func _kick_piece() -> Vector2:
	var valid := true
	var result: Vector2
	
	_initialize_analyzers()
	
	_detect_analyzer_mismatch()
	if valid and not _mismatch_message.empty():
		result = ANALYZER_MISMATCH
		valid = false
	
	if valid:
		var piece := _from_analyzer.create_active_piece(from_orientation)
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


## Initializes the _from_analyzer, from_piece, to_analyzer and _to_piece fields.
func _initialize_analyzers() -> void:
	_from_analyzer = AsciiPieceAnalyzer.new(from_grid)
	_from_piece = _from_analyzer.create_active_piece(from_orientation)
	
	_to_analyzer = AsciiPieceAnalyzer.new(to_grid)
	_to_piece = _to_analyzer.create_active_piece(to_orientation)


## Detects if the two grids did not match each other, such as if they had different dimensions or walls in different
## places.
##
## Any problems are reported to the _mismatch_message field.
func _detect_analyzer_mismatch() -> void:
	_mismatch_message = ""
	var from_size := Vector2.ZERO
	from_size.y = _from_analyzer.ascii_grid.size()
	from_size.x = 0 if _from_analyzer.ascii_grid.empty() else _from_analyzer.ascii_grid[0].length()
	
	var to_size := Vector2.ZERO
	to_size.y = _to_analyzer.ascii_grid.size()
	to_size.x = 0 if _to_analyzer.ascii_grid.empty() else _to_analyzer.ascii_grid[0].length()
	
	if not _mismatch_message and from_size != to_size:
		_mismatch_message = "Piece grid size mismatch; from=%s to=%s" % [from_size, to_size]
	
	if not _mismatch_message:
		for x in range(from_size.x):
			for y in range(from_size.y):
				var cell := Vector2(x, y)
				if _from_analyzer.is_cell_obstructed(cell) != _to_analyzer.is_cell_obstructed(cell):
					_mismatch_message = "Piece grid wall mismatch at %s" % [cell]
					break
