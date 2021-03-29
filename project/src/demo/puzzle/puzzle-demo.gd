extends Node
"""
Shows off the visual effects for the puzzle.

Keys:
	[Q,W,E]: Build a box at different locations in the playfield
	[A,S,D,F,G]: Change the box color to brown, pink, bread, white, cake
	[H]: Change the cake box variation used to make cake boxes
	[U,I,O]: Clear a line at different locations in the playfield
	[J]: Generate a food item
	[K]: Cycle to the next food item
	[L]: Level up
"""

var _line_clear_count := 1
var _color_int := 0
var _food_item_index := 0
var _cake_color_int: int = PuzzleTileMap.BoxColorInt.CAKE_JJO

func _ready() -> void:
	CurrentLevel.settings.set_start_speed("T")
	CurrentLevel.settings.add_speed_up(Milestone.LINES, 10, "1")
	CurrentLevel.settings.add_speed_up(Milestone.LINES, 20, "2")
	CurrentLevel.settings.add_speed_up(Milestone.LINES, 30, "3")
	CurrentLevel.settings.add_speed_up(Milestone.LINES, 40, "4")
	CurrentLevel.settings.add_speed_up(Milestone.LINES, 50, "5")
	CurrentLevel.settings.add_speed_up(Milestone.LINES, 60, "6")
	CurrentLevel.settings.add_speed_up(Milestone.LINES, 70, "7")
	CurrentLevel.settings.add_speed_up(Milestone.LINES, 80, "8")
	CurrentLevel.settings.add_speed_up(Milestone.LINES, 90, "9")
	CurrentLevel.settings.set_finish_condition(Milestone.NONE, 100)
	PuzzleScore.prepare_and_start_game()


func _input(event: InputEvent) -> void:
	match(Utils.key_scancode(event)):
		KEY_Q: _build_box(3)
		KEY_W: _build_box(9)
		KEY_E: _build_box(15)
		
		KEY_A: _color_int = PuzzleTileMap.BoxColorInt.BROWN
		KEY_S: _color_int = PuzzleTileMap.BoxColorInt.PINK
		KEY_D: _color_int = PuzzleTileMap.BoxColorInt.BREAD
		KEY_F: _color_int = PuzzleTileMap.BoxColorInt.WHITE
		
		KEY_G: _color_int = _cake_color_int
		KEY_H:
			_cake_color_int = wrapi(_cake_color_int + 1,
					PuzzleTileMap.BoxColorInt.CAKE_JJO, PuzzleTileMap.BoxColorInt.CAKE_QUV)
			_color_int = _cake_color_int
		
		KEY_U: _clear_line(3)
		KEY_I: _clear_line(9)
		KEY_O: _clear_line(15)
		
		KEY_J: $Puzzle/FoodItems.add_food_item(Vector2(1, 4), _food_item_index)
		KEY_K:
			_food_item_index = (_food_item_index + 1) % 16
			$Puzzle/FoodItems.add_food_item(Vector2(1, 4), _food_item_index)
		
		KEY_L:
			PuzzleScore.set_speed_index((PuzzleScore.speed_index + 1) % CurrentLevel.settings.speed_ups.size())


func _build_box(y: int) -> void:
	$Puzzle/Playfield/BoxBuilder.build_box(Rect2(6, y, 3, 3), _color_int)


func _clear_line(cleared_line: int) -> void:
	$Puzzle/Playfield/LineClearer.lines_being_cleared = range(cleared_line, cleared_line + _line_clear_count)
	$Puzzle/Playfield/LineClearer.clear_line(cleared_line, 1, 0)
