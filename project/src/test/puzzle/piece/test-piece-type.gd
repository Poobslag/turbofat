extends GutTest

var type: PieceType = PieceType.new()


func test_get_box_type() -> void:
	assert_eq(2, PieceTypes.piece_t.get_box_type())
	assert_eq(1, PieceTypes.piece_j.get_box_type())
	assert_eq(0, PieceTypes.piece_null.get_box_type())


func test_empty() -> void:
	assert_eq(PieceTypes.piece_t.empty(), false)
	assert_eq(PieceTypes.piece_null.empty(), true)


func test_size() -> void:
	assert_eq(PieceTypes.piece_t.size(), 4)
	assert_eq(PieceTypes.piece_p.size(), 5)
	assert_eq(PieceTypes.piece_null.size(), 0)
