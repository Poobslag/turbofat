extends Node
"""
Shows off the visual effects for the puzzle.

Keys:
	[Q,W,E]: Build a box at different locations in the playfield
	[A,S,D,F,G]: Change the box color to brown, pink, bread, white, cake
	[U,I,O]: Clear a line at different locations in the playfield
"""

var _line_clear_count := 1
var _color_int := 0

func _ready() -> void:
	Scenario.settings.set_start_level("T")
	Scenario.settings.set_finish_condition(Milestone.NONE, 100)
	PuzzleScore.prepare_and_start_game()


func _input(event: InputEvent) -> void:
	match(Utils.key_scancode(event)):
		KEY_Q: _build_box(3)
		KEY_W: _build_box(9)
		KEY_E: _build_box(15)
		
		KEY_A: _color_int = 0
		KEY_S: _color_int = 1
		KEY_D: _color_int = 2
		KEY_F: _color_int = 3
		KEY_G: _color_int = 4
		
		KEY_U: _clear_line(3)
		KEY_I: _clear_line(9)
		KEY_O: _clear_line(15)


func _build_box(y: int) -> void:
	$Puzzle/Playfield/BoxBuilder.build_box(Rect2(6, y, 3, 3), _color_int)


func _clear_line(cleared_line: int) -> void:
	$Puzzle/Playfield/LineClearer.lines_being_cleared = range(cleared_line, cleared_line + _line_clear_count)
	$Puzzle/Playfield/LineClearer.clear_line(cleared_line, 1, 0)
