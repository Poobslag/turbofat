extends Node
## Demo which shows off the progress board's trail of dots and lines.
##
## Keys:
## 	[=/-]: Increase/decrease the number of spots on the trail.
## 	[T]: Toggle whether or not the number of spots on the board is truncated.

@onready var path := $ColorRect/Trail

func _input(event: InputEvent) -> void:
	match Utils.key_keycode(event):
		KEY_MINUS:
			path.spot_count -= 1
		KEY_EQUAL:
			path.spot_count += 1
		KEY_T:
			path.spots_truncated = not path.spots_truncated
		
