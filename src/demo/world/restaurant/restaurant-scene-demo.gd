extends Node2D
"""
A demo which shows off the restaurant scene.

Keys:
	[F]: Feed the creature
	[1-9,0]: Change the creature's size from 10% to 100%
	brace keys: Change the creature's appearance
"""

const FATNESS_KEYS = [10.0, 1.0, 1.5, 2.0, 3.0, 5.0, 6.0, 7.0, 8.0, 9.0]

var _current_color_index := -1

func _ready() -> void:
	# Ensure creatures are random
	randomize()


func _input(event: InputEvent) -> void:
	match Utils.key_scancode(event):
		KEY_F: $RestaurantScene.get_creature().feed()
		KEY_0, KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6, KEY_7, KEY_8, KEY_9:
			$RestaurantScene.get_creature().set_fatness(FATNESS_KEYS[Utils.key_num(event)])
		KEY_BRACELEFT:
			if _current_color_index == -1:
				_current_color_index = 0
			else:
				_current_color_index += CreatureLoader.DEFINITIONS.size()
				_current_color_index = (_current_color_index - 1) % CreatureLoader.DEFINITIONS.size()
			$RestaurantScene.summon_creature(CreatureLoader.DEFINITIONS[_current_color_index])
		KEY_BRACERIGHT:
			if _current_color_index == -1:
				_current_color_index = 0
			else:
				_current_color_index = (_current_color_index + 1) % CreatureLoader.DEFINITIONS.size()
			$RestaurantScene.summon_creature(CreatureLoader.DEFINITIONS[_current_color_index])
