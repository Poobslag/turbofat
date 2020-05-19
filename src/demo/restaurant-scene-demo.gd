extends Node2D
"""
A demo which shows off the restaurant scene.

Keys:
	[F]: Feed the customer
	[P]: Print the current animation details
	[1-9,0]: Change the customer's size from 10% to 100%
	brace keys: Change the customer's appearance
"""

const FATNESS_KEYS = [10.0, 1.0, 1.5, 2.0, 3.0, 5.0, 6.0, 7.0, 8.0, 9.0]

var _current_color_index := -1

func _ready() -> void:
	# Ensure customers are random
	randomize()


func _input(event: InputEvent) -> void:
	match Global.key_scancode(event):
		KEY_F: $RestaurantScene.feed()
		KEY_0, KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6, KEY_7, KEY_8, KEY_9:
			$RestaurantScene.set_fatness(FATNESS_KEYS[Global.key_num(event)])
		KEY_BRACELEFT:
			if _current_color_index == -1:
				_current_color_index = 0
			else:
				_current_color_index += CustomerLoader.DEFINITIONS.size()
				_current_color_index = (_current_color_index - 1) % CustomerLoader.DEFINITIONS.size()
			Global.customer_queue.push_front(CustomerLoader.DEFINITIONS[_current_color_index])
			$RestaurantScene.summon_customer(1)
		KEY_BRACERIGHT:
			if _current_color_index == -1:
				_current_color_index = 0
			else:
				_current_color_index = (_current_color_index + 1) % CustomerLoader.DEFINITIONS.size()
			Global.customer_queue.push_front(CustomerLoader.DEFINITIONS[_current_color_index])
			$RestaurantScene.summon_customer(1)
		KEY_P:
			print($RestaurantScene/Customer/AnimationPlayer.current_animation)
			print($RestaurantScene/Customer/AnimationPlayer.is_playing())
