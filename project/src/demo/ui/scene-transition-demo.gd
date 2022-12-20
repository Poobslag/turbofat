extends Node
## Demonstrates the scene transition animation.
##
## Keys:
##     F: Fade out and in

func _input(event: InputEvent) -> void:
	match Utils.key_scancode(event):
		KEY_F:
			SceneTransition.fade_out()
