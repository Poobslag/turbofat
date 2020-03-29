"""
A demo which shows off the restaurant scene.

Keys:

[F]: Feed the customer
[P]: Print the current animation details
[1-9,0]: Change the customer's size from 10% to 100%
brace keys: Change the customer's appearance
"""
extends Node2D

var current_color_index := -1

func _ready():
	# Ensure customers are random
	randomize()

func _input(event: InputEvent) -> void:
	var just_pressed := event.is_pressed() && !event.is_echo()
	if Input.is_key_pressed(KEY_F) && just_pressed:
		$RestaurantScene.feed()
	if Input.is_key_pressed(KEY_1) && just_pressed:
		$RestaurantScene.set_fatness(1.0)
	if Input.is_key_pressed(KEY_2) && just_pressed:
		$RestaurantScene.set_fatness(1.5)
	if Input.is_key_pressed(KEY_3) && just_pressed:
		$RestaurantScene.set_fatness(2.0)
	if Input.is_key_pressed(KEY_4) && just_pressed:
		$RestaurantScene.set_fatness(3.0)
	if Input.is_key_pressed(KEY_5) && just_pressed:
		$RestaurantScene.set_fatness(5.0)
	if Input.is_key_pressed(KEY_6) && just_pressed:
		$RestaurantScene.set_fatness(6.0)
	if Input.is_key_pressed(KEY_7) && just_pressed:
		$RestaurantScene.set_fatness(7.0)
	if Input.is_key_pressed(KEY_8) && just_pressed:
		$RestaurantScene.set_fatness(8.0)
	if Input.is_key_pressed(KEY_9) && just_pressed:
		$RestaurantScene.set_fatness(9.0)
	if Input.is_key_pressed(KEY_0) && just_pressed:
		$RestaurantScene.set_fatness(10.0)
	if Input.is_key_pressed(KEY_BRACELEFT) && just_pressed:
		if current_color_index == -1:
			current_color_index = 0
		else:
			current_color_index += Global.CUSTOMER_DEFS.size()
			current_color_index = (current_color_index - 1) % Global.CUSTOMER_DEFS.size()
		$RestaurantScene.recolor(Global.CUSTOMER_DEFS[current_color_index], 1)
	if Input.is_key_pressed(KEY_BRACERIGHT) && just_pressed:
		if current_color_index == -1:
			current_color_index = 0
		else:
			current_color_index = (current_color_index + 1) % Global.CUSTOMER_DEFS.size()
		$RestaurantScene.recolor(Global.CUSTOMER_DEFS[current_color_index], 1)
	if Input.is_key_pressed(KEY_P) && just_pressed:
		print($RestaurantScene/Customer/AnimationPlayer.current_animation)
		print($RestaurantScene/Customer/AnimationPlayer.is_playing())
