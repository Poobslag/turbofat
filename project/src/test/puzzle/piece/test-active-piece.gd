extends "res://addons/gut/test.gd"

var ascii_grid := []

func assert_sealed(expected: bool) -> void:
	var analyzer := AsciiPieceAnalyzer.new(ascii_grid)
	var piece := analyzer.create_active_piece()
	assert_eq(piece.is_sealed(), expected)


func test_is_sealed_true() -> void:
	ascii_grid = [
		"  :  ",
		"  t  ",
		":ttt:",
		"  :  "
	]
	assert_sealed(true)


func test_is_sealed_false_down() -> void:
	ascii_grid = [
		"  :  ",
		"  t  ",
		":ttt:",
		"     "
	]
	assert_sealed(false)


func test_is_sealed_false_left() -> void:
	ascii_grid = [
		"  :  ",
		"  t  ",
		" ttt:",
		"  :  "
	]
	assert_sealed(false)


func test_is_sealed_false_up() -> void:
	ascii_grid = [
		"     ",
		"  t  ",
		":ttt:",
		"  :  "
	]
	assert_sealed(false)


func test_is_sealed_false_right() -> void:
	ascii_grid = [
		"  :  ",
		"  t  ",
		":ttt ",
		"  :  "
	]
	assert_sealed(false)


func test_center_o() -> void:
	# the O-Block's center x and y coordinates are in between two grid coordinates
	var piece := ActivePiece.new(PieceTypes.piece_o, null)
	assert_eq(piece.center(), Vector2(3.5, 3.5))
	
	# when moved, the O-Block's center moves too
	piece.pos = Vector2(2, 2)
	assert_eq(piece.center(), Vector2(2.5, 2.5))


func test_center_t() -> void:
	# the T-Block's center x is the exact middle of its three columns
	var piece := ActivePiece.new(PieceTypes.piece_t, null)
	assert_eq(piece.center(), Vector2(4.0, 3.5))
	
	# when rotated, the T-Block's center y is the exact middle of its three rows
	piece.orientation = 1
	assert_eq(piece.center(), Vector2(4.5, 4.0))
