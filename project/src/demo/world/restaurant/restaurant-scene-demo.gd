extends Node2D
"""
A demo which shows off the restaurant scene.

Keys:
	[F]: Feed the creature
	[1-9,0]: Change the creature's size from 10% to 100%
	[Q,W,E]: Switch to the 1st, 2nd or 3rd creature.
	brace keys: Change the creature's appearance
"""

const FATNESS_KEYS = [10.0, 1.0, 1.5, 2.0, 3.0, 5.0, 6.0, 7.0, 8.0, 9.0]

func _input(event: InputEvent) -> void:
	match Utils.key_scancode(event):
		KEY_F: $RestaurantScene.get_customer().feed(FoodColors.BROWN)
		KEY_0, KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6, KEY_7, KEY_8, KEY_9:
			$RestaurantScene.get_customer().set_fatness(FATNESS_KEYS[Utils.key_num(event)])
		KEY_BRACELEFT, KEY_BRACERIGHT:
			$RestaurantScene.summon_creature(CreatureLoader.random_def())
		KEY_Q: $RestaurantScene.current_creature_index = 0
		KEY_W: $RestaurantScene.current_creature_index = 1
		KEY_E: $RestaurantScene.current_creature_index = 2
