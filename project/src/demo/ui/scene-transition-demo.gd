extends Node
## Demonstrates the scene transition animation.
##
## Keys:
##     F: Fade out and in

func _input(event: InputEvent) -> void:
	match Utils.key_keycode(event):
		KEY_F:
			SceneTransition.fade_out()
