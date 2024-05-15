extends Node
## Demonstrates the onion puzzle critter.
##
## Keys:
## 	[0]: Disappear
## 	[1]: Dance
## 	[2]: Dance End
## 	[3]: Night
## 	[4]: Disappear
## 	[N]: Skip to night mode

onready var _onion := $Onion

func _input(event: InputEvent) -> void:
	match Utils.key_scancode(event):
		KEY_0: _onion.state = OnionConfig.OnionState.NONE
		KEY_1: _onion.state = OnionConfig.OnionState.DAY
		KEY_2: _onion.state = OnionConfig.OnionState.DAY_END
		KEY_3: _onion.state = OnionConfig.OnionState.NIGHT
		KEY_4: _onion.state = OnionConfig.OnionState.NONE
		KEY_N: _onion.skip_to_night_mode()
