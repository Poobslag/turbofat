extends Node
## Demonstrates the scene transition cover.
##
## Keys:
##     F: Fade in/out

var faded_out := false

onready var _cover := $SceneTransitionCover

func _input(event: InputEvent) -> void:
	match Utils.key_scancode(event):
		KEY_F:
			if faded_out:
				_cover.fade_in()
				faded_out = false
			else:
				_cover.fade_out()
				faded_out = true
