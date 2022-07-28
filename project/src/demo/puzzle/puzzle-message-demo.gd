extends Node
## Keys:
##  [Q, W, E]: Short good/neutral/bad message
##  [A, S, D]: Wide good/neutral/bad message
##  [Z, X, C]: Multiline good/neutral/bad message

onready var _message := $PuzzleMessage

func _input(event: InputEvent) -> void:
	match Utils.key_scancode(event):
		KEY_Q: _message.show_message(PuzzleMessage.GOOD, "Good!")
		KEY_A: _message.show_message(PuzzleMessage.GOOD, "Entertaining!!")
		KEY_Z: _message.show_message(PuzzleMessage.GOOD, "All\nClear!")
		
		KEY_W: _message.show_message(PuzzleMessage.NEUTRAL, "Ready?")
		KEY_S: _message.show_message(PuzzleMessage.NEUTRAL, "Important")
		KEY_X: _message.show_message(PuzzleMessage.NEUTRAL, "Weight\nRelax?")
		
		KEY_E: _message.show_message(PuzzleMessage.BAD, "Regret...")
		KEY_D: _message.show_message(PuzzleMessage.BAD, "Unkempt summer")
		KEY_C: _message.show_message(PuzzleMessage.BAD, "Mundane\nToes")
		
		KEY_SPACE: _message.hide_message()
