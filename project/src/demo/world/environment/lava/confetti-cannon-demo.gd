extends Node
## Demo which shows off the confetti cannon's orientations and animations
##
## Keys:
## 	[F]: Fire the cannon
## 	arrows: Change the cannon's orientation

onready var _cannon := $ConfettiCannon

func _input(event: InputEvent) -> void:
	match Utils.key_scancode(event):
		KEY_F:
			_cannon.fire()
		KEY_RIGHT:
			_cannon.orientation = ConfettiCannon.SOUTHEAST
		KEY_DOWN:
			_cannon.orientation = ConfettiCannon.SOUTHWEST
		KEY_LEFT:
			_cannon.orientation = ConfettiCannon.NORTHWEST
		KEY_UP:
			_cannon.orientation = ConfettiCannon.NORTHEAST
