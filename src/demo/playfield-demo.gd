extends Control
"""
Shows off the visual effects for the playfield.

Keys:
	[Q,W,E,R,T]: Make a box at different locations in the playfield
	[A,S,D,F,G]: Change the box color to brown, pink, bread, white, cake
	[Z,X,C,V,B]: Clear a line at different locations in the playfield
	[.]: Place a piece without continuing the combo
"""

var _line_clear_count := 1
var _box_color := 0

func _input(event: InputEvent) -> void:
	match(Global.key_scancode(event)):
		KEY_1, KEY_2, KEY_3: _line_clear_count = Global.key_num(event)
		
		# make boxes
		KEY_Q: _make_box(3)
		KEY_W: _make_box(6)
		KEY_E: _make_box(9)
		KEY_R: _make_box(12)
		KEY_T: _make_box(15)
		
		KEY_A: _box_color = 0
		KEY_S: _box_color = 1
		KEY_D: _box_color = 2
		KEY_F: _box_color = 3
		KEY_G: _box_color = 4
		
		# clear lines
		KEY_Z: _clear_line(3)
		KEY_X: _clear_line(6)
		KEY_C: _clear_line(9)
		KEY_V: _clear_line(12)
		KEY_B: _clear_line(15)
		
		# write pieces
		KEY_PERIOD: _write_piece()


func _make_box(y: int) -> void:
	$Playfield.combo_break = 0
	$Playfield.make_box(0, y, 3, 3, _box_color)


func _clear_line(cleared_line: int) -> void:
	$Playfield.combo_break = 0
	$Playfield.cleared_lines = range(cleared_line, cleared_line + _line_clear_count)
	$Playfield.clear_line(cleared_line, 1, 0)


func _write_piece() -> void:
	$Playfield.write_piece(Vector2(5, 5), 0, PieceTypes.piece_t)
