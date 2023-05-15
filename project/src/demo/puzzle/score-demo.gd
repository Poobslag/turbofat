extends Node
## Demo which lets you test the puzzle scoreboard.
##
## Keys:
## 	[1-4]: Adds ¥10, ¥200, ¥300, or ¥4,000 to the current combo
## 	[Enter]: Ends the current combo, incrementing the score
## 	[R]: Resets the level
## 	[T]: Tops out

@onready var _score := $ColorRect/Score

func _input(event: InputEvent) -> void:
	match Utils.key_keycode(event):
		KEY_1: PuzzleState.add_line_score(1, 1)
		KEY_2: PuzzleState.add_line_score(20, 20)
		KEY_3: PuzzleState.add_line_score(300, 300)
		KEY_4: PuzzleState.add_line_score(4000, 4000)
		
		KEY_ENTER: PuzzleState.end_combo()
		
		KEY_R: PuzzleState.reset()
		KEY_T: PuzzleState.top_out()
