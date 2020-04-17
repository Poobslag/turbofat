extends Node2D
"""
A demo which shows off the restaurant scene.

Keys:
	[F]: Feed the customer
	[P]: Print the current animation details
	[1-9,0]: Change the customer's size from 10% to 100%
	brace keys: Change the customer's appearance
"""

var _current_color_index := -1

func _ready():
	# Ensure customers are random
	randomize()

func _input(event: InputEvent) -> void:
	var just_pressed := event.is_pressed() and not event.is_echo()
	if Input.is_key_pressed(KEY_F) and just_pressed:
		$RestaurantScene.feed()
	if Input.is_key_pressed(KEY_1) and just_pressed:
		$RestaurantScene.set_fatness(1.0)
	if Input.is_key_pressed(KEY_2) and just_pressed:
		$RestaurantScene.set_fatness(1.5)
	if Input.is_key_pressed(KEY_3) and just_pressed:
		$RestaurantScene.set_fatness(2.0)
	if Input.is_key_pressed(KEY_4) and just_pressed:
		$RestaurantScene.set_fatness(3.0)
	if Input.is_key_pressed(KEY_5) and just_pressed:
		$RestaurantScene.set_fatness(5.0)
	if Input.is_key_pressed(KEY_6) and just_pressed:
		$RestaurantScene.set_fatness(6.0)
	if Input.is_key_pressed(KEY_7) and just_pressed:
		$RestaurantScene.set_fatness(7.0)
	if Input.is_key_pressed(KEY_8) and just_pressed:
		$RestaurantScene.set_fatness(8.0)
	if Input.is_key_pressed(KEY_9) and just_pressed:
		$RestaurantScene.set_fatness(9.0)
	if Input.is_key_pressed(KEY_0) and just_pressed:
		$RestaurantScene.set_fatness(10.0)
	if Input.is_key_pressed(KEY_BRACELEFT) and just_pressed:
		if _current_color_index == -1:
			_current_color_index = 0
		else:
			_current_color_index += CustomerLoader.DEFINITIONS.size()
			_current_color_index = (_current_color_index - 1) % CustomerLoader.DEFINITIONS.size()
		$RestaurantScene.summon_customer(CustomerLoader.DEFINITIONS[_current_color_index], 1)
	if Input.is_key_pressed(KEY_BRACERIGHT) and just_pressed:
		if _current_color_index == -1:
			_current_color_index = 0
		else:
			_current_color_index = (_current_color_index + 1) % CustomerLoader.DEFINITIONS.size()
		$RestaurantScene.summon_customer(CustomerLoader.DEFINITIONS[_current_color_index], 1)
	if Input.is_key_pressed(KEY_P) and just_pressed:
		print($RestaurantScene/Customer/AnimationPlayer.current_animation)
		print($RestaurantScene/Customer/AnimationPlayer.is_playing())
