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
	if Input.is_key_pressed(KEY_F) and not event.is_echo():
		$RestaurantScene.feed()
	if Global.is_num_just_pressed():
		$RestaurantScene.set_fatness(FATNESS_KEYS[Global.get_num_just_pressed()])
	if Input.is_key_pressed(KEY_BRACELEFT) and not event.is_echo():
		if _current_color_index == -1:
			_current_color_index = 0
		else:
			_current_color_index += CustomerLoader.DEFINITIONS.size()
			_current_color_index = (_current_color_index - 1) % CustomerLoader.DEFINITIONS.size()
		$RestaurantScene.summon_customer(CustomerLoader.DEFINITIONS[_current_color_index], 1)
	if Input.is_key_pressed(KEY_BRACERIGHT) and not event.is_echo():
		if _current_color_index == -1:
			_current_color_index = 0
		else:
			_current_color_index = (_current_color_index + 1) % CustomerLoader.DEFINITIONS.size()
		$RestaurantScene.summon_customer(CustomerLoader.DEFINITIONS[_current_color_index], 1)
	if Input.is_key_pressed(KEY_P) and not event.is_echo():
		print($RestaurantScene/Customer/AnimationPlayer.current_animation)
		print($RestaurantScene/Customer/AnimationPlayer.is_playing())
