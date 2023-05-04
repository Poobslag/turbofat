extends Node
## Shows off the visual effects for the playfield.
##
## Keys:
## 	[Q,W,E,R,T]: Build a box at different locations in the playfield
## 	[A,S,D,F,G]: Change the box color to brown, pink, bread, white, cake
## 	[Z,X,C,V,B]: Clear a line at different locations in the playfield
## 	[.]: Place a piece without continuing the combo

var _line_clear_count := 1
var _box_type := 0

func _input(event: InputEvent) -> void:
	match Utils.key_scancode(event):
		KEY_1, KEY_2, KEY_3: _line_clear_count = Utils.key_num(event)
		
		KEY_Q: _build_box(3)
		KEY_W: _build_box(6)
		KEY_E: _build_box(9)
		KEY_R: _build_box(12)
		KEY_T: _build_box(15)
		
		KEY_A: _box_type = 0
		KEY_S: _box_type = 1
		KEY_D: _box_type = 2
		KEY_F: _box_type = 3
		KEY_G: _box_type = 4
		
		KEY_Z: _clear_line(3)
		KEY_X: _clear_line(6)
		KEY_C: _clear_line(9)
		KEY_V: _clear_line(12)
		KEY_B: _clear_line(15)
		
		KEY_PERIOD: _write_piece()


func _build_box(y: int) -> void:
	$Playfield/BoxBuilder.build_box(Rect2i(0, y, 3, 3), _box_type)


func _clear_line(cleared_line: int) -> void:
	$Playfield/LineClearer.lines_being_cleared = range(cleared_line, cleared_line + _line_clear_count)
	$Playfield/LineClearer.clear_line(cleared_line, 1, 0)


func _write_piece() -> void:
	$Playfield.write_piece(Vector2i(5, 5), 0, PieceTypes.piece_t)
