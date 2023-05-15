extends Node
## Demo which shows off the turbo fat restaurant.
##
## Keys:
## 	[C]: Shows/hides the closed sign.

onready var _restaurant := $TurboFatRestaurant

func _input(event: InputEvent) -> void:
	match Utils.key_scancode(event):
		KEY_C:
			if _restaurant.closed_sign.visible:
				_restaurant.hide_closed_sign()
			else:
				_restaurant.show_closed_sign()
