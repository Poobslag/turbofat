extends Node
## Shows off the screen after the credits which congratulates the player and shows their grade.
##
## Keys:
## 	[Q]: Shows the screen with 25% completion.
## 	[W]: Shows the screen with 100% completion, including a grade.

onready var _end_text := $EndText


func _input(event: InputEvent) -> void:
	match Utils.key_scancode(event):
		KEY_Q:
			_end_text.play(0.25, "-")
		KEY_W:
			_end_text.play(1.00, "S+")
