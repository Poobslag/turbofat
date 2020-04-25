extends Node2D
"""
A demo which shows off the customer view.

Keys:
	[F]: Feed the customer
	[D]: Ring the doorbell
	[V]: Say something
	[P]: Print the current animation details
	[1-9,0]: Change the customer's size from 10% to 100%
	[Q,W,E]: Switch to the 1st, 2nd or 3rd customer.
	brace keys: Change the customer's appearance
"""

const FATNESS_KEYS = [10.0, 1.0, 1.5, 2.0, 3.0, 5.0, 6.0, 7.0, 8.0, 9.0]

var _current_color_index := -1

func _ready() -> void:
	# Ensure customers are random
	randomize()


func _input(event: InputEvent) -> void:
	match Global.key_scancode(event):
		KEY_F: $CustomerView/SceneClip/CustomerSwitcher/Scene.feed()
		KEY_D: $CustomerView/SceneClip/CustomerSwitcher/Scene.play_door_chime(0)
		KEY_V: $CustomerView/SceneClip/CustomerSwitcher/Scene.play_goodbye_voice()
		KEY_0, KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6, KEY_7, KEY_8, KEY_9:
			$CustomerView.set_fatness(FATNESS_KEYS[Global.key_num(event)])
		KEY_Q: $CustomerView.set_current_customer_index(0)
		KEY_W: $CustomerView.set_current_customer_index(1)
		KEY_E: $CustomerView.set_current_customer_index(2)
		KEY_BRACELEFT:
			if _current_color_index == -1:
				_current_color_index = 0
			else:
				_current_color_index += CustomerLoader.DEFINITIONS.size()
				_current_color_index = (_current_color_index - 1) % CustomerLoader.DEFINITIONS.size()
			$CustomerView.summon_customer(CustomerLoader.DEFINITIONS[_current_color_index])
		KEY_BRACERIGHT:
			if _current_color_index == -1:
				_current_color_index = 0
			else:
				_current_color_index = (_current_color_index + 1) % CustomerLoader.DEFINITIONS.size()
			$CustomerView.summon_customer(CustomerLoader.DEFINITIONS[_current_color_index])
		KEY_P:
			print($CustomerView/SceneClip/CustomerSwitcher/Scene/Customer/AnimationPlayer.current_animation)
			print($CustomerView/SceneClip/CustomerSwitcher/Scene/Customer/AnimationPlayer.is_playing())
