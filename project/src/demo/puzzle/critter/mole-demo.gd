extends Node
## Demo which shows off the mole puzzle critter.
##
## Keys:
## 	[0]: Disappear
## 	[1]: Wait, with a '...' speech bubble
## 	[2]: Dig animation, with a '...' speech bubble
## 	[3]: Final dig animation, with a '!' speech bubble
## 	[4]: Found a seed animation
## 	[5]: Found a star animation
## 	[6]: Disappear

onready var _mole := $Mole

func _input(event: InputEvent) -> void:
	match Utils.key_scancode(event):
		KEY_0: _mole.state = Mole.NONE
		KEY_1: _mole.state = Mole.WAITING
		KEY_2: _mole.state = Mole.DIGGING
		KEY_3: _mole.state = Mole.DIGGING_END
		KEY_4: _mole.state = Mole.FOUND_SEED
		KEY_5: _mole.state = Mole.FOUND_STAR
		KEY_6: _mole.state = Mole.NONE
