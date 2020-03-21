"""
A demo which shows off the restaurant scene. Press 'F' to feed the customer, and 'P' to print the current animation
details.
"""
extends Node2D

func _input(event: InputEvent) -> void:
	var just_pressed := event.is_pressed() && !event.is_echo()
	if Input.is_key_pressed(KEY_F) && just_pressed:
		$RestaurantScene.feed()
	if Input.is_key_pressed(KEY_P) && just_pressed:
		print($RestaurantScene/Customer/AnimationPlayer.current_animation)
		print($RestaurantScene/Customer/AnimationPlayer.is_playing())
