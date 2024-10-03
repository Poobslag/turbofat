extends Node
## Demonstrates the save indicator.
##
## Keys:
## 	[Space]: Show/hide save indicator

onready var _save_indicator := $SaveIndicator

func _input(event: InputEvent) -> void:
	match Utils.key_scancode(event):
		KEY_SPACE:
			if _save_indicator.is_playing():
				_save_indicator.stop()
			else:
				_save_indicator.play()
