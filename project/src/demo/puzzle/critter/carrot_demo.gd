extends Node
## Demo which shows off the carrot puzzle critter.
##
## Keys:
## [1]: Show
## [2]: Hide
## [Q]: Toggle smoke amount
## [W]: Toggle carrot size

@onready var _carrot := $Carrot

func _input(event: InputEvent) -> void:
	match Utils.key_keycode(event):
		KEY_1: _carrot.show_carrot()
		KEY_2: _carrot.hide_carrot()
		KEY_Q: _carrot.smoke = (_carrot.smoke + 1) % CarrotConfig.Smoke.size()
		KEY_W: _carrot.carrot_size = (_carrot.carrot_size + 1) % CarrotConfig.CarrotSize.size()
