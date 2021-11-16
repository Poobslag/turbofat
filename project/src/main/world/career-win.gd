extends Node
## Shows a 'You win!' screen when the player finishes career mode

onready var _button := $Button

func _on_Button_pressed() -> void:
	SceneTransition.pop_trail()
	_button.grab_focus()
