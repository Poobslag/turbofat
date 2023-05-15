extends GutTest

var type: PieceType = PieceType.new()

func test_copy_from_performs_deep_copy() -> void:
	type.copy_from(PieceTypes.piece_domino)
	
	type.kicks[01][0] = Vector2(12, 35)
	type.color_arr[0][0] = Vector2(33, 48)
	type.pos_arr[0][0] = Vector2(56, 32)
	
	# updating the piece's kicks
	assert_eq(PieceTypes.piece_domino.kicks[01][0], Vector2(1, 0))
	assert_eq(PieceTypes.piece_domino.color_arr[0][0], Vector2(8, 3))
	assert_eq(PieceTypes.piece_domino.pos_arr[01][0], Vector2(0, 0))


func test_get_box_type() -> void:
	assert_eq(2, PieceTypes.piece_t.get_box_type())
	assert_eq(1, PieceTypes.piece_j.get_box_type())
	assert_eq(0, PieceTypes.piece_null.get_box_type())


func test_set_box_type() -> void:
	type.copy_from(PieceTypes.piece_t)
	type.set_box_type(50)
	
	assert_eq(50, type.get_box_type())


func test_empty() -> void:
	assert_eq(PieceTypes.piece_t.is_empty(), false)
	assert_eq(PieceTypes.piece_null.is_empty(), true)


func test_size() -> void:
	assert_eq(PieceTypes.piece_t.size(), 4)
	assert_eq(PieceTypes.piece_p.size(), 5)
	assert_eq(PieceTypes.piece_null.size(), 0)
