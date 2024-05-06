extends Node
## Demonstrates the carrot puzzle critter.
##
## Keys:
## 	[1]: Show
## 	[2]: Hide
## 	[Q]: Toggle smoke amount
## 	[W]: Toggle carrot size

onready var _carrot := $Carrot

func _input(event: InputEvent) -> void:
	match Utils.key_scancode(event):
		KEY_1: _carrot.show()
		KEY_2: _carrot.hide()
		KEY_Q: _carrot.smoke = (_carrot.smoke + 1) % CarrotConfig.Smoke.size()
		KEY_W: _carrot.carrot_size = (_carrot.carrot_size + 1) % CarrotConfig.CarrotSize.size()
