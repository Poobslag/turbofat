extends Node
## Demonstrates the tomato puzzle critter.
##
## Keys:
## 	[0]: Disappear
## 	[1,2,3]: Idle animation with 1/2/3 fingers

onready var _tomato := $Tomato

func _input(event: InputEvent) -> void:
	match Utils.key_scancode(event):
		KEY_0:
			_tomato.state = Tomato.NONE
		KEY_1:
			_tomato.state = Tomato.IDLE_1
		KEY_2:
			_tomato.state = Tomato.IDLE_2
		KEY_3:
			_tomato.state = Tomato.IDLE_3
