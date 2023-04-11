extends GutTest

var type: PieceType = PieceType.new()

## ' t '    ' t '
## ' tt' -> ' t '
## ' t '    ' t '
func test_remove_cell_t() -> void:
	type.copy_from(PieceTypes.piece_t)
	PieceTypeMutator.new(type).remove_cell(1, Vector2(2, 1))
	
	assert_eq(type.pos_arr[0], [Vector2(0, 1), Vector2(1, 1), Vector2(2, 1)])
	assert_eq(type.pos_arr[1], [Vector2(1, 0), Vector2(1, 1), Vector2(1, 2)])
	assert_eq(type.pos_arr[2], [Vector2(0, 1), Vector2(1, 1), Vector2(2, 1)])
	assert_eq(type.pos_arr[3], [Vector2(1, 0), Vector2(1, 1), Vector2(1, 2)])


## '   '    ' t '
## ' tt' -> ' t '
## ' t '    ' t '
func test_reshape_t() -> void:
	type.copy_from(PieceTypes.piece_t)
	PieceTypeMutator.new(type).remove_cell(1, Vector2(1, 0))
	
	assert_eq(type.color_arr[0], [Vector2( 2, 2), Vector2( 9, 2), Vector2( 4, 2)])
	assert_eq(type.color_arr[1], [Vector2(10, 2), Vector2( 4, 2), Vector2( 1, 2)])
	assert_eq(type.color_arr[2], [Vector2( 8, 2), Vector2( 6, 2), Vector2( 1, 2)])
	assert_eq(type.color_arr[3], [Vector2( 2, 2), Vector2( 8, 2), Vector2( 5, 2)])


## 'oo'    'o '
## 'oo' -> 'oo'
func test_remove_cell_o() -> void:
	type.copy_from(PieceTypes.piece_o)
	PieceTypeMutator.new(type).remove_cell(2, Vector2(1, 0))
	
	assert_eq(type.pos_arr[0], [Vector2(0, 0), Vector2(1, 0), Vector2(1, 1)])
	assert_eq(type.pos_arr[1], [Vector2(1, 0), Vector2(0, 1), Vector2(1, 1)])
	assert_eq(type.pos_arr[2], [Vector2(0, 0), Vector2(0, 1), Vector2(1, 1)])
	assert_eq(type.pos_arr[3], [Vector2(0, 0), Vector2(1, 0), Vector2(0, 1)])
